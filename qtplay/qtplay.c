//
//  qtplay.c
//  qtplay
//
//  Copyright (c) 2002-2004, Rainbow Flight.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  *  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  *  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//  *  Neither the name of Rainbow Flight nor the names of its contributors may be
//  used to endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
//  Created by Sarah Childers on Aug 22 2002.
//
//  Released version 1.0 on Sep 7 2002.
//  - Plays any audio file supported by Quicktime, including CDs, AIFF, MIDI, and MP3.
//  - Playlist features such as loop, shuffle, and random.
//  - Special flag for simply playing a CD, for lazy people.
//  - Verbose and quiet flags for different levels of feedback.
//
//  Modified on Sep 10 2002 by Matt Slot (MJS).
//  - Use UpTime() to generate a better random seed.
//
//  Modified on Sep 18 2002.
//  - Automatic recognition of CDs.
//  - Ability to read stdin.
//
//  Modified on Sep 27 2002. Released version 1.1.
//  - Converted Cocoa calls to Carbon/System calls.
//  - Added support for signals: SIGINT (stop song).
//  - Added support for Aliases.
//  cc -Wall -Wmost -Wcast-qual -O3 -framework Quicktime -framework Carbon -o qtplay qtplay.c
//
//  Modified on Nov 17 2002 by Carsten Klapp.
//  - Work around possible qt bug where white boxes show on screen even though all non-audio tracks have already been deleted.
//
//  Modified on Dec 15 2002.
//  - Work around a bug in Mac OS X 10.0.x where the filesystem ID and signature bytes were erroneously swapped.
//  - CD detection based on filesystem ID only (instead of on ID and signature).
//  - Added "update time" flag for changing processor usage.
//
//  Modified on Dec 18 2002.
//  - Possibly improved error handling while playing.
//  - Added support for playing sound resource files (using Sound Manager).
//
//  Modified on Dec 19 2002.
//  - Fixed bug where if a directory was specified, the filename of files was the whole path instead of relative path. (Bug in Carbon v1.1. Correct in Cocoa v1.0.)
//  - Added support for signals: SIGTSTP (pause song) and SIGCONT (continue song). (Bug: glitches/skipping on 'continue' in v1.1.)
//
//  Modified on Dec 22 2002. Released version 1.2.
//  - Added "volume" flag.
//  - Fixed bug where if "qtplay" was run without specifying filenames, "./" was prepended to the filenames. (Bug: crashed if type 'qtplay ""'.)
//  cc -prebind -no-cpp-precomp -O3 -framework Quicktime -framework Carbon -o qtplay qtplay.c
//
//  Modified on Mar 21 2003.
//  - Added ability to play internet URLs (as well as POSIX pathnames).
//  - Split code for processSignal into two functions for better (?) response if ^C^C quickly.
//  - Rewrote structure of playfile functions for better readability.
//
//  Modified on Apr 22 2003.
//  - Rewrote structure of addContents for less redundancy (rewrote recursion).
//  - Fixed inaccuracy of comparing timing of ^C^C to GetDblTime.
//  - Added "double click time" flag for override GetDblTime().
//  - Added "treat files as playlist" flag.
//  - Rewrote stucture of CFArrayCreateFileList() so it plays playlist files. Added function addContentsFile().
//  - Added abilty to play text file playlists as a non-random entity.
//
//  Modified on Apr 29 2003.
//  - Fixed error codes and print statements. myprinturl() now uses printf().
//  - Fixed bug so myerror() and myerrorurl() uses stderr instead of stdout.
//  - Fixed bug so -cd parsed correctly. (Bug: missrecognized if type flag as -cdd)
//  - Fixed memory leak: deallocate list of files when done with them.
//  - Fixed bug where print wrong error when opening non-Quicktime URL.
//  - Fixed bug so does not attempt to read binary files as playlist.
//  - Fixed bug so printurl functions don't crash. (Bug: crash if type 'qtplay //')
//
//  Modified on May 29 2003.
//  - Fixed bug if printurl fails or passed NULL (so that it prints '\n').
//  - Added QT and SM only flags.
//  - Removed the volume flag limitation so can have volumes greater than 100%. (Misleading QT documentation.)
//  - Fixed bug so all flags parsed correctly. (Bug: missrecognized if type flags as -vv)
//  - Added print version number in verbose mode.
//  - Added "one random file" flag.
//
//  Modified on Jun 1 2003.
//  - Fixed bug so playlist part of getfile doesn't crash. (Bug: crash if type 'qtplay -f ""')
//  - Fixed bug so blank lines in playlist are ignored (not replaced with working directory).
//  - Added check for playlists: list must be valid paths or URLs
//  - Bug fix. CFStringGetCStringPtr() replaced with function, which was broken out of printurl, that returns malloced cstring of CFURL.
//
//  Modified on Jun 23 2003.
//  - Bug fix. Correctly differentiates 'qtplay' (working directory) and 'qtplay ""' (NULL filename)
//  - Bug fix. Gives error when 'qtplay -f directory'.
//  - Simplified some control logic and initializations.
//  - Leak fix with closing file when using fopen.
//
//  Modified on Sep 18 2003. Released version 1.3.
//  - Added "DJ mode" flag. (Thanks Edward Patel.)
//  - Added "--version" flag.
//  - Fixed signal (stop,pause) catching for some playlists.
//
//  Modified on Nov 30 2003.
//  - Bug fix. Playing aliases works properly again. (Bug in v1.3: treated as file://localhost/filepath. Correct in v1.2.)
//  - Bug fix. Forgot to free a malloced cstring of CFURL.
//  - Rewrote file subroutines to take FILE instead of path to file.
//  - Bug fix. When playing playlist, correctly interprets relative (as well as absolute) paths: file contents relative to file's parent directory.
//
//  Modified on Dec 8 2003. Released version 1.3.1 on Jan 30 2004.
//  - Un-hardcoded mount point of Audio CDs, instead uses FSRef.
//  - Broke out function CFReleaseFileList() to match CFArrayCreateFileList().
//  - Bug fix. Show error when resolving alias. (code was there, but forgot =)
//  - Added "--" flag.
//  - Bug fix. Show help/error when flags used incorrectly (eg. "qtplay -cd -f" or "qtplay -cd file").
//
// Modified on August 17, 2007 by Kevin Wojniak
//  - Fixed warning with CFStringCreateWithBytes
//  - Replaced "if (theErr != NULL)" with "if (theErr != 0)"
//  - Fixed deprecated warning with EmptyRect
//  - Fixed warning with CFArrayCreateFileList
//  - Built within Xcode as a universal binary


