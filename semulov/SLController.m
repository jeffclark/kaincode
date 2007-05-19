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

@interface NSImage (resize)
- (NSImage *)resize:(NSSize)size;
@end
@implementation NSImage (resize)
- (NSImage *)resize:(NSSize)size
{
    NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];
    
    [image setSize:size];
    
 	[self setScalesWhenResized: YES];
	[self setSize:size];
	
    [image lockFocus];
	[self compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
    [image unlockFocus];
	
    return image;
}
@end


#define SLShowVolumesNumber @"SLShowVolumesNumber"
#define SLShowStartupDisk	@"SLShowStartupDisk"
#define SLShowEjectAll		@"SLShowEjectAll"
#define SLDisableInternalHD	@"SLDisableInternalHD"


@implementation SLController

+ (void)initialize
{
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], SLShowVolumesNumber,
		[NSNumber numberWithBool:NO], SLShowStartupDisk,
		[NSNumber numberWithBool:NO], SLShowEjectAll,
		[NSNumber numberWithBool:YES], SLDisableInternalHD,
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self updateStatusItemMenu];
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
	[_statusItem setImage:[NSImage imageNamed:@"Eject"]];
	[_statusItem setAlternateImage:[NSImage imageNamed:@"EjectPressed"]];
	[self updateStatusItemMenu];
}

- (BOOL)volumeCanBeEjected:(SLVolume *)volume
{
	return !([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:SLDisableInternalHD] boolValue] == YES && 
			[volume isInternalHardDrive]);
}

- (void)updateStatusItemMenu
{
	NSMenu *menu = [[NSMenu alloc] init];
	NSDictionary *defaultValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	BOOL showVolumesNumber = [[defaultValues valueForKey:SLShowVolumesNumber] boolValue];
	BOOL showStartupDisk = [[defaultValues valueForKey:SLShowStartupDisk] boolValue];
	BOOL showEjectAll = [[defaultValues valueForKey:SLShowEjectAll] boolValue];
	
	while ([[_statusItem menu] numberOfItems])
		[[_statusItem menu] removeItemAtIndex:0];

	[_volumes release];
	_volumes = [[SLVolume allVolumes] retain];
	NSEnumerator *volumesEnum = [_volumes objectEnumerator];
	SLVolume *vol = nil;
	SLVolumeType _lastType = -1;
	int vcount = 0;
	NSMenuItem *menuItem = nil, *altMenu = nil;
	NSString *titleName = nil;
	
	while (vol = [volumesEnum nextObject])
	{
		if (showStartupDisk == NO && [vol isRoot]) continue;
		
		if ([vol type] != _lastType)
		{
			_lastType = [vol type];
			
			if (_lastType == SLVolumeDrive)
				titleName = @"Volumes";
			else if (_lastType == SLVolumeRoot)
				titleName = @"Startup Disk";
			else if (_lastType == SLVolumeiPod)
				titleName = @"iPod";
			else if (_lastType == SLVolumeNetwork)
				titleName = @"Network";
			else if (_lastType == SLVolumeiDisk)
				titleName = @"iDisk";
			else if (_lastType == SLVolumeFTP)
				titleName = @"FTP";			
			menuItem = [[NSMenuItem alloc] initWithTitle:titleName action:nil keyEquivalent:@""];
			[menu addItem:menuItem];		
			[menuItem release];
		}
		
		menuItem = [[NSMenuItem alloc] initWithTitle:[vol name] action:([vol isRoot] ? nil : @selector(doEject:)) keyEquivalent:@""];
		[menuItem setRepresentedObject:vol];
		[menuItem setImage:[[vol image] resize:NSMakeSize(16, 16)]];
		[menuItem setIndentationLevel:1];
		if (![self volumeCanBeEjected:vol])
			[menuItem setAction:nil];
		[menu addItem:menuItem];
		
		altMenu = [menuItem copy];
		[altMenu setAlternate:YES];
		[altMenu setTitle:[NSString stringWithFormat:@"Show %@", [altMenu title]]];
		[altMenu setKeyEquivalentModifierMask:NSAlternateKeyMask];
		[altMenu setAction:@selector(doShowInFinder:)];
		[menu addItem:altMenu];
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

- (void)doEject:(id)sender
{
	if (![[sender representedObject] eject])
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"Unmount failed",@"Failed to eject volume.",@"OK",nil,nil);
	}
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

- (void)doUpdates:(id)sender
{
	[_updater checkForUpdates:nil];
}

- (void)doFeedback:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:kainjow@kainjow.com?subject=Semulov%20Feedback"]];
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
