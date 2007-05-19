//
//  iPLController.m
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "iPLController.h"
#import "iPLPod.h"
#import "iPLInstaller.h"

#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>


@implementation iPLController

- (id)init
{
	if (self = [super init])
	{
		NSNotificationCenter *workspace = [[NSWorkspace sharedWorkspace] notificationCenter];
		[workspace addObserver:self selector:@selector(updateiPods) name:NSWorkspaceDidMountNotification object:nil];
		[workspace addObserver:self selector:@selector(updateiPods) name:NSWorkspaceDidUnmountNotification object:nil];
		
		installer = nil;
	}
	
	return self;
}	

- (void)dealloc
{
	[iPods release];
	[installer release];
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -

- (void)awakeFromNib
{
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];
	
	foundNonFourthGeniPod = NO;
	[self updateiPods];
	
	if ([iPods count] == 0 && foundNonFourthGeniPod == YES)
	{
		int result = NSRunAlertPanel(NSLocalizedStringFromTable(@"1-3G iPod Found Title", nil, nil), NSLocalizedStringFromTable(@"1-3G iPod Found Message", nil, nil), NSLocalizedStringFromTable(@"View Website", nil, nil), NSLocalizedStringFromTable(@"Quit", nil, nil), nil);
		if (result == NSOKButton)
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://ipodlinuxinstl.sourceforge.net/"]];
		[NSApp terminate:nil];
	}
	
	[installProgress setUsesThreadedAnimation:YES];
	
	[self updateUI:nil];
}

- (void)updateiPods
{
	NSMutableArray *temp = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];

	struct statfs *buf;
	int i, count;
	
	count = getmntinfo(&buf, 0);
	for (i=0; i<count; i++)
	{
		if ((buf[i].f_flags & MNT_LOCAL) == MNT_LOCAL)
		{
			NSString *path = [NSString stringWithUTF8String:buf[i].f_mntonname];
			
			NSString *iPodControl = [path stringByAppendingPathComponent:@"iPod_Control"];
			if ([fm fileExistsAtPath:iPodControl])
			{
				iPLPod *pod = [[[iPLPod alloc] initWithPath:path] autorelease];
				
				if ([pod FAT32] == NO)
				{
					switch ([pod iPodGeneration])
					{
						case iPLPodColor:
						case iPLPodFourthBW:
						case iPLPodMini:
							[temp addObject:pod];
							break;
						case iPLPod123G:
							foundNonFourthGeniPod = YES;
							break;
						default:
							break;
					}
				}
			}			
		}
	}

	[iPods release];
	iPods = [temp retain];
	[iPodsTableView deselectAll:nil];
	[iPodsTableView reloadData];
	
	if ([iPods count] > 0)
		[iPodsTableView selectRow:0 byExtendingSelection:NO];
}

- (BOOL)linuxInstalled:(iPLPod *)pod
{
	if (pod == nil)
		return NO;
	
	BOOL isDir;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[pod path] stringByAppendingPathComponent:@"bin"] isDirectory:&isDir] && isDir)
		return YES;
	
	return NO;
}

#pragma mark -

- (IBAction)disagree:(id)sender
{
	[NSApp terminate:nil];
}

- (IBAction)agree:(id)sender
{
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:1]];
}

#pragma mark -

- (IBAction)updateUI:(id)sender
{
	if ([iPodsTableView numberOfSelectedRows] == 0)
	{
		[actionsPopUp setEnabled:NO];
		[goButton setEnabled:NO];
	}
	else
	{
		[actionsPopUp setEnabled:YES];
		[goButton setEnabled:YES];
		
		switch ([[actionsPopUp selectedItem] tag])
		{
			case 0: // install
			{
				[goButton setTitle:NSLocalizedStringFromTable(@"Install", nil, nil)];
				break;
			}
			
			case 1: // uninstall
			{
				[goButton setTitle:NSLocalizedStringFromTable(@"Uninstall", nil, nil)];
				break;
			}
			
			case 2: // update files
			{
				[goButton setTitle:NSLocalizedStringFromTable(@"Next", nil, nil)];
				break;
			}
		}
	}
	
	if ([updatePodzilla state] || [updateKernel state])
		if (![[podzillaField stringValue] isEqualToString:@""] || ![[kernelField stringValue] isEqualToString:@""])
			[updateFilesButton setEnabled:YES];
	else
		[updateFilesButton setEnabled:NO];
	[choosePodzillaButton setEnabled:[updatePodzilla state]];
	[chooseKernelButton setEnabled:[updateKernel state]];
}

