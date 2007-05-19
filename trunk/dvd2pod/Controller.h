/* $Id: Controller.h,v 1.35 2005/08/01 14:29:50 titer Exp $

   This file is part of the HandBrake source code.
   Homepage: <http://handbrake.m0k.org/>.
   It may be used under the terms of the GNU General Public License. */

#import <Cocoa/Cocoa.h>
//#import "hb.h"
#import "mediafork.h"

@class DvdDisk;

@interface Controller : NSObject
{
    IBOutlet NSWindow *fWindow;
    IBOutlet NSTextField *fStatusField;
    IBOutlet NSProgressIndicator *fRipIndicator;
    IBOutlet NSButton *fRipButton;
	IBOutlet NSTextField *dvdName;
	IBOutlet NSImageView *imageView;
	IBOutlet NSPopUpButton *titlesPopUp;
	IBOutlet NSButton *showOptions;
	IBOutlet NSTextField *showOptionsField;
	IBOutlet NSPopUpButton *outputDirectoryPopUp;
	IBOutlet NSButton *sendToiTunes;
	IBOutlet NSMatrix *optimizeMatrix;
	IBOutlet NSTextField *renameField;

    hb_handle_t *fHandle;
	DvdDisk *_dvd;
	NSMutableDictionary *_dvdNames;
	NSString *_moviePath;
	BOOL _working;
}

- (IBAction)rip:(id)sender;

- (IBAction)toggleOptions:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)chooseOutputDirectory:(id)sender;
- (IBAction)updateSendToiTunes:(id)sender;
- (IBAction)updateOptimizeMatrix:(id)sender;

@end

