//
//  XfireGame.m
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XfireGameInfo.h"


@implementation XfireGameInfo

- (id)init
{
	if ((self = [super init]))
	{
		[self setName:nil];
		[self setGameID:nil];
		[self setIcon:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[self setName:nil];
	[self setGameID:nil];
	[self setIcon:nil];
	
	[super dealloc];
}

- (NSString *)name
{
	return _name;
}

- (void)setName:(NSString *)name
{
	if (_name != name)
	{
		[_name release];
		_name = [name copy];
	}
}

- (NSString *)gameID
{
	return _gameID;
}

- (void)setGameID:(NSString *)gameID
{
	if (_gameID != gameID)
	{
		[_gameID release];
		_gameID = [gameID copy];
	}
}

- (NSImage *)icon
{
	return _icon;
}

- (void)setIcon:(NSImage *)icon
{
	if (_icon != icon)
	{
		[_icon release];
		_icon = [icon retain];
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%@)", [self name], [self gameID]];
}

@end
