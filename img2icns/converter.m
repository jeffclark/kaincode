#import "converter.h"
#import "IconFamily.h"

#define PREFS_OUTPUT_TYPE	@"OutputType"

@implementation converter

- (int)outputType
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:PREFS_OUTPUT_TYPE];
}

- (void)awakeFromNib
{
	int output = [self outputType];
	int i;
	for (i=0; i<[prefMatrix numberOfRows]; i++)
		if (i == output)
			[[prefMatrix cellAtRow:i column:0] setState:YES];
		else
			[[prefMatrix cellAtRow:i column:0] setState:NO];

}

- (IBAction)savePrefs:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[prefMatrix selectedRow] forKey:PREFS_OUTPUT_TYPE];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[prefWin makeKeyAndOrderFront:self];
	return YES;
}

// makes sure a file isn't written over
- (NSString *)safeNameForFile:(NSString *)file
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if (![fm fileExistsAtPath:file])
		return file;
	
	int i;
	NSString *pathExtension = [file pathExtension];
	NSString *pathWithoutExtension = [file stringByDeletingPathExtension];
	NSString *checkPath;
	
	i = 1;
	do
	{
		checkPath = [NSString stringWithFormat:@"%@ %d.%@", pathWithoutExtension, i, pathExtension];
		i++;
	} while ([fm fileExistsAtPath:checkPath]);
	return checkPath;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filePaths
{
	int outType = [self outputType];
	NSEnumerator *pathsEnum = [filePaths objectEnumerator];
	NSString *path;
	
	while (path = [pathsEnum nextObject])
	{
		NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
		IconFamily *icon = [IconFamily iconFamilyWithThumbnailsOfImage:image];

		if (outType == 0)
		{
			NSString *icnsPath = [self safeNameForFile:[[path stringByDeletingPathExtension] stringByAppendingString:@".icns"]];
			[icon writeToFile:icnsPath];
			[icon setAsCustomIconForFile:icnsPath];
		}
		else
		{
			NSString *pathDir = [path stringByDeletingPathExtension];
			[[NSFileManager defaultManager] createDirectoryAtPath:pathDir attributes:nil];
			[icon setAsCustomIconForDirectory:pathDir];
		}
	}
}

@end
