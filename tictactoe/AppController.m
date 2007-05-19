//
//  AppController.m
//  TicTacToe
//
//  Created by Kevin Wojniak on 2/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void)awakeFromNib
{
	[self newGame:nil];
}

- (IBAction)newGame:(id)sender
{
	Xturn = YES;
	gameOver = NO;

	int x, y;
	for (x=0; x<[matrix numberOfRows]; x++)
		for (y=0; y<[matrix numberOfColumns]; y++)
			[[matrix cellAtRow:x column:y] setTitle:@""];
}

- (IBAction)doTurn:(id)sender
{
	if (gameOver) return;
	
	id cell = [matrix selectedCell];
	if (![[cell title] isEqualToString:@""]) return;
	
	[cell setTitle:(Xturn ? @"X" : @"O")];
	Xturn = !Xturn;
	
	[self checkEnd];
}

- (void)checkEnd;
{
	int r, c;
	for (r=0; r<[matrix numberOfRows]; r++)
	{
		if ([self rowEqual:r])
		{
			[self doGameOver];
			return;
		}
	}

	for (c=0; c<[matrix numberOfColumns]; c++)
	{
		if ([self columnEqual:c])
		{
			[self doGameOver];
			return;
		}
	}
	
	if ([self diagonalEqual1] || [self diagonalEqual2]) [self doGameOver];
}

- (void)doGameOver
{
	NSBeep();
	if (NSRunAlertPanel(@"Game Over", @"The game is over.", @"OK", nil, @"Quit", nil) == NSAlertOtherReturn)
		[NSApp terminate:nil];
		
	gameOver = YES;
}

- (BOOL)rowEqual:(int)r
{
	int c;
	for (c=0; c<[matrix numberOfColumns]; c++)
	{
		if (![[[matrix cellAtRow:r column:c] title] isEqualToString:[[matrix cellAtRow:r column:0] title]] ||
			[[[matrix cellAtRow:r column:c] title] isEqualToString:@""])
			return NO;
	}
	return YES;
}

- (BOOL)columnEqual:(int)c
{
	int r;
	for (r=0; r<[matrix numberOfRows]; r++)
	{
		if (![[[matrix cellAtRow:r column:c] title] isEqualToString:[[matrix cellAtRow:0 column:c] title]] ||
			[[[matrix cellAtRow:r column:c] title] isEqualToString:@""])
			return NO;
	}
	return YES;
}

- (BOOL)diagonalEqual1
{
	if ([matrix numberOfRows] != [matrix numberOfColumns]) return NO;
	
	int i;
	for (i=0; i<[matrix numberOfRows]; i++)
		if (![[[matrix cellAtRow:i column:i] title] isEqualToString:[[matrix cellAtRow:0 column:0] title]] ||
			[[[matrix cellAtRow:i column:i] title] isEqualToString:@""])
			return NO;
	return YES;
}

- (BOOL)diagonalEqual2
{
	if ([matrix numberOfRows] != [matrix numberOfColumns]) return NO;
	
	int i;
	for (i=[matrix numberOfRows]-1; i>=0; i--)
		if (![[[matrix cellAtRow:[matrix numberOfRows]-i-1 column:i] title] isEqualToString:[[matrix cellAtRow:0 column:[matrix numberOfColumns]-1] title]] ||
			[[[matrix cellAtRow:[matrix numberOfRows]-i-1 column:i] title] isEqualToString:@""])
			return NO;

	return YES;
}

@end
