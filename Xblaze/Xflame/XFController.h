//
//  XFController.h
//  Xflame
//
//  Created by Kevin Wojniak on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Xfire.h"

@interface XFController : NSWindowController <XfireDelegate>
{
	IBOutlet NSTableView *buddyListTableView;
	IBOutlet NSTextField *statusField;
	IBOutlet NSTextField *passwordField;
	
	
	Xfire *_xfire;
}

- (IBAction)login:(id)sender;
- (IBAction)setStatus:(id)sender;

@end
