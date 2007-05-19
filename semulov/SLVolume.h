//
//  SLVolume.h
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/mount.h>

typedef enum
{
	SLVolumeRoot,
	SLVolumeDrive,
	SLVolumeiPod,
	SLVolumeNetwork,
	SLVolumeiDisk,
	SLVolumeFTP,
} SLVolumeType;

@interface SLVolume : NSObject
{
	NSString *_path;
	NSString *_name;
	NSImage *_image;
	BOOL _local;
	BOOL _root;
	NSURL *_hostURL;
	BOOL _internal;
	
	SLVolumeType _type;
}

+ (NSArray *)allVolumes;

- (id)initWithStatfs:(struct statfs *)statfs;

- (NSString *)path;
- (NSString *)name;
- (NSImage *)image;
- (BOOL)isLocal;
- (BOOL)isRoot;
- (SLVolumeType)type;
- (NSURL *)hostURL;
- (BOOL)isInternalHardDrive;

- (BOOL)isiPod;

- (BOOL)eject;
- (BOOL)showInFinder;

@end
