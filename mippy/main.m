//
//  main.m
//  DockIP
//
//  Created by Ed Wojniak on Sun Oct 20 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"

int main(int argc, const char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSApplication sharedApplication];
	
	AppController *controller = [[AppController alloc] init];
	
	[NSApp setDelegate:controller];
	[NSApp run];
	
	[controller release];
	
	[pool release];
	
    return 0;
}
