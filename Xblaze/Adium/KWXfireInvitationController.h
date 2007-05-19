//
//  KWXfireInvitationController.h
//  Xfire
//
//  Created by Kevin Wojniak on 7/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KWXfireInvitationController : NSWindowController
{
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *messageField;
	NSString *_username;
}

- (void)showWindowForUsername:(NSString *)username message:(NSString *)message;

- (IBAction)deny:(id)sender;
- (IBAction)accept:(id)sender;

@end
