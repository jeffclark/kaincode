//
//  XFController.m
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XFController.h"

#import "XfireBuddyList.h"
#import "XfireBuddyListEntry.h"
#import "XfireGamesList.h"
#import "XfireGameInfo.h"


@implementation XFController

- (id)init
{
	if (self = [super init])
	{
		_xfire = [[Xfire alloc] initWithDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	[_xfire release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[self setWindowFrameAutosaveName:@"XFBuddyListWindow"];
	[buddyListTableView setAutosaveTableColumns:YES];
	[buddyListTableView setAutosaveName:@"XFBuddyListTable"];
	
	NSString *pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
	if ([pass length] > 0)
		[passwordField setStringValue:pass];
}

- (IBAction)login:(id)sender
{
	if ([[sender title] isEqualToString:@"Connect"])
	{
		[_xfire connectWithUsername:@"kainjow" password:[passwordField stringValue]];
		[sender setTitle:@"Disconnect"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[passwordField stringValue] forKey:@"Password"];
	}
	else
	{
		[_xfire disconnect];
		[sender setTitle:@"Connect"];
		
		[buddyListTableView reloadData];
		[statusField setStringValue:@""];
	}
}

- (IBAction)setStatus:(id)sender
{
	[_xfire setStatusMessage:[statusField stringValue]];
}

- (void)xfire:(Xfire *)xfire loginStatus:(BOOL)success
{
	if (success == NO)
	{
		NSBeep();
		NSBeginAlertSheet(@"Incorrect Username or Password",@"OK",nil,nil,[self window],self,nil,nil,NULL,@"Failed to log in.");
	}
	
	[buddyListTableView reloadData];
}

- (void)xfireDidUpdateBuddyList:(Xfire *)xfire
{
	[buddyListTableView reloadData];
}

- (void)xfire:(Xfire *)xfire receivedMessage:(NSString *)message fromBuddy:(XfireBuddyListEntry *)entry
{
	NSLog(@"received message from %@: %@", [entry username], message);
}

- (void)xfire:(Xfire *)xfire receivedInvitationMessage:(NSString *)message fromUser:(NSString *)username withNickname:(NSString *)nickname
{
	
}

- (void)xfireOtherUseLoggedOn:(Xfire *)xfire {}
- (void)xfire:(Xfire *)xfire setGameStatus:(XfireGameInfo *)gameInfo {}


#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)tv
{
	return [[[_xfire buddyList] onlineEntries] count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(int)rowIndex
{
	NSString *identifier = [tc identifier];
	XfireBuddyListEntry *entry = [[[_xfire buddyList] onlineEntries] objectAtIndex:rowIndex];
	
	if ([identifier isEqualToString:@"Name"])
		return [entry displayName];
	else if ([identifier isEqualToString:@"Status"])
		return [entry statusMessage];
	else if ([identifier isEqualToString:@"GameInfo"])
		return [[entry game] name];
	
	return nil;
}


@end
