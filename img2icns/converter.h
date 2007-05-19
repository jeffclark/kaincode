/* converter */

#import <Cocoa/Cocoa.h>

@interface converter : NSObject
{
    IBOutlet NSWindow *prefWin;
	IBOutlet NSMatrix *prefMatrix;
}

- (IBAction)savePrefs:(id)sender;

@end
