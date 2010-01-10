//
//  BOStatusMenuController.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/6/08.
//  Copyright 2008-2010 Kevin Wojniak. All rights reserved.
//

#import "BOStatusMenuController.h"
#import "BOBoot.h"
#import "BOApplicationAdditions.h"
#import "BOMedia.h"


#define BOPrefsLaunchAtStartup	@"LaunchAtStartup"
#define BOPrefsNextOnly		@"NextOnly"

@implementation BOStatusMenuController

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:YES], BOPrefsLaunchAtStartup,
							  [NSNumber numberWithBool:YES], BOPrefsNextOnly,
							  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (NSImage *)statusImage
{
	NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize(22.0, 22.0)];
	NSRect bounds = NSMakeRect(0.0, 0.0, [img size].width, [img size].height);
	NSSize size = NSMakeSize(5.0, 5.0);
	NSRect drawBounds;
	drawBounds.size = NSMakeSize(size.width*2+1.5, size.height*2+1.5);
	drawBounds.origin = NSMakePoint(NSMinX(bounds) + floor((NSWidth(bounds)-NSWidth(drawBounds))/2),
									NSMinY(bounds) + floor((NSHeight(bounds)-NSHeight(drawBounds))/2));
	bounds = drawBounds;
	NSBezierPath *bz = nil;
	CGFloat colors[] = {0.1, 0.25, 0.4, 0.55};
	
	[img lockFocus];
	
	NSAffineTransform *at = [NSAffineTransform transform];
	[at translateXBy:NSWidth(bounds) yBy:NSHeight(bounds)];
	[at rotateByDegrees:45.0];
	[at translateXBy:-NSWidth(bounds) yBy:-NSHeight(bounds)];
	[at concat];
	
	// top left
	[[NSColor colorWithCalibratedWhite:colors[3] alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds)+size.width, NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds)+size.width, NSMaxY(bounds)-size.height)];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)-size.height)];
	[bz fill];

	// top right
	[[NSColor colorWithCalibratedWhite:colors[0] alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)-size.height)];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMaxY(bounds)-size.height)];
	[bz fill];

	// bottom right
	[[NSColor colorWithCalibratedWhite:colors[1] alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMinY(bounds)+size.height)];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds)+size.height)];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMinY(bounds))];
	[bz fill];

	// bottom left
	[[NSColor colorWithCalibratedWhite:colors[2] alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds)+size.height)];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds)+size.width, NSMinY(bounds)+size.height)];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds)+size.width, NSMinY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
	[bz fill];
	
	[img unlockFocus];
	[img setTemplate:YES];
	return [img autorelease];
}

- (void)checkPrefs
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:BOPrefsLaunchAtStartup])
		[NSApp addToLoginItems];
	else
		[NSApp removeFromLoginItems];
}

- (void)updateBootMenuWithMedia:(NSArray *)media
{
	[bootMenuItem setTitle:NSLocalizedString(@"Restart into Windows...", "restart into windows menu item")];
	if (![media count])
	{
		// no media
		[bootMenuItem setTarget:nil];
		[bootMenuItem setAction:nil];
		[bootMenuItem setSubmenu:nil];
		[bootMenuItem setRepresentedObject:nil];
	}
	else
	{
		[bootMenuItem setTarget:self];
		[bootMenuItem setAction:@selector(bootWindows:)];
		
		if ([media count] == 1)
		{
			// only 1 media
			[bootMenuItem setSubmenu:nil];
			[bootMenuItem setRepresentedObject:[media lastObject]];
		}
		else
		{
			// multiple media
			NSMenu *submenu = [[[NSMenu alloc] init] autorelease];
			for (BOMedia *m in media)
			{
				NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:m.name action:@selector(bootWindows:) keyEquivalent:@""] autorelease];
				[item setTarget:self];
				[item setRepresentedObject:m];
				[submenu addItem:item];
			}
			[bootMenuItem setSubmenu:submenu];
			[bootMenuItem setRepresentedObject:nil];
		}
	}
}

