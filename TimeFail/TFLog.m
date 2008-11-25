//
//  TFLog.m
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "TFLog.h"


@implementation TFLog

@synthesize message = m_message;
@synthesize logType = m_logType;

- (void)dealloc
{
	self.message = nil;
	[super dealloc];
}

@end
