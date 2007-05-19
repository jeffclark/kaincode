//
//  SPiPod.m
//  Spodlight
//
//  Created by Kevin Wojniak on 5/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SPiPod.h"


@implementation SPiPod

+ (NSArray *)connectediPods
{
	NSArray *allVolumes = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
	NSMutableArray *iPods = [NSMutableArray array];
	NSEnumerator *e = [allVolumes objectEnumerator];
	NSString *path = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	while (path = [e nextObject])
	{
		NSString *iPodControlPath = [path stringByAppendingPathComponent:@"iPod_Control"];
		if ([fileManager fileExistsAtPath:iPodControlPath])
		{
			[iPods addObject:[SPiPod iPodAtPath:path]];
		}
	}
	
	return iPods;	
}

+ (id)iPodAtPath:(NSString *)path
{
	return [[[self alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString *)path
{
	if (self = [super init])
	{
		_path = [path copy];
	}
	
	return self;
}

- (void)dealloc
{
	[_path release];
	[super dealloc];
}

- (NSString *)path
{
	return _path;
}

- (NSString *)name
{
	return [[NSFileManager defaultManager] displayNameAtPath:_path];
}

#pragma mark -

- (NSString *)description
{
	return [self name];
}

@end
