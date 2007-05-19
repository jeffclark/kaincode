/* $Id: Controller.mm,v 1.78 2005/11/04 13:09:41 titer Exp $

   This file is part of the HandBrake source code.
   Homepage: <http://handbrake.m0k.org/>.
   It may be used under the terms of the GNU General Public License. */

#import "Controller.h"
#import "DvdDisk.h"

#define _(a) NSLocalizedString(a, nil)

#define PREFS_CHOSEN_DIR	@"ChosenDirectory"
#define PREFS_SEND_ITUNES	@"SendToiTunes"
#define PREFS_OPTIMIZE		@"OptimizeFor"
#define PREFS_DVD_NAMES		@"DVDNames"

static int FormatSettings[3][4] =
  { { HB_MUX_MP4 | HB_VCODEC_FFMPEG | HB_ACODEC_FAAC,
      HB_MUX_MP4 | HB_VCODEC_X264   | HB_ACODEC_FAAC,
      0,
      0 },
    { HB_MUX_AVI | HB_VCODEC_FFMPEG | HB_ACODEC_LAME,
      HB_MUX_AVI | HB_VCODEC_FFMPEG | HB_ACODEC_AC3,
      HB_MUX_AVI | HB_VCODEC_X264   | HB_ACODEC_LAME,
      HB_MUX_AVI | HB_VCODEC_X264   | HB_ACODEC_AC3 },
    { HB_MUX_OGM | HB_VCODEC_FFMPEG | HB_ACODEC_VORBIS,
      HB_MUX_OGM | HB_VCODEC_FFMPEG | HB_ACODEC_LAME,
      0,
      0 } };

@interface Controller (priv)
- (DvdDisk *)dvd;
- (void)setDVD:(DvdDisk *)dvd;
- (void)loadDVDs;
- (void)dvdStartReading;
- (void)dvdFinishReading;
- (void)done;
- (void)updateSubtitles;
- (void)updateOutputDirectory;
- (void)start;
- (void)cancel;
- (void)shrinkWindow;
- (void)enlargeWindow;
- (void)resizeWindowToHeight:(float)height;
- (void)sendToiTunes;
- (void)setMoviePath:(NSString *)moviePath;
- (NSString *)moviePath;
@end

@implementation Controller

- (id)init
{
	if (self = [super init])
	{
		// check for another DVD2Pod instance running
		NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
		NSEnumerator *appsEnum = [apps objectEnumerator];
		NSDictionary *dict;
		int count = 0;
		while (dict = [appsEnum nextObject])
			if ([[dict objectForKey:@"NSApplicationName"] isEqualToString:@"DVD2Pod"])
				count++;
		if (count > 1)
			[NSApp terminate:nil];
		
		
		//fHandle = NULL;
		fHandle = hb_init(HB_DEBUG_NONE, 0);
		
		_dvdNames = [[NSMutableDictionary alloc] init];
		id savedNames = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_DVD_NAMES];
		if (savedNames) [_dvdNames setDictionary:savedNames];
		
		_working = NO;
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(volumeMounted:) name:NSWorkspaceDidMountNotification object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(volumeUnmounted:) name:NSWorkspaceDidUnmountNotification object:nil];
	}
	
    return self;
}

