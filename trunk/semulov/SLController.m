//
//  SLController.m
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SLController.h"
#import "SLVolume.h"
#import "SLGrowlController.h"
#import <Sparkle/SUUpdater.h>
#import "SLPrefsController.h"
#import "SLNSImageAdditions.h"
#import "UKLoginItemRegistry.h"


#define SLShowVolumesNumber		@"SLShowVolumesNumber"
#define SLShowStartupDisk		@"SLShowStartupDisk"
#define SLShowEjectAll			@"SLShowEjectAll"
#define SLDisableInternalHD		@"SLDisableInternalHD"
#define SLLaunchAtStartup		@"SLLaunchAtStartup"
#define SLDisableDiscardWarning	@"SLDisableDiscardWarning"
#define SLHideInternalDrives	@"SLHideInternalDrives"


@implementation SLController

+ (void)initialize
{
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], SLShowVolumesNumber,
		[NSNumber numberWithBool:NO], SLShowStartupDisk,
		[NSNumber numberWithBool:NO], SLShowEjectAll,
		[NSNumber numberWithBool:YES], SLDisableInternalHD,
		[NSNumber numberWithBool:NO], SLLaunchAtStartup,
		[NSNumber numberWithBool:NO], SLDisableDiscardWarning,
		[NSNumber numberWithBool:NO], SLHideInternalDrives,
		nil]];
}

- (id)init
{
	if (self = [super init])
	{
		[self setupStatusItem];
		
		[[SLGrowlController sharedController] setup];
		
		_updater = [[SUUpdater alloc] init];
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(handleMount:) name:NSWorkspaceDidMountNotification object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(handleUnmount:) name:NSWorkspaceDidUnmountNotification object:nil];
		
		[self setupBindings];
	}
	
	return self;
}

- (void)dealoc
{
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	[_statusItem release];

	[_slMenuItem release];
	[_volumes release];
	[_updater release];
	[_prefs release];

	[super dealloc];
}

#pragma mark -
#pragma mark Bindings

- (void)setupBindings
{
	NSUserDefaultsController *sdc = [NSUserDefaultsController sharedUserDefaultsController];
	[sdc addObserver:self forKeyPath:@"values.SLShowVolumesNumber" options:nil context:SLShowVolumesNumber];
	[sdc addObserver:self forKeyPath:@"values.SLShowStartupDisk" options:nil context:SLShowStartupDisk];
	[sdc addObserver:self forKeyPath:@"values.SLShowEjectAll" options:nil context:SLShowEjectAll];
	[sdc addObserver:self forKeyPath:@"values.SLDisableInternalHD" options:nil context:SLDisableInternalHD];
	[sdc addObserver:self forKeyPath:@"values.SLLaunchAtStartup" options:nil context:SLLaunchAtStartup];
	[sdc addObserver:self forKeyPath:@"values.SLHideInternalDrives" options:nil context:SLHideInternalDrives];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(NSString *)context isEqualToString:@"SLLaunchAtStartup"])
	{
		NSURL *appURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SLLaunchAtStartup"])
		{
			// add us to the login items
			if ([UKLoginItemRegistry indexForLoginItemWithURL:appURL] == -1)
				[UKLoginItemRegistry addLoginItemWithURL:appURL hideIt:NO];
		}
		else
		{
			[UKLoginItemRegistry removeLoginItemWithURL:appURL];
		}
	}
	else
	{
		[self updateStatusItemMenu];
	}
}

#pragma mark -
#pragma mark Status Item

- (void)setupStatusItem
{
	if (_statusItem)
	{
		[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
		[_statusItem release];
	}
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength/*(_showVolumesNumber ? NSVariableStatusItemLength : 24)*/] retain];
	[_statusItem setHighlightMode:YES];
	
	NSImage *ejectImage = [NSImage imageNamed:@"Eject"];
	if ([ejectImage respondsToSelector:@selector(setTemplate:)])
	{
		// Leopard compatibility
		[ejectImage setTemplate:YES];
	}
	else
	{
		// Leopard generates the alternative image automagically.
		// Tiger does not so we have to set it ourselves
		[_statusItem setAlternateImage:[NSImage imageNamed:@"EjectWhite"]];
	}
	[_statusItem setImage:ejectImage];
	[self updateStatusItemMenu];
}

- (BOOL)volumeCanBeEjected:(SLVolume *)volume
{
	NSArray *userDefaultValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	
	if ([volume isInternalHardDrive] == NO)
		return YES;
	
	if ([[userDefaultValues valueForKey:SLDisableInternalHD] boolValue] || 
		[[userDefaultValues valueForKey:SLHideInternalDrives] boolValue])
		return NO;
	
	return YES;
}

