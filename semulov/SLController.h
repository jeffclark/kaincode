//
//  SLController.h
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SUUpdater, SLPrefsController;

@interface SLController : NSObject
{
	NSStatusItem *_statusItem;
	NSMenuItem *_slMenuItem;
	NSArray *_volumes;
	SUUpdater *_updater;
	SLPrefsController *_prefs;
}

- (void)setupBindings;
- (void)setupStatusItem;
- (void)updateStatusItemMenu;

@end
