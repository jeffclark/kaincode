//
//  AppController.h
//  WPS
//
//  Created by Kevin Wojniak on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject
{
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *latField;
	IBOutlet NSTextField *longField;
}

- (IBAction)viewMap:(id)sender;

@end
