#include "Textures.h"
#include "PathUtils.h"

bool Textures::LoadTGA(TextureImage *texture, char *filename)			// Loads A TGA File Into Memory
{    
	GLubyte		TGAheader[12]={0,0,2,0,0,0,0,0,0,0,0,0};	// Uncompressed TGA Header
	GLubyte		TGAcompare[12];								// Used To Compare TGA Header
	GLubyte		header[6];									// First 6 Useful Bytes From The Header
	GLuint		bytesPerPixel;								// Holds Number Of Bytes Per Pixel Used In The TGA File
	GLuint		imageSize;									// Used To Store The Image Size When Setting Aside Ram
	GLuint		temp;										// Temporary Variable
															//GLuint		type=GL_RGBA;								// Set The Default GL Mode To RBGA (32 BPP)
	
	FILE *file = fopen(filename, "rb");						// Open The TGA File
	
	if(	file==NULL ||										// Does File Even Exist?
		fread(TGAcompare,1,sizeof(TGAcompare),file)!=sizeof(TGAcompare) ||	// Are There 12 Bytes To Read?
		memcmp(TGAheader,TGAcompare,sizeof(TGAheader))!=0				||	// Does The Header Match What We Want?
		fread(header,1,sizeof(header),file)!=sizeof(header))				// If So Read Next 6 Header Bytes
	{
		fclose(file);										// If Anything Failed, Close The File
		return false;										// Return False
	}
	
	texture->width  = header[1] * 256 + header[0];			// Determine The TGA Width	(highbyte*256+lowbyte)
	texture->height = header[3] * 256 + header[2];			// Determine The TGA Height	(highbyte*256+lowbyte)
    
 	if(	texture->width	<=0	||								// Is The Width Less Than Or Equal To Zero
		texture->height	<=0	||								// Is The Height Less Than Or Equal To Zero
		(header[4]!=24 && header[4]!=32))					// Is The TGA 24 or 32 Bit?
	{
		fclose(file);										// If Anything Failed, Close The File
		return false;										// Return False
	}
	
	texture->bpp	= header[4];							// Grab The TGA's Bits Per Pixel (24 or 32)
	bytesPerPixel	= texture->bpp/8;						// Divide By 8 To Get The Bytes Per Pixel
	imageSize		= texture->width*texture->height*bytesPerPixel;	// Calculate The Memory Required For The TGA Data
	
	texture->imageData=(GLubyte *)malloc(imageSize);		// Reserve Memory To Hold The TGA Data
	
	if(	texture->imageData==NULL ||							// Does The Storage Memory Exist?
		fread(texture->imageData, 1, imageSize, file)!=imageSize)	// Does The Image Size Match The Memory Reserved?
	{
		if(texture->imageData!=NULL)						// Was Image Data Loaded
			free(texture->imageData);						// If So, Release The Image Data
		
		fclose(file);										// Close The File
		return false;										// Return False
	}
	
	GLuint i;
	for (i=0; i<imageSize; i+=bytesPerPixel)		// Loop Through The Image Data
	{														// Swaps The 1st And 3rd Bytes ('R'ed and 'B'lue)
		temp=texture->imageData[i];							// Temporarily Store The Value At Image Data 'i'
		texture->imageData[i] = texture->imageData[i + 2];	// Set The 1st Byte To The Value Of The 3rd Byte
		texture->imageData[i + 2] = temp;					// Set The 3rd Byte To The Value In 'temp' (1st Byte Value)
	}
	
	fclose (file);											// Close The File
	
	//if (texture[0].bpp==24)									// Was The TGA 24 Bits
	//{
	//	type=GL_RGB;										// If So Set The 'type' To GL_RGB
	//}
		
	return true;											// Texture Building Went Ok, Return True
}

void Textures::LoadTexture(char *fileName, TextureImage *t)
{
	char fullPath[100];
	PathUtils::FullPathForResourceFile(fileName, fullPath);
	if (LoadTGA(t, fullPath))
	{
		glGenTextures(1, &t->texID);
		glBindTexture(GL_TEXTURE_2D, textureImg.texID);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
		gluBuild2DMipmaps(GL_TEXTURE_2D, 1, t->width, t->height, GL_RGB, GL_UNSIGNED_BYTE, t->imageData);
		
		free(textureImg.imageData);
	}
}

void Textures::Load()
{
	LoadTexture("LCTetrisBlock.tga", &textureImg);
}

void Textures::Bind(TextureImage *t)
{
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, t->texID);
}

void Textures::Unbind()
{
	glDisable(GL_TEXTURE_2D);
}