- (void)dealloc
{
	if (fHandle != NULL)
	{
		hb_close(&fHandle);
		fHandle = NULL;
	}
	
	[_dvd release];
	[_dvdNames release];
	[_moviePath release];
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -

- (NSApplicationTerminateReply)applicationShouldTerminate: (NSApplication *) app
{
    if (_working) // don't quit if scanning or converting
    {
        return NSTerminateCancel;
    }
    
    hb_close(&fHandle);
	fHandle = NULL;
    return NSTerminateNow;
}

- (BOOL)windowShouldClose:(id)sender
{
	if (_working) // don't close if scanning or converting
		return NO;
	
    [NSApp terminate:self];
    return YES;
}

#pragma mark -

- (void)awakeFromNib
{
    // Call UpdateUI every 2/10 sec
    [[NSRunLoop currentRunLoop] addTimer:
		[NSTimer scheduledTimerWithTimeInterval:0.2
										 target:self
									   selector:@selector(updateUI:)
									   userInfo:nil
										repeats:YES] forMode:NSModalPanelRunLoopMode];	
	
	[self shrinkWindow];
	
    [fRipButton setEnabled:NO];
	[fRipIndicator setIndeterminate:YES];
	
	[self updateOutputDirectory];
	[self updateSendToiTunes:nil];
	[self updateOptimizeMatrix:nil];

	[self loadDVDs];
}

- (void)volumeMounted:(NSNotification *)n
{
	NSString *mountedPath = [[n userInfo] objectForKey:@"NSDevicePath"];
	if (mountedPath != nil && [mountedPath hasPrefix:@"/Volumes"] == NO) // this volume mounted is most definitely not a DVD... :-)
		return;

	if ([self dvd] == nil) // if a DVD has already been loaded, don't attempt to rescan for another DVD
	{
		// the volume mounted could be a DVD so let's check
		[self loadDVDs];
	}
}	

- (void)volumeUnmounted:(NSNotification *)n
{
	NSString *mountedPath = [[n userInfo] objectForKey:@"NSDevicePath"];
	if (mountedPath != nil)
	{
		// check to see if the mountedPath is the path of the DVD we already have loaded.
		if ([self dvd] != nil && [[[self dvd] mountedPath] isEqualToString:mountedPath])
		{
			// the volume unmounted is the DVD we're using, so update UI indicating no DVD is loaded
			[self setDVD:nil];
			[self dvdStartReading];
		}
	}
}

- (void)loadDVDs
{
	NSArray *dvds = [DvdDisk allDVDs];
	[self setDVD:([dvds count] ? [[dvds objectAtIndex:0] retain] : nil)];
	[self dvdStartReading];
	
	if ([self dvd] == nil)
		return;
	
	// check to see if we have a name for this DVD already saved
	id savedName = [_dvdNames objectForKey:[[self dvd] mountedPath]];
	if (savedName)
	{
		[renameField setStringValue:savedName];
		[self rename:nil];
	}
	
    hb_scan(fHandle, [[[self dvd] bsdPath] UTF8String], 0);
}

- (DvdDisk *)dvd
{
	return _dvd;
}

- (void)setDVD:(DvdDisk *)dvd
{
	if (_dvd != dvd)
	{
		[_dvd release];
		_dvd = [dvd retain];
	}
}

- (void)dvdStartReading
{
	if ([self dvd] == nil)
	{
		_working = NO;
		
		// no DVD found
		[imageView setImage:[NSImage imageNamed:@"dvd_error"]];
		[dvdName setStringValue:_(@"No DVD")];
		[fStatusField setStringValue:@""];
		[fRipButton setEnabled:NO];
		[fRipIndicator setIndeterminate:NO];
		[fRipIndicator stopAnimation:nil];
		[showOptions setEnabled:NO];
		[self shrinkWindow];
	}
	else
	{
		_working = YES;
		
		// DVD found
		[imageView setImage:[NSImage imageNamed:@"dvd"]];
		[dvdName setStringValue:[[self dvd] name]];
		[renameField setStringValue:[[self dvd] name]];
		[fStatusField setStringValue:_(@"Reading disk")];
		[fRipButton setEnabled:NO];
		[fRipIndicator setIndeterminate:YES];
		[fRipIndicator startAnimation:nil];
		[showOptions setEnabled:NO];
	}
}

- (void)dvdFinishReading
{
	_working = NO;
	
	[fStatusField setStringValue:_(@"DVD Loaded")];
	[fRipButton setEnabled:YES];
	[fRipIndicator stopAnimation:nil];
	[fRipIndicator setIndeterminate:NO];
	[fRipIndicator setDoubleValue:0.0];
	[showOptions setEnabled:YES];
}

- (void)updateUI:(NSTimer *)timer
{
	// ugly - from HB source :P
	
    hb_state_t s;
    hb_get_state( fHandle, &s );
	
    switch( s.state )
    {
        case HB_STATE_SCANNING:
			_working = YES;
            break;

        case HB_STATE_SCANDONE:
        {
			hb_list_t *list;
            hb_title_t *title;
			int listCount = 0, i;
			int longestTitleIndex = -1;
			unsigned long long int longestTitleDuration = 0;
			
            list = hb_get_titles(fHandle);
            listCount = hb_list_count(list);
			
			[titlesPopUp removeAllItems];
            for (i=0; i<listCount; i++)
			{
                title = (hb_title_t *)hb_list_item(list, i);
				if (title->duration > longestTitleDuration)
				{
					longestTitleIndex = i;
					longestTitleDuration = title->duration;
				}
				
				[[titlesPopUp menu] addItemWithTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", title->hours, title->minutes, title->seconds] action:nil keyEquivalent:@""];
			}
			
			[titlesPopUp selectItemAtIndex:longestTitleIndex];
			[self updateSubtitles];
			[self dvdFinishReading];
			
            break;
        }

        case HB_STATE_WORKING:
        {
            float progress_total;
            
			_working = YES;
			
			[fStatusField setStringValue:[NSString stringWithFormat:_(@"%.2f%% complete..."),  100.0 * s.param.working.progress]];

            /* Update slider */
            progress_total = ( s.param.working.progress + s.param.working.job_cur - 1 ) / s.param.working.job_count;
            [fRipIndicator setDoubleValue: 100.0 * progress_total];
            [fRipButton setEnabled:YES];
            [fRipButton setTitle:_(@"Cancel")];
			[fRipButton setTag:1];
            break;
        }

        case HB_STATE_WORKDONE:
        {
			if ([fRipButton state] == 1 && [[[NSUserDefaults standardUserDefaults] objectForKey:PREFS_SEND_ITUNES] boolValue])
				[self sendToiTunes];
			else
				[self done];
			
			break;
        }
    }
}

- (void)done
{
	[fStatusField setStringValue:_(@"Done.")];
	[fRipIndicator setDoubleValue:0.0];
	[fRipButton setEnabled:YES];
	[fRipButton setTitle:_(@"Convert")];
	[fRipButton setTag:0];
	[showOptions setEnabled:YES];
	
	/* FIXME */
	hb_job_t *job;
	while (job = hb_job(fHandle, 0))
		hb_rem(fHandle, job);
	
	_working = NO;
}

- (void)updateSubtitles
{
	// keeping around in case people want this for later...
	
	/*hb_list_t *list;
	hb_title_t *title;
	hb_subtitle_t * subtitle;
	int i;

	list = hb_get_titles(fHandle);
	title = (hb_title_t *)hb_list_item(list, [titlesPopUp indexOfSelectedItem]);
	
	[subtitlesPopUp removeAllItems];
	[subtitlesPopUp addItemWithTitle:_(@"None")];
	for (i=0; i<hb_list_count(title->list_subtitle); i++)
	{
		subtitle = (hb_subtitle_t *)hb_list_item(title->list_subtitle, i);
		
		[[subtitlesPopUp menu] addItemWithTitle:[NSString stringWithUTF8String:subtitle->lang] action:nil keyEquivalent:@""];
	}
	[subtitlesPopUp selectItemAtIndex:0];*/
}

#pragma mark -

- (IBAction)rename:(id)sender
{
	[[self dvd] setName:[renameField stringValue]];
	[dvdName setStringValue:[renameField stringValue]];
	
	// save DVD name
	[_dvdNames setObject:[renameField stringValue] forKey:[[self dvd] mountedPath]];
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d setObject:_dvdNames forKey:PREFS_DVD_NAMES];
}

- (void)updateOutputDirectory
{
	// updates the "Output directory" items
	
	NSString *chosenDir = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_CHOSEN_DIR];
	if (chosenDir == nil)
		chosenDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
	
	[outputDirectoryPopUp removeAllItems];
	
	// add output directory
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:[chosenDir lastPathComponent] action:nil keyEquivalent:@""] autorelease];
	[menuItem setRepresentedObject:chosenDir];
	[[outputDirectoryPopUp menu] addItem:menuItem];
	// add separatory
	[[outputDirectoryPopUp menu] addItem:[NSMenuItem separatorItem]];
	// add Choose...
	[outputDirectoryPopUp addItemWithTitle:_(@"Choose")];

	[outputDirectoryPopUp selectItemAtIndex:0];
}

