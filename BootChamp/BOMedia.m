//
//  BOMedia.m
//  BootChamp
//
//  Created by Kevin Wojniak on 9/9/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "BOMedia.h"


@implementation BOMedia

@synthesize mountPoint, deviceName, name;

- (void)dealloc
{
	self.mountPoint = nil;
	self.deviceName = nil;
	self.name = nil;
	[super dealloc];
}

@end
