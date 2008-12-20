//
//  KWMusicPlayer.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWMusicPlayer.h"
#import <QTKit/QTKit.h>


@implementation KWMusicPlayer

@synthesize delegate = m_delegate;
@synthesize isPlaying = m_isPlaying;

- (id)init
{
	if (self = [super init])
	{
		self.delegate = nil;
		m_movie = nil;
		m_isPlaying = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnd:) name:QTMovieDidEndNotification object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	self.delegate = nil;
	[m_movie release];
	m_movie = nil;
	[super dealloc];
}

- (BOOL)playFileAtPath:(NSString *)path
{
	[m_movie release];
	m_movie = [[QTMovie alloc] initWithFile:path error:nil];
	if (m_movie == nil)
	{
		NSLog(@"Couldn't initialize movie at path: %@", path);
		return NO;
	}
	
	m_isPlaying = NO;
	[self play];

	return YES;
}

- (void)pause
{
	[self play];
}

- (void)play
{
	if (m_isPlaying)
	{
		[m_movie stop];
		m_isPlaying = NO;
	}
	else
	{
		[m_movie play];
		m_isPlaying = YES;
	}
}

- (void)handleEnd:(NSNotification *)notification
{
	[m_movie release];
	m_movie = nil;
	[self.delegate musicPlayerDidFinishPlaying:self];
}

@end
