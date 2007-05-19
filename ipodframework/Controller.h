//
//  Controller.h
//  iPodFrameworkTest
//
//  Created by Kevin Wojniak on 6/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject
{
	IBOutlet NSTableView *tableView;
	IBOutlet NSTextView *textView;
	IBOutlet NSButton *lockButton, *unlockButton;	

	CFArrayRef iPods;
	NSMutableArray *connectediPods;
}

- (void)refreshiPods;

- (IBAction)aquireLock:(id)sender;
- (IBAction)releaseLock:(id)sender;

@end
