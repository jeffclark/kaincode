//
//  KWXfireInvitationController.m
//  Xfire
//
//  Created by Kevin Wojniak on 7/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "KWXfireInvitationController.h"


@implementation KWXfireInvitationController

- (id)init
{
	if (self = [super initWithWindowNibName:@"ReceiveInvitation" owner:self])
	{
	}
	
	return self;
}

- (void)dealloc
{
	[_username release];
	[super dealloc];
}

- (void)showWindowForUsername:(NSString *)username message:(NSString *)message
{
	[_username release];
	_username = [username copy];
	
	NSWindow *win = [self window];
	[usernameField setStringValue:[NSString stringWithFormat:@"%@ has requested to add you as a friend.", username]];
	[messageField setStringValue:message];
	[win makeKeyAndOrderFront:nil];
	[NSApp requestUserAttention:NSCriticalRequest];
}

- (void)acceptInvite:(BOOL)accept
{
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
		_username, @"username",
		[NSNumber numberWithBool:accept], @"accept",
		nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KWXfireDenyAcceptInvitation" object:d];
}

- (IBAction)deny:(id)sender
{
	[self acceptInvite:NO];
	[self close];
}

- (IBAction)accept:(id)sender
{
	[self acceptInvite:YES];
	[self close];
}

@end
