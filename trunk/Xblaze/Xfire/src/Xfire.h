

//
//  Xfire.h
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Xfire;
@class XfireBuddyList;
@class XfireGamesList;
@class XfireGameInfo;
@class XfireBuddyListEntry;


@protocol XfireDelegate
- (void)xfire:(Xfire *)xfire loginStatus:(BOOL)success;
- (void)xfireDidUpdateBuddyList:(Xfire *)xfire;
- (void)xfire:(Xfire *)xfire receivedMessage:(NSString *)message fromBuddy:(XfireBuddyListEntry *)entry;
- (void)xfire:(Xfire *)xfire receivedInvitationMessage:(NSString *)message fromUser:(NSString *)username withNickname:(NSString *)nickname;
- (void)xfireOtherUseLoggedOn:(Xfire *)xfire;
- (void)xfire:(Xfire *)xfire setGameStatus:(XfireGameInfo *)gameInfo;
@end


@interface Xfire : NSObject
{
	id <XfireDelegate> _delegate;
	NSString *_username;
	XfireBuddyList *_buddyList;
	XfireGamesList *_fullGamesList;
	
	BOOL _connected;
}

- (id)initWithDelegate:(id <XfireDelegate>)delegate;

// commands
- (void)connectWithUsername:(NSString *)username password:(NSString *)password;
- (void)disconnect;
- (void)setStatusMessage:(NSString *)message;
- (void)sendMessage:(NSString *)message to:(XfireBuddyListEntry *)buddy;
- (void)acceptInvitationFromUser:(NSString *)username;
- (void)denyInvitationFromUser:(NSString *)username;
- (void)inviteUser:(NSString *)username withMessage:(NSString *)message;
- (void)removeUser:(NSString *)username;

// properties
- (NSString *)username;
- (XfireBuddyList *)buddyList;
- (XfireGamesList *)gamesList;

@end