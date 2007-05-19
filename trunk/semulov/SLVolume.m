//
//  SLVolume.m
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SLVolume.h"
#include <DiskArbitration/DiskArbitration.h>


@implementation SLVolume

+ (NSArray *)allVolumes
{
	NSMutableArray *volumes = [NSMutableArray array];
	
	struct statfs *buf;
	int i, count;
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		SLVolume *vol = [[SLVolume alloc] initWithStatfs:&buf[i]];
		if (vol)
		{
			[volumes addObject:vol];
			[vol release];
		}
	}
	
	[volumes sortUsingSelector:@selector(compare:)];
	
	return volumes;
}

- (id)initWithStatfs:(struct statfs *)statfs
{
	if (self = [super init])
	{
		NSString *path = [NSString stringWithUTF8String:statfs->f_mntonname];
		if (!([path isEqualToString:@"/"] || [path hasPrefix:@"/Volumes"]))
		{
			[self release];
			return nil;
		}
		
		if ((statfs->f_flags & MNT_LOCAL) == MNT_LOCAL)
			_local = YES;
		if ((statfs->f_flags & MNT_ROOTFS) == MNT_ROOTFS)
			_root = YES;
		
		_path = [path copy];		
		_name = [[[NSFileManager defaultManager] displayNameAtPath:path] copy];
		_image = [[[NSWorkspace sharedWorkspace] iconForFile:path] copy];		

		/* for use with FSGetVolumeInfo
		 > filesystemID    signature    format
		 >     0            'BD'        HFS
		 >     0            'H+'        HFS+
		 >     0            0xD2D7        MFS
		 >     0            'AG'        ISO 9960
		 >     0            'BB'        High Sierra
		 >     'cu'        'JH'        Audio CD
		 >     0x55DF        0x75DF        DVD-ROM
		 >     'as'        any            above formats over AppleShare
		 >     'IS'        'BD'        MS-DOS
		 */
		
		if (![self isLocal])
		{
			_type = SLVolumeNetwork;
			
			FSRef ref;
			if (FSPathMakeRef((const unsigned char *)[[self path] fileSystemRepresentation], &ref, NULL) == noErr)
			{
				FSCatalogInfo catalogInfo;
				if (FSGetCatalogInfo (&ref, kFSCatInfoVolume, &catalogInfo, NULL, NULL, NULL) == noErr)
				{
					CFURLRef hostURL = NULL;
					FSCopyURLForVolume(catalogInfo.volume, &hostURL);
					if (hostURL)
					{
						_hostURL = [[(NSURL *)hostURL copy] autorelease];
						CFRelease(hostURL);
						
						if ([[_hostURL host] isEqualToString:@"idisk.mac.com"])
							_type = SLVolumeiDisk;
						else if ([[_hostURL scheme] isEqualToString:@"ftp"])
							_type = SLVolumeFTP;
						else
							NSLog(@"uknown URL: %@", _hostURL);
					}
				}
			}
		}
		else
		{
			if ([self isRoot])
				_type = SLVolumeRoot;
			else if ([self isiPod])
				_type = SLVolumeiPod;
			else
				_type = SLVolumeDrive;
			
			
			DASessionRef session = DASessionCreate(kCFAllocatorDefault);
			if (session)
			{
				DADiskRef disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, statfs->f_mntfromname);
				if (disk)
				{
					CFDictionaryRef desc = DADiskCopyDescription(disk);
					if (desc)
					{
						CFBooleanRef isInternal, isEjectable;
						CFDictionaryGetValueIfPresent(desc, kDADiskDescriptionDeviceInternalKey, (void *)&isInternal);
						CFDictionaryGetValueIfPresent(desc, kDADiskDescriptionMediaEjectableKey, (void *)&isEjectable);
						
						if (isInternal == kCFBooleanTrue && isEjectable == kCFBooleanFalse)
							_internal = YES;
					}
					CFRelease(disk);
				}
				CFRelease(session);
			}
		}
	}
	
	return self;
}

- (void)dealloc
{
	[_path release];
	[_name release];
	[_image release];

	[super dealloc];
}

- (NSString *)path
{
	return [[_path copy] autorelease];
}

- (NSString *)name
{
	return [[_name copy] autorelease];
}

- (NSImage *)image
{
	return [[_image copy] autorelease];
}

- (BOOL)isLocal
{
	return _local;
}

- (BOOL)isRoot
{
	return _root;
}

- (BOOL)eject
{
	BOOL ret = NO;
	
	ret = [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:[self path]];
	
	if (!ret)
	{
		FSRef ref;
		if (FSPathMakeRef((const unsigned char *)[[self path] fileSystemRepresentation], &ref, NULL) == noErr)
		{
			FSCatalogInfo catalogInfo;
			if (FSGetCatalogInfo (&ref, kFSCatInfoVolume, &catalogInfo, NULL, NULL, NULL) == noErr)
			{
				pid_t *dissenter;
				if (FSUnmountVolumeSync(catalogInfo.volume, 0, dissenter) == noErr)
					ret = YES;
			}
		}
	}
	
	return ret;
}

- (BOOL)showInFinder
{
	return [[NSWorkspace sharedWorkspace] openFile:[self path]];
}

- (SLVolumeType)type
{
	return _type;
}

- (NSURL *)hostURL
{
	return [[_hostURL copy] autorelease];
}

- (BOOL)isInternalHardDrive
{
	return _internal;
}

- (BOOL)isiPod
{
	BOOL isDir;
	return ([[NSFileManager defaultManager] fileExistsAtPath:[[self path] stringByAppendingPathComponent:@"iPod_Control"] isDirectory:&isDir] && isDir);
}

- (NSComparisonResult)compare:(SLVolume *)b
{
	if ([self type] == [b type])
		return [[self name] caseInsensitiveCompare:[b name]];
	if ([self type] < [b type])
		return NSOrderedAscending;
	else if ([self type] > [b type])
		return NSOrderedDescending;
	return NSOrderedSame;
}

@end
