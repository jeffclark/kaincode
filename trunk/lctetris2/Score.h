/*
 *  Score.h
 *  LCTetris
 *
 *  Sets up fonts and displays the score
 *
 */
#pragma once
#include "Includes.h"

class Score
{
	int theScore;
	GLvoid BuildFont(GLvoid);
	GLvoid glPrint(const char *fmt, ...);
	GLuint base;
public:
	Score();
	~Score();
	void Update(int);
};