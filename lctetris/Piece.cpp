#include "Piece.h"

Piece::Piece()
{
	blocks = new Block[4];

	pieceType = rand() % 7 + 1;
	rotatePos = 0;
	rotate(); // set initial position
	
	switch (pieceType)
	{
		case 1:
			// z (?) shape
			setColor(1.0f, 0.0f, 0.0f);
			break;
		case 2:
			// backwards "z"
			setColor(0.0f, 1.0f, 1.0f);
			break;
		case 3:
			// bar
			setColor(0.0f, 1.0f, 0.0f);
			break;
		case 4:
			// square
			setColor(0.0f, 0.0f, 1.0f);
			break;
		case 5:
			// L
			setColor(1.0f, 1.0f, 0.0f);
			break;
		case 6:
			// backwards L
			setColor(1.0f, 0.0f, 1.0f);
			break;
		case 7:
			// T
			setColor(1.0f, 0.5f, 0.0f);
			break;
	}
}

Piece::~Piece()
{
	delete []blocks;
}

void Piece::Draw(GLvoid)
{
	for (int i=0; i<4; i++)
	{
		blocks[i].Draw();
	}
}

void Piece::moveLeft()
{
	for (int i=0; i<4; i++)
		blocks[i].moveLeft();
}

void Piece::moveRight()
{
	for (int i=0; i<4; i++)
		blocks[i].moveRight();
}

void Piece::moveDown()
{
	for (int i=0; i<4; i++)
		blocks[i].moveDown();
}

void Piece::moveUp()
{
	for (int i=0; i<4; i++)
		blocks[i].moveUp();
}

void Piece::rotate()
{
	rotatePos++;
	if (rotatePos == 5)
		rotatePos = 1;
	
	if (pieceType == 1)
	{
		// z (?) shape
		switch (rotatePos)
		{
			case 1:
			case 3:
				blocks[1].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(1, -1, &blocks[0]);
				break;
			case 2:
			case 4:
				blocks[1].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[2].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, -1, &blocks[0]);
				break;
		}
	}
	else if (pieceType == 2)
	{
		// backwards "z"
		switch (rotatePos)
		{
			case 1:
			case 3:
				blocks[1].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, -1, &blocks[0]);
				break;
			case 2:
			case 4:
				blocks[1].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[2].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, 1, &blocks[0]);
				break;
		}
	}
	else if (pieceType == 3)
	{
		// bar
		switch (rotatePos)
		{
			case 1:
				blocks[1].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(0, -2, &blocks[0]);
				break;
			case 2:
				blocks[1].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(-2, 0, &blocks[0]);
				break;
			case 3:
				blocks[1].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[3].setPositionFromBlock(0, 2, &blocks[0]);
				break;
			case 4:
				blocks[1].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(2, 0, &blocks[0]);
				break;
		}
	}
	else if (pieceType == 4)
	{
		// square
		switch (rotatePos)
		{
			case 1:
				blocks[1].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(1, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(0, -1, &blocks[0]);
				break;
			default:
				break;
		}
	}
	else if (pieceType == 5)
	{
		// L
		switch (rotatePos)
		{
			case 1:
				blocks[1].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(1, -1, &blocks[0]);
				break;
			case 2:
				blocks[1].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, -1, &blocks[0]);
				break;
			case 3:
				blocks[1].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, 1, &blocks[0]);
				break;
			case 4:
				blocks[1].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(1, 1, &blocks[0]);
				break;
			default:
				break;
		}
	}
	else if (pieceType == 6)
	{
		// backwards L
		switch (rotatePos)
		{
			case 1:
				blocks[1].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, -1, &blocks[0]);
				break;
			case 2:
				blocks[1].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, 1, &blocks[0]);
				break;
			case 3:
				blocks[1].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[3].setPositionFromBlock(1, 1, &blocks[0]);
				break;
			case 4:
				blocks[1].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(1, -1, &blocks[0]);
				break;
		}
	}
	else if (pieceType == 7)
	{
		// T
		switch (rotatePos)
		{
			case 1:
				blocks[1].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(0, 1, &blocks[0]);
				break;
			case 2:
				blocks[1].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[3].setPositionFromBlock(1, 0, &blocks[0]);
				break;
			case 3:
				blocks[1].setPositionFromBlock(1, 0, &blocks[0]);
				blocks[2].setPositionFromBlock(-1, 0, &blocks[0]);
				blocks[3].setPositionFromBlock(0, -1, &blocks[0]);
				break;
			case 4:
				blocks[1].setPositionFromBlock(0, -1, &blocks[0]);
				blocks[2].setPositionFromBlock(0, 1, &blocks[0]);
				blocks[3].setPositionFromBlock(-1, 0, &blocks[0]);
				break;
		}
	}
}

GLfloat Piece::x()
{
	GLfloat x = blocks[0].x();
	for (int i=1; i<4; i++)
		if (blocks[i].x() < x)
			x = blocks[i].x();
	return x;
}

GLfloat Piece::y()
{
	GLfloat y = blocks[0].y();
	for (int i=1; i<4; i++)
		if (blocks[i].y() < y)
			y = blocks[i].y();
	return y;
}

GLfloat Piece::width()
{
	GLfloat start = blocks[0].x();
	GLfloat end = blocks[3].x();
	for (int i=1; i<4; i++)
		if (blocks[i].x() < start)
			start = blocks[i].x();
	for (int i=0; i<3; i++)
		if (blocks[i].x() > end)
			end = blocks[i].x();
	
	end += BLOCK_SIZE;
	
	return (end - start);
}

GLfloat Piece::height()
{
	GLfloat start = blocks[0].y();
	GLfloat end = blocks[3].y();
	for (int i=1; i<4; i++)
		if (blocks[i].y() < start)
			start = blocks[i].y();
	for (int i=0; i<3; i++)
		if (blocks[i].y() > end)
			end = blocks[i].y();
	
	end += BLOCK_SIZE;

	return (end - start);
}

void Piece::copyBlocksIntoVector(vector<Block> *vector)
{
	for (int i=0; i<4; i++)
	{
		vector->push_back(blocks[i]);
	}
}

// helpful for determing if the Piece can move down
bool Piece::containsBlockAboveBlock(Block *block)
{
	for (int i=0; i<4; i++)
		if (blocks[i].x() == block->x() && blocks[i].y() == (block->y() + BLOCK_SIZE))
			return true;
	return false;
}

bool Piece::containsBlockRightOfBlock(Block *block)
{
	for (int i=0; i<4; i++)
		if (blocks[i].x() == (block->x() + BLOCK_SIZE) && blocks[i].y() == block->y())
			return true;
	return false;
}

bool Piece::containsBlockLeftOfBlock(Block *block)
{
	for (int i=0; i<4; i++)
		if ((blocks[i].x() + BLOCK_SIZE) == block->x() && blocks[i].y() == block->y())
			return true;
	return false;
}

void Piece::setColor(GLfloat r, GLfloat g, GLfloat b)
{
	for (int i=0; i<4; i++)
		blocks[i].setColor(r, g, b);
}