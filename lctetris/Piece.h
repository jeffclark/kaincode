/*
 *  Piece.h
 *  LCTetris
 *
 *  This is the piece you control with arrow keys. on initialization it creates a random style
 *
 */

#include "Includes.h"
#include "Constants.h"
#include "Block.h"
#include <iostream>
#include <vector>
using namespace std;

class Piece
{
private:
	Block *blocks;
	int pieceType;
	GLint rotatePos;

public:
	Piece();
	~Piece();
	
	void Draw(GLvoid);
	
	void moveLeft();
	void moveRight();
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
	
	void setColor(GLfloat r, GLfloat g, GLfloat b);
};