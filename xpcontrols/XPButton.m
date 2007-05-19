//
//  XPButton.m
//  XPControls
//
//  Created by Kevin Wojniak on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XPButton.h"
#import "XPButtonCell.h"


@implementation XPButton

+ (Class)cellClass
{
	return [XPButtonCell class];
}

- (id)initWithCoder:(NSCoder *)origCoder
{
	if (![origCoder isKindOfClass: [NSKeyedUnarchiver class]])
	{
		self = [super initWithCoder: origCoder];
	}
	else
	{
		NSKeyedUnarchiver *coder = (id)origCoder;
		
		NSString *oldClassName = [[[self superclass] cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if(!oldClass)
			oldClass = [[super superclass] cellClass];
		[coder setClass: [[self class] cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
	}
	
	return self;
}

- (void)resetCursorRects
{
	[self removeTrackingRect:_trackingRect];
	_trackingRect = [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
}

- (void)mouseEntered:(NSEvent *)event
{
	[[self cell] mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event
{
	[[self cell] mouseExited:event];
}

@end
