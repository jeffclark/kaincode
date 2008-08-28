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
#import <DiskArbitration/DiskArbitration.h>

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

NSDictionary *windowsVolume()
{
	struct statfs *buf = NULL;
	unsigned i, count = 0;
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		BOOL isValidBootCampVolume = NO;
		char *volType = buf[i].f_fstypename;
		char *volPath = buf[i].f_mntonname;
		NSString *volKind = nil;
		NSString *bsdName = [NSString stringWithCString:buf[i].f_mntfromname encoding:NSUTF8StringEncoding];
		
		if ((buf[i].f_flags & MNT_LOCAL) != MNT_LOCAL)
			continue;
		
		// use normal statfs to check for FAT32 (msdos), or NTFS (ufsd, ntfs)
		if ((strcmp(volType, "ntfs") == 0) || (strcmp(volType, "msdos") == 0) || (strcmp(volType, "ufsd") == 0))
			isValidBootCampVolume = YES;
		
		// When MacFUSE and NTFS-3G are installed, statfs shows "fusefs" for the type name, so we need to use
		// the DiskArbitration framework to get the "kind", and check that specifically.
		if (!isValidBootCampVolume && (strcmp(volType, "fusefs") == 0))
		{
			DASessionRef session = DASessionCreate(kCFAllocatorDefault);
			if (session)
			{
				DADiskRef disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, [bsdName UTF8String]);
				if (disk)
				{
					CFDictionaryRef desc = DADiskCopyDescription(disk);
					if (desc) {
						NSDictionary *dict = (NSDictionary *)desc;
						volKind = [dict objectForKey:(NSString *)kDADiskDescriptionVolumeKindKey];
						if ((volKind != nil) && [(NSString *)volKind rangeOfString:@"ntfs-3g" options:NSCaseInsensitiveSearch].location != NSNotFound) {
							isValidBootCampVolume = YES;
						}
						
						CFRelease(desc);
					}
					CFRelease(disk);
				}
				CFRelease(session);
			}
		}

		NSLog(@"%s: %s (%@, %@)", volPath, volType, volKind, bsdName);

		if (isValidBootCampVolume)
			return [NSDictionary dictionaryWithObjectsAndKeys:
					bsdName, @"bsdName",
					[[NSString stringWithUTF8String:volPath] lastPathComponent], @"name",
					nil];
	}
	
	return nil;
}

BOOL setStartupDisk(NSString *bsdName, NSString *name, BOOL *userCancelled)
{
	OSStatus status;
	AuthorizationRef authorizationRef;
	
	status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
	if (status != errAuthorizationSuccess) {
		NSLog(@"AuthorizationCreate error %d", status);
		return NO;
	}
	
	NSString *prompt = [NSString stringWithFormat:NSLocalizedString(@"Administrative access is needed to temporarily change your startup disk to \"%@\".", ""), name];
	const char *promptUTF8 = [prompt UTF8String];
	AuthorizationItem envItems = {kAuthorizationEnvironmentPrompt, strlen(promptUTF8), (void *)promptUTF8, 0};
	AuthorizationEnvironment env = {1, &envItems};
	AuthorizationItem rightsItems = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &rightsItems};
	status = AuthorizationCopyRights(authorizationRef, &rights, &env, kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights, NULL);
	if (status != errAuthorizationSuccess) {
		NSLog(@"AuthorizationCopyRights error %d", status);
		AuthorizationFree(authorizationRef, kAuthorizationFlagDefaults);
		*userCancelled = (status == errAuthorizationCanceled);
		return NO;
	}
	
	char *args[7];
	args[0] = "--verbose";		// extra debug info in Console
	args[1] = "--legacy";		// support for BIOS-based operating systems
	args[2] = "--setBoot";		// boot it up
	args[3] = "--nextonly";		// only change the boot disk for next boot
	args[4] = "--device";
	args[5] = (char *)[bsdName UTF8String];
	args[6] = NULL;
	
	status = AuthorizationExecuteWithPrivileges(authorizationRef, "/usr/sbin/bless", kAuthorizationFlagDefaults, args, NULL);
	if (status != errAuthorizationSuccess) {
		*userCancelled = (status == errAuthorizationCanceled);
		NSLog(@"AuthorizationExecuteWithPrivileges error %d", status);
	}

	AuthorizationFree(authorizationRef, kAuthorizationFlagDefaults);
	return (status == errAuthorizationSuccess);
}

int switchToWindowsAndRestart()
{
	NSDictionary *dict = windowsVolume();
	if (dict == nil || [dict count] < 2)
		return noWindowsVolumeError;
	
	BOOL userCancelledAuthentication = NO;
	if (!setStartupDisk([dict objectForKey:@"bsdName"], [dict objectForKey:@"name"], &userCancelledAuthentication)) {
		[NSApp activateIgnoringOtherApps:YES]; // app may have gone unactive from auth dialog
		return (userCancelledAuthentication ? authCancelled : authFailedOrBlessFailedError);
	}
	
	if (!restartComputer())
		return restartFailedError;
	
	return switchSuccessError;
}

int bootIntoWindows()
{
	BOOL quit = NO;
	int status = switchToWindowsAndRestart();
	NSLog(@"switchToWindowsAndRestart: %d", status);
	switch (status)
	{
		case noWindowsVolumeError:
			NSRunAlertPanel(NSLocalizedString(@"BootChamp was unable to find a Windows volume", nil),
							NSLocalizedString(@"Supported file systems are FAT32 and NTFS.", nil),
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
			break;

		case switchSuccessError:
			quit = YES;
			break;
	}
	
	return quit;
}
