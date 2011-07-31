//
//  SLController.h
//  Semulov
//
//  Created by Kevin Wojniak on 11/5/06.
//  Copyright 2006 - 2011 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SUUpdater;

@interface SLController : NSObject
{
	NSStatusItem *_statusItem;
	NSArray *_volumes;
	SUUpdater *_updater;
	NSWindowController *_prefs;
}

- (void)setupBindings;
- (void)setupStatusItem;
- (void)updateStatusItemMenu;

@end
