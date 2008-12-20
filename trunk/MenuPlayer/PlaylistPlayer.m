//
//  PlaylistPlayer.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PlaylistPlayer.h"
#import "KWMusicPlayer.h"
#import "KWiTunesPlaylist.h"
#import "KWiTunesTrack.h"

NSString *PlaylistPlayerDidStartPlayingTrack = @"PlaylistPlayerDidStartPlayingTrack";
NSString *PlaylistPlayerDidStopPlayingTrack = @"PlaylistPlayerDidStopPlayingTrack";
NSString *PlaylistPlayerDidFinishPlayingPlaylist = @"PlaylistPlayerDidFinishPlayingPlaylist";

@implementation PlaylistPlayer

@synthesize playlist = m_playlist;
@synthesize currentTrack = m_currentTrack;

- (id)init
{
	if (self = [super init])
	{
		self.playlist = nil;
		m_currentTrack = nil;
		m_musicPlayer = [[KWMusicPlayer alloc] init];
		m_musicPlayer.delegate = self;
		m_tracks = nil;
		m_trackIndex = -1;
		
		srandom(time(NULL));
	}
	
	return self;
}

- (void)dealloc
{
	self.playlist = nil;
	[m_currentTrack release];
	m_currentTrack = nil;
	[m_musicPlayer release];
	m_musicPlayer = nil;
	[m_tracks release];
	m_tracks = nil;
	[super dealloc];
}

- (void)shuffleTracks:(BOOL)shuffle
{
	[m_tracks release];
	m_tracks = nil;
	
	if (shuffle)
	{
		[NSThread detachNewThreadSelector:@selector(shuffleTracksThread) toTarget:self withObject:nil];
		return;
	}

	m_tracks = [[self.playlist tracks] retain];
	m_trackIndex = -1;
	[self playNext];
}

- (void)shuffleTracksThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Assume that the random number system has been seeded.
	NSMutableArray *tracks = [self.playlist.tracks mutableCopy];
	NSInteger i, n = [tracks count];
	for(i = 0; i < n; i++)
	{
		// Swap the ith object with one randomly selected from [i,n).
		NSInteger destinationIndex = random() % (n - i) + i;
		[tracks exchangeObjectAtIndex:i withObjectAtIndex:destinationIndex];
	}

	m_tracks = tracks;
	m_trackIndex = -1;
	
	[self performSelectorOnMainThread:@selector(playNext) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)playTrack
{
	[m_currentTrack release];
	m_currentTrack = [[m_tracks objectAtIndex:m_trackIndex] retain];
	[m_musicPlayer playFileAtPath:m_currentTrack.location];
	[[NSNotificationCenter defaultCenter] postNotificationName:PlaylistPlayerDidStartPlayingTrack object:m_currentTrack];
}

- (void)playNext
{
	if (m_trackIndex == [m_tracks count]-1)
	{
		[m_currentTrack release];
		m_currentTrack = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:PlaylistPlayerDidFinishPlayingPlaylist object:m_currentTrack];
		return; // DONE??
	}
	m_trackIndex++;
	[self playTrack];
}

- (void)playPrevious
{
	if (m_trackIndex == 0)
		return; // DONE??
	m_trackIndex--;
	[self playTrack];
}

- (void)playPause
{
	[m_musicPlayer pause];
	[[NSNotificationCenter defaultCenter] postNotificationName:PlaylistPlayerDidStopPlayingTrack object:m_currentTrack];
}

- (void)musicPlayerDidFinishPlaying:(KWMusicPlayer *)player
{
	[self playNext];
}

- (BOOL)isPlaying
{
	return m_musicPlayer.isPlaying;
}

@end
