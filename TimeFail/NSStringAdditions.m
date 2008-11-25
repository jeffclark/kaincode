//
//  NSStringAdditions.m
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "NSStringAdditions.h"


@implementation NSString (NSStringAdditions)

- (BOOL)containsString:(NSString *)string
{
	return ([self rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound ? YES : NO);
}

@end
