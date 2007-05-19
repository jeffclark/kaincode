//
//  Controller.m
//  XPControls
//
//  Created by Kevin Wojniak on 11/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"


@implementation Controller

- (IBAction)toggle:(id)sender
{
	[applyButton setEnabled:![applyButton isEnabled]];
}

- (IBAction)ok:(id)sender
{
	NSRunAlertPanel(@"OK",@":)",@"OK",nil,nil);
}

- (IBAction)cancel:(id)sender
{
	NSRunAlertPanel(@"Cancel",@":(",@"OK",nil,nil);
}

@end
