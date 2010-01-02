//
//  PNGshrinkAppDelegate.m
//  PNGshrink
//
//  Created by Kevin Wojniak on 1/2/10.
//  Copyright 2010 Kevin Wojniak. All rights reserved.
//

#import "PNGshrinkAppDelegate.h"
#import "OptiPNG.h"

@implementation PNGshrinkAppDelegate

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	if (!optiPNG)
		optiPNG = [[OptiPNG alloc] init];
	
	[window center];
	[progress startAnimation:nil];
	[window makeKeyAndOrderFront:nil];
	
	CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
	[optiPNG processFiles:filenames completionHandler:^{
		NSLog(@"Time %f", CFAbsoluteTimeGetCurrent() - start);
		[NSApp terminate:nil];
	}];
}

@end
