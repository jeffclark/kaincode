//
//  AppController.h
//  TicTacToe
//
//  Created by Kevin Wojniak on 2/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject
{
	IBOutlet NSMatrix *matrix;
	
	BOOL Xturn, gameOver;
}

- (IBAction)newGame:(id)sender;
- (IBAction)doTurn:(id)sender;

- (void)checkEnd;
- (void)doGameOver;

- (BOOL)rowEqual:(int)r;
- (BOOL)columnEqual:(int)c;
- (BOOL)diagonalEqual1;
- (BOOL)diagonalEqual2;
@end
