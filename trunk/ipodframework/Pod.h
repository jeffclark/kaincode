//
//  Pod.h
//  iPodFrameworkTest
//
//  Created by Kevin Wojniak on 6/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef const struct __iPodPreferences * iPodPreferencesRef;
typedef const struct __iPod * iPodRef;

typedef UInt32 iPodPreferenceIndex;

enum
{
	kiPodPrefConfigured			= 1,		/* effect of this flag is not yet clear */
	kiPodPrefEnableDiskMode		= 2,		/* [apparently] tells iTunes whether or not it should unmount after update */
	kiPodPrefNeedsSync			= 3,		/* [apparently] tells iSync whether it needs to sync to the iPod or not */
};

@interface Pod : NSObject
{
	iPodRef _iPod;

	NSString *_name;
	NSURL *_url;
	UInt64 _ID;
}

- (id)initWithiPodRef:(iPodRef)iPod;

- (NSString *)name;
- (NSURL *)mountPoint;
- (BOOL)mounted;
- (UInt64)ID;
- (int)lockCount;
- (BOOL)diskModeEnabled;

- (BOOL)aquireLock;
- (BOOL)releaseLock;

@end
