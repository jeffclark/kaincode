//
//  Block.m
//  Tetris
//
//  Created by Kevin Wojniak on Thu Jun 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Block.h"


@implementation Block

+ (id)blockWithBounds:(NSRect)b
{
	return [[[self alloc] initWithBounds:b] autorelease];
}

- (id)initWithBounds:(NSRect)b andPosition:(NSPoint)p
{
	if (self = [super init]) {
		bounds = b;
		position = p;
	}
	
	return self;
}

+ (id)blockWithBounds:(NSRect)b andPosition:(NSPoint)p
{
	return [[[self alloc] initWithBounds:b andPosition:p] autorelease];
}

- (id)initWithBounds:(NSRect)b
{
	if (self = [super init]) {
		bounds = b;
		
		// center
		position.x = (bounds.size.width-BLOCK_SIZE)/2;
		position.y = bounds.size.height - BLOCK_SIZE - BORDER_WIDTH;
	}
	
	return self;
}

+ (id)blockWithBounds:(NSRect)b andPosition:(NSPoint)p byReferencingBaseBlock:(Block *)baseBlock
{
	return [[[self alloc] initWithBounds:b andPosition:p byReferencingBaseBlock:baseBlock] autorelease];
}

- (id)initWithBounds:(NSRect)b andPosition:(NSPoint)p byReferencingBaseBlock:(Block *)baseBlock
{
	if (self = [super init]) {
		bounds = b;
		
		[self setPosition:p byReferencingBaseBlock:baseBlock];
	}
	
	return self;	
}

- (void)dealloc
{
	[color release];
	[super dealloc];
}

- (void)setColor:(NSColor *)c
{
	color = c;
}

- (NSColor *)color
{
	return color;
}

- (void)draw
{
	NSBezierPath *block = [NSBezierPath bezierPathWithRect:NSMakeRect(position.x, position.y, BLOCK_SIZE, BLOCK_SIZE)];

	if (color) [color set];
	[block fill];
}

- (void)setPosition:(NSPoint)p
{
	position = p;
}

- (void)setPosition:(NSPoint)p byReferencingBaseBlock:(Block *)baseBlock
{
	NSPoint temp;
	temp.x = [baseBlock position].x + (BLOCK_SIZE * p.x);
	temp.y = [baseBlock position].y + (BLOCK_SIZE * p.y);

	[self setPosition:temp];
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

- (void)moveToBottom
{
	if (![self isAtBottom])
		position.y = BORDER_WIDTH;	
}

- (void)moveDown
{
	if (![self isAtBottom])
		position.y -= BLOCK_SIZE;
}

- (void)moveLeft
{
	if (![self isAtLeftSide])
		position.x -= BLOCK_SIZE;
}

- (void)moveRight
{
	if (![self isAtRightSide])
		position.x += BLOCK_SIZE;
}

@end
