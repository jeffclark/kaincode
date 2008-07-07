//
//  BOStatusMenuController.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/6/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "BOStatusMenuController.h"
#import "BOBoot.h"


@implementation BOStatusMenuController

- (id)init
{
	if (self = [super init])
	{
		m_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
		[m_statusItem setHighlightMode:YES];
		NSImage *img = [NSImage imageNamed:@"bootchamp"];
		[img setTemplate:YES];
		[m_statusItem setImage:img];
		
		NSMenu *menu = [[[NSMenu alloc] init] autorelease];
		NSMenuItem *menuItem;
		
		// restart into windows
		menuItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Restart into Windows...", nil)
											   action:@selector(bootWindows:)
										keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menu addItem:menuItem];
		[menu addItem:[NSMenuItem separatorItem]];
		
		// app menu
		NSMenuItem *submenuItem = [[[NSMenuItem alloc] initWithTitle:[[NSProcessInfo processInfo] processName] action:nil keyEquivalent:@""] autorelease];
		NSMenu *submenu = [[[NSMenu alloc] init] autorelease];
		[submenu addItemWithTitle:NSLocalizedString(@"About", nil) action:@selector(about:) keyEquivalent:@""];
		[submenu addItemWithTitle:NSLocalizedString(@"Send Feedback", nil) action:@selector(sendFeedback:) keyEquivalent:@""];
		[submenu addItem:[NSMenuItem separatorItem]];
		[submenu addItemWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(quit:) keyEquivalent:@""];
		[[submenu itemArray] makeObjectsPerformSelector:@selector(setTarget:) withObject:self];
		[submenuItem setSubmenu:submenu];
		[menu addItem:submenuItem];
		
		
		[m_statusItem setMenu:menu];
	}
	
	return self;	
}

- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:m_statusItem];
	[m_statusItem release];
	[super dealloc];
}

- (void)bootWindows:(id)sender
{
	bootIntoWindows();
}

- (void)about:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

- (void)sendFeedback:(id)sender
{
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *urlString = [[NSString stringWithFormat:@"mailto:kainjow@kainjow.com?subject=%@ %@ Feedback", [[NSProcessInfo processInfo] processName], appVersion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)quit:(id)sender
{
	[NSApp terminate:nil];
}

@end
