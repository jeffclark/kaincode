#import <Cocoa/Cocoa.h>

#include "Core.h"

@interface MyView : NSOpenGLView
{
	IBOutlet NSWindow *highscoreWindow;
	IBOutlet NSTextField *highScoreLabel, *highScoreField;
	
	NSTimer  *timer;
	NSTimer *dropTimer;
	
	Core *core;
	
	unsigned score, level;
}

- (void)startDrawTimer;
- (void)stopDrawTimer;

- (IBAction)OKHighScore:(id)sender;

@end
