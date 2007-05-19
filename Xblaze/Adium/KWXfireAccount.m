#import "KWXfireAccount.h"
#import "KWXfirePlugin.h"

#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIStatusControllerProtocol.h>
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AIChatControllerProtocol.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/AIInterfaceControllerProtocol.h>
#import <Adium/AIAccountControllerProtocol.h>
#import <Adium/AIChat.h>
#import <Adium/AIContentMessage.h>
#import <Adium/AIContentTyping.h>
#import <Adium/AIHTMLDecoder.h>
#import <Adium/AIListContact.h>
#import <Adium/AIStatus.h>
#import <Adium/NDRunLoopMessenger.h>
#import <AIUtilities/AIMutableOwnerArray.h>
#import <AIUtilities/AIObjectAdditions.h>

#import "XfireBuddyList.h"
#import "XfireBuddyListEntry.h"
#import "XfireGamesList.h"
#import "XfireGameInfo.h"

#import "KWXfireInvitationController.h"


@interface KWXfireAccount (private)
- (BOOL)updateStatusForContact:(AIListContact *)contact entry:(XfireBuddyListEntry *)entry;
- (void)setStatusMessage:(NSString *)statusMessage;
- (void)updateBuddyList;
@end


@implementation KWXfireAccount

- (void)initAccount
{
    [super initAccount];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAcceptOrDenyInvitation:) name:@"KWXfireDenyAcceptInvitation" object:nil];
	
	// initialize our Xfire controller object with self as delegate so we
	// can respond to messages
	_xfire = [[Xfire alloc] initWithDelegate:self];
	_invites = [[NSMutableArray alloc] init];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_xfire release];
	[_invites release];
	[_connectDate release];
	
	[super dealloc];
}

- (BOOL)disconnectOnFastUserSwitch { return YES; }
- (BOOL)connectivityBasedOnNetworkReachability { return NO; }
 // xfire doens't provide user icons
- (NSData *)userIconData { return nil; }
// we don't provide typing info yet (although Xfire supports this)
- (BOOL)sendTypingObject:(AIContentTyping *)inTypingObject { return YES; }
// initiate a new chat
- (BOOL)openChat:(AIChat *)chat { return YES; }
// close a chat instance
- (BOOL)closeChat:(AIChat *)inChat { return YES; }

- (BOOL)availableForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact { return YES; }

#pragma mark -
#pragma mark Adium Methods

// called when we need to connect
- (void)connect
{
	[super connect];
	
	//[self didConnect];
	
	// connect to Xfire using the supplie username and password
	[_xfire connectWithUsername:[self explicitFormattedUID] password:[[adium accountController] passwordForAccount:self]];
}

// called when we need to discconnect
- (void)disconnect
{
	[super disconnect];
	
	[self updateBuddyList];
	
	// disocnnect from Xfire
	[_xfire disconnect];
	
	[self didDisconnect];
}

// respond to changes in status messages
- (void)setStatusState:(AIStatus *)statusState usingStatusMessage:(NSAttributedString *)statusMessage
{
	// we were told to go offline...
	if ([statusState statusType] == AIOfflineStatusType)
	{
		[self disconnect];
		return;
	}

	// we need to be online for any other status, so check that first
	if ([self online] == NO)
	{
		[self connect];
		return;
	}
	
	// hande Away and Available statuses
	switch ([statusState statusType])
	{
		case AIAvailableStatusType:
			[self setStatusMessage:[statusMessage string]];
			break;
		case AIAwayStatusType:
			// Adium sends nil statusMessage for Away..
			[self setStatusMessage:([statusMessage string] ? [statusMessage string] : @"")];
			break;
		default:
			break;
	}
}

// we are sending a message to another Xfire user
- (BOOL)sendMessageObject:(AIContentMessage *)inContentMessage
{
	[_xfire sendMessage:[inContentMessage messageString]
					 to:[[_xfire buddyList] entryWithUsername:[[inContentMessage destination] UID]]];
	return YES;
}

// status keys this account supports
- (NSSet *)supportedPropertyKeys
{
	static NSMutableSet *supportedPropertyKeys = nil;
	
	if (!supportedPropertyKeys) {
		supportedPropertyKeys = [[NSMutableSet alloc] initWithObjects:
			@"Display Name",
			@"Online",
			@"Offline",
			@"Away",
			@"AwayMessage",
			@"StatusMessage",
			nil];
		
		[supportedPropertyKeys unionSet:[super supportedPropertyKeys]];
	}
	
	return supportedPropertyKeys;
}

