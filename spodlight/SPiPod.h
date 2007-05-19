//
//  SPiPod.h
//  Spodlight
//
//  Created by Kevin Wojniak on 5/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
// Handles basic iPod tasks.

#import <Cocoa/Cocoa.h>


@interface SPiPod : NSObject
{
	NSString *_path;
}

+ (NSArray *)connectediPods;

+ (id)iPodAtPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

- (NSString *)path;
- (NSString *)name;

@end
