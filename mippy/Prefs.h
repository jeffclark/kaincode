#import <AppKit/AppKit.h>


@interface Prefs : NSWindowController {
    IBOutlet NSMatrix *matrix;
}

- (IBAction)save:(id)sender;

@end
