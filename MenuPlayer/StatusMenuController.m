//
//  StatusMenuController.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatusMenuController.h"
#import "KWiTunesLibrary.h"
#import "KWiTunesPlaylist.h"
#import "KWiTunesTrack.h"
#import "PlaylistPlayer.h"


#define PREFS_SHUFFLE_TRACKS @"ShuffleTracks"


@interface StatusMenuController (PrivateMethods)
- (void)createStatusItem;
- (void)buildLibrary;
- (void)rebuildMenu;
@end

@implementation StatusMenuController

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:YES], PREFS_SHUFFLE_TRACKS,
							  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init
{
	if (self = [super init])
	{
		m_library = nil;
		m_playlistMenuItems = nil;
		m_shuffle = [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_SHUFFLE_TRACKS];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildMenu) name:PlaylistPlayerDidStartPlayingTrack object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildMenu) name:PlaylistPlayerDidStopPlayingTrack object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaylist:) name:PlaylistPlayerDidFinishPlayingPlaylist object:nil];
		
		m_buildingLibrary = YES;
		[self buildLibrary];

		[self createStatusItem];
	}
	
	return self;
}

- (void)dealloc
{
	[m_statusItem release];
	m_statusItem = nil;
	[m_library release];
	m_library = nil;
	[m_playlistMenuItems release];
	m_playlistMenuItems = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}


- (void)createStatusItem
{
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];

	if (m_statusItem)
	{
		[statusBar removeStatusItem:m_statusItem];
		[m_statusItem release];
	}

	m_statusItem = [[statusBar statusItemWithLength:NSSquareStatusItemLength] retain];
	[m_statusItem setTitle:[NSString stringWithFormat:@"%C", 0x266C]];
	[m_statusItem setHighlightMode:YES];
	
	[self rebuildMenu];
}

- (void)buildLibrary
{
	[NSThread detachNewThreadSelector:@selector(buildLibraryThread) toTarget:self withObject:nil];
}

- (void)buildLibraryThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	m_library = [[KWiTunesLibrary alloc] initWithContentsOfFile:[@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath]];

	if (m_library == nil)
		NSLog(@"Couldn't load iTunes library!");
	
	m_buildingLibrary = NO;
	[self performSelectorOnMainThread:@selector(rebuildMenu) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)rebuildMenu
{	
	NSMenu *menu = [[NSMenu alloc] init];
	NSMenuItem *menuItem = nil;
	
	[menu setShowsStateColumn:YES];
	
	if (m_buildingLibrary)
	{
		menuItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Please Wait...", nil) action:nil keyEquivalent:@""] autorelease];
		[menu addItem:menuItem];
		[menu addItem:[NSMenuItem separatorItem]];
	}
	else
	{
		NSArray *playlists = m_library.playlists;
		if ([playlists count])
		{
			NSImage *smartPlaylistImg = [NSImage imageNamed:@"SmartPlaylist"];
			NSImage *normalPlaylistImg = [NSImage imageNamed:@"NormalPlaylist"];
			
			KWiTunesTrack *currentTrack = m_player.currentTrack;
			if (currentTrack)
			{
				NSString *nowPlayingTitle = ([m_player isPlaying] ? NSLocalizedString(@"Now Playing", nil) : 
											 NSLocalizedString(@"Now Playing (Paused)", nil));
				menuItem = [[[NSMenuItem alloc] initWithTitle:nowPlayingTitle action:nil keyEquivalent:@""] autorelease];
				[menu addItem:menuItem];

				menuItem = [[[NSMenuItem alloc] initWithTitle:currentTrack.name action:nil keyEquivalent:@""] autorelease];
				[menuItem setIndentationLevel:1];
				[menu addItem:menuItem];
				menuItem = [[[NSMenuItem alloc] initWithTitle:currentTrack.artist action:nil keyEquivalent:@""] autorelease];
				[menuItem setIndentationLevel:1];
				[menu addItem:menuItem];
				menuItem = [[[NSMenuItem alloc] initWithTitle:currentTrack.album action:nil keyEquivalent:@""] autorelease];
				[menuItem setIndentationLevel:1];
				[menu addItem:menuItem];
				
				[menu addItem:[NSMenuItem separatorItem]];
				
				NSString *playPauseTitle = ([m_player isPlaying] ? NSLocalizedString(@"Pause", nil) : NSLocalizedString(@"Play", nil));
				menuItem = [[[NSMenuItem alloc] initWithTitle:playPauseTitle action:@selector(playPause) keyEquivalent:@""] autorelease];
				[menuItem setTarget:m_player];
				[menu addItem:menuItem];
				
				menuItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) action:@selector(playNext) keyEquivalent:@""] autorelease];
				[menuItem setTarget:m_player];
				[menu addItem:menuItem];

				menuItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Previous", nil) action:@selector(playPrevious) keyEquivalent:@""] autorelease];
				[menuItem setTarget:m_player];
				[menu addItem:menuItem];
				
				[menu addItem:[NSMenuItem separatorItem]];			
			}
			
			NSMutableArray *playlistMenuItems = [NSMutableArray arrayWithCapacity:[playlists count]];
			
			for (KWiTunesPlaylist *playlist in playlists)
			{
				menuItem = [[NSMenuItem alloc] initWithTitle:playlist.name action:@selector(playPlaylist:) keyEquivalent:@""];
				[menuItem setRepresentedObject:playlist];
				[menuItem setState:(playlist == m_player.playlist ? NSOnState : NSOffState)];

				if (playlist.smart)
					[menuItem setImage:smartPlaylistImg];
				else
					[menuItem setImage:normalPlaylistImg];

				[menuItem setTarget:self];
				[menu addItem:menuItem];
				[playlistMenuItems addObject:menuItem];
				[menuItem release];
			}
			
			[m_playlistMenuItems release];
			m_playlistMenuItems = [playlistMenuItems retain];
			
			[menu addItem:[NSMenuItem separatorItem]];
		}
	}
	
	menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Shuffle", nil) action:@selector(toggleShuffle:) keyEquivalent:@""];
	[menuItem setState:(m_shuffle == YES ? NSOnState : NSOffState)];
	[menuItem setTarget:self];
	[menu addItem:menuItem];
	[menuItem release];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(terminate:) keyEquivalent:@""];
	[menuItem setTarget:NSApp];
	[menu addItem:menuItem];
	[menuItem release];
	
	[m_statusItem setMenu:menu];
	
	[menu release];
}

- (void)playPlaylist:(NSMenuItem *)sender
{
	KWiTunesPlaylist *playlist = [sender representedObject];
	if (playlist == nil)
		return;

	if (m_player == nil)
		m_player = [[PlaylistPlayer alloc] init];
	
	m_player.playlist = playlist;
	[m_player shuffleTracks:m_shuffle];
}

- (void)toggleShuffle:(id)sender
{
	m_shuffle = !m_shuffle;
	[[NSUserDefaults standardUserDefaults] setBool:m_shuffle forKey:PREFS_SHUFFLE_TRACKS];
	[self rebuildMenu];
}

- (void)playerDidFinishPlaylist:(NSNotification *)notification
{
	m_player.playlist = nil;
	[self rebuildMenu];
}

@end
