//
//  BJVolume.m
//  Bookject
//
//  Created by Kevin Wojniak on 8/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BJVolume.h"
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <sys/param.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOBSD.h>
#include <IOKit/storage/IOMediaBSDClient.h>
#include <IOKit/storage/IOMedia.h>
#include <IOKit/storage/IOCDMedia.h>
#include <IOKit/storage/IOCDTypes.h>
#include <IOKit/storage/IOStorage.h>
#include <CoreFoundation/CoreFoundation.h>

@implementation BJVolume

+ (NSArray *)connectedVolumes
{
	NSMutableArray *volumes = [NSMutableArray array];
	
	struct statfs *buf;
	int i, count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		long flags = buf[i].f_flags;
		NSString *mountedPath = [NSString stringWithUTF8String:buf[i].f_mntonname];
		if ([mountedPath isEqualToString:@"/"] || [mountedPath isEqualToString:@"/dev"])
			continue;
		
		//NSLog(@"%s - %s - %s", buf[i].f_mntfromname, buf[i].f_mntonname, buf[i].f_fstypename);
		
		
		if ((flags & MNT_LOCAL) == MNT_LOCAL)
		{
			BJVolumeType type = 0;
			type |= BJDrive;
			
			// check for iPod
			if ([[NSFileManager defaultManager] fileExistsAtPath:[mountedPath stringByAppendingPathComponent:@"iPod_Control"]])
				type |= BJiPod;
			
			[volumes addObject:[BJVolume volumeWithMountedPath:mountedPath type:type]];
		}
	}

	return ([volumes count] > 0 ? volumes : nil);
}

+ (BJVolume *)volumeWithMountedPath:(NSString *)mountedPath type:(BJVolumeType)type
{
	return [[[self alloc] initWithMountedPath:mountedPath type:type] autorelease];
}

- (id)initWithMountedPath:(NSString *)mountedPath type:(BJVolumeType)type
{
	if (self = [super init])
	{
		_mountedPath = [mountedPath copy];
		_type = type;
	}
	
	return self;
}

- (void)dealloc
{
	[_mountedPath release];
	[super dealloc];
}

- (NSString *)mountedPath
{
	return [[_mountedPath copy] autorelease];
}

- (BOOL)isDrive
{
	return ((_type & BJDrive) == BJDrive);
}

- (BOOL)isiPod
{
	return ((_type & BJiPod) == BJiPod);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: is drive: %d; is iPod: %d;", [self mountedPath], [self isDrive], [self isiPod]];
}

@end
