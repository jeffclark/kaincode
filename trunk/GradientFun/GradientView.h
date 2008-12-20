//
//  GradientView.h
//  GradientFun
//
//  Created by Kevin Wojniak on 9/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GradientView : NSView
{
	CGColorRef _startColor, _endColor;
}

@property (readwrite, retain) NSColor *startColor;
@property (readwrite, retain) NSColor *endColor;

- (NSArray *)gradientComponentsForStartingColor:(NSColor *)startColor andEndingColor:(NSColor *)endingColor count:(int)count;

@end
