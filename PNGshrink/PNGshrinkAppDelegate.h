//
//  PNGshrinkAppDelegate.h
//  PNGshrink
//
//  Created by Kevin Wojniak on 1/2/10.
//  Copyright 2010 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class OptiPNG;

@interface PNGshrinkAppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSWindow *window;
	IBOutlet NSProgressIndicator *progress;
	
	OptiPNG *optiPNG;
}

@end
