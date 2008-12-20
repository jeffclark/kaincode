//
//  KWiTunesPlaylist.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWiTunesPlaylist.h"


@implementation KWiTunesPlaylist

@synthesize tracks = m_tracks;
@synthesize smart = m_smart;

- (id)init
{
	if (self = [super init])
	{
		self.tracks = nil;
		self.smart = NO;
	}
	
	return self;
}

- (void)dealloc
{
	self.tracks = nil;
	[super dealloc];
}

@end