#define kVersion "1.3.1"

/*****************************************/

#import <Carbon/Carbon.h>
#import <QuickTime/Movies.h>

#include <unistd.h>

#define kCharCheckSize 1024
#define kLineCheckSize 128
#define kAudioCDFilesystemID 19016

// global flags:
bool  gRecursive = false;
bool  gVerbose = false;
bool  gQuiet = false;
bool  gSpeak = false;
bool  gShuffle = false;
bool  gRandom = false;
bool  gLoop = false;
bool  gOnlyOne = false;
bool  gCD = false;
bool  gPlaylist = false;
bool  gQTOnly = false;
bool  gSMOnly = false;
int   gDblTime;
int   gSleepTime = 100000;
short gVolume = 0x0100;

// global signal flags:
bool gStop = false;
bool gPause = false;
bool gCont = false;
bool gIsPaused = false;

/*****************************************/

// function prototypes:
void printHelp();
void processStopSignal(int sigraised);
void processPauseSignal(int sigraised);

CFMutableArrayRef CFArrayCreateFileList(int count, const char * array[]);
void addContentsFile(FILE * infile, CFMutableArrayRef files, CFURLRef workingDirectory);
void addContents(CFURLRef path, CFMutableArrayRef files);
void CFReleaseFileList(CFMutableArrayRef files);

void playfile(CFURLRef pathname);
OSErr playfile_quicktime(CFURLRef pathname);
OSErr playfile_sndmanager(CFURLRef pathname);
OSErr playfile_playlist(CFURLRef pathname);

bool CFURLHasHostScheme( CFURLRef path );
CFURLRef CFURLCreateFromCFString( CFStringRef pathstr, bool isDir );
CFURLRef CFURLCreateFromCFStringRelativeToBase( CFStringRef pathstr, bool isDir, CFURLRef baseurl );
CFURLRef CFURLCreateFromFSRefRelativeToLocalhost(const FSRef * fsRefPtr);
char * CFURLCreateCString( CFURLRef path );
bool isFileASCII( FILE * f );
bool isFileURLs( FILE * f, CFURLRef workingDirectory );

#define myprint if (!gQuiet) printf
void myerror( const char * fmt, ... ) { if (!gQuiet) {va_list ap; va_start(ap, fmt); vfprintf(stderr,fmt,ap); va_end(ap);} }; // print errors to stderr not stdout
#define myprintv if (!gQuiet && gVerbose) printf

void myprint_sub( FILE * f, CFURLRef path ) { if (!gQuiet) {char * s = CFURLCreateCString(path); fprintf(f, "%s\n", s); if (s) free(s);} };
void myprinturl( CFURLRef path ) { myprint_sub(stdout,path); };
void myerrorurl( CFURLRef path ) { myprint_sub(stderr,path); };
void myprinturlv( CFURLRef path ) { if (gVerbose) myprinturl(path); };

void myspeak( const char * str );
void myspeakurl( CFURLRef path );

/*****************************************/

bool CFURLHasHostScheme( CFURLRef path )
{
	bool returnvalue = false;
	
	if (path != NULL)
	{
		CFStringRef hostname = CFURLCopyHostName(path);
		CFStringRef scheme = CFURLCopyScheme(path);
		
		returnvalue = scheme && hostname;
		
		if (scheme)
			CFRelease(scheme);
		if (hostname)
			CFRelease(hostname);
	}
	
	return returnvalue;
}

CFURLRef CFURLCreateFromCFString( CFStringRef pathstr, bool isDir )
{
	return CFURLCreateFromCFStringRelativeToBase( pathstr, isDir, NULL );
}

CFURLRef CFURLCreateFromCFStringRelativeToBase( CFStringRef pathstr, bool isDir, CFURLRef baseurl )
{
	CFURLRef path = CFURLCreateWithString(NULL, pathstr, NULL); // http://host/path/file%20name (OR) path/filename

	if (path == NULL)
	{
		CFURLRef localhostpath = CFURLCreateWithFileSystemPath(NULL, pathstr, kCFURLPOSIXPathStyle, isDir); // path/file\ name (==>) file://localhost/base/path/file%20name

		if (localhostpath != NULL)
		{
			CFStringRef newstr = CFURLCopyPath(localhostpath);
			path = CFURLCreateWithString(NULL, newstr, NULL); // path/file%20name

			CFRelease(newstr);
			CFRelease(localhostpath);
		}
	}

	// prepend relative-base part of url
	if ( baseurl != NULL && path != NULL && CFURLHasHostScheme(path) == false ) // if file system path
	{
		CFStringRef substr = CFURLCopyFileSystemPath(path, kCFURLPOSIXPathStyle);

		if ( CFStringGetCharacterAtIndex(substr, 0) != (UniChar)('/') ) // if not absolute path
		{
			CFRelease(path);
			path = CFURLCreateCopyAppendingPathComponent(NULL, baseurl, substr, false);
		}
		
		CFRelease(substr);
	}
	
	return path;
}

