//
//  Xfire.m
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xfire.h"

#include <string>
#include <vector>
#include "packetlistener.h"
#include "xfirepacket.h"
#include "client.h"
#include "inviterequestpacket.h"
#include "client.h"
#include "xfirepacket.h"
#include "loginfailedpacket.h"
#include "loginsuccesspacket.h"
#include "otherloginpacket.h"
#include "messagepacket.h"
#include "sendstatusmessagepacket.h"
#include "sendmessagepacket.h"
#include "invitebuddypacket.h"
#include "sendacceptinvitationpacket.h"
#include "senddenyinvitationpacket.h"
#include "sendremovebuddypacket.h"
#include "sendnickchangepacket.h"
#include "sendgamestatuspacket.h"
#include "sendgamestatus2packet.h"
#include "dummyxfiregameresolver.h"
#include "sendgameserverpacket.h"
#include "recvoldversionpacket.h"
#include "recvstatusmessagepacket.h"
#include "recvprefspacket.h"
#include "recvdidpacket.h"
#include "buddylistgames2packet.h"
#include "recvremovebuddypacket.h"
using namespace std;
using namespace xfirelib;

#import "XfireBuddyList.h"
#import "XfireBuddyListEntry.h"
#import "XfireGamesList.h"
#import "XfireGameInfo.h"



@interface NSObject (mainthread)
- (void)performSelectorOnMainThread:(SEL)aSelector arg1:(void *)arg1  arg2:(void *)arg2  arg3:(void *)arg3;
@end
@implementation NSObject (mainthread)
- (void)performSelectorOnMainThread:(SEL)aSelector arg1:(void *)arg1  arg2:(void *)arg2  arg3:(void *)arg3
{
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:aSelector]];
	if (arg1 != NULL)
	{
		[inv setArgument:arg1 atIndex:2];
		if (arg2 != NULL)
		{
			[inv setArgument:arg2 atIndex:3];
			if (arg3 != NULL)
			{
				[inv setArgument:arg3 atIndex:4];
			}
		}
	}
	[inv setSelector:aSelector];
	[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
}
@end



@interface Xfire (priv)
- (void)connect;
- (void)informDelegateOfLoginStatus:(BOOL)status;
- (void)processPacket:(XFirePacket *)packet;
- (void)rebuildBuddyList;
- (void)setUsername:(NSString *)username;
- (void)setBuddyList:(XfireBuddyList *)buddyList;
@end


class XFireListener : public PacketListener
{
public:
    void (*receivedPacketFunc)(XFirePacket *packet, void *delegate);
	void *delegate;
	
	XFireListener::XFireListener(void (*receivedPacketFunc)(XFirePacket *, void *), void *delegate)
	{
		this->receivedPacketFunc = receivedPacketFunc;
		this->delegate = delegate;
	}

    void XFireListener::receivedPacket(XFirePacket *packet)
	{
		receivedPacketFunc(packet, this->delegate);
	}
};



// xfirelib
Client *client;
string *lastInviteRequest;
XFireListener *listener;


void receivedPacket(XFirePacket *packet, void *delegate);


@implementation Xfire

- (id)initWithDelegate:(id <XfireDelegate>)delegate
{
	if ((self = [super init]))
	{
		listener = new XFireListener(&receivedPacket, self);
		client = new Client();
		client->setGameResolver( new DummyXFireGameResolver() );
		client->addPacketListener(listener);
		
		_delegate = delegate;
		_buddyList = nil;
		
		_fullGamesList = [[XfireGamesList alloc] init];
		
		_connected = NO;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleGameStatusNotification:)
													 name:@"KWXfireGameStatus"
												   object:nil];
		
	}
	
	return self;
}

- (void)dealloc
{
	delete client;
	delete lastInviteRequest;
	delete listener;
	
	_delegate = nil;
	[_username release];
	[_buddyList release];
	[_fullGamesList release];
	
	[super dealloc];
}

