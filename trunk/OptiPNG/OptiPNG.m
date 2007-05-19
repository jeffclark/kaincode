//
//  OptiPNG.m
//  OptiPNG
//
//  Created by Kevin Wojniak on 1/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "OptiPNG.h"
#import "optipng.c"


@implementation OptiPNG

- (void)optimizePNGFile:(NSString *)file
{
	opng_optimize_png([file fileSystemRepresentation]);
}

@end
