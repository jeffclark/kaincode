//
//  main.m
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SLController.h"


int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSApplication sharedApplication];

	SLController *controller = [[SLController alloc] init];
	
	[NSApp setDelegate:controller];
	[NSApp run];
	
	[controller release];
	
	[pool release];
	
    return 0;
}