- (void)resizeWindowToHeight:(float)height
{
	NSSize newSize;
	NSRect newFrame;
	float newHeight, newWidth;
	newSize = NSMakeSize([mainWindow frame].size.width, height);
	newHeight = newSize.height;
	newWidth = newSize.width;
	newFrame = [NSWindow contentRectForFrameRect:[mainWindow frame] styleMask:[mainWindow styleMask]];
	newFrame.origin.y += newFrame.size.height;
	newFrame.origin.y -= newHeight;
	newFrame.size.height = newHeight;
	newFrame.size.width = newWidth;
	newFrame = [NSWindow frameRectForContentRect:newFrame styleMask:[mainWindow styleMask]];
	[mainWindow setFrame:newFrame display:YES animate:YES];
}	

- (IBAction)go:(id)sender
{
	switch ([[actionsPopUp selectedItem] tag])
	{
		case 0: // install
		{
			// skip options (Linux as default does not work)
			//[tabView selectTabViewItem:[tabView tabViewItemAtIndex:4]];
			
			if ([self linuxInstalled:[iPods objectAtIndex:[iPodsTableView selectedRow]]])
			{
				NSRunCriticalAlertPanel(NSLocalizedStringFromTable(@"iPodLinux Already Installed Title", nil, nil), NSLocalizedStringFromTable(@"iPodLinux Already Installed Message", nil, nil), NSLocalizedStringFromTable(@"OK", nil, nil), nil, nil);
			}
			else
			{
				[self install:nil];
			}
			break;
		}
		
		case 1: // uninstall
		{
			if ([self linuxInstalled:[iPods objectAtIndex:[iPodsTableView selectedRow]]] == NO)
			{
				NSRunCriticalAlertPanel(NSLocalizedStringFromTable(@"iPodLinux Not Installed Title", nil, nil), NSLocalizedStringFromTable(@"iPodLinux Not Installed Message", nil, nil), NSLocalizedStringFromTable(@"OK", nil, nil), nil, nil);
			}
			else
			{
				[installTitleField setStringValue:NSLocalizedStringFromTable(@"Uninstalling iPodLinux", nil, nil)];
				[installProgress startAnimation:nil];
				[tabView selectTabViewItem:[tabView tabViewItemAtIndex:2]];
				
				[self resizeWindowToHeight:145];
				
				if (installer == nil)
					installer = [[iPLInstaller alloc] initWithDelegate:self
																  iPod:[iPods objectAtIndex:[iPodsTableView selectedRow]]
														   bootToLinux:[[defaultBootOSMatrix cellAtRow:1 column:0] state]];
				[installer uninstall];
			}
			break;
		}
			
		case 2: // update files
		{
			if ([self linuxInstalled:[iPods objectAtIndex:[iPodsTableView selectedRow]]] == NO)
			{
				NSRunCriticalAlertPanel(NSLocalizedStringFromTable(@"iPodLinux Not Installed Title", nil, nil), NSLocalizedStringFromTable(@"iPodLinux Not Installed Message", nil, nil), NSLocalizedStringFromTable(@"OK", nil, nil), nil, nil);
			}
			else
			{
				[tabView selectTabViewItem:[tabView tabViewItemAtIndex:5]];
			}
			break;
		}
	}
}

