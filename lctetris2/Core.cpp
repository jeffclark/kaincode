#include "Core.h"

// Class constructor... initialize variables
Core::Core()
{
#ifdef __TETRIS_MAC__
	srandom(time(NULL));
#else
	srand(time(NULL));
#endif
	textures = new Textures();
	frame = new Frame();
	piece = NULL;
	nextPiece = NULL;
	gameOver = true;
	callbackFunc = NULL;
	paused = false;
	
	audioPlayer = new AudioPlayer();
}

// Class destructor... release any variables
Core::~Core()
{
	audioPlayer->StopMusic();
	
	delete textures;
	delete frame;
	delete piece;
	delete nextPiece;
	delete audioPlayer;
}

// Sets the callback function used to change the timer
void Core::SetCallbackFunction(void (*func)(GLuint))
{
	callbackFunc = func;
}

// sets the callback function used to handle when a game is over and a high score is achieved (not implemented)
void Core::SetHighscoreFunction(void (*func)(GLuint, GLuint))
{
	highscoreFunc = func;
}

// Inits the OpenGL
void Core::InitGL()
{
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClearDepth(1.0);

	glEnable(GL_DEPTH_TEST);
	glShadeModel(GL_SMOOTH);

	textures->Load();
	glEnable(GL_TEXTURE_2D);
}

void Core::DrawString(char *s)
{
	unsigned int i;
	for (i = 0; i < strlen (s); i++)
		glutBitmapCharacter (GLUT_BITMAP_HELVETICA_10, s[i]);
}

void Core::DrawStringBig(char *s)
{
	unsigned int i;
	for (i = 0; i < strlen (s); i++)
		glutBitmapCharacter (GLUT_BITMAP_HELVETICA_18, s[i]);
}

void Core::DrawScoreAndLevel()
{
	// draw score
	glLoadIdentity();
	glTranslatef(0.0f, 0.0f, -20);
	char label[100];
	glColor3f(1.0f, 1.0f, 1.0f);
	sprintf(label, "Score: %d", (int)score);
	glRasterPos2f((FRAME_WIDTH/2) + BLOCK_SIZE * 2, (BLOCK_SIZE * 5));
	DrawStringBig(label);
	sprintf(label, "Level: %d", (int)level);
	glRasterPos2f((FRAME_WIDTH/2) + BLOCK_SIZE * 2, (BLOCK_SIZE * 6));
	DrawStringBig(label);
}

// Does our OpenGL drawing... drops the frame first, then each block, then the current piece
void Core::Draw()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);

	DrawScoreAndLevel();
	
	frame->Draw();

	textures->Bind(&textures->textureImg);
	// draw each block
	for (int i=0; i<(int)blocks.size(); i++)
		blocks.at(i).Draw();
	nextPiece->Draw();
	piece->Draw();

	textures->Unbind();
}

