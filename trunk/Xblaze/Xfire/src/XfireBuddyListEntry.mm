//
//  XfireBuddyList.m
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XfireBuddyListEntry.h"
#import "XfireGameInfo.h"

#include "buddylist.h"
using namespace xfirelib;


@implementation XfireBuddyListEntry

- (id)initWithBuddyListEntry:(void *)buddyListEntry
{
	if ((self = [super init]))
	{
		_buddyListEntry = buddyListEntry;
		_game = nil;
	}
	
	return self;
}

- (void)dealloc
{
	_buddyListEntry = NULL;
	[_game release];
	
	[super dealloc];
}

- (NSString *)username
{
	return [NSString stringWithUTF8String:((BuddyListEntry *)_buddyListEntry)->username.c_str()];
}

- (NSString *)nickname
{
	return [NSString stringWithUTF8String:((BuddyListEntry *)_buddyListEntry)->nick.c_str()];
}

- (NSString *)statusMessage
{
	return [NSString stringWithUTF8String:((BuddyListEntry *)_buddyListEntry)->statusmsg.c_str()];
}

- (int)userid
{
	return ((BuddyListEntry *)_buddyListEntry)->userid;
}

- (int)gameID
{
	return ((BuddyListEntry *)_buddyListEntry)->game;
}

- (XfireGameInfo *)game
{
	return _game;
}

- (void)setGame:(XfireGameInfo *)game
{
	if (_game != game)
	{
		[_game release];
		_game = [game retain];
	}
}

- (BOOL)isOnline
{
	return ((BuddyListEntry *)_buddyListEntry)->isOnline() ? YES : NO;
}

- (NSString *)displayName
{
	if ([[self nickname] length] > 0)
		return [self nickname];
	return [self username];
}

- (void *)data
{
	return _buddyListEntry;
}


- (NSString *)description
{
	if ([[self nickname] length] > 0)
		return [NSString stringWithFormat:@"%@ (%@)", [self nickname], [self username]];
	return [self username];
}

- (NSComparisonResult)compare:(XfireBuddyListEntry *)entry
{
	return [[self displayName] caseInsensitiveCompare:[entry displayName]];
}

@end
