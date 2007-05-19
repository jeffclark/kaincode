//
//  PieChartView.m
//  PieChart
//
//  Created by Kevin Wojniak on Tue Jun 08 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "PieChartView.h"


@implementation PieChartView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		centerPoint = NSMakePoint(0, 0);
		radius = 100;
		rotation = 2;
		dataString = [[NSString alloc] initWithString:@"10, 10, 45"];
    }
    return self;
}

- (void)dealloc
{
	[dataString release];
	[super dealloc];
}

- (void)setData:(NSString *)d
{
	[dataString release];
	[d retain];
	dataString = d;
	[self setNeedsDisplay:YES];
}

- (void)setRotation:(int)r
{
	rotation = r;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	
	NSArray *data = [dataString componentsSeparatedByString:@","];
	NSEnumerator *e = [data objectEnumerator];
	NSPoint currentPoint;
	id item;
	int i=0;
	NSArray *colors = [NSArray arrayWithObjects:[NSColor redColor], [NSColor greenColor], [NSColor blueColor], [NSColor magentaColor], [NSColor cyanColor], [NSColor orangeColor], [NSColor yellowColor], [NSColor brownColor], [NSColor grayColor], nil];
	
	centerPoint = NSMakePoint(bounds.size.width/2, bounds.size.height/2);
	
	int dataTotal = [self totalForData:data];
	int startAngle = rotation, endAngle;
	
	currentPoint = [self pointForAngle:startAngle];
	
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	while (item = [e nextObject]) {
		NSBezierPath *pie = [NSBezierPath bezierPath];
		//NSAffineTransform *transform = [NSAffineTransform transform];

		// draw line from starting angle to where angle begins
		[pie moveToPoint:centerPoint];
		[pie lineToPoint:currentPoint];
		
		// draw arc
		endAngle = (int)[self angleForPercent:[item floatValue]/dataTotal]+startAngle;
		if (i==[data count]-1)
			endAngle += fabs((360+rotation)-endAngle); // make sure it fills full circle on last wedge
		[pie appendBezierPathWithArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle];
		
		currentPoint = [pie currentPoint];
		startAngle = endAngle;
		
		// draw line from end of arc to center
		[pie lineToPoint:centerPoint];
		[pie closePath];
		
		[[colors objectAtIndex:i] set];
		
		//[transform scaleBy:rotation];
		//[pie transformUsingAffineTransform:transform];
		
		[pie fill];
			
		i++;
	}
}

- (int)totalForData:(NSArray *)d
{
	int t=0, i;
	for (i=0; i<[d count]; i++)
		t+=[[d objectAtIndex:i] intValue];
	return t;
}

- (float)angleForPercent:(float)percent
{
	return 360*percent;
}

- (NSPoint)pointForAngle:(int)a
{
	NSBezierPath *p = [NSBezierPath bezierPath];
	[p appendBezierPathWithArcWithCenter:centerPoint radius:radius startAngle:a endAngle:a];
	return [p currentPoint];
}

@end
