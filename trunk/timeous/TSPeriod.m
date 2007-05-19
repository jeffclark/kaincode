//
//  TSPeriod.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSPeriod.h"


@implementation TSPeriod

- (id)init
{
	if (self = [super init])
	{
		[self setStart:[NSCalendarDate calendarDate]];
		[self setEnd:nil];
		[self setDay:nil];
		_notes = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[self setStart:nil];
	[self setEnd:nil];
	[self setDay:nil];
	[_notes release];
	[super dealloc];
}

- (NSCalendarDate *)start
{
	return _start;
}

- (void)setStart:(NSCalendarDate *)date
{
	if (_start != date)
	{
		[_start release];
		_start = [date copy];
	}
}

- (NSCalendarDate *)end
{
	return _end;
}

- (void)setEnd:(NSCalendarDate *)date
{
	if (_end != date)
	{
		[_end release];
		_end = [date copy];
	}
}

- (NSString *)notes
{
	return _notes;
}

- (void)setNotes:(NSString *)notes
{
	if (_notes != notes)
	{
		[_notes release];
		_notes = [notes retain];
	}
}

- (int)numberOfItems
{
	return 0;
}

- (unsigned long long)totalSeconds
{
	return (unsigned long long)[[self end] timeIntervalSinceDate:[self start]];
}

- (TSPeriodDay *)day
{
	return _day;
}

- (void)setDay:(TSPeriodDay *)day
{
	_day = day;
}

@end
