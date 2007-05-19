/*
 *  Includes.h
 *  LCTetris
 *
 *  All the #includes you'll need to compile, for Windows and Mac..
 *  ..also sets up the __TETRIS_WINDOWS__ defines
 *
 */

#include "Constants.h"

#if defined(__APPLE__) || defined(MACOSX)

#define __TETRIS_MAC__ 1

#include <QuickTime/QuickTime.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#include <string.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>

#else

#define __TETRIS_WINDOWS__ 1

#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <gl\glaux.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
// QuickTime
#include "Movies.h"
#include "QTML.h"
#include "Shlwapi.h"

#endif

