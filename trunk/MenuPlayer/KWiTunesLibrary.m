//
//  KWiTunesLibrary.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWiTunesLibrary.h"
#import "KWiTunesPlaylist.h"
#import "KWiTunesTrack.h"


@interface KWiTunesLibrary (PrivateMethods)
- (BOOL)loadMusicLibraryXMLAtPath:(NSString *)path;
@end


@implementation KWiTunesLibrary

@synthesize playlists = m_playlists;

- (id)initWithContentsOfFile:(NSString *)path
{
	if (self = [super init])
	{
		m_playlists = nil;

		if (![self loadMusicLibraryXMLAtPath:path])
		{
			[self release];
			return nil;
		}
	}
	
	return self;
}

- (void)dealloc
{
	[m_playlists release];
	m_playlists = nil;
	[super dealloc];
}

- (BOOL)loadMusicLibraryXMLAtPath:(NSString *)path
{
	NSDictionary *xmlDict = nil;
	
	xmlDict = [[NSDictionary alloc] initWithContentsOfFile:path];
	if (xmlDict == nil)
	{
		return NO;
	}
	
	NSDictionary *xmlTracks = [xmlDict objectForKey:@"Tracks"];
	NSArray *xmlPlaylists = [xmlDict objectForKey:@"Playlists"];

	if (xmlTracks == nil)
	{
		NSLog(@"Couldn't find \"Tracks\" in XML!");
		return NO;
	}
	
	if (xmlPlaylists == nil)
	{
		NSLog(@"Couldn't find \"Playlists\" in XML!");
		return NO;
	}
	
	NSMutableArray *playlists = [[NSMutableArray alloc] init];
	
	for (NSDictionary *xmlPlaylist in xmlPlaylists)
	{
		// skip all non-user playlists
		if ([xmlPlaylist objectForKey:@"Master"] || [xmlPlaylist objectForKey:@"Distinguished Kind"])
			continue;
		
		KWiTunesPlaylist *playlist = [[KWiTunesPlaylist alloc] init];
		NSMutableArray *tracks = [NSMutableArray array];
		playlist.name = [xmlPlaylist objectForKey:@"Name"];
		playlist.smart = ([xmlPlaylist objectForKey:@"Smart Info"] != nil ? YES : NO);
		
		NSArray *xmlPlaylistItems = [xmlPlaylist objectForKey:@"Playlist Items"];
		for (NSDictionary *xmlPlaylistItem in xmlPlaylistItems)
		{
			NSString *xmlTrackID = [[xmlPlaylistItem objectForKey:@"Track ID"] stringValue];
			if (xmlTrackID == nil)
			{
				NSLog(@"Couldn't get track ID!");
				continue;
			}
			
			NSDictionary *xmlTrack = [xmlTracks objectForKey:xmlTrackID];
			if (xmlTrack == nil)
			{
				NSLog(@"Couldn't find track for track ID: %@", xmlTrackID);
				continue;
			}
			
			KWiTunesTrack *track = [[KWiTunesTrack alloc] init];
			track.name = [xmlTrack objectForKey:@"Name"];
			track.artist = [xmlTrack objectForKey:@"Artist"];
			track.album = [xmlTrack objectForKey:@"Album"];
			track.location = [[NSURL URLWithString:[xmlTrack objectForKey:@"Location"]] path];
			[tracks addObject:track];
			[track release];
		}
		
		playlist.tracks = tracks;
		
		if ([playlist.tracks count])
			[playlists addObject:playlist];
		
		[playlist release];
	}
	
	[xmlDict release];
	
	m_playlists = [playlists retain];
	[playlists release];
	
	return YES;
}

@end
