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
	NSError *error = nil;
	NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	return [[str componentsSeparatedByString:@"\n"] objectEnumerator];
}

@end
