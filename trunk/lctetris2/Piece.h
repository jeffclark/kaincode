/*
 *  Piece.h
 *  LCTetris
 *
 *  This is the piece you control with arrow keys. on initialization it creates a random style
 *
 */
#pragma once

#include "Includes.h"
#include "Constants.h"
#include "Block.h"
#include <iostream>
#include <vector>
using namespace std;

typedef enum PieceType
{
	ZType = 1,
	BkwdZType,
	BarType,
	SquareType,
	LType,
	BkwdLType,
	TType
} PieceType;

class Piece
{
private:
	Block *blocks;
	PieceType pieceType;
	GLint rotatePos;

public:
	Piece();
	~Piece();
	
	void Draw(GLvoid);
	
	void moveLeft();
	void moveLeft(int x);
	void moveRight();
	void moveRight(int x);
	void moveDown();
	void moveUp();
	void rotate();
	
	GLfloat x();
	GLfloat y();
	GLfloat width();
	GLfloat height();
	
	void copyBlocksIntoVector(vector<Block> *vector);
	bool containsBlockAboveBlock(Block *block);
	bool containsBlockRightOfBlock(Block *block);
	bool containsBlockLeftOfBlock(Block *block);
	bool containsBlockEqualToBlock(Block *block);
	
	void setColor(GLfloat r, GLfloat g, GLfloat b);
	void DrawPaused(bool value);
};