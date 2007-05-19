//
//  TSPeriodDay.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TSPeriodDay : NSObject
{
	NSMutableArray *_periods;
	
}

- (NSMutableArray *)periods;

- (NSCalendarDate *)start;

- (int)numberOfItems;
- (unsigned long long)totalSeconds;

@end