- (IBAction)chooseOutputDirectory:(id)sender
{
	// called when a user chooses an item in the "Output directory" pop up
	
	if ([[outputDirectoryPopUp titleOfSelectedItem] isEqualToString:_(@"Choose")])
	{
		NSOpenPanel *op = [NSOpenPanel openPanel];
		[op setCanChooseFiles:NO];
		[op setCanChooseDirectories:YES];
		
		if ([op runModal] == NSOKButton)
		{
			NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
			[d setObject:[op filename] forKey:PREFS_CHOSEN_DIR];
			[d synchronize];
			[self updateOutputDirectory];
		}
		else
		{
			[outputDirectoryPopUp selectItemAtIndex:0];
		}
	}
}

- (IBAction)updateSendToiTunes:(id)sender
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	if (sender == nil)
	{
		// updating value from prefs
		[sendToiTunes setState:[[d objectForKey:PREFS_SEND_ITUNES] boolValue]];
	}
	else
	{
		// user clicked on the checkbox
		[d setObject:[NSNumber numberWithBool:[sendToiTunes state]] forKey:PREFS_SEND_ITUNES];
		[d synchronize];
	}
}

- (IBAction)updateOptimizeMatrix:(id)sender
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	if (sender == nil)
	{
		// updating value from prefs
		[optimizeMatrix selectCellWithTag:[[d objectForKey:PREFS_OPTIMIZE] intValue]];
	}
	else
	{
		// user clicked on a cell
		[d setObject:[NSNumber numberWithInt:[[optimizeMatrix selectedCell] tag]] forKey:PREFS_OPTIMIZE];
		[d synchronize];
	}
}