CFURLRef CFURLCreateFromFSRefRelativeToLocalhost(const FSRef * fsRefPtr)
{
	CFURLRef path = CFURLCreateFromFSRef(NULL, fsRefPtr);

	// remove file://localhost from file system path
	if (path != NULL)
	{
		CFStringRef newstr = CFURLCopyPath(path);

		CFRelease(path);
		path = CFURLCreateWithString(NULL, newstr, NULL);

		CFRelease(newstr);
	}

	return path;
}

char * CFURLCreateCString( CFURLRef path )
{
	char * s = NULL;
	if (path != NULL)
	{
		CFStringRef str;
		if ( CFURLHasHostScheme(path) )
			str = CFRetain(CFURLGetString(path));
		else
			str = CFURLCopyFileSystemPath(path, kCFURLPOSIXPathStyle);

		if (str)
		{
			CFIndex bufferSize = CFStringGetLength(str) + 1;
			{
				char * buffer = calloc(bufferSize,sizeof(char));
				CFStringGetCString(str, buffer, bufferSize, CFStringGetSystemEncoding());
				s = buffer;
			}

			CFRelease(str);
		}
	}
	return s;
}

bool isFileASCII( FILE * f )
{
	if (f == NULL)
	{
		return false;
	}
	else
	{
		int i;
		bool returnVal = true;
		
		rewind(f);
		
		// check a sample of the contents of file
		for (i = 1; (i < kCharCheckSize && returnVal); i++)
		{
			int c = fgetc(f); // read a character
			if (c == EOF)
				i = kCharCheckSize;
			else if (c > 127) // then not ascii
				returnVal = false;
		}

		return returnVal;
	}
}

bool isFileURLs( FILE * f, CFURLRef workingDirectory )
{
	if (f == NULL)
	{
		return false;
	}
	else
	{
		size_t length;
		char * chars;
		int badcount = 0;
		int goodcount = 0;

		rewind(f);

		// check a sample of the contents of file
		while ( (chars = fgetln(f, &length)) != NULL && (badcount+goodcount < kLineCheckSize) ) // read a line
		{
			CFURLRef path;
			CFStringRef pathstr;

			if (length > 0 && chars[length-1] == '\n') length--;

			pathstr = CFStringCreateWithBytes(NULL, (const UInt8 *)chars, length, CFStringGetSystemEncoding(), false);
			path = CFURLCreateFromCFStringRelativeToBase(pathstr, false, workingDirectory);
			CFRelease(pathstr);

			// determine good/badness of this line
			{
				FSRef temp;
				if ( path != NULL && (CFURLHasHostScheme(path) || CFURLGetFSRef(path,&temp)) )
					goodcount++;
				else if ( length > 0 )
					badcount++;
			}
			
			if (path != NULL)
				CFRelease(path);
		}

		return (goodcount >= badcount); // badness is arbitrary
	}
}

void myspeak(const char * str)
{
	SpeechChannel speechChannel;
	if (gSpeak && NewSpeechChannel(NULL, &speechChannel) == noErr)
	{
		// speak str
		SpeakText(speechChannel, str, strlen(str));
		// wait until done speaking, and clean up
		while (SpeechBusy())
		{
			// so less processor intensive:
			usleep(gSleepTime);

			// if we recieved a "stop" or "suspend" signal, then stop speech,
			// and let playfile_xxx take care of signal
			if (gPause || gStop)
				StopSpeech(speechChannel);
		}
		if (speechChannel)
			DisposeSpeechChannel(speechChannel);
	}
}

void myspeakurl( CFURLRef path )
{
	if (path != NULL)
	{
		// get filename without path-to and extension
		CFURLRef    tmp1 = CFURLCreateCopyDeletingPathExtension(NULL, path);
		CFStringRef tmp2 = CFURLCopyLastPathComponent(tmp1);
		CFURLRef    p    = CFURLCreateFromCFString(tmp2, false);

		// speak
		char * s = CFURLCreateCString(p);
		if (s)
		{
			myspeak(s);
			free(s);
		}

		CFRelease(p);
		CFRelease(tmp2);
		CFRelease(tmp1);
	}
}

/*****************************************/

