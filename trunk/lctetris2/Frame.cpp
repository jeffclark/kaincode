#include "Frame.h"

Frame::Frame()
{
}

void Frame::Draw(GLvoid)
{
	glLoadIdentity();
	glTranslatef(0.0f, 0.0f, -20);
	
	// left side
	glBegin(GL_QUADS);
	glColor3f(1.0f, 1.0f, 1.0f);
	glVertex3f(-FRAME_WIDTH/2, -FRAME_HEIGHT/2, 0.0f);
	glVertex3f(-FRAME_WIDTH/2 - FRAME_THICKNESS, -FRAME_HEIGHT/2, 0.0f);
	glVertex3f(-FRAME_WIDTH/2 - FRAME_THICKNESS, FRAME_HEIGHT/2, 0.0f);
	glVertex3f(-FRAME_WIDTH/2, FRAME_HEIGHT/2, 0.0f);
	glEnd();

	// right side
	glBegin(GL_QUADS);
	glColor3f(1.0f, 1.0f, 1.0f);
	glVertex3f(FRAME_WIDTH/2, -FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2 + FRAME_THICKNESS, -FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2 + FRAME_THICKNESS, FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2, FRAME_HEIGHT/2, 0.0f);
	glEnd();	

	// top side
	glBegin(GL_QUADS);
	glColor3f(1.0f, 1.0f, 1.0f);
	glVertex3f(-FRAME_WIDTH/2 - FRAME_THICKNESS, FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2 + FRAME_THICKNESS, FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2 + FRAME_THICKNESS, FRAME_HEIGHT/2 + FRAME_THICKNESS, 0.0f);
	glVertex3f(-FRAME_WIDTH/2 - FRAME_THICKNESS, FRAME_HEIGHT/2 + FRAME_THICKNESS, 0.0f);
	glEnd();		

	// bottom side
	glBegin(GL_QUADS);
	glColor3f(1.0f, 1.0f, 1.0f);
	glVertex3f(-FRAME_WIDTH/2 - FRAME_THICKNESS, -FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2 + FRAME_THICKNESS, -FRAME_HEIGHT/2, 0.0f);
	glVertex3f(FRAME_WIDTH/2 + FRAME_THICKNESS, -FRAME_HEIGHT/2 - FRAME_THICKNESS, 0.0f);
	glVertex3f(-FRAME_WIDTH/2 - FRAME_THICKNESS, -FRAME_HEIGHT/2 - FRAME_THICKNESS, 0.0f);
	glEnd();			
}