- (BOOL)contactListEditable
{
	return YES;
}

- (void)addContacts:(NSArray *)objects toGroup:(AIListGroup *)group
{
	NSEnumerator *e = [objects objectEnumerator];
	AIListContact *contact;
	while (contact = [e nextObject])
	{
		[_xfire inviteUser:[contact UID] withMessage:@"Add me to your Friends list"];
	}
}

- (void)removeContacts:(NSArray *)objects
{
	NSEnumerator *e = [objects objectEnumerator];
	AIListContact *contact;
	
	[[adium contactController] delayListObjectNotifications];
	
	while (contact = [e nextObject])
	{
		[_xfire removeUser:[contact UID]];
		[contact setRemoteGroupName:nil];
		[contact setOnline:NO notify:NotifyNow silently:YES];
		[contact notifyOfChangedStatusSilently:YES];
	}
	
	[[adium contactController] endListObjectNotificationsDelay];

	[self updateBuddyList];
}


#pragma mark -
#pragma mark Xfire Delegate

// delegate method called from our Xfire object when a login attempt has succeeded or failed
- (void)xfire:(Xfire *)xfire loginStatus:(BOOL)success
{
	if (success)
	{
		[self didConnect];
		
		[_connectDate release];
		_connectDate = [[NSDate date] retain];
	}
	else
	{
		[self disconnect];
		
		[[adium interfaceController] handleErrorMessage:@"Xfire Error"
										withDescription:@"Failed to log in with supplied username and password. Please try again."];
	}
}

// delegate method called from our Xfire object when we've received a message from another Xfire user
- (void)xfire:(Xfire *)xfire receivedMessage:(NSString *)message fromBuddy:(XfireBuddyListEntry *)entry
{
	// get the contact that sent the message
	AIListContact *source = [self contactWithUID:[entry username]];
	// create the messsage content
	AIContentMessage *msg = [[[AIContentMessage alloc] initWithChat:[[adium chatController] chatWithContact:source]
															 source:source
														destination:nil
															   date:[NSDate date]
															message:[[[NSAttributedString alloc] initWithString:message] autorelease]] autorelease];
	// display the message in the chat window
	[[adium contentController] displayContentObject:msg immediately:YES];
}

- (void)xfire:(Xfire *)xfire receivedInvitationMessage:(NSString *)message fromUser:(NSString *)username withNickname:(NSString *)nickname
{
	KWXfireInvitationController *inv = [[KWXfireInvitationController alloc] init];
	[inv showWindowForUsername:username message:message];
	
	[_invites addObject:inv];
	[inv release];
}

- (void)userDidAcceptOrDenyInvitation:(NSNotification *)n
{
	NSDictionary *d = (NSDictionary *)[n object];
	NSString *username = [d objectForKey:@"username"];
	BOOL accept = [[d objectForKey:@"accept"] boolValue];
	if (accept)
		[_xfire acceptInvitationFromUser:username];
	else
		[_xfire denyInvitationFromUser:username];
}

// delegate method called from our Xfire object when our Xfire buddy list has been updated
// (i.e. status messages, on/offline buddies, etc
- (void)xfireDidUpdateBuddyList:(Xfire *)xfire
{
	[self updateBuddyList];
}

// delegate method sent when this account was logged on from another location
- (void)xfireOtherUseLoggedOn:(Xfire *)xfire
{
	[[adium interfaceController] handleErrorMessage:@"Xfire Error"
									withDescription:@"Another user has logged on with your username."];
	[self disconnect];
}

- (void)xfire:(Xfire *)xfire setGameStatus:(XfireGameInfo *)gameInfo
{
	
}

#pragma mark -
#pragma mark Xfire Helpers

