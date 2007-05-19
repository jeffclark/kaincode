//
//  Pod.m
//  iPodFrameworkTest
//
//  Created by Kevin Wojniak on 6/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Pod.h"


@implementation Pod

- (id)initWithiPodRef:(iPodRef)iPod
{
	if (self = [super init])
	{
		_iPod = iPod;
		
		iPodCopyName(_iPod, &_name);
		iPodCopyMountpoint(_iPod, &_url);
		_ID = iPodGetUniqueID(_iPod);
	}
	
	return self;
}

- (void)dealloc
{
	_iPod = NULL;
	
	[_name release];
	[_url release];
	
	[super dealloc];
}

- (NSString *)name
{
	return _name;
}

- (NSURL *)mountPoint
{
	return _url;
}

- (BOOL)mounted
{
	return ([self mountPoint] != nil);
}

- (UInt64)ID
{
	return _ID;
}

- (int)lockCount
{
	CFIndex count = iPodGetLockCount(_iPod);
	return (int)count;
}

- (BOOL)diskModeEnabled
{
	BOOL diskModeEnabled = NO;
	
	if ([self mountPoint] != nil)
	{
		iPodPreferencesRef prefs;
		if (iPodCopyPreferences(_iPod, &prefs) == noErr)
		{
			Boolean value;
			iPodPreferenceGetValue(prefs, kiPodPrefEnableDiskMode, &value);
			diskModeEnabled = (value == 0 ? NO : YES);
			
			
			CFRelease(prefs);
		}
		else
		{
			NSLog(@"couldn't open prefs");
		}
	}
	
	return diskModeEnabled;
}

- (BOOL)aquireLock
{
	return (iPodAquireLock(_iPod) == 0);
}

- (BOOL)releaseLock
{
	return (iPodReleaseLock(_iPod) == 0);
}

- (NSString *)description
{
	return [self name];
}

@end
