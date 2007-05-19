//
//  GameView.h
//  Tetris
//
//  Created by Kevin Wojniak on Thu Jun 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "GameSettings.h"
#import "Piece.h"
#import "Block.h"

@interface GameView : NSView {
	NSRect position;
	NSMutableArray *blocks;
	Piece *piece;
}

- (BOOL)freeSpaceBelowPiece;

- (BOOL)freeSpaceBelowBlock:(Block *)b;
- (BOOL)freeSpaceOnLeftSideOfBlock:(Block *)b;
- (BOOL)freeSpaceOnRightSideOfBlock:(Block *)b;

- (void)newPiece;
- (BOOL)gameOver;
- (void)clearRow;

- (void)drawBorder;
- (void)drawBlocks;

@end
