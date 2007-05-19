//
//  MLController.m
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MLController.h"
#import "MLPreferences.h"
#import "NSMenu+MLExtension.h"
#import <Sparkle/SUUpdater.h>

#import "MLDeliciousAccount.h"
#import "DCAPIClient.h"
#import "DCAPICache.h"
#import "DCAPIPost.h"
#import "DCAPITag.h"


@interface MLController (priv)

- (void)setupStatusItem;

- (void)relogin;
- (void)loginToDeliciousWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)refreshAll;
- (void)updateTagTitles;
- (void)addPostToMenu:(DCAPIPost *)post;

- (void)initPrefs;

- (DCAPIClient *)client;
- (void)setClient:(DCAPIClient *)client;
- (DCAPICache *)cache;
- (void)setCache:(DCAPICache *)cache;
@end


@implementation MLController

- (id)init
{
	if (self = [super init])
	{
		_statusMenu = [[NSMenu alloc] init];
		_menuliciousMenu = [[NSMenu alloc] init];
		_tagsMenu = [[NSMenu alloc] init];
		
		_account = [[MLDeliciousAccount sharedAccount] retain];
		
		_client = nil;
		_cache = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[_statusMenu release];
	[_menuliciousMenu release];
	[_tagsMenu release];
	
	[_statusItem release];
	[_prefs release];
	
	[_account release];
	[_client release];
	[_cache release];
	
	[super dealloc];
}

#pragma mark -

- (void)awakeFromNib
{
	[self initPrefs];
	
	[self setupStatusItem];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (_account == nil || [_account username] == nil)
	{
		[self openPreferences:nil];
	}
	else
	{
		[self relogin];
	}
	
	[updater checkForUpdatesInBackground];
}

- (void)refreshStatusMenu
{
	BOOL tagsInMenu = [[NSUserDefaults standardUserDefaults] boolForKey:MLTAGSINMAINMENU];
	int i;
	
	[_statusMenu removeAllItems];
	
	if ([_menuliciousMenu numberOfItems] == 0)
	{
		[_menuliciousMenu addItemWithTitle:NSLocalizedString(@"REFRESH", nil) target:self action:@selector(refreshAll)];
		[_menuliciousMenu addItem:[NSMenuItem separatorItem]];
		[_menuliciousMenu addItemWithTitle:NSLocalizedString(@"PREFS", nil) target:self action:@selector(openPreferences:)];
		[_menuliciousMenu addItem:[NSMenuItem separatorItem]];
		[_menuliciousMenu addItemWithTitle:NSLocalizedString(@"ABOUT", nil) target:self action:@selector(showAbout:)];
		[_menuliciousMenu addItemWithTitle:NSLocalizedString(@"QUIT", nil) target:NSApp action:@selector(terminate:)];
	}
	
	NSMenuItem *firstMenu = nil;
	NSMenu *second = nil;
	
	if ([_tagsMenu numberOfItems] == 0)
	{
		// could be still updating?
		[_tagsMenu addItemWithTitle:NSLocalizedString(@"UPDATING", nil) action:nil keyEquivalent:@""];
	}
	
	if (tagsInMenu)
	{
		firstMenu = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"APPNAME", nil) action:nil keyEquivalent:@""] autorelease];
		[firstMenu setSubmenu:_menuliciousMenu];
		second = _tagsMenu;
	}
	else
	{
		firstMenu = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"TAGS", nil) action:nil keyEquivalent:@""] autorelease];
		[firstMenu setSubmenu:_tagsMenu];
		second = _menuliciousMenu;
	}

	[_statusMenu addItem:firstMenu];
	if (tagsInMenu) [_statusMenu addItem:[NSMenuItem separatorItem]];
	for (i=0; i<[second numberOfItems]; i++)
		[_statusMenu addItem:[[(NSMenuItem *)[second itemAtIndex:i] copy] autorelease]];
}

- (void)setupStatusItem
{
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:22] retain];
	[_statusItem setHighlightMode:YES];
	[_statusItem setImage:[NSImage imageNamed:@"delicious_bw"]];
	[_statusItem setAlternateImage:[NSImage imageNamed:@"delicious_bw_alt"]];
	[_statusItem setMenu:_statusMenu];
	
	[self refreshStatusMenu];
}

#pragma mark -

- (void)relogin
{
	[self loginToDeliciousWithUsername:[_account username] andPassword:[_account password]];
	[self refreshAll];
}

- (void)loginToDeliciousWithUsername:(NSString *)username andPassword:(NSString *)password
{
	DCAPIClient *dcClient = [[[DCAPIClient alloc] initWithAPIURL:[NSURL URLWithString:kDEFAULT_API_URL]
														username:username
														password:password
														delegate:self] autorelease];
	DCAPICache *dcCache = [DCAPICache DCAPICacheForUsername:username client:dcClient];
	[self setClient:dcClient];
	[self setCache: dcCache];
}