int main (int argc, const char * argv[])
{
	int filenum = 1; // 0 = path to app; 1 = path to file; ...

	gDblTime = (int)GetDblTime();

	while (filenum < argc && argv[filenum][0] == '-')
	{
		if (argv[filenum][1] == '\0')
		{
			// treat as "file" (stdin)
			break;
		}
		else if (strcmp(argv[filenum],"--") == 0)
		{
			// treat all remaining arguments as "files"
			filenum++;
			break;
		}
		else if (argv[filenum][2] == '\0')
		{
			switch (argv[filenum][1])
			{
				case 'f':
					gPlaylist = true;
					break;
				case 'l':
					gLoop = true;
					break;
				case 'q':
					gQuiet = true;
					gVerbose = false;
					break;
				case 'Q':
					gQTOnly = true;
					gSMOnly = false;
					break;
				case 'r':
					gRecursive = true;
					break;
				case 's':
					gSpeak = true;
					break;
				case 'S':
					gQTOnly = false;
					gSMOnly = true;
					break;
				case 't':
					if (filenum+1 < argc)
					{
						float seconds;
						if (sscanf(argv[filenum+1],"%f",&seconds) > 0)
						{
							gSleepTime = (int)(seconds * 1000000.0);
							filenum++;
							break;
						}
					}
					// else print help and exit:
					printHelp();
					return 0;
				case 'T':
					if (filenum+1 < argc)
					{
						int ticks;
						if (sscanf(argv[filenum+1],"%d",&ticks) > 0)
						{
							gDblTime = ticks;
							filenum++;
							break;
						}
					}
					// else print help and exit:
					printHelp();
					return 0;
				case 'v':
					gQuiet = false;
					gVerbose = true;
					break;
				case 'V':
					if (filenum+1 < argc)
					{
						float percent;
						if (sscanf(argv[filenum+1],"%f",&percent) > 0)
						{
							if (percent <= 0) percent = 0;
							gVolume = (short)(percent * .01 * 256); // 100% --> 0x0100
							filenum++;
							break;
						}
					}
					// else print help and exit:
					printHelp();
					return 0;
				case 'z':
					gShuffle = true;
					gRandom = false;
					gOnlyOne = false;
					break;
				case 'Z':
					gShuffle = false;
					gRandom = true;
					gOnlyOne = false;
					break;
				case '1':
					gShuffle = true;
					gOnlyOne = true;
					break;
				default:
					// print help and exit:
					printHelp();
					return 0;
			}
		}
		else if (strcmp(argv[filenum],"-cd") == 0 || strcmp(argv[filenum],"--cd") == 0)
		{
			gCD = true;
		}
		else if (strcmp(argv[filenum],"--version") == 0)
		{
			// print version and exit:
			printf("%s\n", kVersion);
			return 0;
		}
		else
		{
			// print help and exit:
			printHelp();
			return 0;
		}
		filenum++;
	}

	if ( (gCD && gPlaylist) || (gCD && filenum < argc))
	{
		// print help and exit:
		printHelp();
		return 0;
	}
	
	myprintv("Welcome to Quicktime Player by Sarah Childers (version %s)\n", kVersion);
	myprintv("Initializing.\n");

	// seed random number generator:
	if (gRandom || gShuffle)
		srandom(clock() ^ AbsoluteToNanoseconds(UpTime()).lo); // -- MJS

	// set up signal callbacks:
	signal(SIGINT, &processStopSignal);
	signal(SIGTSTP, &processPauseSignal);
	signal(SIGCONT, &processPauseSignal);
	
	{
		CFMutableArrayRef files;

		// create list of files
		myprintv("Creating file list.\n");
		
//		if (gCD) //???
//			// contents of CDs (passed by global variable):
//			files = CFArrayCreateFileList(0, NULL);
//		else
			files = CFArrayCreateFileList(argc-filenum, &argv[filenum]);
		
		myprintv("%d files in file list.\n", (int)CFArrayGetCount(files));
	
		// play list of files
		if (gOnlyOne)
		{
			myprintv("Playing one file in file list.\n");
		}
		else
		{
			myprintv("Playing file list.\n");
		}

		EnterMovies();
		do
		{
			filenum = 0;
			while (filenum < CFArrayGetCount(files))
			{
				if (gRandom || gShuffle)
				{
					// swap array[i] with array[random]
					int new = filenum + ( random() % (CFArrayGetCount(files)-filenum) );
					CFURLRef temp = CFArrayGetValueAtIndex(files, filenum);
					CFArraySetValueAtIndex(files, filenum, CFArrayGetValueAtIndex(files, new));
					CFArraySetValueAtIndex(files, new, temp);
				}
				
				playfile( CFArrayGetValueAtIndex(files, filenum) );

				if (gOnlyOne)
					break;
				else if (!gRandom)
					filenum++;
			}
		}
		while (gLoop);
		ExitMovies();

		// deallocate list of files
		CFReleaseFileList(files);
	}
	
    return 0;
}

void printHelp()
{
	printf("usage: qtplay [OPTION] [file(s) | directory(s) | -]\n");
	printf("       qtplay [OPTION] -cd\n");
	printf("       qtplay [OPTION] -f [file(s)]\n");
	printf("\n");
	printf(" -l      loop\n");
	printf(" -q      quiet\n");
	printf(" -Q      quicktime only\n"); // (do not use Sound Manager)
	printf(" -r      recursive\n");
	printf(" -s      DJ mode (ie. speak filename)\n");
	printf(" -S      sound manager only\n"); // (do not use Quicktime)
	printf(" -v      verbose\n");
	printf(" -z      shuffle play\n");
	printf(" -Z      random play\n");
	printf(" -1      one random file\n");
	printf("\n");
	printf(" -t val  update time (in seconds; default = .1)\n");
	printf(" -T val  kill time (in ticks; default = double click time)\n");
	printf(" -V val  volume (in percent; default = 100)\n");
	printf("\n");
	printf(" -cd     plays all CDs\n");
	printf(" -f      treat contents of file(s) as if on command line (ie. as playlist)\n");
	printf("\n");
	printf(" -       read standard input\n");
	printf(" --      treat remaining arguments as file names even if they begin with dash\n");
	printf("\n");
	//printf(" --version  print version information and exit\n");
	printf("(qtplay version %s)\n", kVersion); //???
}

void processStopSignal(int sigraised)
{
	static time_t mytime = 0;
	time_t newtime = TickCount();

	myprint("\n"); // so ^C on its own line...

	//if (sigraised == SIGINT) // interupt: ^C
	{
		gStop = true;
		if (newtime - mytime <= gDblTime)
		{
			myprintv("User terminated program: double clicked in %d of %d ticks.\n", (int)(newtime - mytime), gDblTime);
			exit(0); // no error: we want to exit if press ^C^C
		}
		mytime = newtime;
	}
}

void processPauseSignal(int sigraised)
{
	myprint("\n"); // so ^Z on its own line...
	if (sigraised == SIGTSTP) // keyboard suspend: ^Z
		gPause = true;
	else if (sigraised == SIGCONT) // continue: fg, bg
		gCont = true;
}

