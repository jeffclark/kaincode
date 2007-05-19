//
//  NSTaskXtra.m
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/14/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSTaskXtra.h"


@implementation NSTask (NSTaskXtra)

+ (NSData *)runTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments inputData:(NSData *)inputData
{
	return [NSTask runTaskWithLaunchPath:path arguments:arguments inputData:inputData currentDirectory:nil];
}

+ (NSData *)runTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments inputData:(NSData *)inputData currentDirectory:(NSString *)currentDirectory
{
	NSTask *task = [[[NSTask alloc] init] autorelease];
	NSPipe *inPipe = [NSPipe pipe], *outPipe = [NSPipe pipe];
	NSFileHandle *inHandle = [inPipe fileHandleForWriting], *outHandle = [outPipe fileHandleForReading];
	NSData *output = nil;
	
	[task setLaunchPath:path];
	[task setStandardError:outPipe];
	[task setStandardOutput:outPipe];
	[task setStandardInput:inPipe];
	[task setArguments:arguments];
	if (currentDirectory != nil)
		[task setCurrentDirectoryPath:currentDirectory];
	
	[task launch];
	if (inputData)
	{
		[inHandle writeData:inputData];
		[inHandle closeFile];
	}
	output = [outHandle readDataToEndOfFile];
	
	[task waitUntilExit];
	
	return output;	
}

@end
