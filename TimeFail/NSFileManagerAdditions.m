//
//  NSFileManagerAdditions.m
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "NSFileManagerAdditions.h"


@implementation NSFileManager (NSFileManagerAdditions)

- (NSEnumerator *)lineEnumeratorWithContentsOfFile:(NSString *)path
{
	NSString *str = [NSString stringWithContentsOfFile:path];
	return [[str componentsSeparatedByString:@"\n"] objectEnumerator];
}

@end