- (void)updateStatusItemMenu
{
	NSMenu *menu = [[NSMenu alloc] init];
	NSDictionary *defaultValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	BOOL showVolumesNumber = [[defaultValues valueForKey:SLShowVolumesNumber] boolValue];
	BOOL showStartupDisk = [[defaultValues valueForKey:SLShowStartupDisk] boolValue];
	BOOL showEjectAll = [[defaultValues valueForKey:SLShowEjectAll] boolValue];
	BOOL hideInternalDrives = [[defaultValues valueForKey:SLHideInternalDrives] boolValue];
	
	while ([[_statusItem menu] numberOfItems])
		[[_statusItem menu] removeItemAtIndex:0];

	[_volumes release];
	_volumes = [[SLVolume allVolumes] retain];
	NSEnumerator *volumesEnum = [_volumes objectEnumerator];
	SLVolume *vol = nil;
	SLVolumeType _lastType = -1;
	int vcount = 0;
	NSMenuItem *titleMenu = nil, *menuItem = nil, *altMenu = nil, *altaltMenu;
	NSString *titleName = nil;
	
	while (vol = [volumesEnum nextObject])
	{
		if ((showStartupDisk == NO && [vol isRoot]) ||
			(hideInternalDrives && [vol isInternalHardDrive]))
		{
			continue;
		}
		
		titleMenu = nil;
		if ([vol type] != _lastType)
		{
			_lastType = [vol type];
			
			if (_lastType == SLVolumeDrive)
				titleName = @"Volumes";
			else if (_lastType == SLVolumeRoot)
				titleName = @"Startup Disk";
			else if (_lastType == SLVolumeiPod)
				titleName = @"iPods";
			else if (_lastType == SLVolumeNetwork)
				titleName = @"Network";
			else if (_lastType == SLVolumeiDisk)
				titleName = @"iDisks";
			else if (_lastType == SLVolumeFTP)
				titleName = @"FTP";
			else if (_lastType == SLVolumeWebDAV)
				titleName = @"WebDAV";
			else if (_lastType == SLVolumeDiskImage)
				titleName = @"Disk Images";
			else if (_lastType == SLVolumeDVD)
				titleName = @"DVDs";
			else if (_lastType == SLVolumeDVDVideo)
				titleName = @"Video DVDs";
			else if (_lastType == SLVolumeCDROM)
				titleName = @"CDs";
			else if (_lastType == SLVolumeAudioCDROM)
				titleName = @"Audio CDs";
			else if (_lastType == SLVolumeHardDrive)
				titleName = @"Hard Drives";
			titleMenu = [[NSMenuItem alloc] initWithTitle:titleName action:nil keyEquivalent:@""];
		}
		
		SEL mainItemAction = ([vol isRoot] ? nil : @selector(doEject:));
		NSImage *mainItemImage = [[vol image] slResize:NSMakeSize(16, 16)];
		
		// setup the main item
		menuItem = [[NSMenuItem alloc] initWithTitle:[vol name] action:mainItemAction keyEquivalent:@""];
		[menuItem setRepresentedObject:vol];
		[menuItem setImage:mainItemImage];
		[menuItem setIndentationLevel:1];
		[menuItem setTarget:self];
		if (![self volumeCanBeEjected:vol])
			[menuItem setAction:nil];
		
		// setup the first alternate item
		altMenu = [[NSMenuItem alloc] initWithTitle:[vol name] action:mainItemAction keyEquivalent:@""];
		[altMenu setAlternate:YES];
		[altMenu setKeyEquivalentModifierMask:NSAlternateKeyMask];
		[altMenu setRepresentedObject:vol];
		[altMenu setImage:mainItemImage];
		[altMenu setIndentationLevel:1];
		[altMenu setTarget:self];
		if ([vol type] == SLVolumeDiskImage)
		{
			[altMenu setTitle:[NSString stringWithFormat:@"Discard %@", [vol name]]];
			[altMenu setAction:@selector(doEjectAndDeleteDiskImage:)];
		}
		if (![self volumeCanBeEjected:vol])
			[altMenu setAction:nil];

		// setup the second alternate item
		altaltMenu = [[NSMenuItem alloc] initWithTitle:[vol name] action:mainItemAction keyEquivalent:@""];
		[altaltMenu setAlternate:YES];
		[altaltMenu setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];
		[altaltMenu setRepresentedObject:vol];
		[altaltMenu setImage:mainItemImage];
		[altaltMenu setIndentationLevel:1];
		[altaltMenu setTitle:[NSString stringWithFormat:@"Show %@", [vol name]]];
		[altaltMenu setAction:@selector(doShowInFinder:)];
		[altaltMenu setTarget:self];
		
		if (titleMenu)
		{
			[menu addItem:titleMenu];
			[titleMenu release];
		}

		[menu addItem:menuItem];
		[menu addItem:altMenu];
		[menu addItem:altaltMenu];
		
		/*if (altaltMenu)
		{
			[menu addItem:altaltMenu];
			[altaltMenu release];
		}*/			

		[altaltMenu release];
		[altMenu release];
		[menuItem release];

		vcount++;
	}
	
	if (showVolumesNumber)
		[_statusItem setTitle:[NSString stringWithFormat:@"%d", vcount]];
	else
		[_statusItem setTitle:nil];
	
	if (vcount)
	{
		if (showEjectAll)
		{
			[menu addItem:[NSMenuItem separatorItem]];
			[menu addItemWithTitle:@"Eject All" action:@selector(doEjectAll:) keyEquivalent:@""];
		}
		
		[menu addItem:[NSMenuItem separatorItem]];
	}

	if (_slMenuItem == nil)
	{
		NSMenu *slSubmenu = [[NSMenu alloc] init];
		_slMenuItem = [[NSMenuItem alloc] initWithTitle:@"Semulov" action:nil keyEquivalent:@""];
		[slSubmenu addItemWithTitle:@"About" action:@selector(doAbout:) keyEquivalent:@""];
		[slSubmenu addItem:[NSMenuItem separatorItem]];
		[slSubmenu addItemWithTitle:@"Preferences..." action:@selector(doPrefs:) keyEquivalent:@""];
		[slSubmenu addItemWithTitle:@"Check for Updates..." action:@selector(doUpdates:) keyEquivalent:@""];
		[slSubmenu addItem:[NSMenuItem separatorItem]];
		[slSubmenu addItemWithTitle:@"Send Feedback" action:@selector(doFeedback:) keyEquivalent:@""];
		[slSubmenu addItem:[NSMenuItem separatorItem]];
		[slSubmenu addItemWithTitle:@"Quit" action:@selector(doQuit:) keyEquivalent:@""];
		[_slMenuItem setSubmenu:slSubmenu];
		[slSubmenu release];
	}
	[menu addItem:_slMenuItem];

	[_statusItem setMenu:menu];
	[menu release];
}

