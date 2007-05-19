//
//  TSPeriodDay.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSPeriodDay.h"
#import "TSPeriod.h"

@implementation TSPeriodDay

- (id)init
{
	if (self = [super init])
	{
		_periods = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_periods release];
	[super dealloc];
}

- (NSMutableArray *)periods
{
	return _periods;
}

- (NSCalendarDate *)start
{
	NSCalendarDate *date = ([[self periods] count] == 0 ? nil : [[[self periods] objectAtIndex:0] start]);
	if (date == nil)
		return nil;
	
	return [NSCalendarDate dateWithYear:[date yearOfCommonEra]
								  month:[date monthOfYear]
									day:[date dayOfMonth]
								   hour:0
								 minute:0
								 second:0
							   timeZone:[date timeZone]];
}

- (int)numberOfItems
{
	return [[self periods] count];
}

- (unsigned long long)totalSeconds
{
	unsigned long long total = 0;
	int i;
	for (i=0; i<[[self periods] count]; i++)
		total += [[[self periods] objectAtIndex:i] totalSeconds];
	return total;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%d periods", [[self periods] count]];
}

@end
