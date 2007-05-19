//
//  Block.h
//  Tetris
//
//  Created by Kevin Wojniak on Thu Jun 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameSettings.h"

@interface Block : NSObject {
	NSPoint position;
	NSRect bounds;
	NSColor *color;
}

+ (id)blockWithBounds:(NSRect)b;
- (id)initWithBounds:(NSRect)b;

+ (id)blockWithBounds:(NSRect)b andPosition:(NSPoint)p;
- (id)initWithBounds:(NSRect)b andPosition:(NSPoint)p;

+ (id)blockWithBounds:(NSRect)b andPosition:(NSPoint)p byReferencingBaseBlock:(Block *)baseBlock;
- (id)initWithBounds:(NSRect)b andPosition:(NSPoint)p byReferencingBaseBlock:(Block *)baseBlock;

- (void)setColor:(NSColor *)c;
- (NSColor *)color;

- (void)draw;

- (void)setPosition:(NSPoint)p;
- (void)setPosition:(NSPoint)p byReferencingBaseBlock:(Block *)baseBlock;
- (NSPoint)position;

- (BOOL)isAtBottom;
- (BOOL)isAtLeftSide;
- (BOOL)isAtRightSide;

- (void)moveToBottom;
- (void)moveDown;
- (void)moveLeft;
- (void)moveRight;

@end
