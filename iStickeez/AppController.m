//
//  AppController.m
//  iStickeez
//
//  Created by Kevin Wojniak on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "StickiesDocument.h"


@implementation AppController

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
	[NSThread detachNewThreadSelector:@selector(loadStickies) toTarget:self withObject:nil];
}

- (void)loadStickies
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"StickiesDatabase"];
		//path = [[NSBundle bundleWithPath:[[NSWorkspace sharedWorkspace] fullPathForApplication:@"Stickies"]] pathForResource:@"StickiesDefaultDatabase" ofType:nil];
		
		NSUnarchiver *unarchiver = [[[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]] autorelease];
		// Stickies.app uses a Document class name, but we want to replace it with our own.
		[unarchiver decodeClassName:@"Document" asClassName:NSStringFromClass([StickiesDocument class])];
		NSArray *objs = [unarchiver decodeObject];
		[self performSelectorOnMainThread:@selector(loadStickiesComplete:) withObject:objs waitUntilDone:NO];
	}
	@catch (NSException *exception) {
		[self performSelectorOnMainThread:@selector(loadStickiesFailure:) withObject:exception waitUntilDone:NO];
	}

	[pool release];
}

- (void)loadStickiesFailure:(NSException *)exception
{
	NSRunAlertPanel(NSLocalizedString(@"Failed to load Stickies file.", nil), [exception reason], nil, nil, nil);
	[NSApp terminate:nil];
}

- (void)loadStickiesComplete:(NSArray *)objs
{
	[arrayController addObserver:self forKeyPath:@"selection" options:0 context:nil];
	[self setValue:objs forKey:@"stickies"];
	[[self window] makeKeyAndOrderFront:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSArray *selectedObjs = [arrayController selectedObjects];
	if (selectedObjs && [selectedObjs count]) {
		StickiesDocument *doc = [selectedObjs objectAtIndex:0];
		[textView setBackgroundColor:[doc color]];
	} else
		[textView setBackgroundColor:[NSColor whiteColor]];
}

@end