CFMutableArrayRef CFArrayCreateFileList(int count, const char * array[])
{
	CFMutableArrayRef files = CFArrayCreateMutable(NULL, 0, NULL); // note: we must retain/release each file ourselves!
	int filenum = 0;
	OSErr theErr = noErr;

	if (gCD)
	{
		FSVolumeInfo info;
		FSRef volumeFSRef;
		
		for ( filenum = 1; theErr != nsvErr; filenum++ )
		{
			theErr = FSGetVolumeInfo(kFSInvalidVolumeRefNum, filenum, NULL, kFSVolInfoFSInfo, &info, NULL, &volumeFSRef);
			
			if (theErr == noErr)
			{
				// bug fix from Apple web site example code:
				// Work around a bug in Mac OS X 10.0.x where the filesystem ID and signature bytes were erroneously swapped. This was fixed in Mac OS X 10.1 (r. 2653443).
				long systemVersion;
				if (Gestalt(gestaltSystemVersion, &systemVersion) != noErr)
					systemVersion = 0;
				if ((systemVersion >= 0x00001000 && systemVersion < 0x00001010 && info.signature == kAudioCDFilesystemID)
					|| info.filesystemID == kAudioCDFilesystemID)
				{
					// volume is an Audio CD, set path to volume name:
					CFURLRef path = CFURLCreateFromFSRefRelativeToLocalhost(&volumeFSRef);
					
					myprintv("Getting contents of CD: ");
					myprinturlv(path);
		
					// add Audio CD to list of files:
					addContents(path,files);
				}
			}
			else if (theErr != nsvErr)
			{
				myerror("Error getting information for volume %d. Error %d returned.\n", filenum, theErr);
			}
		}
	}
	else if (gPlaylist)
	{
		if (filenum == count)
			myerror("Error opening playlist file. Cannot open working directory.\n");
		
		while ( filenum < count )
		{
			CFStringRef pathstr = CFStringCreateWithCString(NULL, array[filenum], CFStringGetSystemEncoding());
			CFURLRef path = CFURLCreateFromCFString(pathstr, false);
			CFRelease(pathstr);

			if (path != NULL)
			{
				myprintv("Getting contents of playlist: %s\n", array[filenum]);
				{
					FILE * infile = fopen(array[filenum],"r+"); // open for reading (and writing only to catch error on directory)

					if (infile == NULL) // if error
					{
						if (CFURLHasHostScheme(path))
							myerror("Error opening playlist file. Cannot open a URL: %s\n", array[filenum]);
						else if (errno == EISDIR)
							myerror("Error opening playlist file. Cannot open a directory: %s\n", array[filenum]);
						else if (errno == ENOENT)
							myerror("Error opening playlist file. File does not exist: %s\n", array[filenum]);
						else
							myerror("Error opening playlist file. Unix error %d returned: %s\n", errno, array[filenum]);
					}
					else // if infile exists (ie. not error)
					{
						CFURLRef directory = CFURLCreateCopyDeletingLastPathComponent(NULL, path);
						myprintv("Files contents relative to: ");
						myprinturlv(directory);
						if ( CFEqual(CFURLGetString(directory), CFSTR("./")) ) // ignore directory if working directory
						{
							CFRelease(directory);
							directory = NULL;
						}
						
						// if good file, add contents of file
						if ( !isFileASCII(infile) )
							myerror("Error opening playlist file. File is not ASCII text: %s\n", array[filenum]);
						else if ( !isFileURLs(infile, directory) )
							myerror("Error opening playlist file. File does not contain valid file Paths or URLs: %s\n", array[filenum]);
						else // add contents of file
							addContentsFile(infile, files, directory);

						if (directory)
							CFRelease(directory);

						theErr = fclose(infile);
						if (theErr != 0)
							myerror("Error closing playlist file. Error %d returned: %s\n", theErr, array[filenum]);
					}
				}
				
				CFRelease(path);
			}
			else
			{
				myerror("Error. Playlist file name not specified.\n");
			}
			
			filenum++;
		}
	}
	else if ( filenum == count )
	{
		addContents(NULL,files); // add contents of working directory
	}
	else
	{
		while ( filenum < count )
		{
			CFStringRef pathstr = CFStringCreateWithCString(NULL, array[filenum], CFStringGetSystemEncoding());
			CFURLRef path = CFURLCreateFromCFString(pathstr, false);
			CFRelease(pathstr);

			if (path != NULL)
			{
				if ( CFEqual(CFURLGetString(path), CFSTR("-")) )
					addContentsFile(stdin, files, NULL); // add contents of stdin
				else
					addContents(path, files); // add file (or files in a directory)
			}
			else
			{
				myerror("Error. File name not specified.\n");
			}
			
			filenum++;
		}
	}

	return files;
}

void addContentsFile(FILE * infile, CFMutableArrayRef files, CFURLRef workingDirectory)
{
	if (infile != NULL)
	{
		size_t length;
		char * chars;

		rewind(infile);
		
		while ( (chars = fgetln(infile, &length)) != NULL)
		{
			CFURLRef path = NULL;
			CFStringRef pathstr;

			if (length > 0 && chars[length-1] == '\n') length--;

			pathstr = CFStringCreateWithBytes(NULL, (const UInt8 *)chars, length, CFStringGetSystemEncoding(), false);
			path = CFURLCreateFromCFStringRelativeToBase(pathstr, false, workingDirectory);
			CFRelease(pathstr);

			// add file (or files in a directory) to list of files
			if (path != NULL) // ignore blank lines (do not "replace" path with working directory)
				addContents(path,files);
		}
	}
}

