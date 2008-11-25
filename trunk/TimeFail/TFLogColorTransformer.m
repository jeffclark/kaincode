//
//  TFLogColorTransformer.m
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "TFLogColorTransformer.h"
#import "TFLog.h"


@implementation TFLogColorTransformer

+ (Class)transformedValueClass
{
    return [NSColor class];
}

- (id)transformedValue:(TFLog *)value
{
	switch (value.logType) {
		case TFLogTypeError:
			return [NSColor redColor];
		case TFLogTypeSuccess:
			return [NSColor blueColor];
	}
	
	return  [NSColor blackColor];
}

@end
