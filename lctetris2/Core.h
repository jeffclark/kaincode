/*
 *  Core.h
 *  LCTetris
 *
 *  Created by Kevin Wojniak on 5/28/05.
 *
 *  The "main" class for Tetris. Handles almost everything.
 *
 */

#pragma once

#include <iostream>
#include <vector>

#include "Includes.h"
#include "Block.h"
#include "Frame.h"
#include "Piece.h"
#include "AudioPlayer.h"
#include "Prefs.h"
#include "Textures.h"

using namespace std;

typedef enum KeyEvent
{
	UpArrowKeyEvent,
	DownArrowKeyEvent,
	LeftArrowKeyEvent,
	RightArrowKeyEvent,
	SpacebarKeyEvent,
	EnterKeyEvent,
	LetterNKeyEvent
} KeyEvent;

class Core
{
private:
	vector<Block> blocks;
	Frame *frame;
	Piece *piece;
	Piece *nextPiece;
	AudioPlayer *audioPlayer;
	Textures *textures;
	GLint score, level;
	bool gameOver;
	bool paused;
	bool canMovePiece;
	
	GLuint milliseconds;
	void (*callbackFunc)(GLuint);
	void (*highscoreFunc)(GLuint, GLuint);

	bool CheckForGameOver();
	void doGameOver();
	void DoPauseUnpause();
	
	void newPiece();
	void checkForRow();

	void DrawString(char *s);
	void DrawStringBig(char *s);
	void DrawScoreAndLevel();		
	
	void shiftBlocksDownAboveRow(int row);
	bool pieceCanMoveDown();
	bool pieceCanMoveLeft();
	bool pieceCanMoveRight();
	bool pieceCanRotate();

public:
	Core();
	~Core();
	
	void SetCallbackFunction(void (*func)(GLuint));
	void SetHighscoreFunction(void (*func)(GLuint, GLuint));
	
	void InitGL();
	void Draw();
	void Reshape(GLsizei width, GLsizei height);
	void Drop();
	void DoKeyEvent(KeyEvent keyEvent);
	void NewGame();
	void AddHighScore(const char *name, GLuint score, GLuint level);
};