- (void)handleUpdatedInstallationStatus:(NSString *)status
{
	if (status == nil) // done
	{
		switch ([[actionsPopUp selectedItem] tag])
		{
			case 0: // installed
			{
				[workDoneField setStringValue:NSLocalizedStringFromTable(@"Install Successful", nil, nil)];
				break;
			}
				
			case 1: // uninstalled
			{
				[workDoneField setStringValue:NSLocalizedStringFromTable(@"Uninstall Successful", nil, nil)];
				break;
			}
			
			case 2: // update files
			{
				[workDoneField setStringValue:NSLocalizedStringFromTable(@"Updated Files Successfully", nil, nil)];
				break;
			}
		}

		[tabView selectTabViewItem:[tabView tabViewItemAtIndex:3]];
		[installProgress stopAnimation:nil];
		
		// resize window
		[self resizeWindowToHeight:331];
	}
	else
	{
		[installStatusField setStringValue:status];
	}
}

- (IBAction)back:(id)sender
{
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:1]];
}

- (IBAction)install:(id)sender
{
	[installTitleField setStringValue:NSLocalizedStringFromTable(@"Installing iPodLinux", nil, nil)];
	[installProgress startAnimation:nil];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:2]];
	
	[self resizeWindowToHeight:145];
	
	if (installer == nil)
		installer = [[iPLInstaller alloc] initWithDelegate:self
													  iPod:[iPods objectAtIndex:[iPodsTableView selectedRow]]
											   bootToLinux:[[defaultBootOSMatrix cellAtRow:1 column:0] state]];
	[installer setInstallType:iPLInstallFull];
	[installer setPodzillaPath:nil];
	[installer setKernelPath:nil];
	[installer install];
}

- (IBAction)updateFiles:(id)sender
{
	[installTitleField setStringValue:NSLocalizedStringFromTable(@"Installing iPodLinux", nil, nil)];
	[installProgress startAnimation:nil];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex:2]];
	
	[self resizeWindowToHeight:145];
	
	if (installer == nil)
		installer = [[iPLInstaller alloc] initWithDelegate:self
													  iPod:[iPods objectAtIndex:[iPodsTableView selectedRow]]
											   bootToLinux:[[defaultBootOSMatrix cellAtRow:1 column:0] state]];
	iPLInstallType type;
	if ([updatePodzilla state] && [updateKernel state])
		type = iPLInstallKernelAndPodzillaOnly;
	else if ([updatePodzilla state] && ![updateKernel state])
		type = iPLInstallPodzillaOnly;
	else
		type = iPLInstallKernelOnly;
	[installer setInstallType:type];
	[installer setPodzillaPath:[podzillaField stringValue]];
	[installer setKernelPath:[kernelField stringValue]];
	[installer install];	
}

- (IBAction)choosePodzilla:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:NO];
	[op setCanChooseFiles:YES];
	if ([op runModalForTypes:[NSArray arrayWithObject:@""]] == NSOKButton)
	{
		[podzillaField setStringValue:[op filename]];
	}
	[self updateUI:nil];
}

- (IBAction)chooseKernel:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:NO];
	[op setCanChooseFiles:YES];
	if ([op runModalForTypes:[NSArray arrayWithObject:@"bin"]] == NSOKButton)
	{
		[kernelField setStringValue:[op filename]];
	}
	[self updateUI:nil];
}

#pragma mark -

- (IBAction)showHelp:(id)sender
{
	NSRunInformationalAlertPanel(NSLocalizedStringFromTable(@"Unsupported Title", nil, nil), NSLocalizedStringFromTable(@"Unsupported Message", nil, nil), NSLocalizedStringFromTable(@"OK", nil, nil), nil, nil);
	//[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.ipodlinux.org/forums"]];
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)tv
{
	return [iPods count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(int)rowIndex
{
	NSString *identifier = [tc identifier];
	iPLPod *pod = [iPods objectAtIndex:rowIndex];
	
	if ([identifier isEqualToString:@"img"])
		return [pod image];
	else if ([identifier isEqualToString:@"name"])
		return [pod name];
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)not
{
	[self updateUI:nil];
}

#pragma mark -

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if (installer != nil && [installer isWorking])
		return NSTerminateCancel;
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
