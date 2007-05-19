//
//  KWXfireService.m
//  Adium
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "KWXfireService.h"
#import "KWXfireAccount.h"
#import "KWXfireAccountViewController.h"

#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIStatusControllerProtocol.h>
#import <AIUtilities/AIImageAdditions.h>

@implementation KWXfireService

- (Class)accountClass
{
	return [KWXfireAccount class];
}

- (AIAccountViewController *)accountViewController
{
    return [KWXfireAccountViewController accountViewController];
}

- (NSString *)serviceCodeUniqueID
{
	return @"xfire";
}
- (NSString *)serviceID
{
	return @"Xfire";
}
- (NSString *)serviceClass
{
	return @"Xfire";
}
- (NSString *)shortDescription
{
	return @"Xfire";
}
- (NSString *)longDescription
{
	return @"Xfire";
}
- (NSCharacterSet *)allowedCharacters
{
	return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890"];
}
- (NSCharacterSet *)ignoredCharacters{
	return [NSCharacterSet characterSetWithCharactersInString:@""];
}
- (int)allowedLength{
	return 30;
}
- (BOOL)caseSensitive{
	return YES;
}
- (AIServiceImportance)serviceImportance{
	return AIServiceSecondary;
}
- (BOOL)supportsProxySettings{
	return NO;
}
- (BOOL)requiresPassword
{
	return YES;
}
- (void)registerStatuses{
	[[adium statusController] registerStatus:STATUS_NAME_AVAILABLE
							 withDescription:[[adium statusController] localizedDescriptionForCoreStatusName:STATUS_NAME_AVAILABLE]
									  ofType:AIAvailableStatusType
								  forService:self];
	
	[[adium statusController] registerStatus:STATUS_NAME_AWAY
							 withDescription:[[adium statusController] localizedDescriptionForCoreStatusName:STATUS_NAME_AWAY]
									  ofType:AIAwayStatusType
								  forService:self];
}

- (NSImage *)defaultServiceIconOfType:(AIServiceIconType)iconType
{
	if (iconType == AIServiceIconLarge)
		return [NSImage imageNamed:@"XfireLarge" forClass:[self class]];
	return [NSImage imageNamed:@"XfireSmall" forClass:[self class]];
}

- (BOOL)canCreateGroupChats
{
	return NO; // Xfire does support this though...
}

@end
