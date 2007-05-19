//
//  GameView.m
//  Tetris
//
//  Created by Kevin Wojniak on Thu Jun 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"

@implementation GameView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		blocks = [[NSMutableArray alloc] init];
		
		[self newPiece];
		
		[NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(move) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)awakeFromNib
{
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)dealloc
{
	[blocks release];
	[piece release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {

	// set background color
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:[self bounds]];
	
	// draw the border
	[self drawBorder];
	
	// draw blocks
	[self drawBlocks];
	
	// draw piece
	[piece draw];
}

- (void)move
{
	if (![self gameOver]) {
		if (![self freeSpaceBelowPiece]) {
			[self newPiece];
			return;
		}
		
		[piece moveDown];
		[self setNeedsDisplay:YES];

		[self clearRow];
	} else {
		NSBeep();
	}
}

- (BOOL)freeSpaceBelowPiece
{
	NSEnumerator *e = [[piece blocks] objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if (![self freeSpaceBelowBlock:block] || [block isAtBottom])
			return NO;
	}
	return YES;
}

- (BOOL)freeSpaceOnLeftSideOfPiece
{
	NSEnumerator *e = [[piece blocks] objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if (![self freeSpaceOnLeftSideOfBlock:block] || [block isAtLeftSide])
			return NO;
	}
	return YES;
}

- (BOOL)freeSpaceOnRightSideOfPiece
{
	NSEnumerator *e = [[piece blocks] objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if (![self freeSpaceOnRightSideOfBlock:block] || [block isAtRightSide])
			return NO;
	}
	return YES;
}

- (BOOL)freeSpaceBelowBlock:(Block *)b
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if (([block position].y+BLOCK_SIZE == [b position].y) && ([block position].x == [b position].x)) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)freeSpaceOnLeftSideOfBlock:(Block *)b
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if (([block position].x == ([b position].x - BLOCK_SIZE)) && ([block position].y == [b position].y))
			return NO;
	}
	
	return YES;
}

- (BOOL)freeSpaceOnRightSideOfBlock:(Block *)b
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if (([block position].x == ([b position].x + BLOCK_SIZE)) && ([block position].y == [b position].y))
			return NO;
	}
	
	return YES;
}

- (void)newPiece
{
	if (piece) {
		[blocks addObjectsFromArray:[piece blocks]];

		[self clearRow];
	
		[piece release];
	}
	
	piece = [[Piece alloc] initWithBounds:[self bounds]];	
	[self setNeedsDisplay:YES];
}

- (BOOL)gameOver
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		if ([block position].y == [self bounds].size.height-BLOCK_SIZE-BORDER_WIDTH)
			return YES;
	}
	
	return NO;
}

- (void)clearRow
{
	NSEnumerator *e;
	Block *block;
	int y, c=0, i, theY=-1, rowsCleared=0;
	int blocksWide, blocksHigh, height;
	NSMutableArray *theBlocks = [NSMutableArray array];
	
	blocksWide = ([self bounds].size.width  -BORDER_WIDTH*2) / BLOCK_SIZE;
	blocksHigh = ([self bounds].size.height -BORDER_WIDTH*2) / BLOCK_SIZE;
	height = [self bounds].size.height - BORDER_WIDTH*2;
		
	for (y=BORDER_WIDTH; y<height; y+=BLOCK_SIZE) {
		NSMutableArray *tempBlocks = [NSMutableArray array];
		c = 0;
		
		e = [blocks objectEnumerator];
		while (block = [e nextObject]) {
			if ([block position].y == y) {
				[tempBlocks addObject:block];
				c++;
			}
		}
		
		if (c==blocksWide) {
			[theBlocks addObjectsFromArray:tempBlocks];
			
			rowsCleared++;
			
			if (theY == -1)
				theY = y;
		}
	}

	// remove blocks and shift down
	if (c % blocksWide == 0 && [theBlocks count]>0) {
		if ([theBlocks count]>0) {
			[blocks removeObjectsInArray:theBlocks];
			
			// remove blocks start at row above cleared row 
			for (y=theY+BLOCK_SIZE; y<height; y+=BLOCK_SIZE) {
				e = [blocks objectEnumerator];
				while (block = [e nextObject]) {
					if ([block position].y == y)
						for (i=0; i<rowsCleared; i++) // move down for each row cleared
							[block moveDown];
				}
			}
		}
	}

	[self setNeedsDisplay:YES];
}

- (void)drawBorder
{
	NSRect bounds = [self bounds];
	NSBezierPath *border = [NSBezierPath bezierPath];
	
	// left
	[border appendBezierPathWithRect:NSMakeRect(0, 0, BORDER_WIDTH, bounds.size.height)];
	// right
	[border appendBezierPathWithRect:NSMakeRect(bounds.size.width-BORDER_WIDTH, 0, BORDER_WIDTH, bounds.size.height)];
	// bottom
	[border appendBezierPathWithRect:NSMakeRect(0, 0, bounds.size.width, BORDER_WIDTH)];
	// top
	[border appendBezierPathWithRect:NSMakeRect(0, bounds.size.height-BORDER_WIDTH, bounds.size.width, bounds.size.height)];
	
	[[NSColor grayColor] set];
	[border fill];
}

- (void)drawBlocks
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		[block draw];
	}
}

- (void)keyDown:(NSEvent *)event
{
	if (![self gameOver]) {
		if ([[event characters] characterAtIndex:0] == NSLeftArrowFunctionKey) {			// left arrow
			if ([self freeSpaceOnLeftSideOfPiece]) {
				[piece moveLeft];
				[self setNeedsDisplay:YES];
			}
		} else 	if ([[event characters] characterAtIndex:0] == NSRightArrowFunctionKey) {	// right arrow
			if ([self freeSpaceOnRightSideOfPiece]) {
				[piece moveRight];
				[self setNeedsDisplay:YES];
			}
		} else 	if ([[event characters] characterAtIndex:0] == NSDownArrowFunctionKey) {	// down arrow
			[self move];
		} else 	if ([[event characters] characterAtIndex:0] == NSUpArrowFunctionKey) {	// up arrow
			[piece rotateCounterClockwise];
			[self setNeedsDisplay:YES];
		}
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}


/*- (BOOL)becomeFirstResponder
{
	return YES;
}*/

@end