- (void)connectWithUsername:(NSString *)username password:(NSString *)password
{
	[self setUsername:username];
	
	client->connect([[self username] UTF8String], [password UTF8String]);

	
	/*
		
		} else if(cmds[0] == "nick"){
			if(cmds.size() < 2) {
				cout << "Usage: nick <nickname>" << endl;
				continue;
			}
			SendNickChangePacket nick;
			nick.nick = joinString(cmds,1);
			client->send( &nick );
			cout << "Sent nick change." << endl;
		
		}
	}*/
}

void receivedPacket(XFirePacket *packet, void *delegate)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[(Xfire *)delegate performSelectorOnMainThread:@selector(processPacket:)
									 arg1:&packet
									 arg2:NULL
									 arg3:NULL];
	[pool release];
}

- (void)processPacket:(XFirePacket *)packet
{
	NSLog(@"getPacketId: %d", packet->getContent()->getPacketId());
	
	XFirePacketContent *content = packet->getContent();	
	switch (content->getPacketId())
	{
		// login succeeded
		case XFIRE_LOGIN_SUCCESS_ID:
		{
			[_delegate xfire:self loginStatus:YES];
			[_fullGamesList findGames];
			_connected = YES;
			break;
		}
		
		// the login failed
		case XFIRE_LOGIN_FAILED_ID:
		{
			[_delegate xfire:self loginStatus:NO];
			[self setBuddyList:nil];
			break;
		}
		
		// instant message was received
		case XFIRE_MESSAGE_ID:
		{
			if (((MessagePacket*)content)->getMessageType() == 0)
			{
				BuddyListEntry *entry = client->getBuddyList()->getBuddyBySid( ((MessagePacket*)content)->getSid() );
				XfireBuddyListEntry *buddy = [[self buddyList] entryWithUsername:
					[NSString stringWithUTF8String:entry->username.c_str()]];
				NSString *message = [NSString stringWithUTF8String:((MessagePacket*)content)->getMessage().c_str()];

				[_delegate xfire:self receivedMessage:message fromBuddy:buddy];
			}

			break;
		}
			
		// an invite was requested for this user
		case XFIRE_PACKET_INVITE_REQUEST_PACKET:
		{
			InviteRequestPacket *invite = (InviteRequestPacket*)content;
			
			[_delegate xfire:self
   receivedInvitationMessage:[NSString stringWithUTF8String:invite->msg.c_str()]
					fromUser:[NSString stringWithUTF8String:invite->name.c_str()]
				withNickname:[NSString stringWithUTF8String:invite->nick.c_str()]];
			
			/*cout << "  Name   :  " << invite->name << endl;
			cout << "  Nick   :  " << invite->nick << endl;
			cout << "  Message:  " << invite->msg << endl;
			cout << "     -- type 'accept' for accepting this request. (or 'accept "
				<< invite->name << "' if you receive another invitation in the meantime." << endl;*/
			lastInviteRequest = new string(invite->name);
			break;
		}
		
		// account was signed on somewhere else
		case XFIRE_OTHER_LOGIN:
		{
			[_delegate xfireOtherUseLoggedOn:self];
			[self disconnect];
			break;
		}
			
		// updates to the buddy list
		case XFIRE_BUDDYS_NAMES_ID:		// sent when we received names of buddies..
		case XFIRE_BUDDYS_ONLINE_ID:	// sent when a buddy goes on off off line
		case XFIRE_BUDDYS_GAMES_ID:		// sent when a buddy's game status changes
		case XFIRE_BUDDYS_GAMES2_ID:
		case XFIRE_RECV_STATUSMESSAGE_PACKET_ID:	// sent when status messages are changed
		case XFIRE_RECVREMOVEBUDDYPACKET:			// someone else removed us as a friend :(
		{
			/*switch (content->getPacketId())
			{
				case XFIRE_BUDDYS_NAMES_ID:
					NSLog(@"XFIRE_BUDDYS_NAMES_ID");
					break;
				case XFIRE_BUDDYS_ONLINE_ID:
					NSLog(@"XFIRE_BUDDYS_ONLINE_ID");
					break;
				case XFIRE_BUDDYS_GAMES_ID:
					NSLog(@"XFIRE_BUDDYS_GAMES_ID");					
					break;
				case XFIRE_RECV_STATUSMESSAGE_PACKET_ID:
					NSLog(@"XFIRE_RECV_STATUSMESSAGE_PACKET_ID");
					break;
			}*/
			
			[self rebuildBuddyList];
			[_delegate xfireDidUpdateBuddyList:self];
			break;
		}
			
		// unused..
		case XFIRE_RECVPREFSPACKET:
		case XFIRE_RECVDIDPACKET:
		case XFIRE_RECV_OLDVERSION_PACKET_ID:
		{
			break;
		}
			
		default:
			NSLog(@"Unused packet: %d", content->getPacketId());
			break;
    }
}


