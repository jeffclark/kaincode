#import "AppController.h"

// NSMenu addition
@interface NSMenu (xtras)
- (void)addMenuItemWithTitle:(NSString *)title action:(SEL)action;
@end

@implementation NSMenu (xtras)
- (void)addMenuItemWithTitle:(NSString *)title action:(SEL)action
{
	NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
	[self addItem:mi];
	[mi release];
}
@end

// NSString addition
@interface NSString (xtras)
- (NSString *)stringByTrimmingWhitespace;
@end

@implementation NSString (xtras)
- (NSString *)stringByTrimmingWhitespace
{
	NSMutableString *s = [[self mutableCopy] autorelease];
    CFStringTrimWhitespace((CFMutableStringRef)s);
    return (NSString *)[[s copy] autorelease];
}
@end

// AppController private methods
@interface AppController (priv)
- (void)addToLoginItems;
- (void)updateMenu;
- (NSString *)externalIP;
- (NSString *)localIP;
@end

@implementation AppController

- (id)init
{
	if (self = [super init])
	{
		_statusItem = nil;
	}
	
    return self;
}

- (void)dealloc
{
    [_statusItem release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:26] retain];
	[_statusItem setImage:[NSImage imageNamed:@"network"]];
	[_statusItem setHighlightMode:YES];

	[self updateMenu];
	[self addToLoginItems];
	
	[NSTimer scheduledTimerWithTimeInterval:60.0*30.0 target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
}

- (void)addToLoginItems
{
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	NSString *appName = [[appPath lastPathComponent] stringByDeletingLastPathComponent];
	NSString *source = [NSString stringWithFormat:@"set appPath to \"%@\"\rtell application \"System Events\"\rdelete every login item whose path contains \"%@\"\rmake login item at end with properties {path:appPath, hidden:false}\rend tell", appPath, appName];
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:source] autorelease];
	[script executeAndReturnError:nil];
}

- (void)updateMenu
{
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    NSString *externalIP = [NSString stringWithFormat:@"  %@", [self externalIP]];
    NSString *localIP = [NSString stringWithFormat:@"  %@", [self localIP]];

    if ([externalIP isEqualTo:localIP] == NO)
	{
		[menu addMenuItemWithTitle:NSLocalizedString(@"External", nil) action:nil];
		[menu addMenuItemWithTitle:externalIP action:@selector(copyIP:)];
    }

	[menu addMenuItemWithTitle:NSLocalizedString(@"Local", nil) action:nil];
	[menu addMenuItemWithTitle:localIP action:@selector(copyIP:)];

	// add Quit
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addMenuItemWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(quit:)];
	
	[_statusItem setMenu:menu];
}

- (NSString *)externalIP
{
	return [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.whatismyip.org"]];
}

- (NSString *)localIP
{
	NSEnumerator *e = [[[NSHost currentHost] addresses] objectEnumerator];
	id address;
	
	while (address = [e nextObject])
	{
		if (![address hasPrefix:@":"] && ![address hasPrefix:@"f"] && ![address isEqualToString:@"127.0.0.1"])
			return address;
	}
	
	return nil;
}

- (IBAction)copyIP:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pb setString:[[sender title] stringByTrimmingWhitespace] forType:NSStringPboardType];
}

- (IBAction)quit:(id)sender
{
	[NSApp terminate:self];
}

@end