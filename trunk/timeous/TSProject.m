//
//  TSProject.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSProject.h"
#import "TSPeriodDay.h"
#import "TSPeriod.h"


@implementation TSProject

- (id)init
{
	if (self = [super init])
	{
		_periodDays = [[NSMutableArray alloc] init];
		_name = [@"Untitled" retain];
		_rate = 0.0;
		_tax = 0.0;
		_uid = -1;
	}
	
	return self;
}

- (void)dealloc
{
	[_periodDays release];
	[_currentPeriod release];
	[_name release];

	[super dealloc];
}

- (NSMutableArray *)days
{
	return _periodDays;
}

- (TSPeriod *)currentPeriod
{
	return _currentPeriod;
}

- (void)setCurrentPeriod:(TSPeriod *)period
{
	if (_currentPeriod != period)
	{
		[_currentPeriod release];
		_currentPeriod = [period retain];
	}
}

- (NSString *)name
{
	return _name;
}

- (void)setName:(NSString *)name
{
	if (_name != name)
	{
		[_name release];
		_name = [name copy];
	}
}

- (float)rate
{
	return _rate;
}

- (void)setRate:(float)rate
{
	_rate = rate;
}

- (float)tax
{
	return _tax;
}

- (void)setTax:(float)tax
{
	_tax = tax;
}

- (unsigned long long)totalSeconds
{
	unsigned long long total = 0;
	int i;
	for (i=0; i<[[self days] count]; i++)
		total += [[[self days] objectAtIndex:i] totalSeconds];
	return total;
}

- (TSPeriodDay *)periodDayForToday
{
	return [self periodDayForDate:[[NSDate date] dateWithCalendarFormat:nil timeZone:nil]]; //[NSCalendarDate calendarDate]];
}

- (TSPeriodDay *)periodDayForDate:(NSCalendarDate *)date
{
	NSCalendarDate *today = [NSCalendarDate dateWithYear:[date yearOfCommonEra]
												   month:[date monthOfYear]
													 day:[date dayOfMonth]
													hour:0
												  minute:0
												  second:0
												timeZone:[date timeZone]];
	NSEnumerator *daysEnum = [[self days] objectEnumerator];
	TSPeriodDay *day;
	while (day = [daysEnum nextObject])
	{
		NSCalendarDate *start = [day start];
		if ([start dayOfMonth] == [today dayOfMonth] && 
			[start monthOfYear] == [today monthOfYear] && 
			[start yearOfCommonEra] == [today yearOfCommonEra])
			return day;
	}
	
	// got here because no new date exists, so create one
	day = [[TSPeriodDay alloc] init];
	[[self days] addObject:day];
	return [day autorelease];
}

- (TSPeriod *)startPeriodForDay:(TSPeriodDay *)day
{
	TSPeriod *period = [[TSPeriod alloc] init];
	[period setDay:day];
	[[day periods] addObject:period];
	
	return [period autorelease];
}

- (int)uid
{
	return _uid;
}

- (void)setUID:(int)uid
{
	_uid = uid;
}

@end
