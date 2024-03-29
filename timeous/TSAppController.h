//
//  TSAppController.h
//  Timeous
//
//  Created by Kevin Wojniak on 12/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSDataController, TSMainController;


@interface TSAppController : NSObject
{
	TSDataController *_dataController;
	TSMainController *_mainController;
	NSWindowController *_prefsController;
}

- (IBAction)import:(id)sender;
- (IBAction)sendFeedback:(id)sender;
- (IBAction)showPrefs:(id)sender;

@end
