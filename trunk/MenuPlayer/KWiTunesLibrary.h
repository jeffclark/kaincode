//
//  KWiTunesLibrary.h
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KWiTunesLibrary : NSObject
{
	NSArray *m_playlists;
}

@property (readonly) NSArray *playlists;

- (id)initWithContentsOfFile:(NSString *)path;

@end
