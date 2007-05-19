//
//  BJController.h
//  Bookject
//
//  Created by Kevin Wojniak on 8/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BJBatteryNotifier.h"

@interface BJController : NSObject <BJBatteryNotifierDelegate>
{
	BJBatteryNotifier *_notifier;
}



@end
