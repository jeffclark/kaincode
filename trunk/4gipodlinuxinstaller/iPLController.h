//
//  iPLController.h
//  4G iPodLinux Installer
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iPLPod, iPLInstaller;

@interface iPLController : NSObject
{
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTabView *tabView;

	// main
	IBOutlet NSTableView *iPodsTableView;
	IBOutlet NSPopUpButton *actionsPopUp;
	IBOutlet NSButton *goButton;
	
	// install options
	IBOutlet NSMatrix *defaultBootOSMatrix;

	// update files
	IBOutlet NSTextField *podzillaField, *kernelField;
	IBOutlet NSButton *updatePodzilla, *updateKernel;
	IBOutlet NSButton *choosePodzillaButton, *chooseKernelButton;
	IBOutlet NSButton *updateFilesButton;
	
	// working
	IBOutlet NSTextField *installTitleField;
	IBOutlet NSTextField *installStatusField;
	IBOutlet NSButton *cancelInstallButton;
	IBOutlet NSProgressIndicator *installProgress;

	// done
	IBOutlet NSTextField *workDoneField;
	
	NSArray *iPods;
	BOOL foundNonFourthGeniPod;
	
	iPLInstaller *installer;
}

- (void)updateiPods;
- (BOOL)linuxInstalled:(iPLPod *)pod;

// agreement
- (IBAction)disagree:(id)sender;
- (IBAction)agree:(id)sender;

// main
- (IBAction)updateUI:(id)sender;
- (IBAction)go:(id)sender;

// install options
- (IBAction)back:(id)sender;
- (IBAction)install:(id)sender;

// update files
- (IBAction)updateFiles:(id)sender;
- (IBAction)choosePodzilla:(id)sender;
- (IBAction)chooseKernel:(id)sender;

- (IBAction)showHelp:(id)sender;

@end