#pragma mark -

- (void)prepareJob
{
	// setup the settings for iPod output
	hb_list_t  * list  = hb_get_titles( fHandle );
    hb_title_t * title = (hb_title_t *) hb_list_item( list, [titlesPopUp indexOfSelectedItem] );
    hb_job_t * job = title->job;

    /* Chapter selection */
    job->chapter_start = 1; //[fSrcChapterStartPopUp indexOfSelectedItem] + 1;
    job->chapter_end   = hb_list_count(title->list_chapter); //[fSrcChapterEndPopUp   indexOfSelectedItem] + 1;

    /* Format and codecs */
    int format = 0; // MP4 //[fDstFormatPopUp indexOfSelectedItem];
    int codecs = 0; // ffmpeg //[fDstCodecsPopUp indexOfSelectedItem];
	job->mux    = FormatSettings[format][codecs] & HB_MUX_MASK;
    job->vcodec = FormatSettings[format][codecs] & HB_VCODEC_MASK;
    job->acodec = FormatSettings[format][codecs] & HB_ACODEC_MASK;

    /* Audio tracks */
    job->arate = hb_audio_rates[hb_audio_rates_default].rate;
    job->abitrate = hb_audio_bitrates[hb_audio_bitrates_default].rate;
    job->audios[0] = 0; //[fAudLang1PopUp indexOfSelectedItem] - 1;
    job->audios[1] = -1; //[fAudLang2PopUp indexOfSelectedItem] - 1;
    job->audios[2] = -1;
	
	int optimize = [[[NSUserDefaults standardUserDefaults] objectForKey:PREFS_OPTIMIZE] intValue];
	if (optimize == 0) // iPod
	{
		job->width       = 320;
		job->height      = 240;
		job->vbitrate = 400;
	}
	else // TV
	{
		job->width       = 640;
		job->height      = 480;
		job->vbitrate = 700;
	}
	job->keep_ratio  = 1;
	job->deinterlace = 0;
    job->grayscale = 0;
	job->vquality = -1.0;
	job->subtitle = -1;
	job->vrate      = title->rate;
	job->vrate_base = title->rate_base;

	if (job->keep_ratio)
	{
		hb_fix_aspect( job, HB_KEEP_WIDTH );
		if( job->height > title->height )
		{
			job->height = title->height;
			hb_fix_aspect( job, HB_KEEP_HEIGHT );
		}
	}	
	
	// autocrop
	memcpy( job->crop, title->crop, 4 * sizeof( int ) );
	
	// output file
	NSString *outputDirectory = [[outputDirectoryPopUp selectedItem] representedObject];
	[self setMoviePath:[outputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [[self dvd] name]]]];
	job->file = strdup([[self moviePath] UTF8String]);
	
	job->pass = 0;
	hb_add(fHandle, job); // HB won't do anything unless we give it something to do :)
	
    /* Update lang popups */
    /*hb_audio_t * audio;
    [fAudLang1PopUp removeAllItems];
    [fAudLang2PopUp removeAllItems];
    [fAudLang1PopUp addItemWithTitle: _( @"None" )];
    [fAudLang2PopUp addItemWithTitle: _( @"None" )];
    for( int i = 0; i < hb_list_count( title->list_audio ); i++ )
    {
        audio = (hb_audio_t *) hb_list_item( title->list_audio, i );
		
        [[fAudLang1PopUp menu] addItemWithTitle:
            [NSString stringWithCString: audio->lang]
										 action: NULL keyEquivalent: @""];
        [[fAudLang2PopUp menu] addItemWithTitle:
            [NSString stringWithCString: audio->lang]
										 action: NULL keyEquivalent: @""];
    }
    [fAudLang1PopUp selectItemAtIndex: 1];
    [fAudLang2PopUp selectItemAtIndex: 0];*/	
}

