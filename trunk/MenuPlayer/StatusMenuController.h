//
//  StatusMenuController.h
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KWiTunesLibrary, PlaylistPlayer;

@interface StatusMenuController : NSObject
{
	NSStatusItem *m_statusItem;
	KWiTunesLibrary *m_library;
	BOOL m_buildingLibrary;
	PlaylistPlayer *m_player;
	NSArray *m_playlistMenuItems;
	BOOL m_shuffle;
}

@end
