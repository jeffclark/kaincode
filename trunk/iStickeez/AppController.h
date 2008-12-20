//
//  AppController.h
//  iStickeez
//
//  Created by Kevin Wojniak on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSWindowController {
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSTextView *textView;
	NSArray *stickies;
}

@end
