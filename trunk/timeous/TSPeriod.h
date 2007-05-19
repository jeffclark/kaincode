//
//  TSPeriod.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSPeriodDay;

@interface TSPeriod : NSObject
{
	NSCalendarDate *_start, *_end;
	TSPeriodDay *_day;
	NSString *_notes;
}

- (NSCalendarDate *)start;
- (void)setStart:(NSCalendarDate *)date;

- (NSCalendarDate *)end;
- (void)setEnd:(NSCalendarDate *)date;

- (NSString *)notes;
- (void)setNotes:(NSString *)notes;


- (int)numberOfItems;

- (unsigned long long)totalSeconds;

- (TSPeriodDay *)day;
- (void)setDay:(TSPeriodDay *)day;

@end
