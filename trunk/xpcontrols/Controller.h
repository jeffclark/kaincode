//
//  Controller.h
//  XPControls
//
//  Created by Kevin Wojniak on 11/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Controller : NSObject
{
	IBOutlet NSButton *applyButton;
}

- (IBAction)toggle:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
