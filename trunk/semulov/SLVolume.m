//
//  SLVolume.m
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SLVolume.h"
#import <DiskArbitration/DiskArbitration.h>
#import <DVDPlayback/DVDPlayback.h>
#import <DiscRecording/DiscRecording.h>


static NSMutableDictionary *slValidDVDs;

@implementation SLVolume

+ (void)initialize
{
	slValidDVDs = [[NSMutableDictionary alloc] init];
}

+ (NSDictionary *)mountedDiskImages
{
	NSTask *hdiUtilTask = nil;
	NSPipe *inPipe = nil, *outPipe = nil;
	NSFileHandle *inHandle = nil, *outHandle = nil;
	NSData *outData = nil;
	NSString *plistStr = nil;
	
	hdiUtilTask = [[NSTask alloc] init];
	inPipe = [NSPipe pipe];
	inHandle = [inPipe fileHandleForWriting];
	outPipe = [NSPipe pipe];
	outHandle = [outPipe fileHandleForReading];
	
	if (!inPipe || !outPipe)
	{
		// couldn't get a pipe!
		return nil;
	}
	
	[hdiUtilTask setLaunchPath:@"/usr/bin/hdiutil"];
	[hdiUtilTask setArguments:[NSArray arrayWithObjects:@"info", @"-plist", nil]];
	[hdiUtilTask setStandardError:outPipe];
	[hdiUtilTask setStandardOutput:outPipe];
	[hdiUtilTask setStandardInput:inPipe];
	
	[inHandle closeFile];
	
	[hdiUtilTask launch];
	
	outData = [outHandle readDataToEndOfFile];
	[outHandle closeFile];

	[hdiUtilTask waitUntilExit];
	[hdiUtilTask release];
	
	plistStr = [[[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding] autorelease];
	if (plistStr == nil)
		return nil;
	
	// sometimes hdiutil returns an error in the first line or so of it's output.
	// so we try to determine if an error exists, and skip past it to the xml
	
	NSString *xmlStr = @"<?xml";
	NSRange xmlRange = [plistStr rangeOfString:xmlStr];
	if (xmlRange.location == NSNotFound)
	{
		// not valid xml?!
		return nil;
	}
	if (xmlRange.location > 0)
	{
		// scan up to XML
		NSScanner *scanner = [NSScanner scannerWithString:plistStr];
		[scanner scanUpToString:xmlStr intoString:nil];
		plistStr = [plistStr substringFromIndex:[scanner scanLocation]];
	}

	NSDictionary *plistDict = [plistStr propertyList];
	if ((plistDict == nil) || ([plistDict isKindOfClass:[NSDictionary class]] == NO))
		return nil;
	
	NSMutableDictionary *mountPoints = [NSMutableDictionary dictionary];
	NSEnumerator *plistEnum = [[plistDict objectForKey:@"images"] objectEnumerator];
	NSDictionary *imagesDict = nil;
	while (imagesDict = [plistEnum nextObject])
	{
		NSString *imagePath = [imagesDict objectForKey:@"image-path"];
		NSEnumerator *sysEntitiesEnum = [[imagesDict objectForKey:@"system-entities"] objectEnumerator];
		NSDictionary *sysEntity = nil;
		
		// if .dmg is mounted from safari, imagePath will be the .dmg within the .download file
		NSRange dotDownloadRange = [imagePath rangeOfString:@".download"];
		if (dotDownloadRange.location != NSNotFound)
			imagePath = [imagePath substringToIndex:dotDownloadRange.location];
		
		while (sysEntity = [sysEntitiesEnum nextObject])
		{
			NSString *mountPoint = [sysEntity objectForKey:@"mount-point"];
			
			if ((imagePath != nil) && (mountPoint != nil))
			{
				[mountPoints setObject:imagePath forKey:mountPoint];
			}
		}
	}
	
	return ([mountPoints count] ? mountPoints : nil);
}

+ (NSArray *)allVolumes
{
	NSMutableArray *volumes = [NSMutableArray array];
	
	struct statfs *buf;
	int i, count;
	
	NSDictionary *diskImages = [SLVolume mountedDiskImages];
	
	DVDInitialize();
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		SLVolume *vol = [[SLVolume alloc] initWithStatfs:&buf[i] mountedDiskImages:diskImages];
		if (vol)
		{
			[volumes addObject:vol];
			[vol release];
		}
	}
	
	DVDDispose();
	
	[volumes sortUsingSelector:@selector(compare:)];
	
	return volumes;
}

