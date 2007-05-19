//
//  Controller.m
//  GoogleSMS
//
//  Created by Kevin Wojniak on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "GoogleSMS.h"

@implementation Controller

- (void)awakeFromNib
{
	[GoogleSMS sendMessage:@"testing5959" toPhone:@"XXXXXXXXXX" forCarrier:gVerizon];
}

@end
