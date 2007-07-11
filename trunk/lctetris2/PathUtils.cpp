/*
 *  PathUtils.cpp
 *  LCTetris
 *
 *  Created by Kevin Wojniak on 6/6/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "PathUtils.h"

// pass in to this function just the filename of an audio file, and it will give you
// the full path to the file... for Windows the file must be in the same directory
// as the exe. again, watch the #ifdefs to make sure you're looking at the appropriate code..
void PathUtils::FullPathForResourceFile(const char *fileName, char *fullPath)
{
#ifdef __TETRIS_MAC__
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	if (mainBundle == NULL)
	{
		printf("Unable to get main bundle\n");
		return;
	}
	
	CFStringRef theFileName = CFStringCreateWithCString(NULL, fileName, kCFStringEncodingASCII);
	if (theFileName == NULL)
	{
		printf("Unable to convert fileName to CFStringRef\n");
		return;
	}
	
	CFURLRef musicRef = CFBundleCopyResourceURL(mainBundle, theFileName, NULL, NULL);
	if (musicRef == NULL)
	{
		printf("Unable to locate music file\n");
		return;
	}
	
	CFStringRef urlPath = CFURLCopyFileSystemPath(musicRef, kCFURLPOSIXPathStyle);
	if (urlPath == NULL)
	{
		printf("Unable to get path from URL\n");
		return;
	}
	
	if (CFStringGetCString(urlPath, fullPath, 256, kCFStringEncodingASCII) == false)
	{
		printf("Unable to get string from path\n");
		return;
	}
	
	CFRelease(theFileName);
	CFRelease(urlPath);
	CFRelease(musicRef);
#else
	char buffer[256];
	for (int i=0; i<256; i++)
		buffer[i] = 0;
	GetModuleFileName(NULL,buffer,256);
	PathRemoveFileSpec(buffer); // get the exe's parent directory
	
	int l = (int)strlen(buffer), k=0, i;
	buffer[l] = '//'; // append a forward slash (/)
		
		// append the filename of the audio (or resource) file to the exe's parent directory
		for (i=l+1; i<l+strlen(fileName)+1; i++)
		{
			buffer[i] = fileName[k];
			k++;
		}
	buffer[i] = 0;
	strcpy(fullPath, buffer);
#endif
}

