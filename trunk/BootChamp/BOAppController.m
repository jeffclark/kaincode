//
//  BOAppController.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/6/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "BOAppController.h"
#import "BODefines.h"
#import "BOStatusMenuController.h"
#import "BOBoot.h"


@implementation BOAppController

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:BOBehaviorShowInMenuBar] forKey:BODefaultBehavior]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSInteger defaultBehavior = [[NSUserDefaults standardUserDefaults] integerForKey:BODefaultBehavior];
	switch (defaultBehavior)
	{
		case BOBehaviorBootIntoWindows:
			bootIntoWindows();
			break;

		default:
			m_statusController = [[BOStatusMenuController alloc] init];
			break;
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[m_statusController release];
}

@end