- (IBAction)rip:(id)sender
{
    if ([fRipButton tag] == 1) // "Cancel"
    {
        [self cancel];
	}
	else
	{
		[self prepareJob];
		
		[self shrinkWindow];
		[showOptions setEnabled:NO];
		[fRipIndicator setIndeterminate:NO];
		[fRipButton setEnabled:NO];

		hb_start(fHandle);
	}
}

- (void)cancel
{
	// immediately stops and cancels the conversion
	
	hb_stop(fHandle);
	
	[fRipButton setEnabled:YES];
	[fRipButton setTitle:_(@"Convert")];
	[fRipButton setTag:0];
	/*[fStatusField setStringValue:_(@"Conversion cancelled")];
	[showOptions setEnabled:YES];*/
}

#pragma mark -

#define SMALL_WINDOW 127
#define BIG_WINDOW 290

- (IBAction)toggleOptions:(id)sender
{
	// shows/hides the options
	if ([[fWindow contentView] frame].size.height == SMALL_WINDOW)
		[self enlargeWindow];
	else
		[self shrinkWindow];
}

- (void)shrinkWindow
{
	if ([[fWindow contentView] frame].size.height == BIG_WINDOW)
		[self resizeWindowToHeight:SMALL_WINDOW];
	[showOptions setState:NO];
	[showOptionsField setStringValue:_(@"Show Options")];
}

- (void)enlargeWindow
{
	if ([[fWindow contentView] frame].size.height == SMALL_WINDOW)
		[self resizeWindowToHeight:BIG_WINDOW];
	[showOptions setState:YES];
	[showOptionsField setStringValue:_(@"Hide Options")];
}

- (void)resizeWindowToHeight:(float)height
{
	// this is old code.. probably needs updating but it works and I'm lazy :p
	
	NSSize newSize;
	NSRect newFrame;
	float newHeight, newWidth;
	newSize = NSMakeSize([fWindow frame].size.width, height);
	newHeight = newSize.height;
	newWidth = newSize.width;
	newFrame = [NSWindow contentRectForFrameRect:[fWindow frame] styleMask:[fWindow styleMask]];
	newFrame.origin.y += newFrame.size.height;
	newFrame.origin.y -= newHeight;
	newFrame.size.height = newHeight;
	newFrame.size.width = newWidth;
	newFrame = [NSWindow frameRectForContentRect:newFrame styleMask:[fWindow styleMask]];
	[fWindow setFrame:newFrame display:YES animate:YES];
}

#pragma mark -

- (void)sendToiTunes
{
	[fStatusField setStringValue:_(@"Sending to iTunes")];
	[fRipIndicator setIndeterminate:YES];
	[fRipIndicator startAnimation:nil];
	[NSThread detachNewThreadSelector:@selector(threadedSendToiTunes:) toTarget:self withObject:[self moviePath]];
}

- (void)threadedSendToiTunes:(NSString *)moviePath
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *scriptSource = [NSString stringWithFormat:@"tell application \"iTunes\" to add (\"%@\" as POSIX file)", moviePath];
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	if (script)
	{
		[script executeAndReturnError:nil];
	}
	
	[self performSelectorOnMainThread:@selector(sendToiTunesComplete) withObject:nil waitUntilDone:YES];
	
	[pool release];
}

- (void)sendToiTunesComplete
{
	[fRipIndicator stopAnimation:nil];
	[fRipIndicator setIndeterminate:NO];

	[self done];
}

#pragma mark -

- (void)setMoviePath:(NSString *)moviePath
{
	if (_moviePath != moviePath)
	{
		[_moviePath release];
		_moviePath = [moviePath retain];
	}
}

- (NSString *)moviePath
{
	return _moviePath;
}

@end
