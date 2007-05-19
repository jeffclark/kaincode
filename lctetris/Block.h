/*
 *  Block.h
 *  LCTetris
 *
 *  The "core" of the program. Every piece consists of 4 blocks
 *
 */

#include "Includes.h"

#pragma once

class Block
{
private:
	GLfloat zoomVal;
	GLfloat angle;
	bool visible;
	GLfloat r, g, b;

	void InitGL(GLvoid);
	void shift(GLfloat xOffset, GLfloat yOffset);
	
public:
	GLfloat xOffset, yOffset;

	Block();
	
	void Draw(GLvoid);
	
	void moveLeft();
	void moveRight();
	void moveDown();
	void moveUp();
	void moveLeft(GLuint amount);
	void moveRight(GLuint amount);
	void moveDown(GLuint amount);
	void moveUp(GLuint amount);
	void setPositionFromBlock(GLint x, GLint y, Block *baseBlock);
	
	void zoom(GLfloat value);
	
	GLfloat x();
	GLfloat y();
	
	void setVisible(bool flag);
	void setColor(GLfloat rr, GLfloat gg, GLfloat bb);
};