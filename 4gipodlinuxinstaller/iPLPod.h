//
//  iPLPod.h
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	iPLPodOther,
	iPLPodColor,
	iPLPodMini,
	iPLPodFourthBW,
	iPLPod123G,
} iPLPodGeneration;

@interface iPLPod : NSObject
{
	NSString *_path;
	iPLPodGeneration podgen;
	int _deviceID;
	BOOL _fat32;
	
	NSImage *_img;
}

- (id)initWithPath:(NSString *)path;

- (NSString *)path;
- (NSString *)name;
- (iPLPodGeneration)iPodGeneration;

- (int)deviceID;
- (BOOL)FAT32;

- (NSImage *)image;

@end
