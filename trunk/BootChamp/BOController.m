//
//  BOController.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BOController.h"
#import <Carbon/Carbon.h>
#import <Security/Security.h>
#import <sys/mount.h>


@implementation BOController

- (BOOL)restartComputer
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

- (NSString *)windowsVolume
{
	struct statfs *buf = NULL;
	unsigned i, count = 0;
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		if ((buf[i].f_flags & MNT_LOCAL) != MNT_LOCAL)
			continue;
		
		char *volType = buf[i].f_fstypename;
		if ((strcmp(volType, "ntfs") == 0) || (strcmp(volType, "msdos") == 0))
		{
			NSString *path = [NSString stringWithUTF8String:buf[i].f_mntonname];
			if (path)
				return path;
		}
		else
			NSLog(@"Unsupported? %s", volType);
	}
	
	return nil;
}

- (BOOL)setVolumeAsStartupDisk:(NSString *)volume
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
	return (status == noErr);
}

- (OSStatus)switchToWindowsAndRestart
{
	NSString *windowsVolume = [self windowsVolume];
	if (windowsVolume == nil)
		return noWindowsVolumeError;
	
	if (![self setVolumeAsStartupDisk:windowsVolume])
		return authFailedOrBlessFailedError;
	
	if (![self restartComputer])
		return restartFailedError;
	
	return switchSuccessError;
}

- (void)applicationDidFinishLaunching:(NSNotification *)not
{
	switch ([self switchToWindowsAndRestart])
	{
		case noWindowsVolumeError:
			NSRunAlertPanel(@"BootChamp was unable to find a Windows volume",
							@"If your Windows installation is on a separate drive, please connect it and relaunch BootChamp.",
							@"OK",nil,nil);
			break;
			
		case authFailedOrBlessFailedError:
			NSRunAlertPanel(@"BootChamp was unable to set your Windows volume as startup disk",
							@"Authentication may have failed.",
							@"OK",nil,nil);
			break;
		
		case restartFailedError:
			NSRunAlertPanel(@"BootChamp was unable to restart your computer",
							@"Please restart your computer manually.",
							@"OK",nil,nil);
			break;
			
		case switchSuccessError:
			break;
	}

	[NSApp terminate:nil];
}

@end
