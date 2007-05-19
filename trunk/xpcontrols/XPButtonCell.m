//
//  XPButtonCell.m
//  XPControls
//
//  Created by Kevin Wojniak on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XPButtonCell.h"
#import "CTGradient.h"


#define RGB(r, g, b) [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0]


@interface CTGradient (XP)
+ (CTGradient *)XPButtonGradient;
@end

@implementation CTGradient (XP)
+ (CTGradient *)XPButtonGradient
{
	CTGradient *g = [[CTGradient alloc] init];
	
	CTGradientElement color1;
	color1.red   = 1.0;
	color1.green = 1.0;
	color1.blue  = 1.0;
	color1.alpha = 1.00;
	color1.position = 0.0;
	
	CTGradientElement color2;
	color2.red   = 246/255.0;
	color2.green = 246/255.0;
	color2.blue  = 243/255.0;
	color2.alpha = 1.00;
	color2.position = 0.2;
	
	CTGradientElement color3;
	color3.red   = 246/255.0;
	color3.green = 246/255.0;
	color3.blue  = 243/255.0;
	color3.alpha = 1.0;
	color3.position = 0.8;
	
	CTGradientElement color4;
	color4.red   = 214/255.0;
	color4.green = 208/255.0;
	color4.blue  = 197/255.0;
	color4.alpha = 1.0;
	color4.position = 1.0;
	
	[g addElement:&color1];
	[g addElement:&color2];
	[g addElement:&color3];
	[g addElement:&color4];
	
	return [g autorelease];
}

+ (CTGradient *)XPButtonGradientMouseDown
{
	CTGradient *g = [[CTGradient alloc] init];
	
	CTGradientElement color1;
	color1.red   = 217/255.0;
	color1.green = 213/255.0;
	color1.blue  = 205/255.0;
	color1.alpha = 1.0;
	color1.position = 0.0;
	
	CTGradientElement color2;
	color2.red   = 234/255.0;
	color2.green = 233/255.0;
	color2.blue  = 228/255.0;
	color2.alpha = 1.0;
	color2.position = 0.2;
	
	CTGradientElement color3;
	color3.red   = 234/255.0;
	color3.green = 233/255.0;
	color3.blue  = 228/255.0;
	color3.alpha = 1.0;
	color3.position = 0.8;
	
	CTGradientElement color4;
	color4.red   = 245/255.0;
	color4.green = 244/255.0;
	color4.blue  = 242/255.0;
	color4.alpha = 1.0;
	color4.position = 1.0;
	
	[g addElement:&color1];
	[g addElement:&color2];
	[g addElement:&color3];
	[g addElement:&color4];
	
	return [g autorelease];
}

@end


@implementation XPButtonCell

- (NSBezierPath *) bezierPathWithRoundRectInRect:(NSRect) rect  
									  withRadius:(float) radius
{
	id path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(NSMidX(rect), NSMinY(rect))];
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMaxX(rect),  
														NSMinY(rect))
								   toPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect))
									radius: radius];
	
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMaxX(rect),  
														NSMaxY(rect))
								   toPoint: NSMakePoint(NSMidX(rect), NSMaxY(rect))
									radius: radius];
	
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMinX(rect),  
														NSMaxY(rect))
								   toPoint: NSMakePoint(NSMinX(rect), NSMinY(rect))
									radius: radius];
	
	[path appendBezierPathWithArcFromPoint: NSMakePoint(NSMinX(rect),  
														NSMinY(rect))
								   toPoint: NSMakePoint(NSMidX(rect), NSMinY(rect))
									radius: radius];
	[path closePath];
	return path;
}

- (NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
	NSRect r = frame;
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[[NSFontManager sharedFontManager] fontWithFamily:@"Tahoma" traits:0.0 weight:1.0 size:11], NSFontAttributeName,
		([self isEnabled] ? [NSColor blackColor] : RGB(161/255.0, 161/255.0, 146/255.0)), NSForegroundColorAttributeName,
		nil];
	NSString *caption = [title string];
	NSSize captionSize = [caption sizeWithAttributes:attrs];
	NSRect captionRect;
	captionRect.size = captionSize;
	captionRect.origin = NSMakePoint(r.origin.x + (r.size.width-captionSize.width)/2, r.origin.y + (r.size.height-captionSize.height)/2 - 1);
	//[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[caption drawInRect:captionRect withAttributes:attrs];
	//[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	return captionRect;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
	// button background
	if (![self isEnabled])
	{
		[RGB(245/255.0, 244/255.0, 234/255.0) set];
		NSRectFill(frame);
	}
	else if ([self isHighlighted] || !_mouseHover)
		[([self isHighlighted] ? [CTGradient XPButtonGradientMouseDown] : [CTGradient XPButtonGradient]) fillRect:frame angle:90.0];

	// hover orange border
	if ([self isEnabled] && ![self isHighlighted] && _mouseHover)
	{
		/*if ([[self keyEquivalent] length] > 0)
		{
			if ([[self keyEquivalent] characterAtIndex:0] == 13)
				;
		}*/
		
		//[[NSColor colorWithCalibratedRed:188/255.0 green:212/255.0 blue:246/255.0 alpha:1.0] set];
		//[[NSColor colorWithCalibratedRed:255/255.0 green:204/255.0 blue:51/255.0 alpha:1.0] set];
		NSRect newFrame = frame;
		newFrame.origin.x += 1; newFrame.origin.y += 1; newFrame.size.width -= 2; newFrame.size.height -= 2;
		[[CTGradient gradientWithBeginningColor:RGB(1.0, 1.0, 204/255.0) endingColor:RGB(248/255.0, 178/255.0, 47/255.0)] fillRect:newFrame angle:90.0];
		
		NSRect bgFrame = frame;
		bgFrame.origin.x += 3; bgFrame.origin.y += 3; bgFrame.size.width -= 6; bgFrame.size.height -= 5.5;
		[[CTGradient XPButtonGradient] fillRect:bgFrame angle:90.0];	
	}
	
	// border (blue - enabled, gray - disabled)
	[([self isEnabled] ? RGB(0.0, 60/255.0, 116/255.0) : RGB(201/255.0, 199/255.0, 186/255.0)) set];
	NSRect newFrame = frame;
	newFrame.origin.x += 0.5; newFrame.origin.y += 0.5; newFrame.size.width -= 1; newFrame.size.height -= 1;
	[[self bezierPathWithRoundRectInRect:newFrame withRadius:3.0] stroke];
	
}

- (void)mouseEntered:(NSEvent *)event
{
	_mouseHover = YES;
	[[self controlView] setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
	_mouseHover = NO;
	[[self controlView] setNeedsDisplay:YES];
}

@end
