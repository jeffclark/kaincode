//
//  GradientView.m
//  GradientFun
//
//  Created by Kevin Wojniak on 9/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GradientView.h"


@interface GradientView (Private)
+ (CGColorRef)convertColor:(NSColor *)color;
@end


@implementation GradientView

@synthesize startColor, endColor;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setStartColor:[NSColor purpleColor]];
		[self setEndColor:[NSColor yellowColor]];
	}
	
	return self;
}

- (void)dealloc
{
	CGColorRelease(_startColor);
	CGColorRelease(_endColor);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Components

- (float **)getGradientComponentsForStartingColor:(CGColorRef)startColor andEndingColor:(CGColorRef)endingColor count:(int)count
{
	float **rgbComps = malloc(sizeof(float*) * 4 * count);
	
	float xSteps;
	float *startComps, *endComps;
	float startR, startG, startB;
	float stepR, stepG, stepB;
	float endR, endG, endB;
	float cR, cG, cB;
	int x = 0;
	
	startComps = (float *)CGColorGetComponents(startColor);
	endComps = (float *)CGColorGetComponents(endingColor);
	startR = startComps[0];
	startG = startComps[1];
	startB = startComps[2];
	endR = endComps[0];
	endG = endComps[1];
	endB = endComps[2];
	
	xSteps = (float)count;
	stepR = (endR - startR) / xSteps;
	stepG = (endG - startG) / xSteps;
	stepB = (endB - startB) / xSteps;
	cR = startR;
	cG = startG;
	cB = startB;
	
	for (x=0; x<xSteps; x++)
	{
		float *cComps = malloc(4);
		cComps[0] = cR;
		cComps[1] = cG;
		cComps[2] = cB;
		cComps[3] = 1.0;
		rgbComps[x] = cComps;
		
		cR += stepR;
		cG += stepG;
		cB += stepB;
	}
	
	return rgbComps;
}

- (NSArray *)gradientComponentsForStartingColor:(NSColor *)startColor andEndingColor:(NSColor *)endingColor count:(int)count
{
	NSMutableArray *comps = [NSMutableArray arrayWithCapacity:count];
	float **rgbComps = NULL;
	int x = 0;
	
	rgbComps = [self getGradientComponentsForStartingColor:[GradientView convertColor:startColor]
											andEndingColor:[GradientView convertColor:endingColor]
													 count:count];
	
	for (x=0; x<count; x++)
	{
		float *cComps = rgbComps[x];
		
		NSColor *color = [NSColor colorWithDeviceRed:cComps[0] green:cComps[1] blue:cComps[2] alpha:cComps[3]];
		[comps addObject:color];
		
		free(cComps);
	}
	
	free(rgbComps);
	
	return ([comps count] ? comps : nil);
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGRect bounds = CGRectMake([self bounds].origin.x,
							   [self bounds].origin.y,
							   [self bounds].size.width,
							   [self bounds].size.height);
	
	CGContextRef contextRef = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	
	float **rgbComps = NULL;
	float count = bounds.size.width;
	int x = 0;
	
	rgbComps = [self getGradientComponentsForStartingColor:_startColor andEndingColor:_endColor count:count];
	
	CGContextSetFillColorWithColor(contextRef, _startColor);
	
	for (x=0; x<count; x++)
	{
		float *cComps = rgbComps[x];
		
		CGRect cRect = CGRectMake((float)x, 0, 1, bounds.size.height);
		CGContextSetFillColor(contextRef, cComps);
		CGContextFillRect(contextRef, cRect);
		
		free(cComps);
	}
	
	CGContextFlush(contextRef);
	
	free(rgbComps);
}

#pragma mark -
#pragma mark Colors

+ (CGColorRef)convertColor:(NSColor *)color
{
	CGColorRef colorRef = NULL;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSColor *newColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	float comps[4] = {0, 0, 0, 0};
	[newColor getRed:&comps[0] green:&comps[1] blue:&comps[2] alpha:&comps[3]];
	colorRef = CGColorCreate(colorSpace,comps);
	return colorRef;
}

+ (NSColor *)convertColorRef:(CGColorRef)colorRef
{
	float *comps = (float *)CGColorGetComponents(colorRef);
	return [NSColor colorWithDeviceRed:comps[0] green:comps[1] blue:comps[2] alpha:comps[3]];
}

- (void)setStartColor:(NSColor *)color
{
	CGColorRelease(_startColor);
	_startColor = [GradientView convertColor:color];
	[self setNeedsDisplay:YES];
}

- (void)setEndColor:(NSColor *)color
{
	CGColorRelease(_endColor);
	_endColor = [GradientView convertColor:color];
	[self setNeedsDisplay:YES];
}

- (NSColor *)startColor
{
	return [GradientView convertColorRef:_startColor];
}

- (NSColor *)endColor
{
	return [GradientView convertColorRef:_endColor];
}

@end
