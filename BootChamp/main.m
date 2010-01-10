//
//  main.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/4/07.
//  Copyright 2007-2010 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BOAppController.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSApplication sharedApplication];
	
	BOAppController *controller = [[BOAppController alloc] init];
	
	[NSApp setDelegate:controller];
	[NSApp run];
	
	[controller release];
	
	[pool release];
	
    return 0;
}

