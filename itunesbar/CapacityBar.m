//
//  View.m
//  iTunesCapacityBar
//
//  Created by Kevin Wojniak on 11/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CapacityBar.h"
#import "CTGradient.h"

#define RGB(r,g,b) ([NSColor colorWithCalibratedRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0])
#define BLUE_COLOR		RGB(102, 138, 252)
#define PURPLE_COLOR	RGB(167, 93, 248)
#define YELLOW_COLOR	RGB(254, 243, 101)
#define ORANGE_COLOR	RGB(254, 183, 47)
#define WHITE_COLOR		RGB(252, 252, 252)
#define	WHITE_DARK_COLOR	RGB(200, 200, 200)


@interface NSBezierPath (RoundedRect)
+ (NSBezierPath *)bezierPathWithRoundRectInRect:(NSRect)rect withRadius:(float)radius;
@end
@implementation NSBezierPath (RoundedRect)
+ (NSBezierPath *)bezierPathWithRoundRectInRect:(NSRect)rect withRadius:(float)radius
{
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(NSMidX(rect), NSMinY(rect))];
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMaxX(rect), NSMinY(rect)) toPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius: radius];
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect)) toPoint: NSMakePoint(NSMidX(rect), NSMaxY(rect)) radius: radius];
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect)) toPoint: NSMakePoint(NSMinX(rect), NSMinY(rect)) radius: radius];	
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMinX(rect), NSMinY(rect)) toPoint: NSMakePoint(NSMidX(rect), NSMinY(rect)) radius: radius];
	[path closePath];
	return path;
}
@end

@interface NSColor (Darker)
- (NSColor *)darkerColor;
@end
@implementation NSColor (Darker)
- (NSColor *)darkerColor
{
	NSColor *converted = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	float factor = 75/255.0;
	return [NSColor colorWithCalibratedRed:[converted redComponent]-factor
									 green:[converted greenComponent]-factor
									  blue:[converted blueComponent]-factor
									 alpha:[converted alphaComponent]];
}
@end


@implementation CapacityBar

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		_values = [[NSMutableArray alloc] init];
		_max = 100.0;
		_drawLines = YES;
	}
	
	return self;
}

- (void)setMaxValue:(float)max
{
	_max = max;
}

- (float)maxValue
{
	return _max;
}

- (void)addValue:(float)value forColor:(NSColor *)color
{	
	[_values addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:value], @"value",
		color, @"color",
		nil]];
	[self setNeedsDisplay:YES];
}

- (void)clearAllValues
{
	[_values removeAllObjects];
	[self setNeedsDisplay:YES];
}

- (void)setDrawLines:(BOOL)drawLines
{
	_drawLines = drawLines;
	[self setNeedsDisplay:YES];
}

- (BOOL)drawLines
{
	return _drawLines;
}

+ (NSColor *)iTunesBlueColor
{
	return BLUE_COLOR;
}

+ (NSColor *)iTunesPurpleColor
{
	return PURPLE_COLOR;
}

+ (NSColor *)iTunesYellowColor
{
	return YELLOW_COLOR;
}

+ (NSColor *)iTunesOrangeColor
{
	return ORANGE_COLOR;
}

- (void)drawRect:(NSRect)rect
{
	NSSize barSize = [self bounds].size; //NSMakeSize(455, 20);
	NSRect centerRect = NSMakeRect((rect.size.width-barSize.width)/2, (rect.size.height-barSize.height)/2, barSize.width, barSize.height);
	
	[[NSBezierPath bezierPathWithRoundRectInRect:centerRect withRadius:centerRect.size.height/2] addClip];
	
	// draw white background...
	[[CTGradient gradientWithBeginningColor:WHITE_DARK_COLOR/*[WHITE_COLOR darkerColor]*/ endingColor:WHITE_COLOR] fillRect:centerRect angle:90.0];
	
	// enumerate through each value
	NSEnumerator *valuesEnum = [_values objectEnumerator];
	NSDictionary *val = nil;
	float valx = 0;
	while (val = [valuesEnum nextObject])
	{
		float width = ([[val objectForKey:@"value"] floatValue] / _max) * barSize.width;
		NSColor *color = [val objectForKey:@"color"];
		NSRect valRect = NSMakeRect(centerRect.origin.x + valx, centerRect.origin.y, width, barSize.height);
		valx += width;
		
		[[CTGradient gradientWithBeginningColor:[color darkerColor] endingColor:color] fillRect:valRect angle:90.0];
	}
	
	if (_drawLines)
	{
		// draw vertical lines
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		float line_width = 21;
		float sx = line_width;
		while (sx < barSize.width)
		{
			NSRect lineRect = NSMakeRect(centerRect.origin.x + sx, centerRect.origin.y, 1, barSize.height-2);
			
			[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.1] set];
			[NSBezierPath strokeLineFromPoint:lineRect.origin toPoint:NSMakePoint(lineRect.origin.x, lineRect.origin.y+barSize.height)];
			sx++;
			lineRect.origin.x++;
			[[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.2] set];
			[NSBezierPath strokeLineFromPoint:lineRect.origin toPoint:NSMakePoint(lineRect.origin.x, lineRect.origin.y+barSize.height)];
			sx += line_width + 1;
		}
		[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	}
	
}

@end
