//
//  Piece.m
//  Tetris
//
//  Created by Kevin Wojniak on Thu Jun 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Piece.h"


@implementation Piece

- (id)initWithBounds:(NSRect)b
{
	if (self = [super init]) {
		bounds = b;
		
		kind = (((float)random() / RAND_MAX) * 7);		// 0-6 for different shapes
		rotation = 0;   // 0-3 for 4 different types of of rotation
		
		baseBlock = [[Block alloc] initWithBounds:bounds];
		blocks = [[NSMutableArray alloc] init];
		
		[blocks addObject:baseBlock]; // base block
		switch (kind) {
			case 0:		// T
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, 0) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, -1) byReferencingBaseBlock:baseBlock]];
				break;
			case 1:		// |
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 2) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, -1) byReferencingBaseBlock:baseBlock]];
				break;
			case 2:		// block
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, 1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, 0) byReferencingBaseBlock:baseBlock]];
				break;
			case 3:		// obj1
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, 0) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, -1) byReferencingBaseBlock:baseBlock]];
				break;
			case 4:		// obj2
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, 0) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, 1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, -1) byReferencingBaseBlock:baseBlock]];
				break;
			case 5:		// L-f
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, -1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(1, -1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 1) byReferencingBaseBlock:baseBlock]];
				break;
			case 6:		// L-b
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, -1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(-1, -1) byReferencingBaseBlock:baseBlock]];
				[blocks addObject:[Block blockWithBounds:bounds andPosition:NSMakePoint(0, 1) byReferencingBaseBlock:baseBlock]];
				break;
		}
		
		position.x = (bounds.size.width-BLOCK_SIZE)/2;
		position.y = bounds.size.height - BLOCK_SIZE - BORDER_WIDTH;
	}
	
	return self;
}

- (void)dealloc
{
	[blocks release];
	[baseBlock release];
	[super dealloc];
}

- (void)draw
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	NSColor *color = nil;

	switch (kind) {
		case 0:
			color = [NSColor redColor];
			break;
		case 1:
			color = [NSColor blueColor];
			break;
		case 2:
			color = [NSColor greenColor];
			break;
		case 3:
			color = [NSColor yellowColor];
			break;
		case 4:
			color = [NSColor orangeColor];
			break;
		case 5:
			color = [NSColor purpleColor];
			break;
		case 6:
			color = [NSColor cyanColor];
			break;
	}

	while (block = [e nextObject]) {
		[block setColor:color];
		[block draw];
	}
}

- (NSArray *)blocks
{
	return [blocks retain];//[NSArray arrayWithArray:blocks];
}

- (Block *)baseBlock
{
	return baseBlock;
}

- (void)rotateCounterClockwise
{
	rotation++;
	if (rotation==4) rotation=0;

	[self rotate];
}

