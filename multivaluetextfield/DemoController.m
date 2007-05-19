//
//  DemoController.m
//  KWMultiValueTextField
//
//  Created by Kevin Wojniak on 12/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DemoController.h"
#import "KWMultiValueTextField.h"


@implementation DemoController

- (void)awakeFromNib
{
	[textField setStringValues:[NSArray arrayWithObjects:
		@"Version 10.4.8",
		@"Build 8L2127",
		@"Serial Number XXXXXXXXXX",
		nil]];
}

@end
