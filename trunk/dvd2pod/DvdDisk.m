//
//  DvdDisk.m
//  DVD2Pod
//
//  Created by Kevin Wojniak on 12/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DvdDisk.h"
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>
#include <paths.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOBSD.h>
#include <IOKit/storage/IOMedia.h>
#include <IOKit/storage/IODVDMedia.h>

#define _(a) NSLocalizedString(a, nil)

@implementation DvdDisk

+ (NSArray *)allDVDs
{
    /* Scan DVD drives (stolen from VLC) */
    io_object_t next_media;
    mach_port_t  master_port;
    kern_return_t kern_result;
    io_iterator_t media_iterator;
    CFMutableDictionaryRef classes_to_match;
	
    kern_result = IOMasterPort(MACH_PORT_NULL, &master_port);
    if (kern_result != KERN_SUCCESS)
        return nil;
	
    classes_to_match = IOServiceMatching(kIODVDMediaClass);
    if (classes_to_match == NULL)
        return nil;
	
    CFDictionarySetValue(classes_to_match, CFSTR(kIOMediaEjectableKey), kCFBooleanTrue);
	
    kern_result = IOServiceGetMatchingServices(master_port, classes_to_match, &media_iterator);
    if (kern_result != KERN_SUCCESS)
        return nil;
	
    NSMutableArray *drivesList = [NSMutableArray arrayWithCapacity:1];
	
    next_media = IOIteratorNext(media_iterator);
    if (next_media)
    {
        char psz_buf[0x32];
        size_t dev_path_length;
        CFTypeRef str_bsd_path;
		
        do
        {
            str_bsd_path = IORegistryEntryCreateCFProperty(next_media, CFSTR(kIOBSDNameKey), kCFAllocatorDefault, 0);
            if (str_bsd_path == NULL)
            {
                IOObjectRelease(next_media);
                continue;
            }
			
            snprintf(psz_buf, sizeof(psz_buf), "%s%c", _PATH_DEV, 'r');
            dev_path_length = strlen(psz_buf);
			
            if (CFStringGetCString((CFStringRef)str_bsd_path, (char*)&psz_buf + dev_path_length, sizeof(psz_buf) - dev_path_length, kCFStringEncodingUTF8))
            {
				DvdDisk *dvd = [DvdDisk dvdWithBSDPath:[NSString stringWithUTF8String:psz_buf]];
				if (dvd)
					[drivesList addObject:dvd];
            }
			
            CFRelease(str_bsd_path);
            IOObjectRelease(next_media);
			
        } while ((next_media = IOIteratorNext(media_iterator)));
    }
	
    IOObjectRelease(media_iterator);
	
	return drivesList;
}

+ (id)dvdWithBSDPath:(NSString *)path
{
	return [[[self alloc] initWithBSDPath:path] autorelease];
}

- (id)initWithBSDPath:(NSString *)path
{
	if (self = [super init])
	{
		_bsdPath = [path retain];
		_name = nil;
		_mountedPath = nil;
		
		// hackish way of attempting to get a name
		NSString *lastPath = [_bsdPath lastPathComponent];
		if ([lastPath hasPrefix:@"r"])
			lastPath = [lastPath substringFromIndex:1];
		
		struct statfs *buf;
		int i, count = getmntinfo(&buf, 0);
		for (i=0; i<count; i++)
		{
			if ((buf[i].f_flags & MNT_LOCAL) == MNT_LOCAL)
			{
				NSString *bsdPath = [NSString stringWithUTF8String:buf[i].f_mntfromname];
				if ([[bsdPath lastPathComponent] isEqualToString:lastPath])
				{
					// make the DVD name purty
					NSMutableString *tempName = [NSMutableString string];
					NSString *mountedPath = [NSString stringWithUTF8String:buf[i].f_mntonname];
					[tempName setString:[mountedPath lastPathComponent]];
					[tempName replaceOccurrencesOfString:@"_" withString:@" " options:0 range:NSMakeRange(0, [tempName length])];
					[tempName setString:[tempName capitalizedString]];
					
					[self setName:tempName];
					[self setMountedPath:mountedPath];
					
					break;
				}
				//printf("%s (%s - %s)\n", buf[i].f_mntfromname, buf[i].f_mntonname, buf[i].f_fstypename);
			}
		}
		
		if (_name == nil) // no name found.. so just use a generic name
			[self setName:_(@"DVD")];
	}
	
	return self;
}

- (void)dealloc
{
	[_name release];
	[_bsdPath release];
	[_mountedPath release];
	[super dealloc];
}

- (NSString *)name
{
	return _name;
}

- (NSString *)bsdPath
{
	return _bsdPath;
}

- (NSString *)mountedPath
{
	return _mountedPath;
}

- (void)setName:(NSString *)name
{
	if (_name != name)
	{
		[_name release];
		_name = [name retain];
	}
}

- (void)setBSDPath:(NSString *)bsdPath
{
	if (_bsdPath != bsdPath)
	{
		[_bsdPath release];
		_bsdPath = [bsdPath retain];
	}
}

- (void)setMountedPath:(NSString *)mountedPath
{
	if (_mountedPath != mountedPath)
	{
		[_mountedPath release];
		_mountedPath = [mountedPath retain];
	}
}

- (NSString *)description
{
	return [self name];
}

@end