void addContents(CFURLRef path, CFMutableArrayRef files)
{
	OSErr theErr;
	FSRef fsRef;

	// if a remote file, then add file
	if ( CFURLHasHostScheme(path) )
	{
		myprintv("Adding URL to playlist: ");
		myprinturlv(path);
		CFArrayInsertValueAtIndex(files, CFArrayGetCount(files), path);
		return;
	}
	
	// get fsRef:
	if ( path == NULL )
	{
		// "replace" path with working directory
		CFURLRef temp = CFURLCreateFromCFString(CFSTR("."), true);
		CFURLGetFSRef(temp, &fsRef);
		CFRelease(temp);
	}
	else if ( !CFURLGetFSRef(path, &fsRef) )
	{
		myerror("Error. File does not exist: ");
		myerrorurl(path);
		return;
	}

	// add file or directory:
	{
		Boolean isDir;
		Boolean wasAlias;
		theErr = FSResolveAliasFileWithMountFlags(&fsRef, true, &isDir, &wasAlias, kResolveAliasFileNoUI);

		if (theErr == noErr)
		{
			if (wasAlias)
			{
				myprintv("Resolving alias: ");
				myprinturlv(path);

				CFRelease(path); // "replace" path
				path = CFURLCreateFromFSRefRelativeToLocalhost(&fsRef);
			}

			// if a directory, add contents, else add file
			if (!isDir)
			{
				myprintv("Adding file to playlist: ");
				myprinturlv(path);
				CFArrayInsertValueAtIndex(files, CFArrayGetCount(files), path);
			}
			else
			{
				FSIterator iterator;
				ItemCount actualNumFiles;
				FSRef contentFSRef;
				HFSUniStr255 contentName;

				theErr = FSOpenIterator(&fsRef, kFSIterateFlat, &iterator);
				if (theErr != noErr)
				{
					myerror("Error opening iterator: ");
					myerrorurl(path);
				}

				while (theErr == noErr)
				{
					theErr = FSGetCatalogInfoBulk(iterator, 1, &actualNumFiles, NULL, kFSCatInfoNone, NULL, &contentFSRef, NULL, &contentName);

					if (theErr != errFSNoMoreItems && theErr != noErr)
					{
						myerror("Error getting contents of directory. Error %d returned: ", theErr);
						myerrorurl(path);
					}
					else if ( actualNumFiles > 0 && (contentName.unicode[0]) != (UniChar)('.') ) // if exists and not invisible:
					{
						CFURLRef pathurl;
						Boolean contentIsDir;
						Boolean contentWasAlias;

						{
							CFStringRef substr = CFStringCreateWithCharacters(NULL, contentName.unicode, contentName.length);
							
							if ( path != NULL )
								pathurl = CFURLCreateCopyAppendingPathComponent(NULL, path, substr, isDir);
							else
								pathurl = CFURLCreateFromCFString(substr, isDir);
							
							CFRelease(substr);
						}
						
						// add file or directory (if not recursive, then do not add directories):
						if (gRecursive)
						{
							addContents(pathurl, files);
						}
						else
						{
							theErr = FSResolveAliasFileWithMountFlags(&contentFSRef, true, &contentIsDir, &contentWasAlias, kResolveAliasFileNoUI);

							if (theErr != noErr)
							{
								myerror("Error getting info about file in a directory. Error %d returned: ", theErr);
								myerrorurl(pathurl);
							}
							else if (!contentIsDir)
							{
								addContents(pathurl, files);
							}
						}
					}
				}
				
				theErr = FSCloseIterator(iterator);
				if (theErr != noErr)
				{
					myerror("Error closing iterator: ");
					myerrorurl(path);
				}
			}
		}
		else
		{
			myerror("Error getting info about file. Error %d returned: ", theErr);
			myerrorurl(path);
		}
	}
	
	return;
}

void CFReleaseFileList(CFMutableArrayRef files)
{
	int filenum = 0;
	while (filenum < CFArrayGetCount(files))
	{
		CFRelease(CFArrayGetValueAtIndex(files,filenum));
		filenum++;
	}
	CFRelease(files);
}

void playfile(CFURLRef pathname)
{
	OSErr theErr = noErr;
	
	if (!pathname)
	{
		myerror("Error. Play file passed NULL.\n");
		return;
	}

	myprintv("\n");
	myprinturl(pathname);

	if (gQTOnly)
	{
		theErr = playfile_quicktime(pathname);
		if (theErr == noMovieFound)
			myerror("Error opening file. Not a Quicktime file.\n");
	}
	else if (gSMOnly)
	{
		if (CFURLHasHostScheme(pathname))
		{
			myerror("Error opening file. Sound Manager cannot open a URL.\n");
			return;
		}
		
		theErr = playfile_sndmanager(pathname);
		if (theErr == noMovieFound)
			myerror("Error opening file. No sound resources.\n");
	}
	else
	{
		// first, try opening file as a quicktime file:
		theErr = playfile_quicktime(pathname);
		// if not quicktime file, then try opening file as a sound resource file (switch to sound manager):
		if (theErr == noMovieFound)
		{
			if (CFURLHasHostScheme(pathname))
			{
				myerror("Error opening file. Not a Quicktime file. Cannot open a URL.\n");
				return;
			}
			
			// second, try opening file as a sound file:
			myprintv("Not a Quicktime file. Switching to sound manager.\n");
			theErr = playfile_sndmanager(pathname);
			if (theErr == noMovieFound)
			{
				// third, try opening as playlist (if correct file extension):
				myprintv("No sound resources. Switching to ascii playlist.\n");

				theErr = playfile_playlist(pathname);
				if (theErr != noErr)
					myerror("Error opening file. Not a playlist.\n");
			}
		}
	}

	return;
}

