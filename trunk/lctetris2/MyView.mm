#import "MyView.h"

@implementation MyView

- (id)initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attr[] = 
	{
        NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute) 32,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute) 23,
		(NSOpenGLPixelFormatAttribute) 0
	};
	NSOpenGLPixelFormat *nsglFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attr] autorelease];
	
    if (self = [super initWithFrame:frameRect pixelFormat:nsglFormat])
	{
		core = new Core();
		
		NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter addObserver:self selector:@selector(handleSpeedUpTimer:) name:@"SpeedUpTimer" object:nil];
		[defaultCenter addObserver:self selector:@selector(handleHighscore:) name:@"Highscore" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	delete core;
	
	[timer invalidate];
	[timer release];
	[dropTimer invalidate];
	[dropTimer release];
	
	[[NSNotificationCenter defaultCenter]  removeObserver:self];
	
	[super dealloc];
}

- (void)prepareOpenGL
{
	core->InitGL();
}

void speedUpTimer(GLuint milliseconds)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SpeedUpTimer" object:[NSNumber numberWithUnsignedInt:milliseconds]];
}

- (void)handleSpeedUpTimer:(NSNotification *)notification
{
	NSNumber *num = [notification object];
	unsigned milliseconds = [num unsignedIntValue];
	double mil = (milliseconds / 1000.0);

	[self startDrawTimer];
	
	if (dropTimer != nil)
	{
		[dropTimer invalidate];
		[dropTimer release];
		dropTimer = nil;
	}
	
	if (mil > 0)
		dropTimer = [[NSTimer scheduledTimerWithTimeInterval:mil target:self selector:@selector(drop) userInfo:nil repeats:YES] retain];
}

void highscore(GLuint score, GLuint level)
{
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:score], @"score",
		[NSNumber numberWithInt:level], @"level",
		nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Highscore" object:nil userInfo:info];
}

- (void)handleHighscore:(NSNotification *)notification
{
	// do nothing for now
	return;
	
	NSDictionary *userInfo = [notification userInfo];
	if (userInfo == nil)
		return;
	
	[self stopDrawTimer];
	
	score = [[userInfo objectForKey:@"score"] intValue];
	level = [[userInfo objectForKey:@"level"] intValue];
	
	[highScoreLabel setStringValue:[NSString stringWithFormat:@"You got a high score of %d! Please enter your name:", score]];
	[NSApp runModalForWindow:highscoreWindow];
}

- (IBAction)OKHighScore:(id)sender
{
	[NSApp stopModal];
	[highscoreWindow orderOut:nil];
	
	NSString *name = [highScoreField stringValue];
	core->AddHighScore([name UTF8String], score, level);
}

- (void)awakeFromNib
{
	core->SetCallbackFunction(speedUpTimer);
	core->SetHighscoreFunction(highscore);
	core->NewGame();

	[self startDrawTimer];

	[[self window] makeFirstResponder:self]; 
	[[self window] setAcceptsMouseMovedEvents:YES]; 
}

- (void)startDrawTimer
{
	if (timer == nil)
	{
		timer = [[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(drawFrame) userInfo:nil repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSModalPanelRunLoopMode];
	}
}

- (void)stopDrawTimer
{
	if (timer != nil)
	{
		[timer invalidate];
		[timer release];
		timer = nil;
	}
}

- (void)drop
{
	core->Drop();
}

- (void)reshape
{
	NSSize bounds = [self frame].size;
	core->Reshape((GLsizei)bounds.width, (GLsizei)bounds.height);	
}

- (void)drawFrame
{
	core->Draw();
	
	// flush
	[[self openGLContext] flushBuffer];
}

- (void)keyDown:(NSEvent *)event
{
	unichar character = [[event characters] characterAtIndex:0];
	
	if (character == NSLeftArrowFunctionKey)
	{
		core->DoKeyEvent(LeftArrowKeyEvent);
	}
	else if (character == NSUpArrowFunctionKey)
	{
		core->DoKeyEvent(UpArrowKeyEvent);
	}
	else if (character == NSRightArrowFunctionKey)
	{
		core->DoKeyEvent(RightArrowKeyEvent);
	}
	else if (character == NSDownArrowFunctionKey)
	{
		core->DoKeyEvent(DownArrowKeyEvent);
	}
	else if (character == 32)
	{
		core->DoKeyEvent(SpacebarKeyEvent);
	}
	else if (character == 13)
	{
		core->DoKeyEvent(EnterKeyEvent);
	}
	else if (character == 'n' || character == 'N')
	{
		core->DoKeyEvent(LetterNKeyEvent);
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

@end
