//
//  BOBoot.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/4/07.
//  Copyright 2007-2009 Kainjow LLC. All rights reserved.
//

#import "BOBoot.h"
#import "BOMedia.h"
#import <Carbon/Carbon.h>
#import <Security/Security.h>


@implementation BOBoot

@synthesize nextonly, media;

- (void)dealloc
{
	self.media = nil;
	[super dealloc];
}

- (BOOL)restartComputer
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
    OSStatus error = noErr;
	
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, sizeof(kPSNOfSystemProcess), &targetDesc);
    if (error != noErr)
        return NO;
	
    error = AECreateAppleEvent(kCoreEventClass, kAERestart, &targetDesc, kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
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


- (OSStatus)blessMedia:(NSDictionary **)outputDict
{
	OSStatus status;
	AuthorizationRef authorizationRef;
	
	status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
	if (status != errAuthorizationSuccess) {
		return status;
	}
	
	NSString *prompt = [NSString stringWithFormat:NSLocalizedString(@"Administrative access is needed to change your startup disk to \"%@\".", ""), media.name];
	const char *promptUTF8 = [prompt UTF8String];
	AuthorizationItem envItems = {kAuthorizationEnvironmentPrompt, strlen(promptUTF8), (void *)promptUTF8, 0};
	AuthorizationEnvironment env = {1, &envItems};
	AuthorizationItem rightsItems = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &rightsItems};
	status = AuthorizationCopyRights(authorizationRef, &rights, &env, kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights, NULL);
	if (status != errAuthorizationSuccess) {
		AuthorizationFree(authorizationRef, kAuthorizationFlagDefaults);
		return status;
	}
	
	char *args[5];
	if (media.deviceName) {
		args[0] = "-device";
		args[1] = (char *)[media.deviceName UTF8String];
	}
	else {
		args[0] = "-folder";
		args[1] = (char *)[media.mountPoint UTF8String];
	}
	args[2] = "-nextonly";
	args[3] = (self.nextonly ? "yes" : "no");
	args[4] = NULL;
	
	FILE *file = NULL;
	NSString *toolPath = [[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"bcbless"];
	status = AuthorizationExecuteWithPrivileges(authorizationRef, [toolPath fileSystemRepresentation], kAuthorizationFlagDefaults, args, &file);
	if (status != errAuthorizationSuccess) {
		return status;
	}
	
	if (file)
	{
		NSMutableString *str = [NSMutableString string];
		char line[512];
		while (fgets(line, 512, file) != NULL)
			[str appendFormat:@"%s", line];
		*outputDict = [NSPropertyListSerialization propertyListFromData:[str dataUsingEncoding:NSUTF8StringEncoding] mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:nil];
		fclose(file);
	}

	AuthorizationFree(authorizationRef, kAuthorizationFlagDefaults);
	return status;
}

- (int)switchToWindowsAndRestart:(NSString **)bcblessErrorMessage
{
	if (media == nil)
		return noWindowsVolumeError;
	
	NSDictionary *outputDict = nil;
	OSStatus status = [self blessMedia:&outputDict];
	if (status == errAuthorizationCanceled)
		return authCancelled;
	else if (status != errAuthorizationSuccess)
		return authFailedOrBlessFailedError;

	if (outputDict && [outputDict isKindOfClass:[NSDictionary class]])
	{
		NSString *error = [outputDict objectForKey:@"Error"];
		if (error) {
			*bcblessErrorMessage = error;
			return bcblessError;
		}
		
#if 0
		NSString *successMsg = [outputDict objectForKey:@"Success"];
		*bcblessErrorMessage = successMsg;
		return bcblessError;
#endif
	}
	
	if (![self restartComputer])
		return restartFailedError;
	
	return switchSuccessError;
}

- (NSInteger)bootIntoWindows
{
	BOOL quit = NO;
	NSString *bcblessErrorMessage = nil;
	int status = [self switchToWindowsAndRestart:&bcblessErrorMessage];

	[NSApp activateIgnoringOtherApps:YES]; // app may have gone inactive from auth dialog

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
							(bcblessErrorMessage ? bcblessErrorMessage : @""),
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

@end
