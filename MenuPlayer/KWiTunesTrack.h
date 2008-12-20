//
//  KWiTunesTrack.h
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWiTunesObject.h"


@interface KWiTunesTrack : KWiTunesObject
{
	NSString *m_artist;
	NSString *m_album;
	NSString *m_location;
}

@property (retain, readwrite) NSString *artist, *album, *location;

@end
