//
//  AppController.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "StatusMenuController.h"


@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)not
{
	m_statusMenuController = [[StatusMenuController alloc] init];
}

- (void)dealloc
{
	[m_statusMenuController release];
	m_statusMenuController = nil;
	
	[super dealloc];
}

@end