OSErr playfile_quicktime(CFURLRef pathname)
{
	OSErr theErr = noErr;
	Movie qtMovie = NULL;

	// initialize movie

	if ( !CFURLHasHostScheme(pathname) )
	{
		FSRef fsRef;
		FSSpec fsSpec;
		short refNum;

		myprintv("Initializing movie file from a file.\n");

		// convert CFURL to FSSpec
		if ( !CFURLGetFSRef(pathname, &fsRef) )
		{
			myerror("Error opening movie file. File does not exist.\n");
			return errFSBadFSRef;
		}

		theErr = FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL);
		if (theErr != noErr)
		{
			myerror("Error opening movie file. Can't get file specifier. Error %d returned.\n", theErr);
			return theErr;
		}

		// instantiate a movie from the specified file:
		theErr = OpenMovieFile(&fsSpec, &refNum, fsRdPerm);
		if (theErr != noErr)
		{
			myerror("Error opening movie file. Error %d returned.\n", theErr);
			return theErr;
		}
		theErr = NewMovieFromFile(&qtMovie, refNum, NULL, NULL, newMovieActive & newMovieDontAskUnresolvedDataRefs, NULL);
		CloseMovieFile(refNum);
	}
	else
	{
		char *	urlStr = NULL;
		Handle			myHandle = NULL;
		CFIndex			mySize = 0;
		
		myprintv("Initializing movie file from a URL.\n");
		
		// convert CFURL to char*
		urlStr = CFURLCreateCString(pathname);
		mySize = CFStringGetLength(CFURLGetString(pathname)) + 1;
		
		if (urlStr == NULL)
		{
			myerror("Error opening movie file. Could not create URL string.\n");
			return kTextUndefinedElementErr;
		}
		
		// copy the specified URL into a handle
		myHandle = NewHandleClear((Size)mySize); // allocate a new handle
		if (myHandle == NULL)
		{
			myerror("Error opening movie file. Could not create URL handle.\n");
			return nilHandleErr;
		}
		BlockMoveData(urlStr, *myHandle, (Size)mySize);
		
		// instantiate a movie from the specified URL
		theErr = NewMovieFromDataRef(&qtMovie, newMovieActive & newMovieDontAskUnresolvedDataRefs, NULL, myHandle, URLDataHandlerSubType);
		
		if (myHandle != NULL)
			DisposeHandle(myHandle);
		free(urlStr);
	}
	
	if (theErr != noErr)
	{
		if (theErr != noMovieFound)
			myerror("Error opening movie file. Can't create new movie from file. Error %d returned.\n", theErr);
		return theErr;
	}

	// remove tracks which are not sound tracks:
	{
		long index;
		Track track;
		OSType mediaType;

		// remove all tracks except sound (are there any others that should be supported?)
		for (index = GetMovieTrackCount(qtMovie); index > 0; index--)
		{
			track = GetMovieIndTrack(qtMovie, index);
			GetMediaHandlerDescription(GetTrackMedia(track), &mediaType, NULL, NULL);
			if (mediaType != SoundMediaType && mediaType != MusicMediaType)
			{
				DisposeMovieTrack(track);
			}
		}

		// bug fix by Carsten Klapp:
		// work around possible qt bug where white boxes show on screen even though all non-audio tracks have already been deleted
		{
			Rect boxRect = {0,0,0,0};
			//EmptyRect(&boxRect);
			SetMovieBox(qtMovie, &boxRect);
		}
	}

	// make sure movie file exists
	if (GetMovieTrackCount(qtMovie) <= 0)
	{
		return noMovieFound;
	}

	// set volume:
	SetMovieVolume(qtMovie, gVolume);

	// so start at beginning:
	GoToBeginningOfMovie(qtMovie);
	// so beginning of movie not cut off:
	usleep(100000);

	// play movie
	myprintv("Playing movie file.\n");
	myspeakurl(pathname);

	StartMovie(qtMovie);

	// if file type is not movie, then stop:
	theErr = GetMoviesError();
	if (theErr != noErr)
		myerror("Error starting movie file. Error %d returned.\n", theErr);

	while( (theErr == noErr) && !IsMovieDone(qtMovie) )
	{
		// so less processor intensive:
		usleep(gSleepTime);

		// if we recieved a "stop" signal, then stop
		if (gStop == true)
		{
			gStop = false;
			myprintv("User cancelled movie file.\n");
			StopMovie(qtMovie);
			theErr = userCanceledErr;
		}
		// if we recieved a "suspend" signal, then pause
		else if (gPause == true)
		{
			gPause = false;
			myprintv("User paused movie file.\n");
			if (gIsPaused == false)
			{
				gIsPaused = true;
				StopMovie(qtMovie);
				kill(getpid(),SIGSTOP); // suspend process
			}
		}
		// if we recieved a "continue" signal, then resume where we left off
		else if (gCont == true)
		{
			gCont = false;
			myprinturl(pathname);
			myprintv("User continued movie file.\n");
			if (gIsPaused == true)
			{
				gIsPaused = false;
				StartMovie(qtMovie);
			}
		}
		else
		{
			// so update movie:
			MoviesTask(qtMovie, 0);

			// if error, then stop:
			theErr = GetMoviesError();
			if (theErr != noErr)
				myerror("Error playing movie file. Error %d returned.\n", theErr);
		}
	}

	// deallocate movie
	myprintv("Movie file done.\n");

	DisposeMovie(qtMovie);

	if ( theErr == userCanceledErr )
		return noErr;
	else
		return theErr;
}

