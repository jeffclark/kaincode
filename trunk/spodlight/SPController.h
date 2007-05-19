//
//  SPController.h
//  Spodlight
//
//  Created by Kevin Wojniak on 5/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
// The main controller of the app.

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "SPiPod.h"
#import "SPIndexer.h"

@interface SPController : NSObject
{
	IBOutlet NSTableView *iPodsTableView;
	IBOutlet NSButton *indexButton;
	IBOutlet NSWindow *mainWindow;
	
	SPIndexer *_indexer;
	NSArray *_iPods;
	NSMutableDictionary *_lastIndexed;
}

- (void)refreshiPods;
- (IBAction)indexiPod:(id)sender;

@end
