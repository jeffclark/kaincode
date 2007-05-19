//
//  ReflectionView.m
//  ReflectionView
//
//  Created by Kevin Wojniak on 11/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ReflectionView.h"
#import "CTGradient.h"


NSRect KWCenterSizeInRect(NSSize size, NSRect bigRect)
{
	return NSMakeRect(floor((bigRect.size.width - size.width) / 2)+0.5, floor((bigRect.size.height - size.height) / 2)+0.5, size.width, size.height);
}


@interface CTGradient (refl)
+ (CTGradient *)reflectionGradientForColor:(NSColor *)color;
@end

@implementation CTGradient (refl)
+ (CTGradient *)reflectionGradientForColor:(NSColor *)color
{
	id newInstance = [[CTGradient alloc] init];
	
	CTGradientElement color1;
	color1.red   = 1.0;
	color1.green = color1.red;
	color1.blue  = color1.red;
	color1.alpha = 0.0;
	color1.position = 1;
	
	NSColor *ccolor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CTGradientElement color2;
	color2.red   = [ccolor redComponent];
	color2.green = [ccolor greenComponent];
	color2.blue  = [ccolor blueComponent];
	color2.alpha = 1.00;
	color2.position = 0.5;

	CTGradientElement color3;
	color3.red   = color2.red;
	color3.green = color2.green;
	color3.blue  = color2.blue;
	color3.alpha = color2.alpha;
	color3.position = 0;	
	
	[newInstance addElement:&color2];
	[newInstance addElement:&color1];
	
	return [newInstance autorelease];
}	
@end



@implementation ReflectionView

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setImage:[NSImage imageNamed:@"groban"]];
		_bgColor = [[NSColor colorWithCalibratedRed:0.4902 green:0.6078 blue:0.7569 alpha:1.0] retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_img release];
	[_bgColor release];
	[super dealloc];
}

- (void)awakeFromNib
{
	NSColorPanel *cp = [NSColorPanel sharedColorPanel];
	[cp setTarget:self];
	[cp setAction:@selector(chooseColor:)];
	[cp setColor:_bgColor];
	[cp makeKeyAndOrderFront:nil];
}

- (void)chooseColor:(id)sender
{
	[_bgColor release];
	_bgColor = [[sender color] copy];
	[self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)image
{
	if (_img != image)
	{
		[_img release];
		_img = [image retain];
		
		NSImageRep *imgRep = [[_img representations] objectAtIndex:0];
		NSSize size = NSMakeSize([imgRep pixelsWide], [imgRep pixelsHigh]);
		[_img setSize:size];
	}

	[self setNeedsDisplay:YES];
}

- (IBAction)chooseImage:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	if ([op runModalForTypes:[NSImage imageFileTypes]] == NSOKButton)
	{
		NSImage *img = [[NSImage alloc] initWithContentsOfFile:[op filename]];
		if (img)
		{
			[self setImage:img];
		}
	}
}

- (void)drawRect:(NSRect)rect
{
	float offset = floor([_img size].height/2);
	NSRect centerRect = KWCenterSizeInRect([_img size], [self bounds]);
	NSRect reflectionRect = centerRect;
	centerRect = NSOffsetRect(centerRect, 0, offset);
	reflectionRect = NSOffsetRect(reflectionRect, 0, -offset-0.5);

	[_bgColor set];
	NSRectFill([self bounds]);
	
	[_img drawInRect:centerRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	//[[NSColor blackColor] set];
	//[NSBezierPath strokeRect:centerRect];
	
	NSPoint op = NSMakePoint(NSMidX(reflectionRect), NSMidY(reflectionRect));
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSAffineTransform *at = [NSAffineTransform transform];
	[at translateXBy:op.x yBy:op.y];
	[at scaleXBy:1.0 yBy:-1.0];
	[at translateXBy:-op.x yBy:-op.y];
	[at concat];
	[_img drawInRect:reflectionRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.6];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	reflectionRect.origin.x -= 1; reflectionRect.size.width += 2;
	[[CTGradient reflectionGradientForColor:_bgColor] fillRect:reflectionRect angle:90.0];
}

@end
