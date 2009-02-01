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

- (BOOL)wasLaunchedByProcessWithIdentifier:(NSString *)processIdentifier
{
	BOOL ret = NO;
	
	ProcessSerialNumber psn;
	if (GetCurrentProcess(&psn) == noErr)
	{
		ProcessInfoRec procInfo;
		bzero (&procInfo, sizeof(procInfo));
		procInfo.processInfoLength = (UInt32)sizeof(ProcessInfoRec);
		if (GetProcessInformation(&psn, &procInfo) == noErr)
		{
			ProcessSerialNumber parentPSN = procInfo.processLauncher;
			NSDictionary *parentDict = [(NSDictionary *)ProcessInformationCopyDictionary(&parentPSN, kProcessDictionaryIncludeAllInformationMask) autorelease];
			ret = [(NSString *)[parentDict objectForKey:@"CFBundleIdentifier"] isEqualToString:processIdentifier];
		}
	}
	
	return ret;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSInteger defaultBehavior = [[NSUserDefaults standardUserDefaults] integerForKey:BODefaultBehavior];
	
	NSString *key = @"MacBooksWarning";
	if (![[NSUserDefaults standardUserDefaults] boolForKey:key])
	{
		NSBeep();
		[NSApp activateIgnoringOtherApps:YES];
		NSRunCriticalAlertPanel(NSLocalizedString(@"Important", nil),
									 NSLocalizedString(@"BootChamp doesn’t work with the new unibody MacBooks, which includes the Air and Pro. The app uses the built-in tool bless (/usr/sbin/bless) to set the boot disk, and one of the options it uses to set the boot disk for the next boot is broken and not working. Unfortunately I do not have a workaround at this time.\n\nThis message will only appear once.", nil), nil, nil, nil);
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
	}
	
	if ([self wasLaunchedByProcessWithIdentifier:@"com.apple.spotlight"])
		defaultBehavior = BOBehaviorBootIntoWindows;

	switch (defaultBehavior)
	{
		case BOBehaviorBootIntoWindows:
			[NSApp activateIgnoringOtherApps:YES];
			if (!bootIntoWindows() && lastError() == authCancelled)
				[NSApp terminate:nil];
			break;

		default:
			m_statusController = [[BOStatusMenuController alloc] init];
			break;
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[m_statusController release];
	m_statusController = nil;
}

@end
