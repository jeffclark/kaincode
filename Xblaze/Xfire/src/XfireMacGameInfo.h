//
//  XfireMacGameInfo.h
//  Xfire
//
//  Created by Kevin Wojniak on 7/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XfireGameInfo;

@interface XfireMacGameInfo : NSObject
{
	NSString *_appName;
	XfireGameInfo *_gameInfo;
}

- (NSString *)appName;
- (void)setAppName:(NSString *)appName;
- (XfireGameInfo *)gameInfo;
- (void)setGameInfo:(XfireGameInfo *)gameInfo;

@end
