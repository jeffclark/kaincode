//
//  BJBatteryNotifier.h
//  Bookject
//
//  Created by Kevin Wojniak on 8/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BJBatteryNotifierDelegate
- (void)powerDidSwitchToBattery;
- (void)powerDidSwitchToACAdapter;
@end


@interface BJBatteryNotifier : NSObject
{
	id <BJBatteryNotifierDelegate> _delegate;
	BOOL _runningOnBattery;
}

- (id)initWithDelegate:(id <BJBatteryNotifierDelegate>)delegate;
- (BOOL)isRunningOnBattery;

@end
