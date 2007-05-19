#include "Block.h"

Block::Block()
{
	xOffset = 0.0f;
	yOffset = 0.0f;
	zoomVal = -20.0f;
	angle = -90.0f;
	visible = true;
	
	setColor(1.0f, 1.0f, 1.0f); // white
}

void Block::Draw(GLvoid)
{
	if (!visible) return;
	
	glLoadIdentity();
	//glRotatef(angle, 0.0f, -2.0f, 0.0f);
	//glRotatef(shiftXOffset, 0.0, 1.0f, 0.0f);
	//glRotatef(shiftYOffset, 1.0, 0.0f, 0.0f);
	///glRotatef(angle, 5.0f, 5.0f, 0.0f);
	glTranslatef(xOffset, yOffset, zoomVal);
	
	// front side
	glBegin(GL_QUADS);
	glColor3f(r, g, b);			// red
	glVertex3f(0.0f, 0.0f, 0.0f);
	glVertex3f(-BLOCK_SIZE, 0.0f, 0.0f);
	glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, 0.0f);
	glVertex3f(0.0f, BLOCK_SIZE, 0.0f);
	glEnd();
	
	/*// back side
	glBegin(GL_LINE_LOOP);
	glColor3f(r, g, b);			// green
	glVertex3f(0.0f, 0.0f, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, 0.0f, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, -BLOCK_SIZE);
	glVertex3f(0.0f, BLOCK_SIZE, -BLOCK_SIZE);
	glEnd();
	
	// left side
	glBegin(GL_LINES);
	glColor3f(r, g, b);			// blue
	glVertex3f(-BLOCK_SIZE, 0.0, 0.0);
	glVertex3f(-BLOCK_SIZE, 0.0f, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, 0.0f);
	glEnd();
	
	// right side
	glBegin(GL_LINES);
	glColor3f(r, g, b);			// magenta
	glVertex3f(0.0, 0.0, 0.0);
	glVertex3f(0.0f, 0.0f, -BLOCK_SIZE);
	glVertex3f(0.0f, BLOCK_SIZE, -BLOCK_SIZE);
	glVertex3f(0.0f, BLOCK_SIZE, 0.0f);
	glEnd();
	
	// top side
	glBegin(GL_LINES);
	glColor3f(r, g, b);			// yellow
	glVertex3f(0.0, BLOCK_SIZE, 0.0);
	glVertex3f(0.0f, BLOCK_SIZE, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, BLOCK_SIZE, 0.0f);
	glEnd();
	
	// bottom side
	glBegin(GL_LINES);
	glColor3f(r, g, b);			// cyan
	glVertex3f(0.0, 0.0, 0.0);
	glVertex3f(0.0f, 0.0f, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, 0.0f, -BLOCK_SIZE);
	glVertex3f(-BLOCK_SIZE, 0.0f, 0.0f);
	glEnd();*/
	
	angle += 0.5f;
	if (angle >= 90.0f) angle = -90.0f;
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

void Block::setVisible(bool flag)
{
	visible = flag;
}

void Block::setColor(GLfloat rr, GLfloat gg, GLfloat bb)
{
	r = rr;
	g = gg;
	b = bb;
}