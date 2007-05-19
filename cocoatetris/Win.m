//
//  CursorWin.m
//  CursorFun
//
//  Created by Kevin Wojniak on 8/17/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "Win.h"


@implementation Win

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	//contentRect = [[NSScreen mainScreen] frame];
    /*if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO]) {
		[self setBackgroundColor:[NSColor clearColor]];
		[self setLevel:NSStatusWindowLevel];
		[self setAlphaValue:1.0];
		[self setOpaque:NO];
		[self setHasShadow:YES];
	}*/
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	
	return self;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint currentLocation;
	NSPoint newOrigin;
	NSRect  screenFrame = [[NSScreen mainScreen] frame];
	NSRect  windowFrame = [self frame];
	
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
		newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    [self setFrameOrigin:newOrigin];
}

- (void)mouseDown:(NSEvent *)theEvent
{    
    NSRect  windowFrame = [self frame];
	
	initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	initialLocation.x -= windowFrame.origin.x;
	initialLocation.y -= windowFrame.origin.y;
}

@end
