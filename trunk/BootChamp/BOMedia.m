//
//  BOMedia.m
//  BootChamp
//
//  Created by Kevin Wojniak on 9/9/08.
//  Copyright 2008-2009 Kainjow LLC. All rights reserved.
//

#import "BOMedia.h"
#import <sys/mount.h>
#import <DiskArbitration/DiskArbitration.h>


@implementation BOMedia

@synthesize mountPoint, deviceName, name;

+ (NSArray *)allMedia
{
	DASessionRef session = DASessionCreate(kCFAllocatorDefault);
	if (!session)
	{
		NSLog(@"DASessionCreate failed.");
		return nil;
	}
	
#define NTFS_3G_KIND @"ntfs-3g"
	NSArray *allowedKinds = [NSArray arrayWithObjects:@"ntfs", @"msdos", @"ufsd", @"cd9660", NTFS_3G_KIND, nil];
	
	NSMutableArray *array = [NSMutableArray array];
	struct statfs *buf = NULL;
	int count = getmntinfo(&buf, 0);
	for (int i=0; i<count; i++)
	{
		const char *bsdName = buf[i].f_mntfromname;
		DADiskRef disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, bsdName);
		if (!disk)
		{
			NSLog(@"DADiskCreateFromBSDName failed for %s", bsdName);
			continue;
		}
		
		CFDictionaryRef desc = DADiskCopyDescription(disk);
		CFRelease(disk);
		if (!desc)
		{
			continue;
		}

		BOMedia *media = [[[BOMedia alloc] init] autorelease];
		
		BOOL isValidBootCampVolume = NO;
		
		NSString *volKind = (NSString *)CFDictionaryGetValue(desc, kDADiskDescriptionVolumeKindKey);
		NSURL *mountURL = (NSURL *)CFDictionaryGetValue(desc, kDADiskDescriptionVolumePathKey);

		for (NSString *kind in allowedKinds)
		{
			if ([kind rangeOfString:volKind options:NSCaseInsensitiveSearch].location != NSNotFound)
			{
				isValidBootCampVolume = YES;
				
				if ([kind isEqualToString:NTFS_3G_KIND])
				{
					// When NTFS-3G/MacFUSE is installed we need to use
					// bless's --device option instead of --folder
					// for some reason --folder doesn't work in this situation.
					media.deviceName = [NSString stringWithUTF8String:bsdName];
				}
				break;
			}
		}
		
		if (isValidBootCampVolume)
		{
			media.mountPoint = [mountURL path];
			media.name = [media.mountPoint lastPathComponent];
			[array addObject:media];
		}
		
		CFRelease(desc);
	}
	
	CFRelease(session);
	
	return array;
}

- (void)dealloc
{
	self.mountPoint = nil;
	self.deviceName = nil;
	self.name = nil;
	[super dealloc];
}

@end
