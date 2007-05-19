//
//  Piece.h
//  Tetris
//
//  Created by Kevin Wojniak on Thu Jun 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Block.h"

@interface Piece : NSObject {
	NSMutableArray *blocks;
	NSRect bounds;
	NSPoint position;
	Block *baseBlock;
	int kind, rotation;
}

- (id)initWithBounds:(NSRect)b;

- (void)draw;

- (NSArray *)blocks;
- (Block *)baseBlock;

- (void)rotateCounterClockwise;
- (void)rotate;
- (void)setPosition:(NSPoint)p ofBlock:(int)blockNum;

- (void)setPosition:(NSPoint)p;
- (NSPoint)position;

- (BOOL)isAtBottom;
- (BOOL)isAtLeftSide;
- (BOOL)isAtRightSide;

- (void)moveDown;
- (void)moveLeft;
- (void)moveRight;

@end
