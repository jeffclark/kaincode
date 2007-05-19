//
//  XfireMacGameInfo.m
//  Xfire
//
//  Created by Kevin Wojniak on 7/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XfireMacGameInfo.h"
#import "XfireGameInfo.h"


@implementation XfireMacGameInfo

- (id)init
{
	if (self = [super init])
	{
		
	}
	
	return self;
}

- (void)dealloc
{
	[self setAppName:nil];
	[self setGameInfo:nil];
	[super dealloc];
}

- (NSString *)appName
{
	return _appName;
}

- (void)setAppName:(NSString *)appName
{
	if (_appName != appName)
	{
		[_appName release];
		_appName = [appName copy];
	}
}

- (XfireGameInfo *)gameInfo
{
	return _gameInfo;
}

- (void)setGameInfo:(XfireGameInfo *)gameInfo
{
	if (_gameInfo != gameInfo)
	{
		[_gameInfo release];
		_gameInfo = [gameInfo retain];
	}
}

- (NSString *)description
{
	return [[self gameInfo] name];
}

@end
