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
	noWindowsVolumeError,
	authFailedOrBlessFailedError,
	authCancelled,
	bcblessError,
	restartFailedError,
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
		
		BOOL isLocal = ((buf[i].f_flags & MNT_LOCAL) == MNT_LOCAL);
		
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

		NSLog(@"%s: %s (%@, %@, %d)", volPath, volType, volKind, bsdName, isLocal);

		if (isValidBootCampVolume)
			return [NSDictionary dictionaryWithObjectsAndKeys:
					bsdName, @"bsdName",
					[[NSString stringWithUTF8String:volPath] lastPathComponent], @"name",
					nil];
	}
	
	return nil;
}

BOOL setStartupDisk(NSString *bsdName, NSString *name, BOOL *userCancelled, NSDictionary **outputDict)
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
	
	char *args[3];
	args[0] = "-device";
	args[1] = (char *)[bsdName UTF8String];
	args[2] = NULL;
	
	FILE *file = NULL;
	NSString *toolPath = [[NSBundle mainBundle] pathForResource:@"bcbless" ofType:nil];
	status = AuthorizationExecuteWithPrivileges(authorizationRef, [toolPath fileSystemRepresentation], kAuthorizationFlagDefaults, args, &file);
	if (status != errAuthorizationSuccess) {
		*userCancelled = (status == errAuthorizationCanceled);
		NSLog(@"AuthorizationExecuteWithPrivileges error %d", status);
	}
	
	NSMutableString *str = [NSMutableString string];
	char line[512];
	while (fgets(line, 512, file) != NULL)
		[str appendFormat:@"%s", line];
	*outputDict = [NSPropertyListSerialization propertyListFromData:[str dataUsingEncoding:NSUTF8StringEncoding] mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:nil];
	if (file)
		fclose(file);

	AuthorizationFree(authorizationRef, kAuthorizationFlagDefaults);
	return (status == errAuthorizationSuccess);
}

int switchToWindowsAndRestart(NSString **bcblessErrorMessage)
{
	NSDictionary *dict = windowsVolume();
	if (dict == nil || [dict count] < 2)
		return noWindowsVolumeError;
	
	NSDictionary *outputDict = nil;
	BOOL userCancelledAuthentication = NO;
	if (!setStartupDisk([dict objectForKey:@"bsdName"], [dict objectForKey:@"name"], &userCancelledAuthentication, &outputDict))
	{
		if (userCancelledAuthentication)
			return authCancelled;

		return authFailedOrBlessFailedError;
	}

	if (outputDict && [outputDict isKindOfClass:[NSDictionary class]])
	{
		NSString *error = [outputDict objectForKey:@"Error"];
		if (error) {
			*bcblessErrorMessage = error;
			return bcblessError;
		}
	}
	
	if (!restartComputer())
		return restartFailedError;
	
	return switchSuccessError;
}

int bootIntoWindows()
{
	BOOL quit = NO;
	NSString *bcblessErrorMessage = nil;
	int status = switchToWindowsAndRestart(&bcblessErrorMessage);

	NSLog(@"switchToWindowsAndRestart: %d", status);
	
	[NSApp activateIgnoringOtherApps:YES]; // app may have gone unactive from auth dialog
	
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
			
		case bcblessError:
			NSRunAlertPanel(NSLocalizedString(@"BootChamp was unable to set your Windows volume as the temporary startup disk", nil),
							bcblessErrorMessage,
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
