//
//  DvdDisk.h
//  DVD2Pod
//
//  Created by Kevin Wojniak on 12/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DvdDisk : NSObject
{
	NSString *_name;
	NSString *_bsdPath;
	NSString *_mountedPath;
}

+ (NSArray *)allDVDs;

+ (id)dvdWithBSDPath:(NSString *)path;
- (id)initWithBSDPath:(NSString *)path;

- (NSString *)name;
- (NSString *)bsdPath;
- (NSString *)mountedPath;

- (void)setName:(NSString *)name;
- (void)setBSDPath:(NSString *)bsdPath;
- (void)setMountedPath:(NSString *)mountedPath;

@end
