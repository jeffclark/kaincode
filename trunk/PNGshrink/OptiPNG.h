//
//  OptiPNG.h
//  PNGshrink
//
//  Created by Kevin Wojniak on 1/2/10.
//  Copyright 2010 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "optipng-0.6.3/src/optipng.h"


@interface OptiPNG : NSObject
{
	NSOperationQueue *queue;
	struct opng_options options;
}

- (void)processFiles:(NSArray *)files completionHandler:(void (^)())handler;

@end
