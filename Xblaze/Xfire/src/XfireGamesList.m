//
//  XfireGamesList.m
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XfireGamesList.h"
#import "XfireGameInfo.h"
#import "XfireMacGameInfo.h"


@interface XfireGamesList (priv)
- (void)loadIni;
- (void)loadMacGames;
@end


@implementation XfireGamesList

- (id)init
{
	if ((self = [super init]))
	{
		_games = nil;
		_macGames = nil;
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(findGames)
																   name:NSWorkspaceDidLaunchApplicationNotification
																 object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(findGames)
																   name:NSWorkspaceDidTerminateApplicationNotification
																 object:nil];
		
		[self loadIni];
		[self loadMacGames];
	}
	
	return self;
}

- (void)dealloc
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[_games release];
	[_macGames release];
	[super dealloc];
}

- (void)loadIni
{
	NSString *iniPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"xfire_games" ofType:@"ini"];
	if (iniPath == nil)
		return;
	
	NSString *iniText = [NSString stringWithContentsOfFile:iniPath];
	if (iniText == nil)
		return;
	
	// ugly parsing...
	NSMutableArray *games = [NSMutableArray array];
	NSEnumerator *linesEnum = [[iniText componentsSeparatedByString:@"\r\n"] objectEnumerator];
	NSString *line;
	XfireGameInfo *currentGame = nil;
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	
	while ((line = [linesEnum nextObject]))
	{
		// read the [1234] lines
		if ([line hasPrefix:@"["] && [line hasSuffix:@"]"])
		{
			if (currentGame != nil)
				[games addObject:currentGame];
			[currentGame release];
			currentGame = [[XfireGameInfo alloc] init];
			
			NSString *gameid = [line substringWithRange:NSMakeRange(1, MIN([line length]-2, 4))];
			[currentGame setGameID:gameid];
		}
		// read the key=value lines
		else if (currentGame != nil)
		{
			NSRange equalRange = [line rangeOfString:@"="];
			if (equalRange.location == NSNotFound)
				continue;
			
			NSString *key = [line substringToIndex:equalRange.location];
			NSString *value = [line substringFromIndex:equalRange.location+1];

			if ([key isEqualToString:@"LongName"])
			{
				[currentGame setName:value];
			}
			else if ([key isEqualToString:@"ShortName"])
			{
				NSString *icon = [NSString stringWithFormat:@"XF_%@.ICO", [value uppercaseString]];
				//NSLog(@"icon: %@", icon);
				NSImage *img = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:icon ofType:nil]];
				[currentGame setIcon:img];
				[img release];
			}
		}
	}
	if (currentGame != nil)
		[games addObject:currentGame];
	
	[_games release];
	_games = [games retain];
}

- (void)loadMacGames
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"macgames" ofType:@"txt"];
	NSString *text = [NSString stringWithContentsOfFile:path];

	NSMutableArray *temp = [NSMutableArray array];
	NSEnumerator *linesEnum = [[text componentsSeparatedByString:@"\n"] objectEnumerator];
	NSString *line;
	while (line = [linesEnum nextObject])
	{
		NSArray *parts = [line componentsSeparatedByString:@"\t"];
		if ([parts count] < 2)
			continue;
		NSString *gameid = [parts objectAtIndex:0];
		NSString *macApp = [parts objectAtIndex:1];
		
		XfireMacGameInfo *game = [[XfireMacGameInfo alloc] init];
		[game setGameInfo:[self gameForID:gameid]];
		[game setAppName:macApp];
		[temp addObject:game];
		[game release];
	}
	[_macGames release];
	_macGames = nil;
	if ([temp count] > 0)
		_macGames = [temp retain];
	
	[self findGames];
}

- (void)findGames
{
	XfireMacGameInfo *foundGame = nil;
	
	NSEnumerator *apps = [[[NSWorkspace sharedWorkspace] launchedApplications] objectEnumerator];
	NSDictionary *app;
	while (app = [apps nextObject])
	{
		NSString *path = [app objectForKey:@"NSApplicationPath"];
		foundGame = [self macGameWithName:[path lastPathComponent]];
		if (foundGame)
			break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KWXfireGameStatus" object:[foundGame gameInfo]];
}

- (NSArray *)games
{
	return _games;
}

- (NSArray *)macGames
{
	return _macGames;
}

- (XfireMacGameInfo *)macGameWithName:(NSString *)appName
{
	NSEnumerator *gamesEnum = [[self macGames] objectEnumerator];
	XfireMacGameInfo *game;
	while ((game = [gamesEnum nextObject]))
		if ([[game appName] isEqualToString:appName])
			return game;
	return nil;
}

- (XfireGameInfo *)gameForID:(NSString *)gameid
{
	NSEnumerator *gamesEnum = [[self games] objectEnumerator];
	XfireGameInfo *game;
	while ((game = [gamesEnum nextObject]))
		if ([[game gameID] isEqualToString:gameid])
			return game;
	return nil;
}

@end