- (void)rebuildBuddyList
{
	vector<BuddyListEntry*> *entries = client->getBuddyList()->getEntries();
	NSMutableArray *buddyList = [NSMutableArray array];

	for (uint i=0 ; i<entries->size(); i++)
	{
		BuddyListEntry *entry = entries->at(i);
		
		XfireBuddyListEntry *listentry = [[XfireBuddyListEntry alloc] initWithBuddyListEntry:entry];
		[listentry setGame:[_fullGamesList gameForID:[NSString stringWithFormat:@"%d", [listentry gameID]]]];
		[buddyList addObject:listentry];
		[listentry release];
	}
	
	[buddyList sortUsingSelector:@selector(compare:)];
	
	[self setBuddyList:[XfireBuddyList buddyListWithEntries:buddyList]];
}

- (void)disconnect
{
    client->disconnect();
	_connected = NO;
	
	[self setBuddyList:nil];
}

- (void)setStatusMessage:(NSString *)message
{
	if (!_connected) return;
	
	SendStatusMessagePacket *packet = new SendStatusMessagePacket();
	packet->awaymsg = (message == nil ? "" : [message UTF8String]);
	client->send(packet);
	delete packet;
}

- (void)sendMessage:(NSString *)message to:(XfireBuddyListEntry *)buddy
{
	if (!_connected) return;

	SendMessagePacket msg;
	msg.init(client, [[buddy username] UTF8String], [message UTF8String]);
	client->send(&msg);
}

- (void)acceptInvitationFromUser:(NSString *)username
{
	if (!_connected) return;
	
	SendAcceptInvitationPacket accept;
	accept.name = [username UTF8String];
	client->send(&accept);
}

- (void)denyInvitationFromUser:(NSString *)username
{
	if (!_connected) return;
	
	SendDenyInvitationPacket deny;
	deny.name = [username UTF8String];
	client->send(&deny);
}

- (void)inviteUser:(NSString *)username withMessage:(NSString *)message
{
	if (!_connected) return;
	
	InviteBuddyPacket invite;
	invite.addInviteName([username UTF8String], [message UTF8String]);
	client->send(&invite);
}

- (void)removeUser:(NSString *)username
{
	if (!_connected) return;
	
	BuddyListEntry *entry = client->getBuddyList()->getBuddyByName([username UTF8String]);
	SendRemoveBuddyPacket removeBuddy;
	removeBuddy.userid = entry->userid;
	client->send(&removeBuddy);
}

- (void)handleGameStatusNotification:(NSNotification *)n
{
	if (!_connected) return;
	
	XfireGameInfo *gameInfo = [n object];

	int gameID = (gameInfo ? [[gameInfo gameID] intValue] : 0);	
	[_delegate xfire:self setGameStatus:gameInfo];
	
	SendGameStatusPacket *packet = new SendGameStatusPacket();
	packet->gameid = gameID;
	char ip[] = {0,0,0,0};
	memcpy(packet->ip,ip,4);
	packet->port = 0;
	client->send(packet);
	delete packet;
}

#pragma mark -

- (NSString *)username
{
	return _username;
}

- (void)setUsername:(NSString *)username
{
	if (_username != username)
	{
		[_username release];
		_username = [username copy];
	}
}

- (XfireBuddyList *)buddyList
{
	return _buddyList;
}

- (void)setBuddyList:(XfireBuddyList *)buddyList
{
	if (_buddyList != buddyList)
	{
		[_buddyList release];
		_buddyList = [buddyList retain];
	}
}

- (XfireGamesList *)gamesList
{
	return _fullGamesList;
}

@end
