//
//  KWMusicPlayer.h
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class QTMovie;

@interface KWMusicPlayer : NSObject
{
	id m_delegate;
	QTMovie *m_movie;
	BOOL m_isPlaying;
}

@property (assign, readwrite) id delegate;
@property (readonly) BOOL isPlaying;

- (BOOL)playFileAtPath:(NSString *)path;

- (void)pause;
- (void)play;

@end


@interface NSObject (KWMusicPlayer)
- (void)musicPlayerDidFinishPlaying:(KWMusicPlayer *)player;
@end