// reshapes the view... called (I think) when the window resizes, etc
void Core::Reshape(GLsizei width, GLsizei height)
{
	if (height==0) height=1;
	
	glViewport(0,0,width,height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f, (GLfloat)width/(GLfloat)height, 0.1f, 100.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();	
}

// Drop the current piece 1 position
void Core::Drop()
{
	if (gameOver || paused == true)
		return;

	if (pieceCanMoveDown())
	{
		piece->moveDown();
	}
	else
	{
		// add the blocks from the current piece into the main blocks array
		piece->copyBlocksIntoVector(&blocks);
		
		checkForRow();
		newPiece();
	}	
}

// handles key events called from main app driver
void Core::DoKeyEvent(KeyEvent keyEvent)
{
	switch (keyEvent)
	{
		case LeftArrowKeyEvent:
			if (pieceCanMoveLeft() && !paused && canMovePiece && !gameOver)
				piece->moveLeft();
			break;
		case UpArrowKeyEvent:
			if (pieceCanRotate() && !paused && canMovePiece && !gameOver)
				piece->rotate();
			break;
		case RightArrowKeyEvent:
			if (pieceCanMoveRight() && !paused && canMovePiece && !gameOver)
				piece->moveRight();
			break;
		case DownArrowKeyEvent:
			if (pieceCanMoveDown() && !paused && canMovePiece && !gameOver)
				Drop();
			break;
		case SpacebarKeyEvent:
			while (pieceCanMoveDown() && !paused && canMovePiece && !gameOver)
				Drop();
			canMovePiece = false;
			break;
		case EnterKeyEvent: // pauses/unpauses
			if (gameOver)
				return;
			DoPauseUnpause();
			break;
		case LetterNKeyEvent:
			NewGame();
			break;
		default:
			break;
	}	
}

// makes a new game, resets everything
void Core::NewGame()
{
	audioPlayer->StopMusic();
	gameOver = false;
	score = 0;
	level = 1;
	milliseconds = 1000;
	paused = false;
	canMovePiece = true;
	blocks.clear();
	
	// if no callback function (for setting the timer) is set, then it won't start
	if (callbackFunc != NULL)
	{
		callbackFunc(milliseconds);
		newPiece();
		audioPlayer->PlayMusic();
	}
}

// not implemented yet
void Core::AddHighScore(const char *name, GLuint score, GLuint level)
{
	//printf("HIGH SCORE of %d by %s at level %d!\n", (int)score, name, (int)level);
}

// checks for a game over
bool Core::CheckForGameOver()
{
	for (int i=0; i<(int)blocks.size(); i++)
		if (piece->containsBlockEqualToBlock(&blocks.at(i)))
			return true;

	return false;
}

// handle when a game is over
void Core::doGameOver()
{
	audioPlayer->StopMusic();
	audioPlayer->PlayGameOver();
	gameOver = true;

	if (callbackFunc != NULL)
		callbackFunc(0);		
		
	if (highscoreFunc != NULL)
		highscoreFunc(score, level);
}

// handles pausing/unpausing of the game
void Core::DoPauseUnpause()
{
	paused = !paused;
	if (paused)
	{
		audioPlayer->PauseMusic();
		piece->DrawPaused(true);
		nextPiece->DrawPaused(true);
		for (int i=0; i<(int)blocks.size(); i++)
			blocks.at(i).DrawPaused(true);
	}
	else
	{
		audioPlayer->PlayMusic();
		piece->DrawPaused(false);
		nextPiece->DrawPaused(false);
		for (int i=0; i<(int)blocks.size(); i++)
			blocks.at(i).DrawPaused(false);
	}	
}

// creates a new piece, and moves it to the top
void Core::newPiece()
{
	//Set the falling piece to the piece that is displayed on right
	if (nextPiece == NULL)
	{
		nextPiece = new Piece();
		piece = nextPiece;
	}
	else
	{
		delete piece;
		piece = nextPiece;
		piece->moveLeft(9);
	}
	//Create the nextPiece and display on the right
	nextPiece = new Piece();
	nextPiece->moveRight(9);

	// move piece to (top - BLOCK_SIZE)
	while ((piece->y() + piece->height()) != ((FRAME_HEIGHT/2) - BLOCK_SIZE))
		piece->moveUp();

	canMovePiece = true;
	
	// check for game over before we finish
	if (CheckForGameOver())
		doGameOver();	
}

// checks for any rows to clear; increments score and goes to next level (if necessary)
void Core::checkForRow()
{
	bool rowsNeedCleared = true;
	while (rowsNeedCleared)
	{
		rowsNeedCleared = false;
		for (int y=-(int)(FRAME_HEIGHT/2); y<(int)(FRAME_HEIGHT/2); y++)
		{
			vector<int> blockIndexesToClear;
			
			int c=0;
			for (int i=0; i<(int)blocks.size(); i++)
			{
				Block block = blocks.at(i);
				if (block.y() == y)
				{
					blockIndexesToClear.push_back(i);
					c++;
				}
			}
			
			if (c == FRAME_WIDTH) // found a row of blocks on same row
			{
				rowsNeedCleared = true;
				
				// remove the blocks from the vector
				for (int i=(int)blockIndexesToClear.size()-1; i>=0; i--)
				{
					blocks.erase(blocks.end() - ((int)blocks.size() - blockIndexesToClear.at(i)));
				}
				
				shiftBlocksDownAboveRow(y);
				
				score++;
				if (score % 10 == 0)
				{
					// advance to the next level!
					level++;

					// increase speed
					milliseconds -= (level >= 1 && level <= 3 ? 200 : 100);
					if (callbackFunc != NULL)
						callbackFunc(milliseconds);
				}
			}
		}
	}
}

// helper function for the function above
void Core::shiftBlocksDownAboveRow(int row)
{
	for (int y=row+1; y<(int)(FRAME_HEIGHT/2); y++)
	{
		for (int i=0; i<(int)blocks.size(); i++)
		{
			if (blocks.at(i).y() == y)
				blocks.at(i).moveDown();
		}
	}
}

// returns whether the current piece can move down
bool Core::pieceCanMoveDown()
{
	// check to see if the piece has hit the bottom
	if (piece->y() == -(FRAME_HEIGHT/2))
		return false;
	
	// check to see if there are any blocks below the piece
	for (int i=0; i<(int)blocks.size(); i++)
	{
		Block block = blocks.at(i);
		if (piece->containsBlockAboveBlock(&block))
			return false;
	}
	
	return true;
}

// returns whether the current piece can move left
bool Core::pieceCanMoveLeft()
{
	if (piece->x() <= -(FRAME_WIDTH/2))
		return false;
	
	for (int i=0; i<(int)blocks.size(); i++)
	{
		Block block = blocks.at(i);
		if (piece->containsBlockRightOfBlock(&block))
			return false;
	}
	
	return true;
}

// returns whether the current piece can move right
bool Core::pieceCanMoveRight()
{
	if ((piece->x() + piece->width()) >= (FRAME_WIDTH/2))
		return false;
	
	for (int i=0; i<(int)blocks.size(); i++)
	{
		Block block = blocks.at(i);
		if (piece->containsBlockLeftOfBlock(&block))
			return false;
	}
	
	return true;
}

// returns whether the current piece can rotate
bool Core::pieceCanRotate()
{
	// this needs work... isn't perfect yet
	GLfloat rotateWidth = piece->height(); // if the piece rotates, its width will become its current height
	if (!pieceCanMoveLeft() || !pieceCanMoveRight())
		return false;
	
	if (rotateWidth != piece->width() && !pieceCanMoveDown())
		return false;
	
	return true;
}