- (id)initWithStatfs:(struct statfs *)statfs mountedDiskImages:(NSDictionary *)diskImages
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

		BOOL gotCatalogInfo = NO;
		FSRef ref;
		CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:[self path]], &ref);
		FSCatalogInfo catalogInfo;
		gotCatalogInfo = (FSGetCatalogInfo(&ref, kFSCatInfoVolume, &catalogInfo, NULL, NULL, NULL) == noErr);
		
		if ([self isLocal] == NO)
		{
			_type = SLVolumeNetwork;
			
			if (gotCatalogInfo)
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
					{
						if (strcmp("webdav", statfs->f_fstypename) == 0)
						{
							_type = SLVolumeWebDAV;
						}
						else
						{
							NSLog(@"uknown URL: %@", _hostURL);
						}
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
			
			if (diskImages != nil)
			{
				NSString *imgPath = [diskImages objectForKey:[self path]];
				if (imgPath)
				{
					_imagePath = [imgPath retain];
					_type = SLVolumeDiskImage;
				}
			}

			if (gotCatalogInfo)
			{
				// for use with FSGetVolumeInfo
				//> filesystemID    signature    format
				//>     0            'BD'        HFS
				//>     0            'H+'        HFS+
				//>     0            0xD2D7        MFS
				//>     0            'AG'        ISO 9960
				//					(0x4147)		'
				//		'cu'			'			'
				//		(0x6375)
				//>     0            'BB'        High Sierra
				//>     'cu'        'JH'        Audio CD
				//>     0x55DF        0x75DF        DVD-ROM
				//>     'as'        any            above formats over AppleShare
				//>     'IS'        'BD'        MS-DOS
				
				//		0			0x482B		disk image
				//		0			0x4244		cd-rom
				//	0x4A48 (JH)		0x4244 (BD)
				
				
				FSVolumeInfo volumeInfo;
				if (FSGetVolumeInfo(catalogInfo.volume, 0, NULL, kFSVolInfoFSInfo, &volumeInfo, NULL, NULL) == noErr)
				{
					if (((volumeInfo.filesystemID == 0) && (volumeInfo.signature == 0x4244)) ||
						((volumeInfo.filesystemID == 0x6375) && (volumeInfo.signature == 0x4147)))
					{
						_type = SLVolumeCDROM;
					}
					else if ((volumeInfo.filesystemID == 0x4A48) && (volumeInfo.signature == 0x4244))
					{
						_type = SLVolumeAudioCDROM;
					}
					
					/*NSLog(@"%@: %02X (%c%c) - %02X (%c%c)",
						  [self name],
						  volumeInfo.filesystemID,
						  (volumeInfo.filesystemID%0xFF00)>>8,
						  volumeInfo.filesystemID&0x00FF,
						  volumeInfo.signature,
						  (volumeInfo.signature&0xFF00)>>8,
						  volumeInfo.signature&0x00FF);*/
				}
			}
			
			CFStringRef devicePath;
			
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
						CFStringRef deviceModel;
						CFDictionaryGetValueIfPresent(desc, kDADiskDescriptionDeviceInternalKey, (void *)&isInternal);
						CFDictionaryGetValueIfPresent(desc, kDADiskDescriptionMediaEjectableKey, (void *)&isEjectable);
						CFDictionaryGetValueIfPresent(desc, kDADiskDescriptionDeviceModelKey, (void *)&deviceModel);
						CFDictionaryGetValueIfPresent(desc, kDADiskDescriptionDevicePathKey, (void *)&devicePath);
						
						// 2nd check for disk images..
						if (([self type] != SLVolumeDiskImage) && ([(NSString *)deviceModel isEqualToString:@"Disk Image"]))
						{
							_type = SLVolumeDiskImage;
						}
						else if ([self type] == SLVolumeDrive) // if we haven't been identified by anything else yet, check for being a hd?
						{
							if ((isInternal == kCFBooleanTrue) && (isEjectable == kCFBooleanFalse))
							{
								_internal = YES;
							}
							
							// (will be overridden later if we're a DVD or CD)
							_type = SLVolumeHardDrive;
						}
					}
					CFRelease(disk);
				}
				CFRelease(session);
			}
			
			// check for a DVD
			if ([slValidDVDs objectForKey:[self path]])
			{
				// already cached this volume as a video DVD
				_type = SLVolumeDVDVideo;
			}
			else
			{
				Boolean isValid = false;
				if ((DVDIsValidMediaRef(&ref, &isValid) == noErr) && (isValid == true))
				{
					_type = SLVolumeDVDVideo;
					[slValidDVDs setObject:[NSNumber numberWithBool:YES] forKey:[self path]];
				}
				else
				{
					// not a video DVD
					
					if ([[DRDevice devices] count])
					{
						DRDevice *dvdDevice = [DRDevice deviceForIORegistryEntryPath:(NSString *)devicePath];
						if ((dvdDevice != nil) && ([dvdDevice mediaIsPresent]))
						{
							if ([[dvdDevice mediaType] hasPrefix:@"DRDeviceMediaTypeDVD"])
								_type = SLVolumeDVD;
							else if ([[dvdDevice mediaType] hasPrefix:@"DRDeviceMediaTypeCD"])
								_type = SLVolumeCDROM;
						}
					}
				}
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
	[_imagePath release];

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

- (NSString *)diskImagePath
{
	return _imagePath;
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
