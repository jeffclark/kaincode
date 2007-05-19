//
//  KWUtils.m
//  Xfire
//
//  Created by Kevin Wojniak on 7/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "KWUtils.h"
#import <AIUtilities/AIImageAdditions.h>


@implementation KWUtils

+ (int)runModalAlertWithMessage:(NSString *)message text:(NSString *)infoText defaultButton:(NSString *)defaultButton alternativeButton:(NSString *)altButton otherButton:(NSString *)otherButton
{
	NSAlert *alert = [NSAlert alertWithMessageText:message
									 defaultButton:defaultButton
								   alternateButton:altButton
									   otherButton:otherButton
						 informativeTextWithFormat:infoText];
	[alert setIcon:[NSImage imageNamed:@"Xblaze" forClass:[self class]]];
	return [alert runModal];
}

@end