// helper method for setting a contact's status message/type. returns YES on change, NO on no change
- (BOOL)updateStatusForContact:(AIListContact *)contact entry:(XfireBuddyListEntry *)entry
{
	BOOL change = NO;
	XfireGameInfo *gameInfo = [[_xfire gamesList] gameForID:[NSString stringWithFormat:@"%d", [entry gameID]]];
	NSMutableString *message = [NSMutableString stringWithString:[entry statusMessage]];
	BOOL isAway = NO;
	
	if ([message length] > 0)
		isAway = YES;
	
	if (gameInfo != nil && [gameInfo name] != nil)
		[message appendFormat:@"%@%@", ([message length] > 0 ? @"\n\n" : @""), [gameInfo name]];

	if ([message length] == 0) // available
	{
		if ([[contact statusMessageString] length] != 0)
		{
			[contact setUserIconData:nil];
			[contact setStatusMessage:nil notify:YES];
			[contact setStatusWithName:nil statusType:AIAvailableStatusType notify:YES];
			change = YES;
		}
	}
	else
	{
		if (![[contact statusMessageString] isEqualToString:message])
		{
			[contact setStatusMessage:[[[NSAttributedString alloc] initWithString:message] autorelease] notify:YES];
			[contact setStatusWithName:nil statusType:(isAway ? AIAwayStatusType : AIAvailableStatusType) notify:YES];
			
			change = YES;
		}
	}

	NSData *userIconData = [[gameInfo icon] TIFFRepresentation];
	if (gameInfo)
	{
		if ([contact userIconData] != userIconData)
		{
			[contact setUserIconData:userIconData];
			change = YES;
		}
	}
	else
		[contact setUserIconData:nil];
	
	
	
	if (change)
		[contact notifyOfChangedStatusSilently:NO];
	return change;
}

- (void)setStatusMessage:(NSString *)message
{
	if (message != nil)
	{
		[_xfire setStatusMessage:([message length] > 0 ? message : @"(AFK) Away From Keyboard")];
		[self setStatusObject:[NSNumber numberWithBool:YES] forKey:@"Away" notify:YES];
	}
	else
	{
		[_xfire setStatusMessage:@""]; // send empty string to Xfire to come back from away
		[self setStatusObject:[NSNumber numberWithBool:YES] forKey:@"Available" notify:YES];
	}
}

// helper method for updating the buddy list
- (void)updateBuddyList
{
	BOOL areOnline = [[self statusObjectForKey:@"Online"] boolValue];
	BOOL justConnected = ([[NSDate date] timeIntervalSinceDate:_connectDate] <= 2.0);
	AIListContact *contact = nil;

	NSEnumerator *entriesEnum = [[[_xfire buddyList] allEntries] objectEnumerator];
	XfireBuddyListEntry *entry = nil;
	
	if (justConnected)
		[[adium contactController] delayListObjectNotifications];
	
	while ((entry = [entriesEnum nextObject]))
	{
		BOOL changeContact = NO;

		contact = [[adium contactController] existingContactWithService:[self service] account:self UID:[entry username]];
		if (contact == nil)
		{
			contact = [[adium contactController] contactWithService:[self service] account:self UID:[entry username]];
			[contact setOnline:[entry isOnline] notify:NotifyNever silently:YES];
			continue;
		}
		
		/*if (!areOnline)
		{
			[contact setRemoteGroupName:nil];
			[contact setOnline:NO notify:NotifyNever silently:YES];
			continue;
		}*/
		
		BOOL onlineValue = (areOnline ? [entry isOnline] : areOnline); 
		if ([contact online] != onlineValue)
		{
			// the status for a contact is being changed.
			// if we're online, and the contact is currently online, then they went offline.
			// otherwise, the contact either just signed on, or we just got the online info about
			// this contact from xfire right after connecting.. so we use a cheap hack to 
			// check the time since we connected :)
			
			if (areOnline && !justConnected && 
				(([contact online] && ![entry isOnline]) ||
				 (![contact online] && [entry isOnline]))
				)
			{
				// the user signed off or on ?
				[contact setOnline:onlineValue notify:NotifyNow silently:NO];
			}
			else
				[contact setOnline:onlineValue notify:NotifyLater silently:YES];
			changeContact = YES;
		}
		
		if (![[contact remoteGroupName] isEqualToString:@"Xfire"])
		{
			[contact setRemoteGroupName:@"Xfire"];
			changeContact = YES;
		}
		
		if (![[contact displayName] isEqualToString:[entry displayName]])
		{
			[contact setDisplayName:[entry displayName]];
			changeContact = YES;
		}
		
		//NSString *status = [[[contact statusMessageString] copy] autorelease];
		if ([self updateStatusForContact:contact entry:entry])
		{
			//NSLog(@"changed statusMessage: %@", [entry displayName]);
			//NSLog(@"was \"%@\" now \"%@\"", status, [contact statusMessageString]);
			changeContact = YES;
		}
		
		if (changeContact)
		{
			//NSLog(@"changeContact: %@", [entry username]);
			[contact notifyOfChangedStatusSilently:(justConnected ? YES : NO)];
		}
	}
	
	if (justConnected)
		[[adium contactController] endListObjectNotificationsDelay];
}	


@end
