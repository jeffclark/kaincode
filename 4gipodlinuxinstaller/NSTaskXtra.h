//
//  NSTaskXtra.h
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/14/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSTask (NSTaskXtra)

+ (NSData *)runTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments inputData:(NSData *)inputData;
+ (NSData *)runTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments inputData:(NSData *)inputData currentDirectory:(NSString *)currentDirectory;

@end
