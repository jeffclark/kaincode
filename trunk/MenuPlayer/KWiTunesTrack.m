//
//  KWiTunesTrack.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWiTunesTrack.h"


@implementation KWiTunesTrack

@synthesize artist = m_artist, album = m_album, location = m_location;

- (id)init
{
	if (self = [super init])
	{
		self.artist = nil;
		self.album = nil;
		self.location = nil;
	}
	
	return self;
}

- (void)dealloc
{
	self.artist = nil;
	self.album = nil;
	self.location = nil;
	[super dealloc];
}
	
@end
