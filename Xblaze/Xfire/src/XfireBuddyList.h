//
//  XfireBuddyList.h
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XfireBuddyListEntry;

@interface XfireBuddyList : NSObject
{
	NSArray *_allEntries, *_onlineEntries, *_offlineEntries;
}

+ (XfireBuddyList *)buddyListWithEntries:(NSArray *)entries;

- (NSArray *)allEntries;
- (NSArray *)onlineEntries;
- (NSArray *)offlineEntries;

- (XfireBuddyListEntry *)entryWithUsername:(NSString *)username;

@end
