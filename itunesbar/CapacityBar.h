//
//  View.h
//  iTunesCapacityBar
//
//  Created by Kevin Wojniak on 11/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CapacityBar : NSView
{
	float _max;
	NSMutableArray *_values;
	BOOL _drawLines;
}

- (void)setMaxValue:(float)max;
- (float)maxValue;
- (void)addValue:(float)value forColor:(NSColor *)color;
- (void)clearAllValues;

- (void)setDrawLines:(BOOL)drawLines;
- (BOOL)drawLines;

+ (NSColor *)iTunesBlueColor;
+ (NSColor *)iTunesPurpleColor;
+ (NSColor *)iTunesYellowColor;
+ (NSColor *)iTunesOrangeColor;

@end
