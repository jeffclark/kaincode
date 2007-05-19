//
//  Controller.m
//  ScrollingTextView
//
//  Created by Kevin Wojniak on 5/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "KWScrollingTextView.h"


@implementation Controller

- (void)awakeFromNib
{
	[textView readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"rtf"]];
	[textView startScrollingWithInitialDelay:1.5];
}

@end