- (void)rotate
{
	switch (kind) {
		case 0:						// T
			switch (rotation) {
				case 0:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, -1) ofBlock:2];
					[self setPosition:NSMakePoint(0, 1) ofBlock:3];
					break;
				case 1:
					[self setPosition:NSMakePoint(0, 1) ofBlock:1];
					[self setPosition:NSMakePoint(-1, 0) ofBlock:2];
					[self setPosition:NSMakePoint(1, 0) ofBlock:3];
					break;
				case 2:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, -1) ofBlock:2];
					[self setPosition:NSMakePoint(0, 1) ofBlock:3];
					break;
				case 3:
					[self setPosition:NSMakePoint(0, -1) ofBlock:1];
					[self setPosition:NSMakePoint(-1, 0) ofBlock:2];
					[self setPosition:NSMakePoint(1, 0) ofBlock:3];
					break;						
			}
			break;
		case 1:						// |
			switch (rotation) {
				case 0:
					[self setPosition:NSMakePoint(0, 1) ofBlock:1];
					[self setPosition:NSMakePoint(0, 2) ofBlock:2];
					[self setPosition:NSMakePoint(0, -1) ofBlock:3];
					break;
				case 1:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(-2, 0) ofBlock:2];
					[self setPosition:NSMakePoint(1, 0) ofBlock:3];
					break;
				case 2:
					[self setPosition:NSMakePoint(0, -1) ofBlock:1];
					[self setPosition:NSMakePoint(0, -2) ofBlock:2];
					[self setPosition:NSMakePoint(0, 1) ofBlock:3];
					break;
				case 3:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(2, 0) ofBlock:2];
					[self setPosition:NSMakePoint(-1, 0) ofBlock:3];
					break;						
			}
			break;
		case 2:						// block
			[self setPosition:NSMakePoint(0, 1) ofBlock:1];
			[self setPosition:NSMakePoint(1, 1) ofBlock:2];
			[self setPosition:NSMakePoint(1, 0) ofBlock:3];
			break;
		case 3:						// obj1
			switch (rotation) {
				case 0:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, 1) ofBlock:2];
					[self setPosition:NSMakePoint(1, -1) ofBlock:3];
					break;
				case 1:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, -1) ofBlock:2];
					[self setPosition:NSMakePoint(-1, -1) ofBlock:3];
					break;
				case 2:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, 1) ofBlock:2];
					[self setPosition:NSMakePoint(1, -1) ofBlock:3];
					break;
				case 3:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, -1) ofBlock:2];
					[self setPosition:NSMakePoint(-1, -1) ofBlock:3];
					break;						
			}
			break;
		case 4:						// obj2
			switch (rotation) {
				case 0:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(1, 1) ofBlock:2];
					[self setPosition:NSMakePoint(0, -1) ofBlock:3];
					break;
				case 1:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, -1) ofBlock:2];
					[self setPosition:NSMakePoint(1, -1) ofBlock:3];
					break;
				case 2:
					[self setPosition:NSMakePoint(1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(1, 1) ofBlock:2];
					[self setPosition:NSMakePoint(0, -1) ofBlock:3];
					break;
				case 3:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(0, -1) ofBlock:2];
					[self setPosition:NSMakePoint(1, -1) ofBlock:3];
					break;						
			}
			break;
		case 5:						// L-f
			switch (rotation) {
				case 0:
					[self setPosition:NSMakePoint(0, -1) ofBlock:1];
					[self setPosition:NSMakePoint(1, -1) ofBlock:2];
					[self setPosition:NSMakePoint(0, 1) ofBlock:3];
					break;
				case 1:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(1, 0) ofBlock:2];
					[self setPosition:NSMakePoint(1, 1) ofBlock:3];
					break;
				case 2:
					[self setPosition:NSMakePoint(0, -1) ofBlock:1];
					[self setPosition:NSMakePoint(0, 1) ofBlock:2];
					[self setPosition:NSMakePoint(-1, 1) ofBlock:3];
					break;
				case 3:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(1, 0) ofBlock:2];
					[self setPosition:NSMakePoint(-1, -1) ofBlock:3];
					break;						
			}
			break;
		case 6:						// L-b
			switch (rotation) {
				case 0:
					[self setPosition:NSMakePoint(0, -1) ofBlock:1];
					[self setPosition:NSMakePoint(-1, -1) ofBlock:2];
					[self setPosition:NSMakePoint(0, 1) ofBlock:3];
					break;
				case 1:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(1, 0) ofBlock:2];
					[self setPosition:NSMakePoint(1, -1) ofBlock:3];
					break;
				case 2:
					[self setPosition:NSMakePoint(0, -1) ofBlock:1];
					[self setPosition:NSMakePoint(0, 1) ofBlock:2];
					[self setPosition:NSMakePoint(1, 1) ofBlock:3];
					break;
				case 3:
					[self setPosition:NSMakePoint(-1, 0) ofBlock:1];
					[self setPosition:NSMakePoint(1, 0) ofBlock:2];
					[self setPosition:NSMakePoint(-1, 1) ofBlock:3];
					break;						
			}
			break;
			
		default:
			break;
	}
}

- (void)setPosition:(NSPoint)p ofBlock:(int)blockNum
{
	[[blocks objectAtIndex:blockNum] setPosition:p byReferencingBaseBlock:[blocks objectAtIndex:0]];
}

- (void)setPosition:(NSPoint)p
{
	position = p;
}

- (NSPoint)position
{
	return position;
}

- (BOOL)isAtBottom
{
	if (position.y == BORDER_WIDTH)
		return YES;
	return NO;
}

- (BOOL)isAtLeftSide
{
	if (position.x == BORDER_WIDTH)
		return YES;
	return NO;
}

- (BOOL)isAtRightSide
{
	if (position.x == (bounds.size.width - BLOCK_SIZE - BORDER_WIDTH))
		return YES;
	return NO;
}

- (void)moveDown
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		[block moveDown];
	}
	
	position.y -= BLOCK_SIZE;
}

- (void)moveLeft
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		[block moveLeft];
	}
	
	position.x -= BLOCK_SIZE;
}

- (void)moveRight
{
	NSEnumerator *e = [blocks objectEnumerator];
	Block *block;
	
	while (block = [e nextObject]) {
		[block moveRight];
	}
	
	position.x += BLOCK_SIZE;
}

@end