//
//  KWXfirePlugin.m
//  Adium
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "KWXfirePlugin.h"
#import "KWXfireService.h"

#import "AIAdium.h"

@implementation KWXfirePlugin

- (void)installPlugin
{
	/*Class aiadium = NSClassFromString(@"AIAdium");
	NSDate *buildDate = [aiadium buildDate];
	NSDate *now = [NSDate date];
	if ([now laterDate
	NSLog(@"buildDate: %@", buildDate);*/
	
	[[KWXfireService alloc] init];
}

@end