- (void)updateBootMenu
{
	[bootMenuItem setTitle:NSLocalizedString(@"Updating...", "updating drives menu item")];
	[bootMenuItem setTarget:nil];
	[bootMenuItem setAction:nil];
	[bootMenuItem setSubmenu:nil];
	[bootMenuItem setRepresentedObject:nil];
	
	// load media objects on a separate queue and call back to self with updateBootMenuWithMedia: when done
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
		NSArray *media = [BOMedia allMedia];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self updateBootMenuWithMedia:media];
		});
	});
}

- (id)init
{
	if (self = [super init])
	{
		m_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
		[m_statusItem setHighlightMode:YES];
		[m_statusItem setImage:[self statusImage]];
		
		NSMenu *menu = [[[NSMenu alloc] init] autorelease];
		
		// restart into windows
		bootMenuItem = [[NSMenuItem alloc] initWithTitle:@""
											   action:nil
										keyEquivalent:@""];
		[menu addItem:bootMenuItem];
		[self updateBootMenu];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(updateBootMenu) name:NSWorkspaceDidMountNotification object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(updateBootMenu) name:NSWorkspaceDidUnmountNotification object:nil];
		
		[menu addItem:[NSMenuItem separatorItem]];
		
		[menu addItemWithTitle:NSLocalizedString(@"Preferences", "preferences title menu item") action:nil keyEquivalent:@""];
		NSMenuItem *menuItem;
		menuItem = [menu addItemWithTitle:NSLocalizedString(@"Launch at startup", "launch at startup menu item") action:@selector(preferenceAction:) keyEquivalent:@""];
		[menuItem setIndentationLevel:1];
		[menuItem setRepresentedObject:BOPrefsLaunchAtStartup];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:BOPrefsLaunchAtStartup])
			[menuItem setState:NSOnState];
		menuItem = [menu addItemWithTitle:NSLocalizedString(@"Next restart only", "next restart only menu item") action:@selector(preferenceAction:) keyEquivalent:@""];
		[menuItem setIndentationLevel:1];
		[menuItem setRepresentedObject:BOPrefsNextOnly];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:BOPrefsNextOnly])
			[menuItem setState:NSOnState];

		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemWithTitle:NSLocalizedString(@"BootChamp Help", "help menu item") action:@selector(showHelp:) keyEquivalent:@""];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemWithTitle:NSLocalizedString(@"Quit", "quit menu item") action:@selector(quit:) keyEquivalent:@""];
		[[menu itemArray] makeObjectsPerformSelector:@selector(setTarget:) withObject:self];
		
		[m_statusItem setMenu:menu];
		
		[self checkPrefs];
	}
	
	return self;	
}

- (void)dealloc
{
	[bootMenuItem release];
	[[NSStatusBar systemStatusBar] removeStatusItem:m_statusItem];
	[m_statusItem release];
	[super dealloc];
}

- (void)bootWindows:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	BOBoot *boot = [[[BOBoot alloc] init] autorelease];
	boot.nextonly = [[NSUserDefaults standardUserDefaults] boolForKey:BOPrefsNextOnly];
	boot.media = [sender representedObject];
	[boot bootIntoWindows];
}

- (void)showHelp:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	NSURL *helpURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help.htm" ofType:nil]];
	[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:helpURL] withAppBundleIdentifier:@"com.apple.helpviewer" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL];
}

- (void)preferenceAction:(id)sender
{
	NSString *key = [sender representedObject];
	NSInteger newState = ([sender state] == NSOnState ? NSOffState : NSOnState);
	[sender setState:newState];
	[[NSUserDefaults standardUserDefaults] setBool:(newState == NSOnState ? YES : NO) forKey:key];
	
	[self checkPrefs];
}

- (void)quit:(id)sender
{
	[NSApp terminate:nil];
}

@end
