//
//  SPIndexer.h
//  Spodlight
//
//  Created by Kevin Wojniak on 5/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
// Handles indexing the iPod and the UI associated with it.

#import <Cocoa/Cocoa.h>
#import "SPiPod.h"

@interface SPIndexer : NSWindowController
{
	IBOutlet NSTextField *titleField;
	IBOutlet NSProgressIndicator *progressIndicator;
}

- (void)indexiPod:(SPiPod *)iPod;

@end
