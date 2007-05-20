#ifndef WINDRIVER_H
#define WINDRIVER_H


#include "Includes.h"

// global variables for the Win32 app
static HDC			hDC=NULL;		// Private GDI Device Context
static HGLRC		hRC=NULL;		// Permanent Rendering Context
static HWND		hWnd=NULL;		// Holds Our Window Handle
static HINSTANCE	hInstance;		// Holds The Instance Of The Application

LRESULT	CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
#endif