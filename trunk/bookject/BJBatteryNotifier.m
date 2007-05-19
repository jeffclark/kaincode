//
//  BJBatteryNotifier.m
//  Bookject
//
//  Created by Kevin Wojniak on 8/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BJBatteryNotifier.h"
#import <IOKit/ps/IOPowerSources.h>

@interface BJBatteryNotifier (priv)
- (BOOL)getRunningOnBatteryValue;
@end

@implementation BJBatteryNotifier

- (id)initWithDelegate:(id <BJBatteryNotifierDelegate>)delegate
{
	if (self = [super init])
	{
		_delegate = delegate;
		_runningOnBattery = [self getRunningOnBatteryValue];
		
		[NSTimer scheduledTimerWithTimeInterval:0.25
										 target:self
									   selector:@selector(checkBattery:)
									   userInfo:nil
										repeats:YES];
	}
	
	return self;
}

- (void)dealloc
{
	_delegate = nil;
	[super dealloc];
}

- (BOOL)getRunningOnBatteryValue
{
	NSEnumerator *enumerator = [(NSArray *)IOPSCopyPowerSourcesList(IOPSCopyPowerSourcesInfo()) objectEnumerator];
	CFTypeRef sourceRef;
	NSDictionary *sourceData;
	while (sourceRef = [enumerator nextObject])
	{
		sourceData = (NSDictionary *)IOPSGetPowerSourceDescription(IOPSCopyPowerSourcesInfo(), sourceRef);
		if ([[sourceData objectForKey:@"Transport Type"] isEqualToString:@"Internal"] &&
			[[sourceData objectForKey:@"Power Source State"] isEqualToString:@"Battery Power"])
			return YES;
	}
	return NO;
}

- (void)checkBattery:(NSTimer *)timer
{
	BOOL runningOnBatt = [self getRunningOnBatteryValue];
	if (_runningOnBattery != runningOnBatt)
	{
		_runningOnBattery = runningOnBatt;
		
		if (_runningOnBattery)
			[_delegate powerDidSwitchToBattery];
		else
			[_delegate powerDidSwitchToACAdapter];
	}
}

- (BOOL)isRunningOnBattery
{
	return _runningOnBattery;
}

@end
