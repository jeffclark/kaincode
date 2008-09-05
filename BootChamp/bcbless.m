/*
 *  bcbless.c
 *  BootChamp
 *
 *  Created by Kevin Wojniak on 9/5/08.
 *  Copyright 2008 Kainjow LLC. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

int executeTask(NSString *taskPath, NSArray *args, NSData **outputData)
{
	NSTask *task = nil;
	NSPipe *inPipe = nil, *outPipe = nil;
	NSFileHandle *inHandle = nil, *outHandle = nil;
	int status = noErr;
	
	if ((taskPath == nil) ||
		([[NSFileManager defaultManager] fileExistsAtPath:taskPath] == NO) ||
		([[NSFileManager defaultManager] isExecutableFileAtPath:taskPath] == NO))
	{
		// task doesn't exist or isn't executable!
		return 1;
	}
	
	task = [[NSTask alloc] init];
	[task setLaunchPath:taskPath];
	if ((args != nil) && ([args count] > 0))
	{
		[task setArguments:args];
	}
	
	// NSPipe can return nil
	outPipe = [[NSPipe alloc] init];
	if (outPipe != nil)
	{
		outHandle = [outPipe fileHandleForReading];
		[task setStandardOutput:outPipe];
		[task setStandardError:outPipe];
	}
	
	inPipe = [[NSPipe alloc] init];
	if (inPipe != nil)
	{
		inHandle = [inPipe fileHandleForWriting];
		[task setStandardInput:inPipe];
	}
	
	[task launch];
	
	if (inHandle != nil)
	{
		NSData *inputData = nil; // dummy
		if ((inputData != nil) && ([inputData length] > 0))
		{
			[inHandle writeData:inputData];
		}
		[inHandle closeFile];
	}
	
	if (outHandle != nil)
	{
		*outputData = [outHandle readDataToEndOfFile];
		[outHandle closeFile];
	}
	
	[task waitUntilExit];
	status = [task terminationStatus];
	
	[outPipe release];
	[inPipe release];
	[task release];
	
	return status;
}

void outputDict(NSDictionary *dict)
{
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
	NSString *plistStr = [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
	printf("%s", [plistStr UTF8String]);
	[plistStr release];
}

void outputSuccess(NSString *message)
{
	outputDict([NSDictionary dictionaryWithObject:message forKey:@"Success"]);
}

void outputError(NSString *message)
{
	outputDict([NSDictionary dictionaryWithObject:message forKey:@"Error"]);
}

int blessDevice(NSString *device, NSString **output)
{
	NSData *outputData = nil;
	NSArray *args = [NSArray arrayWithObjects:
					 @"--verbose",		// extra debug info in Console
					 @"--legacy",		// support for BIOS-based operating systems
					 @"--setBoot",		// boot it up
					 @"--nextonly",		// only change the boot disk for next boot
					 @"--device",
					 device,
					 nil];
	int status = noErr;
	
	status = executeTask(@"/usr/sbin/bless", args, &outputData);
	
	*output = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	
	return status;
}

int main(int argc, char *argv[])
{
	// bcbless -device <device>
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// NSUserDefaults can be used to read command line arguments in the format -option
	NSString *deviceToBless = [[NSUserDefaults standardUserDefaults] objectForKey:@"device"];
	if (!deviceToBless)
	{
		outputError(@"Missing device!");
		[pool release];
		exit(1);
	}
	
	NSString *blessOutput = nil;
	int status = blessDevice(deviceToBless, &blessOutput);
	if (status != noErr) {
		outputError(blessOutput);
		[pool release];
		exit(1);
	}

	outputSuccess(blessOutput);
	
	[pool release];
    return 0;
}

