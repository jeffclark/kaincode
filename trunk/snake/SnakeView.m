//
//  SnakeView.m
//  Snake
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SnakeView.h"

#define BLOCK_SIZE	5

@implementation SnakeView

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		srandom(time(NULL));
		
		[self newGame];
    }

    return self;
}

- (void)dealloc
{
	[gameTimer release];
	[snakeTrails release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[[self window] makeFirstResponder:self];
}

#pragma mark -

- (BOOL)snakeTrailExistsAtPoint:(NSPoint)point
{
	NSEnumerator *e = [snakeTrails objectEnumerator];
	NSString *pointString;
	while (pointString = [e nextObject])
	{
		if (NSEqualPoints(NSPointFromString(pointString), point))
			return YES;
	}
	
	return NO;
}

- (void)newApple
{
	int x, y;
	do
	{
		x = (random() % (int)(([self bounds].size.width-(BLOCK_SIZE*2)) / BLOCK_SIZE) + BLOCK_SIZE) * BLOCK_SIZE;
		y = (random() % (int)(([self bounds].size.height-(BLOCK_SIZE*2)) / BLOCK_SIZE) + BLOCK_SIZE) * BLOCK_SIZE;
	}
	while ([self snakeTrailExistsAtPoint:NSMakePoint(x, y)]);
	
	appleLocation = NSMakePoint(x, y);
}

- (void)nextLevel
{
	[self newGame];
}

- (void)newGame
{
	NSRect bounds = [self bounds];
	snakeLocation = NSMakePoint(bounds.size.width/2, bounds.size.height/2);
	
	snakeDirection = DirectionRight;
	
	[snakeTrails release];
	snakeTrails = [[NSMutableArray alloc] init];
	
	trailLength = 5;
	nextTrailLength = trailLength * 1.5;
	
	score = 0;
	[self newApple];

	if (gameTimer != nil)
	{
		[gameTimer invalidate];
		[gameTimer release];
		gameTimer = nil;
	}
	gameTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveSnake:) userInfo:nil repeats:YES] retain];
}

- (BOOL)canMove
{
	switch (snakeDirection)
	{
		case DirectionLeft:
		{
			if (snakeLocation.x <= BLOCK_SIZE)
				return NO;
			break;
		}
		
		case DirectionRight:
		{
			if (snakeLocation.x + BLOCK_SIZE*2 >= [self bounds].size.width)
				return NO;
			break;
		}
			
		case DirectionUp:
		{
			if (snakeLocation.y + BLOCK_SIZE*2 >= [self bounds].size.height)
				return NO;
			break;
		}
			
		case DirectionDown:
		{
			if (snakeLocation.y <= BLOCK_SIZE)
				return NO;
			break;
		}
	}
	
	return YES;
}

- (void)moveSnake:(NSTimer *)timer
{
	if ([self canMove] == NO)
		return;
	
	[snakeTrails addObject:NSStringFromPoint(snakeLocation)];
	if (trailLength == 0)
	{
		[snakeTrails removeObjectAtIndex:0];
	}
	else
	{
		trailLength--;
	}
	
	switch (snakeDirection)
	{
		case DirectionLeft:
			snakeLocation.x -= BLOCK_SIZE;
			break;
		case DirectionRight:
			snakeLocation.x += BLOCK_SIZE;
			break;
		case DirectionUp:
			snakeLocation.y += BLOCK_SIZE;
			break;
		case DirectionDown:
			snakeLocation.y -= BLOCK_SIZE;
			break;
		default:
			break;
	}
	
	// check for eating apple
	if (NSEqualPoints(snakeLocation, appleLocation))
	{
		score += 100;
		if (score % 1000 == 0)
		{
			[self nextLevel];
		}
		else
		{
			trailLength = nextTrailLength;
			nextTrailLength = trailLength * 1.2;
			[self newApple];
		}
	}
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	
	// draw background
	[[NSColor greenColor] set];
	[NSBezierPath fillRect:bounds];
	
	// draw walls
	[[NSColor brownColor] set];
	[NSBezierPath fillRect:NSMakeRect(0, 0, BLOCK_SIZE, bounds.size.height)];
	[NSBezierPath fillRect:NSMakeRect(0, bounds.size.height-BLOCK_SIZE, bounds.size.width, bounds.size.height-BLOCK_SIZE)];
	[NSBezierPath fillRect:NSMakeRect(bounds.size.width-BLOCK_SIZE, 0, bounds.size.width-BLOCK_SIZE, bounds.size.height)];
	[NSBezierPath fillRect:NSMakeRect(0, 0, bounds.size.width, BLOCK_SIZE)];
	
	[[NSColor blueColor] set];
	NSRect snakeRect;
	snakeRect.size = NSMakeSize(BLOCK_SIZE, BLOCK_SIZE);

	// draw snake trails
	NSEnumerator *e = [snakeTrails objectEnumerator];
	NSString *pointString;
	while (pointString = [e nextObject])
	{
		NSPoint loc = NSPointFromString(pointString);
		snakeRect.origin = loc;		
		[NSBezierPath fillRect:snakeRect];
	}
	
	// draw snake head
	snakeRect.origin = snakeLocation;
	[NSBezierPath fillRect:snakeRect];
	
	// draw apple
	[[NSColor redColor] set];
	NSRect appleRect;
	appleRect.size = NSMakeSize(BLOCK_SIZE, BLOCK_SIZE);
	appleRect.origin = appleLocation;
	[NSBezierPath fillRect:appleRect];
}

- (void)keyDown:(NSEvent *)theEvent
{
	switch ([[theEvent characters] characterAtIndex:0])
	{
		case NSLeftArrowFunctionKey:
			if (snakeDirection != DirectionRight)
				snakeDirection = DirectionLeft;
			break;
		case NSRightArrowFunctionKey:
			if (snakeDirection != DirectionLeft)
				snakeDirection = DirectionRight;
			break;
		case NSUpArrowFunctionKey:
			if (snakeDirection != DirectionDown)
				snakeDirection = DirectionUp;
			break;
		case NSDownArrowFunctionKey:
			if (snakeDirection != DirectionUp)
				snakeDirection = DirectionDown;
			break;
		default:
			break;
	}
	
	[self setNeedsDisplay:YES];
}

@end
