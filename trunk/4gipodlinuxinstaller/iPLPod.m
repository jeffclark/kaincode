//
//  iPLPod.m
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "iPLPod.h"
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>

@interface iPLPod (priv)
- (int)deviceIDForVolumePath:(NSString *)volumePath;
- (NSString *)mountedFileSystemForVolumePath:(NSString *)volume;
- (void)loadDeviceID;
- (void)loadGeneration;
@end


@implementation iPLPod

- (id)initWithPath:(NSString *)path
{
	if (self = [super init])
	{
		_path = [path copy];
		_img = [[[NSWorkspace sharedWorkspace] iconForFile:_path] retain];
		
		[self loadGeneration];
		[self loadDeviceID];
	}
	
	return self;
}

- (void)dealloc
{
	[_path release];
	[_img release];
	
	[super dealloc];
}


- (NSString *)mountedFileSystemForVolumePath:(NSString *)volume
{
	struct statfs *buf;
	int i, count;
	const char *vol = [volume UTF8String];
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		if (strcmp(buf[i].f_mntonname, vol) == 0)
		{
			// load FAT32
			if (strcmp(buf[i].f_fstypename, "msdos") == 0)
				_fat32 = YES;
			else
				_fat32 = NO;
			
			return [NSString stringWithUTF8String:buf[i].f_mntfromname];
		}
	}
	return nil;
}

- (int)deviceIDForVolumePath:(NSString *)volumePath
{
	NSString *mfs = [self mountedFileSystemForVolumePath:volumePath];
	if (mfs && [mfs hasPrefix:@"/dev/disk"] && [mfs length] > 9)
	{
		return [[mfs substringWithRange:NSMakeRange(9, 1)] intValue];
	}
	
	return -1;      
}

- (void)loadDeviceID
{
	_deviceID = [self deviceIDForVolumePath:[self path]];
	
	//NSLog(@"_deviceID: %d (%@)", _deviceID, [self name]);
	
	/*NSTask *task = [[[NSTask alloc] init] autorelease];
	NSPipe *inPipe = [NSPipe pipe], *outPipe = [NSPipe pipe];
	NSFileHandle *outHandle = [outPipe fileHandleForReading];
	
	NSData *output = nil;
	
	[task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"deviceid" ofType:@"pl"]];
	[task setStandardError:outPipe];
	[task setStandardOutput:outPipe];
	[task setStandardInput:inPipe];
	[task setArguments:[NSArray arrayWithObject:[self path]]];
	
	[task launch];
	output = [outHandle readDataToEndOfFile];
	
	[task waitUntilExit];
	
	if (output != nil)
	{
		NSString *temp = [[[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding] autorelease];
		if (temp != nil && [temp length] > 0)
		{
			_deviceID = [temp intValue];
		}
		else
		{
			_deviceID = -1;
		}
	}*/
}

- (void)loadGeneration
{
	NSTask *task = [[[NSTask alloc] init] autorelease];
	NSPipe *inPipe = [NSPipe pipe], *outPipe = [NSPipe pipe];
	NSFileHandle *inHandle = [inPipe fileHandleForWriting], *outHandle = [outPipe fileHandleForReading];
	NSData  *sysInfo = [NSData dataWithContentsOfFile:[[self path] stringByAppendingPathComponent:@"iPod_Control/Device/SysInfo"]];

	if (sysInfo != nil)
	{
		NSData *output = nil;
		
		[task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"podgen" ofType:@"pl"]];
		[task setStandardError:outPipe];
		[task setStandardOutput:outPipe];
		[task setStandardInput:inPipe];
		
		[task launch];
		[inHandle writeData:sysInfo];
		[inHandle closeFile];
		output = [outHandle readDataToEndOfFile];
		
		[task waitUntilExit];
		
		if (output != nil)
		{
			NSString *gen = [[[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding] autorelease];
			if (gen != nil)
			{
				switch ([gen intValue])
				{
					case 1:
					case 2:
					case 3:
						podgen = iPLPod123G;
						break;
					case 4:
					case 7:
						podgen = iPLPodMini;
						break;
					case 5:
						podgen = iPLPodFourthBW;
						break;
					case 6:
						podgen = iPLPodColor;
						break;
					default:
						podgen = iPLPodOther;
				}
				
				return;
			}
		}
	}
		
	podgen = iPLPodOther;
}

- (NSString *)path
{
	return _path;
}

- (NSString *)name
{
	return [[self path] lastPathComponent];
}

- (iPLPodGeneration)iPodGeneration
{
	return podgen;
}

- (int)deviceID
{
	return _deviceID;
}

- (BOOL)FAT32
{
	return _fat32;
}

- (NSImage *)image
{
	return _img;
}

@end
