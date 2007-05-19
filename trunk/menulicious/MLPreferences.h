//
//  MLPreferences.h
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MLDeliciousAccount;

#define MLPREFSWINDOW		@"MLPreferencesWindow"
#define MLADDTOLOGINITEMS	@"MLAddToLoginItems"
#define MLSHOWPOSTCOUNT		@"MLShowPostCount"
#define MLTAGSINMAINMENU	@"MLTagsInMainMenu"
#define MLSHOWIMAGES		@"MLShowImages"

@interface MLPreferences : NSWindowController
{
	IBOutlet NSBox *box1, *box2;
	IBOutlet NSTextField *userLabel, *passLabel;
	IBOutlet NSButton *updateButton;
	IBOutlet NSTextField *dcUsername, *dcPassword;
	IBOutlet NSButton *addToLoginItems;
	IBOutlet NSButton *showPostCount;
	IBOutlet NSButton *showTagsInMainMenu;
	IBOutlet NSButton *showImages;
	
	MLDeliciousAccount *_account;
	id _delegate;
}

- (id)initWithDelegate:(id)delegate;

- (void)setAccount:(MLDeliciousAccount *)account;
- (void)showUsernameAndPassword;
- (IBAction)update:(id)sender;
- (IBAction)save:(id)sender;

@end
