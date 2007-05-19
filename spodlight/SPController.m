//
//  SPController.m
//  Spodlight
//
//  Created by Kevin Wojniak on 5/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SPController.h"

@implementation SPController

- (id)init
{
	if (self = [super init])
	{
		[self refreshiPods];
		_lastIndexed = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iPodIndexed:) name:@"SDiPodIndexed" object:nil];
		NSNotificationCenter *workspace = [[NSWorkspace sharedWorkspace] notificationCenter];
		[workspace addObserver:self selector:@selector(refreshiPods) name:NSWorkspaceDidMountNotification object:nil];
		[workspace addObserver:self selector:@selector(refreshiPods) name:NSWorkspaceDidUnmountNotification object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[_indexer release];
	[_iPods release];
	[_lastIndexed release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -

- (void)awakeFromNib
{
	NSDictionary *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastIndexed"];
	if (temp) [_lastIndexed setDictionary:temp];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Get OS version and check for running on anything below Tiger
	SInt32 MacVersion;
    Gestalt(gestaltSystemVersion, &MacVersion);
	if (MacVersion < 0x1040)
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Spodlight requires Tiger to run."
										 defaultButton:@"Quit"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Since Spotlight doesn't exist on any version of the Mac but Tiger, you're really just wasting your time."];
		NSBeep();
		[alert runModal];
	}
}

- (void)refreshiPods
{
	[_iPods release];
	_iPods = [[SPiPod connectediPods] copy];
	[iPodsTableView reloadData];
}

- (IBAction)indexiPod:(id)sender
{
	[indexButton setEnabled:NO];
	
	if (!_indexer) _indexer = [[SPIndexer alloc] init];
	
	[NSApp beginSheet:[_indexer window] modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[_indexer indexiPod:[_iPods objectAtIndex:[iPodsTableView selectedRow]]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[indexButton setEnabled:YES];
}

- (void)iPodIndexed:(NSNotification *)notification
{
	SPiPod *iPod = [notification object];
	if (iPod)
	{
		[_lastIndexed setObject:[NSDate date] forKey:[iPod name]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastIndexed forKey:@"LastIndexed"];
		[iPodsTableView reloadData];
	}
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_iPods count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSString *identifier = [tableColumn identifier];
	SPiPod *iPod = [_iPods objectAtIndex:row];
	
	if ([identifier isEqualToString:@"iPod"])
	{
		return [iPod name];
	}
	else if ([identifier isEqualToString:@"LastIndexed"])
	{
		NSDate *lastIndex = [_lastIndexed objectForKey:[iPod name]];
		if (lastIndex == nil)
			return @"Never";
		else
			return [lastIndex descriptionWithCalendarFormat:@"%A, %B %e, %Y %H:%M:%S" timeZone:nil locale:nil];
	}

	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[indexButton setEnabled:([iPodsTableView numberOfSelectedRows] == 1)];
}

@end