#pragma mark -
#pragma mark Mount/Unmount

- (SLVolume *)volumeWithMountPath:(NSString *)mountPath
{
	NSEnumerator *volsEnum = [_volumes objectEnumerator];
	SLVolume *vol = nil;
	while (vol = [volsEnum nextObject])
		if ([[vol path] isEqualToString:mountPath])
			return vol;
	return nil;
}

- (void)handleMount:(NSNotification *)not
{
	[self updateStatusItemMenu];
	
	[[SLGrowlController sharedController] postVolumeMounted:
		[self volumeWithMountPath:[[not userInfo] objectForKey:@"NSDevicePath"]]];
}

- (void)handleUnmount:(NSNotification *)not
{
	[[SLGrowlController sharedController] postVolumeUnmounted:
		[self volumeWithMountPath:[[not userInfo] objectForKey:@"NSDevicePath"]]];

	[self updateStatusItemMenu];
}

#pragma mark -
#pragma mark Menu Actions

- (void)doAbout:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

- (void)doQuit:(id)sender
{
	[NSApp terminate:nil];
}

- (BOOL)ejectVolumeWithFeedback:(SLVolume *)volume
{
	if (![volume eject])
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"Unmount failed",@"Failed to eject volume.",@"OK",nil,nil);
		return NO;
	}
	return YES;
}

- (void)doEject:(id)sender
{
	[self ejectVolumeWithFeedback:[sender representedObject]];
}

- (void)doEjectAll:(id)sender
{
	NSEnumerator *volumesEnum = [_volumes objectEnumerator];
	SLVolume *vol = nil;
	while (vol = [volumesEnum nextObject])
		if ([self volumeCanBeEjected:vol])
			[vol eject];
}

- (void)doShowInFinder:(id)sender
{
	if (![[sender representedObject] showInFinder])
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSBeep();
	}
}

- (void)doEjectAndDeleteDiskImage:(id)sender
{
	SLVolume *vol = [sender representedObject];
	NSString *imagePath = [vol diskImagePath];

	[NSApp activateIgnoringOtherApps:YES];

	if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
	{
		NSRunAlertPanel(@"Disk image not found",@"The corresponding disk image file for the mounted volume could not be found.",@"OK",nil,nil);
		return;
	}
	
	BOOL showWarning = [[NSUserDefaults standardUserDefaults] boolForKey:@"SLDisableDiscardWarning"];
	if (
		(showWarning == YES) ||
		((showWarning == NO) && (NSRunAlertPanel(@"Are you sure you want to unmount this volume and delete its associated disk image?",@"You cannot undo this action.",@"No",@"Yes",nil) == NSCancelButton))
		)
	{
		if ([self ejectVolumeWithFeedback:vol])
			[[NSFileManager defaultManager] removeFileAtPath:imagePath handler:nil];
	}

	// move it to the trash
	/*NSString *sourceDir = [imagePath stringByDeletingLastPathComponent];
	NSArray *files = [NSArray arrayWithObject:[imagePath lastPathComponent]];
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	int tag = 0;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:sourceDir
											destination:trashDir
												  files:files
													tag:&tag];*/
}

- (void)doUpdates:(id)sender
{
	[_updater checkForUpdates:nil];
}

- (void)doFeedback:(id)sender
{
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *urlString = [[NSString stringWithFormat:@"mailto:kainjow@kainjow.com?subject=Semulov %@ Feedback", appVersion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)doPrefs:(id)sender
{
	if (_prefs == nil)
		_prefs = [[SLPrefsController alloc] init];
	[_prefs window];
	[NSApp activateIgnoringOtherApps:YES];
	[_prefs showWindow:nil];
}

@end
