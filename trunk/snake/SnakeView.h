//
//  SnakeView.h
//  Snake
//
//  Created by Kevin Wojniak on 8/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	DirectionUp,
	DirectionDown,
	DirectionLeft,
	DirectionRight
} Direction;

@interface SnakeView : NSView
{
	NSTimer *gameTimer;
	NSMutableArray *snakeTrails;

	Direction snakeDirection;
	NSPoint snakeLocation;
	
	int nextTrailLength;
	int trailLength;
	
	NSPoint appleLocation;
	
	int score;
}

- (void)newGame;

@end
