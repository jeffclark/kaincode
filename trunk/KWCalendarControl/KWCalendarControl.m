//
//  KWCalendarControl.m
//  KWCalendarControl
//
//  Created by Kevin Wojniak on 2/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWCalendarControl.h"
#import "KWCalendarControlCell.h"


@implementation KWCalendarControl

+ (Class)cellClass
{
	return [KWCalendarControlCell class];
}

- (IBAction)goToNextMonth:(id)sender
{
	[[self cell] goToNextMonth];
	[self setNeedsDisplay:YES];
}

- (IBAction)goToPreviousMonth:(id)sender
{
	[[self cell] goToPreviousMonth];
	[self setNeedsDisplay:YES];
}

@end
