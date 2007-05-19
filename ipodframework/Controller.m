//
//  Controller.m
//  iPodFrameworkTest
//
//  Created by Kevin Wojniak on 6/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#include "Pod.h"


typedef SInt32 iPodMessage;
enum {
	kiPodMsgAttached			= 1,		// an iPod was just attached to the computer
	kiPodMsgRemoved				= 2,		// an iPod was just removed from the computer
	kiPodMsgMounted				= 3,		// an iPod was just mounted as a hard disk. msgData in the iPodServerCallback is a null-terminated C-string containing mount point path
	kiPodMsgUnmounted			= 4,		// a volume mounted from an attached iPod has just unmounted
	kiPodMsgPrefsChanged		= 5,		// the preferences of the referenced iPod have been set
	kiPodMsgNameChanged			= 8			// the name of the iPod was changed. msgData in the iPodServerCallback is a null-terminated C-string containing the new name
};

@implementation Controller

void doIT(iPodRef iPod, iPodMessage msgCode, void *msgData, void *userInfo)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"iPodCallback" object:[NSNumber numberWithInt:msgCode]];
}

- (id)init
{
	if (self = [super init])
	{
		connectediPods = [[NSMutableArray alloc] init];
		[self refreshiPods];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleiPodCallback:) name:@"iPodCallback" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[connectediPods release];
	CFRelease(iPods);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[tableView reloadData];
	[self tableViewSelectionDidChange:nil];
}

- (void)refreshiPods
{
	[connectediPods removeAllObjects];
	if (iPods != NULL)
		CFRelease(iPods);
	
	if (iPodCopyConnected(&iPods) == noErr)
	{
		if (iPods != nil)
		{
			CFIndex i;
			for (i=0; i<CFArrayGetCount(iPods); i++)
			{
				Pod *pod = [[Pod alloc] initWithiPodRef:(iPodRef)CFArrayGetValueAtIndex(iPods, i)];
				[connectediPods addObject:pod];
				[pod release];
			}
			
			iPodRegisterWithServer(CFRunLoopGetCurrent(), NULL, doIT, NULL);
		}
	}
	
	[tableView reloadData];
}

- (IBAction)aquireLock:(id)sender
{
	Pod *pod = [connectediPods objectAtIndex:[tableView selectedRow]];
	[pod aquireLock];

	[tableView reloadData];	
}

- (IBAction)releaseLock:(id)sender
{
	Pod *pod = [connectediPods objectAtIndex:[tableView selectedRow]];
	[pod releaseLock];

	[tableView reloadData];	
}

- (void)handleiPodCallback:(NSNotification *)not
{
	iPodMessage msgCode = [[not object] intValue];
	
	switch (msgCode)
	{
		case kiPodMsgAttached:
			[textView setString:[NSString stringWithFormat:@"%@Attached\r", [textView string]]];
			break;
			
		case kiPodMsgRemoved:
			[textView setString:[NSString stringWithFormat:@"%@Removed\r", [textView string]]];
			break;
			
		case kiPodMsgMounted:
			[textView setString:[NSString stringWithFormat:@"%@Mounted\r", [textView string]]];
			break;
			
		case kiPodMsgUnmounted:
			[textView setString:[NSString stringWithFormat:@"%@Unmounted\r", [textView string]]];
			break;
			
		case kiPodMsgPrefsChanged:
		//	[textView setString:[NSString stringWithFormat:@"%@PrefsChanged\r", [textView string]]];
			break;
			
		default:
			[textView setString:[NSString stringWithFormat:@"%@Other...\r", [textView string]]];
			break;
	}
	
	[self refreshiPods];
}

- (int)numberOfRowsInTableView:(NSTableView *)table
{
	return [connectediPods count];
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(int)row
{
	Pod *pod = [connectediPods objectAtIndex:row];
	NSString *identifier = [column identifier];
	if ([identifier isEqualToString:@"Name"])
		return [pod name];
	if ([identifier isEqualToString:@"Mounted"])
		return [NSString stringWithFormat:@"%@", [pod mounted] ? @"Y" : @""];
	if ([identifier isEqualToString:@"Locks"])
		return [NSString stringWithFormat:@"%d", [pod lockCount]];
	if ([identifier isEqualToString:@"DiskMode"])
		return [NSString stringWithFormat:@"%@", [pod diskModeEnabled] ? @"Y" : @""];
	return nil;
	
}

- (void)tableViewSelectionDidChange:(NSNotification *)n
{
	[lockButton setEnabled:([tableView numberOfSelectedRows] == 1)];
	[unlockButton setEnabled:([tableView numberOfSelectedRows] == 1)];
}

@end
