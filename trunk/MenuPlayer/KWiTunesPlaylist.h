//
//  KWiTunesPlaylist.h
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWiTunesObject.h"


@interface KWiTunesPlaylist : KWiTunesObject
{
	NSArray *m_tracks;
	BOOL m_smart;
}

@property (retain, readwrite) NSArray *tracks;
@property (readwrite) BOOL smart;

@end
