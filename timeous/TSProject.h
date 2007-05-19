//
//  TSProject.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSPeriod, TSPeriodDay;

@interface TSProject : NSObject
{
	NSMutableArray *_periodDays;
	TSPeriod *_currentPeriod;
	NSString *_name;

	float _rate, _tax;
	
	int _uid;
}

- (NSMutableArray *)days;
- (TSPeriod *)currentPeriod;
- (void)setCurrentPeriod:(TSPeriod *)period;

- (NSString *)name;
- (void)setName:(NSString *)name;

- (float)rate;
- (void)setRate:(float)rate;
- (float)tax;
- (void)setTax:(float)tax;

- (unsigned long long)totalSeconds;

- (TSPeriodDay *)periodDayForToday;
- (TSPeriodDay *)periodDayForDate:(NSCalendarDate *)date;
- (TSPeriod *)startPeriodForDay:(TSPeriodDay *)day;

- (int)uid;
- (void)setUID:(int)uid;

@end
