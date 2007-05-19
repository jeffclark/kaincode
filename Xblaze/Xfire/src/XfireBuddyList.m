//
//  XfireBuddyList.m
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XfireBuddyList.h"
#import "XfireBuddyListEntry.h"

@implementation XfireBuddyList

- (id)initWithEntries:(NSArray *)entries
{
	if ((self = [super init]))
	{
		NSMutableArray *online = [NSMutableArray array], *offline = [NSMutableArray array];
		NSEnumerator *entriesEnum = [entries objectEnumerator];
		XfireBuddyListEntry *entry;
		while ((entry = [entriesEnum nextObject]))
		{
			if ([entry isOnline])
				[online addObject:entry];
			else
				[offline addObject:entry];
		}
		
		[_allEntries release];
		[_onlineEntries release];
		[_offlineEntries release];
		_allEntries = [entries retain];
		_onlineEntries = [online retain];
		_offlineEntries = [offline retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_onlineEntries release];
	[_offlineEntries release];
	[_allEntries release];
	[super dealloc];
}

+ (XfireBuddyList *)buddyListWithEntries:(NSArray *)entries
{
	return [[[self alloc] initWithEntries:entries] autorelease];
}

- (NSArray *)allEntries
{
	return _allEntries;	
}

- (NSArray *)onlineEntries
{
	return _onlineEntries;
}

- (NSArray *)offlineEntries
{
	return _offlineEntries;
}

- (XfireBuddyListEntry *)entryWithUsername:(NSString *)username
{
	NSEnumerator *e = [[self allEntries] objectEnumerator];
	XfireBuddyListEntry *en;
	while ((en = [e nextObject]))
		if ([[en username] isEqualToString:username])
			return en;
	return nil;
}

@end
