//
//  BOBoot.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BOBoot.h"
#import <Carbon/Carbon.h>
#import <Security/Security.h>
#import <sys/mount.h>


enum {
	switchSuccessError = 0,
	noWindowsVolumeError = 1,
	authFailedOrBlessFailedError = 2,
	authCancelled = 3,
	restartFailedError = 4,
};


BOOL restartComputer()
{
	AEEventID eventToSend = kAERestart;
	
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
    OSStatus error = noErr;
	
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, sizeof(kPSNOfSystemProcess), &targetDesc);
    if (error != noErr)
        return NO;
	
    error = AECreateAppleEvent(kCoreEventClass, eventToSend, &targetDesc, kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
    AEDisposeDesc(&targetDesc);
    if (error != noErr)
        return NO;
	
    error = AESend(&appleEventToSend, &eventReply, kAENoReply, kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
        return NO;
	
    AEDisposeDesc(&eventReply);
	return (error == noErr);
}

NSString* windowsVolume()
{
	struct statfs *buf = NULL;
	unsigned i, count = 0;
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		if ((buf[i].f_flags & MNT_LOCAL) != MNT_LOCAL)
			continue;
		
		char *volType = buf[i].f_fstypename;
		char *volPath = buf[i].f_mntonname;
		if ((strcmp(volType, "ntfs") == 0) || (strcmp(volType, "msdos") == 0))
		{
			NSString *path = [NSString stringWithUTF8String:volPath];
			if (path)
				return path;
		}
	}
	
	return nil;
}

BOOL setVolumeAsStartupDisk(NSString *volume, BOOL *userCancelled)
{
	OSStatus status;
	AuthorizationRef authorizationRef;
	
	status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
	if (status != noErr)
		return NO;
	
	char *args[7];
	args[0] = "--verbose";		// extra debug info in Console
	args[1] = "--legacy";		// support for BIOS-based operating systems
	args[2] = "--setBoot";		// boot it up
	args[3] = "--nextonly";		// only change the boot disk for next boot
	args[4] = "--folder";
	args[5] = (char *)[volume UTF8String];
	args[6] = NULL;
	
	status = AuthorizationExecuteWithPrivileges(authorizationRef, "/usr/sbin/bless", 0, args, NULL);
	*userCancelled = (status == errAuthorizationCanceled);
	return (status == noErr);
}

int switchToWindowsAndRestart()
{
	NSString *volume = windowsVolume();
	if (volume == nil)
		return noWindowsVolumeError;
	
	BOOL userCancelledAuthentication;
	if (!setVolumeAsStartupDisk(volume, &userCancelledAuthentication))
		return (userCancelledAuthentication ? authCancelled : authFailedOrBlessFailedError);
	
	if (!restartComputer())
		return restartFailedError;
	
	return switchSuccessError;
}

void bootIntoWindows()
{
	BOOL quit = NO;
	
	[NSApp activateIgnoringOtherApps:YES];

	switch (switchToWindowsAndRestart())
	{
		case noWindowsVolumeError:
			NSRunAlertPanel(NSLocalizedString(@"BootChamp was unable to find a Windows volume", nil),
							NSLocalizedString(@"If your Windows installation is on a separate drive, please connect it and relaunch BootChamp.", nil),
							nil,nil,nil);
			break;
			
		case authFailedOrBlessFailedError:
			NSRunAlertPanel(NSLocalizedString(@"BootChamp was unable to set your Windows volume as the temporary startup disk", nil),
							NSLocalizedString(@"Authentication may have failed.", nil),
							nil,nil,nil);
			break;

		case restartFailedError:
			NSRunAlertPanel(NSLocalizedString(@"BootChamp was unable to restart your computer", nil),
							NSLocalizedString(@"Please restart your computer manually.", nil),
							nil,nil,nil);
			break;
			
		case authCancelled:
		case switchSuccessError:
			quit = YES;
			break;
	}
	
	if (quit)
		[NSApp terminate:nil];
}
