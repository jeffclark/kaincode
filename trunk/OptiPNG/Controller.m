//
//  Controller.m
//  OptiPNG
//
//  Created by Kevin Wojniak on 1/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "OptiPNG.h"


@implementation Controller

- (IBAction)open:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	if ([op runModal] == NSOKButton)
	{
		NSString *file = [op filename];
		OptiPNG *opng = [[OptiPNG alloc] init];
		[opng optimizePNGFile:file];
		[opng release];
	}
}

@end
