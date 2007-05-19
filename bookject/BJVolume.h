//
//  BJVolume.h
//  Bookject
//
//  Created by Kevin Wojniak on 8/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef unsigned int BJVolumeType;
#define	BJDrive	0x000000001
#define BJiPod	0x000000002

@interface BJVolume : NSObject
{
	NSString *_mountedPath;
	BJVolumeType _type;
}

+ (NSArray *)connectedVolumes;

+ (BJVolume *)volumeWithMountedPath:(NSString *)mountedPath type:(BJVolumeType)type;
- (id)initWithMountedPath:(NSString *)mountedPath type:(BJVolumeType)type;
- (NSString *)mountedPath;

- (BOOL)isDrive;
- (BOOL)isiPod;

@end
