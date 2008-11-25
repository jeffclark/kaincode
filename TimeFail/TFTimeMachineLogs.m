//
//  TFTimeMachineLogs.m
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "TFTimeMachineLogs.h"
#import "TFLog.h"
#import "NSStringAdditions.h"
#import "NSFileManagerAdditions.h"

@implementation TFTimeMachineLogs

+ (NSArray *)logs
{
	NSMutableArray *logs = [NSMutableArray array];
	
	NSEnumerator *linesEnum = [[NSFileManager defaultManager] lineEnumeratorWithContentsOfFile:@"/var/log/system.log"];
	NSString *line = nil;
	while (line = [linesEnum nextObject])
	{
		if ([line containsString:@"/System/Library/CoreServices/backupd"] && ![line containsString:@"TimeFail"])
		{
			NSRange dividerRange = [line rangeOfString:@": "];
			NSString *msg = [line substringFromIndex:(dividerRange.location + dividerRange.length)];
			BOOL isError = [msg containsString:@"Error:"];
			BOOL isSuccess = [msg containsString:@"Successfully"];
			
			TFLog *log = [[[TFLog alloc] init] autorelease];
			TFLogType logType = TFLogTypeNormal;
			if (isError)
				logType = TFLogTypeError;
			else if (isSuccess)
				logType = TFLogTypeSuccess;
			log.message = msg;
			log.logType = logType;
			[logs addObject:log];
		}
	}
	
	return ([logs count] ? logs : nil);
}

@end
