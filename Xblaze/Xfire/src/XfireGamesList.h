//
//  XfireGamesList.h
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XfireGameInfo;
@class XfireMacGameInfo;

@interface XfireGamesList : NSObject
{
	NSArray *_games;
	NSArray *_macGames;
}

- (void)findGames;

- (NSArray *)games;
- (NSArray *)macGames;

- (XfireMacGameInfo *)macGameWithName:(NSString *)appName;
- (XfireGameInfo *)gameForID:(NSString *)gameid;

@end
