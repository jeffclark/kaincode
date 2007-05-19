//
//  MLController.h
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MLPreferences;
@class MLDeliciousAccount;
@class DCAPIClient, DCAPICache;
@class SUUpdater;

@interface MLController : NSObject
{
	IBOutlet SUUpdater *updater;
	
	NSMenu *_statusMenu, *_menuliciousMenu, *_tagsMenu;
	
	NSStatusItem *_statusItem;
	MLPreferences *_prefs;

	MLDeliciousAccount *_account;
	DCAPIClient *_client;
	DCAPICache *_cache;
}

- (IBAction)openPreferences:(id)sender;
- (IBAction)showAbout:(id)sender;

@end
