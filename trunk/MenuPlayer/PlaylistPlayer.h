//
//  PlaylistPlayer.h
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *PlaylistPlayerDidStartPlayingTrack;
extern NSString *PlaylistPlayerDidStopPlayingTrack;
extern NSString *PlaylistPlayerDidFinishPlayingPlaylist;

@class KWMusicPlayer, KWiTunesPlaylist, KWiTunesTrack;

@interface PlaylistPlayer : NSObject
{
	KWMusicPlayer *m_musicPlayer;
	KWiTunesPlaylist *m_playlist;
	NSArray *m_tracks;
	NSInteger m_trackIndex;
	KWiTunesTrack *m_currentTrack;
}

@property (retain, readwrite) KWiTunesPlaylist *playlist;
@property (readonly) KWiTunesTrack *currentTrack;

- (void)shuffleTracks:(BOOL)shuffle;

- (void)playNext;
- (void)playPrevious;
- (void)playPause;

- (BOOL)isPlaying;

@end
