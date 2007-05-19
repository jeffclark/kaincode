//
//  MLPreferences.m
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MLPreferences.h"
#import "MLDeliciousAccount.h"

@implementation MLPreferences

- (id)initWithDelegate:(id)delegate
{
	if (self = [super initWithWindowNibName:@"Preferences" owner:self])
	{
		_delegate = delegate;
		
		[self setWindowFrameAutosaveName:MLPREFSWINDOW];
	}
	
	return self;
}

- (void)dealloc
{
	_delegate = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	[box1 setTitle:NSLocalizedString(@"BOX1", nil)];
	[box2 setTitle:NSLocalizedString(@"BOX2", nil)];
	[userLabel setStringValue:NSLocalizedString(@"USER", nil)];
	[passLabel setStringValue:NSLocalizedString(@"PASS", nil)];
	[updateButton setTitle:NSLocalizedString(@"UPDATE", nil)];
	[addToLoginItems setTitle:NSLocalizedString(@"MISC1", nil)];
	[showPostCount setTitle:NSLocalizedString(@"MISC2", nil)];
	[showTagsInMainMenu setTitle:NSLocalizedString(@"MISC3", nil)];
	[showImages setTitle:NSLocalizedString(@"MISC4", nil)];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[addToLoginItems setState:[defaults boolForKey:MLADDTOLOGINITEMS]];
	[showPostCount setState:[defaults boolForKey:MLSHOWPOSTCOUNT]];
	[showTagsInMainMenu setState:[defaults boolForKey:MLTAGSINMAINMENU]];
	[showImages setState:[defaults boolForKey:MLSHOWIMAGES]];
}

- (void)setAccount:(MLDeliciousAccount *)account
{
	_account = account;
}

- (void)showUsernameAndPassword
{
	[dcUsername setStringValue:([_account username] ? [_account username] : @"")];
	[dcPassword setStringValue:([_account password] ? [_account password] : @"")];
}

- (IBAction)update:(id)sender
{
	[_account setUsername:[dcUsername stringValue] password:[dcPassword stringValue]];
	
	[_delegate performSelector:@selector(userDidUpdateAccount:) withObject:nil];
}

- (IBAction)save:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:[addToLoginItems state] forKey:MLADDTOLOGINITEMS];
	[defaults setBool:[showPostCount state] forKey:MLSHOWPOSTCOUNT];
	[defaults setBool:[showTagsInMainMenu state] forKey:MLTAGSINMAINMENU];
	[defaults setBool:[showImages state] forKey:MLSHOWIMAGES];

	[_delegate performSelector:@selector(userDidUpdatePreferences:) withObject:self];
}

@end
