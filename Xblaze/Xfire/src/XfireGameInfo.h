//
//  XfireGame.h
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XfireGameInfo : NSObject
{
	NSString *_name;
	NSString *_gameID;
	NSImage *_icon;
}



- (NSString *)name;
- (void)setName:(NSString *)name;

- (NSString *)gameID;
- (void)setGameID:(NSString *)gameID;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)icon;

@end
