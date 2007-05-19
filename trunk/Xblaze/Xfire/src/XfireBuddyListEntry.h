//
//  XfireBuddyList.h
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XfireGameInfo;

@interface XfireBuddyListEntry : NSObject
{
	void *_buddyListEntry;
	
	XfireGameInfo *_game;
}

- (id)initWithBuddyListEntry:(void *)buddyListEntry;

- (NSString *)username;
- (NSString *)nickname;
- (NSString *)statusMessage;
- (int)userid;
- (int)gameID;
- (XfireGameInfo *)game;
- (void)setGame:(XfireGameInfo *)game;
- (BOOL)isOnline;

- (NSString *)displayName;

- (void *)data;


- (NSComparisonResult)compare:(XfireBuddyListEntry *)entry;

@end
