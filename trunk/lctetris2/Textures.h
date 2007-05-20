/*
 *  Textures.h
 *  LCTetris
 *
 *  Handles Textures
 *
 */

#include "Includes.h"

#pragma once

typedef struct TextureImage
{
	GLubyte	*imageData;
	GLuint	bpp;
	GLuint	width;
	GLuint	height;
	GLuint	texID;
} TextureImage;

class Textures
{
private:
	bool LoadTGA(TextureImage *texture, char *filename);
	void LoadTexture(char *fileName, TextureImage *t);
public:
	TextureImage textureImg;
	TextureImage backgroundImg;

	void Load();
	void Bind(TextureImage *t);
	void Unbind();
};