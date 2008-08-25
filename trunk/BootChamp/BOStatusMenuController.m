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
	
	[img lockFocus];
	
	NSAffineTransform *at = [NSAffineTransform transform];
	[at translateXBy:NSWidth(bounds) yBy:NSHeight(bounds)];
	[at rotateByDegrees:45.0];
	[at translateXBy:-NSWidth(bounds) yBy:-NSHeight(bounds)];
	[at concat];
	
	// top left
	[[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds)+size.width, NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds)+size.width, NSMaxY(bounds)-size.height)];
	[bz lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)-size.height)];
	[bz fill];

	// top right
	[[NSColor colorWithCalibratedWhite:0.1 alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)-size.height)];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMaxY(bounds)-size.height)];
	[bz fill];

	// bottom right
	[[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
	bz = [NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMinY(bounds)+size.height)];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds)+size.height)];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
	[bz lineToPoint:NSMakePoint(NSMaxX(bounds)-size.width, NSMinY(bounds))];
	[bz fill];

	// bottom left
	[[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] set];
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

- (id)init
{
	if (self = [super init])
	{
		m_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
		[m_statusItem setHighlightMode:YES];
		[m_statusItem setImage:[self statusImage]];
		
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
		[submenu addItemWithTitle:NSLocalizedString(@"About...", nil) action:@selector(about:) keyEquivalent:@""];
		[submenu addItemWithTitle:NSLocalizedString(@"Send Feedback...", nil) action:@selector(sendFeedback:) keyEquivalent:@""];
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
