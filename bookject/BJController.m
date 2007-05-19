//
//  BJController.m
//  Bookject
//
//  Created by Kevin Wojniak on 8/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BJController.h"
#import "BJVolume.h"

@implementation BJController

- (id)init
{
	if (self = [super init])
	{
		_notifier = [[BJBatteryNotifier alloc] initWithDelegate:self];
		
		NSLog(@"volumes: %@", [BJVolume connectedVolumes]);
	}
	
	return self;
}

- (void)dealloc
{
	[_notifier release];
	[super dealloc];
}

- (void)powerDidSwitchToBattery
{
	NSLog(@"Now running on battery!");
}
- (void)powerDidSwitchToACAdapter
{
	NSLog(@"Now running on AC adapter!");
}


@end
