#include "Block.h"

Block::Block()
{
	xOffset = 0.0f;
	yOffset = 0.0f;
	zoomVal = -20.0f;

	setColor(1.0f, 1.0f, 1.0f); // white
	drawPaused = false;
}

void Block::Draw(GLvoid)
{
	glLoadIdentity();
	glTranslatef(xOffset, yOffset, zoomVal);
	
	GLfloat tempR, tempG, tempB;
	
	if (drawPaused)
	{
		// compute grayscale for paused
		GLfloat average = (r + g + b) / 3.0f;
		tempR = average;
		tempG = average;
		tempB = average;
	}
	else
	{
		tempR = r;
		tempG = g;
		tempB = b;
	}
	
	// front side
	glBegin(GL_QUADS);
	glColor3f(tempR, tempG, tempB);
	glNormal3f( 0.0f, 0.0f, 1.0f);
	glTexCoord2f(0.0f, 0.0f); glVertex3f(0.0f, 0.0f, 0.0f);
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-BLOCK_SIZE, 0.0f, 0.0f);
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, 0.0f);
	glTexCoord2f(0.0f, 1.0f); glVertex3f(0.0f, BLOCK_SIZE, 0.0f);
	glEnd();
	// back side
	glBegin(GL_QUADS);
	glColor3f(tempR, tempG, tempB);
	glNormal3f( 0.0f, 0.0f, -1.0f);
	glTexCoord2f(0.0f, 0.0f); glVertex3f(0.0f, 0.0f, -BLOCK_SIZE);
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-BLOCK_SIZE, 0.0f, -BLOCK_SIZE);
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, -BLOCK_SIZE);
	glTexCoord2f(0.0f, 1.0f); glVertex3f(0.0f, BLOCK_SIZE, -BLOCK_SIZE);
	glEnd();

	// left side
	glBegin(GL_QUADS);
	glColor3f(tempR, tempG, tempB);
	glNormal3f( -1.0f, 0.0f, 0.0f);
	glTexCoord2f(0.0f, 0.0f);glVertex3f(-BLOCK_SIZE, 0.0, 0.0);
	glTexCoord2f(1.0f, 0.0f);glVertex3f(-BLOCK_SIZE, 0.0f, -BLOCK_SIZE);
	glTexCoord2f(1.0f, 1.0f);glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, -BLOCK_SIZE);
	glTexCoord2f(0.0f, 1.0f);glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, 0.0f);
	glEnd();

	//right side
	glBegin(GL_QUADS);
	glColor3f(tempR, tempG, tempB);
	glNormal3f( 1.0f, 0.0f, 0.0f);
	glTexCoord2f(0.0f, 0.0f);glVertex3f(0, 0.0, 0.0);
	glTexCoord2f(1.0f, 0.0f);glVertex3f(0, 0.0f, -BLOCK_SIZE);
	glTexCoord2f(1.0f, 1.0f);glVertex3f(0, BLOCK_SIZE, -BLOCK_SIZE);
	glTexCoord2f(0.0f, 1.0f);glVertex3f(0, BLOCK_SIZE, 0.0f);
	glEnd();

	//top
	glBegin(GL_QUADS);
	glColor3f(tempR, tempG, tempB);
	glNormal3f( 0.0f, 1.0f, 0.0f);
	glTexCoord2f(0.0f, 0.0f);glVertex3f(0, BLOCK_SIZE, 0.0);
	glTexCoord2f(1.0f, 0.0f);glVertex3f(0, BLOCK_SIZE, -BLOCK_SIZE);
	glTexCoord2f(1.0f, 1.0f);glVertex3f( -BLOCK_SIZE, BLOCK_SIZE, -BLOCK_SIZE);
	glTexCoord2f(0.0f, 1.0f);glVertex3f( -BLOCK_SIZE, BLOCK_SIZE, 0.0f);
	glEnd();

	//bottom
	glBegin(GL_QUADS);
	glColor3f(tempR, tempG, tempB);
	glNormal3f( 0.0f, 1.0f, 0.0f);
	glTexCoord2f(0.0f, 0.0f);glVertex3f(0, 0, 0.0);
	glTexCoord2f(1.0f, 0.0f);glVertex3f(0, 0, -BLOCK_SIZE);
	glTexCoord2f(1.0f, 1.0f);glVertex3f( -BLOCK_SIZE, 0, -BLOCK_SIZE);
	glTexCoord2f(0.0f, 1.0f);glVertex3f( -BLOCK_SIZE, 0, 0.0f);
	glEnd();
}

void Block::moveLeft()
{
	shift(-BLOCK_SIZE, 0.0f);
}

void Block::moveRight()
{
	shift(BLOCK_SIZE, 0.0f);
}

void Block::moveDown()
{
	shift(0.0f, -BLOCK_SIZE);
}

void Block::moveUp()
{
	shift(0.0f, BLOCK_SIZE);
}

void Block::moveLeft(GLuint amount)
{
	for (int i=0; i<(int)amount; i++)
		moveLeft();
}

void Block::moveRight(GLuint amount)
{
	for (int i=0; i<(int)amount; i++)
		moveRight();
}

void Block::moveDown(GLuint amount)
{
	for (int i=0; i<(int)amount; i++)
		moveDown();
}

void Block::moveUp(GLuint amount)
{
	for (int i=0; i<(int)amount; i++)
		moveUp();
}

void Block::setPositionFromBlock(GLint xx, GLint yy, Block *baseBlock)
{
	xOffset = baseBlock->xOffset + (xx * BLOCK_SIZE);
	yOffset = baseBlock->yOffset + (yy * BLOCK_SIZE);
}

void Block::shift(GLfloat xx, GLfloat yy)
{
	xOffset += xx;
	yOffset += yy;
}

void Block::zoom(GLfloat value)
{
	zoomVal += value;
}

GLfloat Block::x()
{
	// the block initially draws below 0...
	return xOffset - BLOCK_SIZE;
}

GLfloat Block::y()
{
	return yOffset;
}

void Block::setColor(GLfloat rr, GLfloat gg, GLfloat bb)
{
	r = rr;
	g = gg;
	b = bb;
}

void Block::DrawPaused(bool value)
{
	drawPaused = value;
}