- (void)refreshAll
{
	[NSThread detachNewThreadSelector:@selector(refreshThread) toTarget:self withObject:nil];
}

- (void)refreshThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSError *err = nil;
	[[self cache] refreshMemoryCacheWithPolicy:CocoaliciousCacheUseProtocolCachePolicy error:&err];
	[self performSelectorOnMainThread:@selector(continueRefresh) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)continueRefresh
{
	NSDictionary *posts = [[self cache] memoryCache];
	NSEnumerator *postsEnum = [posts keyEnumerator];
	NSString *postURL = nil;
	
	[_tagsMenu removeAllItems];
	
	while (postURL = [postsEnum nextObject])
	{
		DCAPIPost *post = [posts objectForKey:postURL];
		[self addPostToMenu:post];
	}
	
	NSEnumerator *itemsEnum = [[_tagsMenu itemArray] objectEnumerator];
	NSMenuItem *mi = nil;
	while (mi = [itemsEnum nextObject])
	{
		if ([mi submenu])
			[[mi submenu] sortItemsByTitle];
	}
	
	[self updateTagTitles];
	[_tagsMenu sortItemsByTitle];

	[self refreshStatusMenu];
}

- (void)updateTagTitles
{
	BOOL showPostCount = [[NSUserDefaults standardUserDefaults] boolForKey:MLSHOWPOSTCOUNT];
	NSEnumerator *itemsEnum = [[_tagsMenu itemArray] objectEnumerator];
	NSMenuItem *mi = nil;
	while (mi = [itemsEnum nextObject])
	{
		if (showPostCount)
			[mi setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ (%d)", nil), [mi representedObject], [[mi submenu] numberOfItems]]];
		else
			[mi setTitle:[mi representedObject]];
	}
}

- (void)addPostToMenu:(DCAPIPost *)post
{
	NSArray *postTags = [post tags];
	NSEnumerator *tagsEnum = [postTags objectEnumerator];
	NSString *tag = nil;
	
	while (tag = [tagsEnum nextObject])
	{
		NSMenuItem *tagMenuItem = nil;
		NSMenu *tagSubmenu = nil;
		NSMenuItem *postMenuItem = nil;
		
		tagMenuItem = [_tagsMenu itemWithRepresentedString:tag];
		if (tagMenuItem == nil)
		{
			tagMenuItem = [[[NSMenuItem alloc] initWithTitle:tag action:nil keyEquivalent:@""] autorelease];
			[tagMenuItem setRepresentedObject:tag];
			[_tagsMenu addItem:tagMenuItem];
		}
		
		if ([tagMenuItem submenu] == nil)
			[tagMenuItem setSubmenu:[[[NSMenu alloc] init] autorelease]];
		tagSubmenu = [tagMenuItem submenu];
		
		postMenuItem = [tagSubmenu itemWithTitle:[post description]];
		if (postMenuItem == nil)
		{
			postMenuItem = [[[NSMenuItem alloc] initWithTitle:[post description] action:nil keyEquivalent:@""] autorelease];
			[postMenuItem setRepresentedObject:post];
			[postMenuItem setToolTip:[[post URL] absoluteString]];
			[postMenuItem setTarget:self];
			[postMenuItem setAction:@selector(openPost:)];
			
			[tagSubmenu addItem:postMenuItem];
		}
	}
}

#pragma mark -

- (void)initPrefs
{
	_prefs = [[MLPreferences alloc] initWithDelegate:self];
	[_prefs setAccount:_account];
	[_prefs window];
	[_prefs save:nil];
}

- (IBAction)openPreferences:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[_prefs showUsernameAndPassword];
	[_prefs showWindow:nil];
}

- (void)userDidUpdateAccount:(id)unused
{
	[self relogin];
}

- (void)userDidUpdatePreferences:(id)unused
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *source = nil;
	if ([defaults boolForKey:MLADDTOLOGINITEMS])
	{
		source = [NSString stringWithFormat:@"set appPath to \"%@\"\rtell application \"System Events\"\rmake login item at end with properties {path:appPath, hidden:false}\rend tell",
			[[NSBundle mainBundle] bundlePath]];
	}
	else
		source = @"tell application \"System Events\" to delete (every login item whose path contains \"Menulicious\")";
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:source] autorelease];
	[script executeAndReturnError:nil];
	
	
	[self updateTagTitles];
	[self refreshStatusMenu];
}

#pragma mark -

- (IBAction)showAbout:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)openPost:(id)sender
{
	DCAPIPost *post = [sender representedObject];
	[[NSWorkspace sharedWorkspace] openURL:[post URL]];
}

#pragma mark -

- (DCAPIClient *)client
{
	return _client;
}

- (void)setClient:(DCAPIClient *)client
{
	if (_client != client)
	{
		[_client release];
		_client = [client retain];
	}
}

- (DCAPICache *)cache
{
	return _cache;
}

- (void)setCache:(DCAPICache *)cache
{
	if (_cache != cache)
	{
		[_cache release];
		_cache = [cache retain];
	}
}

@end