OSErr playfile_sndmanager(CFURLRef pathname)
{
	OSErr theErr = noErr;
	FSRef fsRef;
	FSSpec fsSpec;
	int refNum;
	int max = 0;

	// initialize sound resource
	myprintv("Initializing sound resource file.\n");

	if ( !CFURLGetFSRef(pathname, &fsRef) )
	{
		myerror("Error opening sound resource file. File does not exist.\n");
		return errFSBadFSRef;
	}

	theErr = FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL);
	if (theErr != noErr)
	{
		myerror("Error opening sound resource file. Can't get file specifier. Error %d returned.\n", theErr);
		return theErr;
	}

	refNum = FSpOpenResFile(&fsSpec,fsRdPerm);
	if (refNum < 0)
	{
		theErr = ResError();
		if (theErr != eofErr)
			myerror("Error opening sound resource file. Error %d returned.\n", theErr);
		else
			theErr = noMovieFound;
		return theErr;
	}

	UseResFile(refNum); // "open" resource fork
	theErr = ResError();
	if (theErr != noErr)
	{
		myerror("Error opening sound resource file. Can't use resource file. Error %d returned.\n", theErr);
	}
	else
	{
		max = Count1Resources('snd ');
		theErr = ResError();
		if (theErr != noErr)
			myerror("Error opening sound resource file. Can't count number of resources. Error %d returned.\n", theErr);
	}

	// if resource file exists, play sound resources:
	if (theErr == noErr && max > 0)
	{
		int index;

		SndChannelPtr pchan = NULL;
		
		if (max > 1)
		{
			myprintv("%d sound resources in file.\n", max);
		}

		// allocate sound channel
		theErr = SndNewChannel(&pchan, 0, 0, NULL);
		if (theErr != noErr)
		{
			myerror("Error creating sound channel. Error %d returned.\n", theErr);
			return theErr;
		}

		// set volume:
		{
			SndCommand snd;
			snd.cmd = volumeCmd;
			snd.param2 = gVolume | (gVolume << 16); // sets gVolume to left and right channels
			theErr = SndDoImmediate(pchan, &snd);
			if (theErr != noErr)
				myerror("Error setting volume. Error %d returned.\n", theErr);
		}

		// play sound resource:
		myspeakurl(pathname);
		
		for (index=1; index<=max; index++)
		{
			SndListHandle sndHandle;
			SCStatus theStatus;

			// play sound resource number x
			myprintv("Playing sound resource file: resource number %d.\n", index);

			// getting sound resource number x
			sndHandle = (SndListHandle)(Get1IndResource('snd ',index));
			theErr = ResError();
			if (theErr != noErr)
			{
				myerror("Error opening sound resource file. Can't get resource number %d. Error %d returned.\n", index, theErr);
				break;
			}

			theErr = SndPlay(pchan, sndHandle, true);
			if (theErr != noErr)
				myerror("Error playing sound resource file. Can't play resource number %d. Error %d returned.\n", index, theErr);

			theErr = SndChannelStatus (pchan, sizeof(SCStatus), &theStatus);
			if (theErr != noErr)
				myerror("Error playing sound resource file. Can't get status of resource number %d. Error %d returned.\n", index, theErr);

			while ( (theErr == noErr) && (theStatus.scChannelBusy == true) )
			{
				// so less processor intensive:
				usleep(gSleepTime);

				// if we recieved a "stop" signal, then stop
				if (gStop == true)
				{
					myprintv("User cancelled sound resource file.\n");
					{
						SndCommand snd;
						snd.cmd = flushCmd;
						theErr = SndDoImmediate(pchan, &snd);
						snd.cmd = quietCmd;
						theErr = SndDoImmediate(pchan, &snd);
					}
					theErr = userCanceledErr;
				}
				// if we recieved a "suspend" signal, then pause
				else if (gPause == true)
				{
					gPause = false;
					myprintv("User paused sound resource file.\n");
					if (gIsPaused == false)
					{
						gIsPaused = true;
						{
							SndCommand snd;
							snd.cmd = pauseCmd;
							theErr = SndDoImmediate(pchan, &snd);
						}
						kill(getpid(),SIGSTOP); // suspend process
					}
				}
				// if we recieved a "continue" signal, then resume where we left off
				else if (gCont == true)
				{
					gCont = false;
					myprinturl(pathname);
					myprintv("User continued sound resource file.\n");
					if (gIsPaused == true)
					{
						gIsPaused = false;
						{
							SndCommand snd;
							snd.cmd = resumeCmd;
							theErr = SndDoImmediate(pchan, &snd);
						}
					}
				}
				else
				{
					theErr = SndChannelStatus (pchan, sizeof(SCStatus), &theStatus);
					if (theErr != noErr)
						myerror("Error playing sound resource file. Can't get status of resource number %d. Error %d returned.\n", index, theErr);
				}
			}
			if (gStop == true)
			{
				gStop = false;
				index = max;
			}
		}

		// deallocate sound channel
		myprintv("Sound resource file done.\n");

		theErr = SndDisposeChannel (pchan, false);
		if (theErr != noErr)
			myerror("Error disposing sound channel. Error %d returned.\n", theErr);
	}

	CloseResFile(refNum);

	if ( theErr == userCanceledErr )
		return noErr;
	else if (max <= 0 && theErr == noErr)
		return noMovieFound;
	else
		return theErr;
}

OSErr playfile_playlist(CFURLRef pathname)
{
	// initialize playlist
	myprintv("Initializing ascii playlist file.\n");
	{
		char * array[] = {""};
		CFMutableArrayRef files;
		
		array[0] = CFURLCreateCString(pathname);

		if (array[0] == NULL)
		{
			myerror("Error initializing ascii playlist file. Could not create URL string.\n");
			return kTextUndefinedElementErr;
		}
		
		// get playlist
		{
			bool temp = gPlaylist;
			gPlaylist = true;
			files = CFArrayCreateFileList(1, (const char **)array);
			gPlaylist = temp;
		}
	
		myprintv("%d files in ascii playlist.\n", (int)CFArrayGetCount(files));
	
		// play list of files
		myprintv("Playing ascii playlist.\n");
	
		{
			int filenum = 0;
			while (filenum < CFArrayGetCount(files))
			{
				playfile( CFArrayGetValueAtIndex(files, filenum) );
				filenum++;
			}
			// if we recieved a "stop" signal which playfile didn't process, then stop
			if (gStop == true)
			{
				gStop = false;
				myprintv("User cancelled ascii playlist file.\n");
				//break;
			}
			// if we recieved a "suspend" signal which playfile didn't process, then pause
			else if (gPause == true)
			{
				gPause = false;
				myprintv("User paused ascii playlist file.\n");
				if (gIsPaused == false)
				{
					gIsPaused = true;
					kill(getpid(),SIGSTOP); // suspend process
				}
			}
		}

		// deallocate list of files
		myprintv("Ascii playlist file done.\n");
		myprintv("\n");

		{
			int filenum = 0;
			while (filenum < CFArrayGetCount(files))
			{
				CFRelease(CFArrayGetValueAtIndex(files,filenum));
				filenum++;
			}
			CFRelease(files);
		}

		free(array[0]);
	}
	
	return noErr;
}