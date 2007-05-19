#include "AudioPlayer.h"

// used in the Win32 timer callback functions
#ifdef __TETRIS_WINDOWS__
void * AudioPlayer::pObject;
#endif

// initialize QuickTime, variables, etc
AudioPlayer::AudioPlayer()
{
#ifdef __TETRIS_WINDOWS__
	InitializeQTML(0);
#endif
	
	EnterMovies();
	
	_currentMusic = NULL;
	_music1 = NULL;
	_music2 = NULL;
	_music3 = NULL;
	_gameOver = NULL;
	_musicPaused = false;
	
#ifdef __TETRIS_WINDOWS__
	pObject = this;
#endif
}

// Free up our variables and movies
AudioPlayer::~AudioPlayer()
{
	_currentMusic = NULL;
	if (_music1 != NULL)
		DisposeMovie(_music1);
	if (_music2 != NULL)
		DisposeMovie(_music2);
	if (_music3 != NULL)
		DisposeMovie(_music3);
	if (_gameOver != NULL)
		DisposeMovie(_gameOver);
	
	ExitMovies();

#ifdef __TETRIS_WINDOWS__
	TerminateQTML();
#endif
}

// the timer call back functions (for Mac and Windows). they will check to see if the song is done playing,
// and if it is, play a new song (or loop)
#ifdef __TETRIS_MAC__
void checkForEndOfMusic(EventLoopTimerRef inTimer, void *inUserData)
{
	if (inUserData != NULL)
	{
		AudioPlayer *theAudioPlayer = (AudioPlayer *)inUserData;
		if (theAudioPlayer != NULL)
			theAudioPlayer->CheckForStoppedMusic();
	}
}
#else
void CALLBACK AudioPlayer::TimerProc_Wrapper(HWND hwnd, UINT uMsg, UINT idEvent, DWORD dwTime)
{
	AudioPlayer *audioPlayer = (AudioPlayer*)pObject;
	audioPlayer->CheckForStoppedMusic();
}
#endif

// checks to see if the music has stopped
void AudioPlayer::CheckForStoppedMusic()
{
	// loop music
	if (IsMovieDone(_currentMusic))
	{
		LoadRandomMusic();
	}
}

// loads and plays a random music file
void AudioPlayer::LoadRandomMusic()
{
	if (_currentMusic != NULL)
	{
		StopMovie(_currentMusic);
		_currentMusic = NULL;
	}

	_currentMusic = GetRandomMusic();
	if (_currentMusic != NULL)
		StartMovie(_currentMusic);
}

#ifdef __TETRIS_WINDOWS__
// timer call back function for Win32 to update and continue playing the music
void CALLBACK AudioPlayer::TaskMovie(HWND hwnd, UINT uMsg, UINT idEvent, DWORD dwTime)
{
	AudioPlayer *audioPlayer = (AudioPlayer*)pObject;
	audioPlayer->DoTaskMovie();
}

// makes sure the music keeps playing
void AudioPlayer::DoTaskMovie()
{
	MoviesTask(_currentMusic, 1000);
}
#endif

// plays
void AudioPlayer::PlayMusic()
{
	if (_musicPaused == false)
	{
		// music isn't paused, so load a new random song
		LoadRandomMusic();
		GoToBeginningOfMovie(_currentMusic);
	}
	
	_musicPaused = false;
	StartMovie(_currentMusic);
	
#ifdef __TETRIS_MAC__
	// create a timer to check to see if music is done playing so we can loop it
	EventLoopTimerRef myTimer;
	InstallEventLoopTimer(GetMainEventLoop(), 0, 0.25, NewEventLoopTimerUPP(checkForEndOfMusic), this, &myTimer);
#else
	SetTimer(NULL, NULL, 500, TimerProc_Wrapper); // checks for looping
	SetTimer(NULL, NULL, 1000, (TIMERPROC)TaskMovie); // keeps the movie playing
#endif
}

// stops the music
void AudioPlayer::StopMusic()
{
	if (_currentMusic != NULL)
		StopMovie(_currentMusic);
}

// pauses the music (basically identical to stop)
void AudioPlayer::PauseMusic()
{
	if (_currentMusic != NULL)
		StopMovie(_currentMusic);
	_musicPaused = true;
}

// plays the game over audio
void AudioPlayer::PlayGameOver()
{
	if (_gameOver == NULL)
	{
		char fileName[256];
		getFullPathForFile("gameover.wav", fileName);
		
		_gameOver = LoadMovie(fileName);
		
		if (_gameOver == NULL)
			return;
	}
	
	GoToBeginningOfMovie(_gameOver);
	StartMovie(_gameOver);
}

// loads any QuickTime supported file at the given path and returns a Movie object
// watch the #ifdef's since Windows and Macs get a reference to the file differently
// (FSSpec is QuickTime only...)
Movie AudioPlayer::LoadMovie(char *filePath)
{
	FSSpec fsSpec;

#ifdef __TETRIS_MAC__
	CFStringRef pathString = CFStringCreateWithCString(NULL, filePath, kCFStringEncodingASCII);
	if (pathString == NULL)
	{
		printf("Can't make into CFStringRef\n");
		return NULL;
	}
	
	//CFURLRef urlRef = CFURLCreateWithString(NULL, pathString, NULL);
	CFURLRef urlRef = CFURLCreateWithFileSystemPath(NULL, pathString, kCFURLPOSIXPathStyle, false);
	if (urlRef == NULL)
	{
		printf("Can't make string into URL\n");
		return NULL;
	}
	
	FSRef fsRef;
	if (CFURLGetFSRef(urlRef, &fsRef) == false)
	{
		printf("Can't get FSRef\n");
		return NULL;
	}
	
	CFRelease(pathString);
	CFRelease(urlRef);
	
	if (FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL) != noErr)
	{
		printf("Can't make FSSpec\n");
		return NULL;
	}
#endif
	
#ifdef __TETRIS_WINDOWS__
	if (NativePathNameToFSSpec(filePath, &fsSpec, 0) != noErr)
	{
		printf("Can't get FSSpec\n");
	}
#endif
	
	short resRefNum;
	if (OpenMovieFile(&fsSpec, &resRefNum, fsRdPerm) != noErr)
	{
		printf("Can't open movie file.\n");
		return NULL;
	}
	
	Movie movie;
	if (NewMovieFromFile(&movie, resRefNum, NULL, NULL, 0, NULL) != noErr)
	{
		printf("Can't get movie from file\n");
		return NULL;
	}
	
	CloseMovieFile(resRefNum);
	
	return movie;
}

// pass in to this function just the filename of an audio file, and it will give you
// the full path to the file... for Windows the file must be in the same directory
// as the exe. again, watch the #ifdefs to make sure you're looking at the appropriate code..
void AudioPlayer::getFullPathForFile(const char *fileName, char *fullPath)
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

// returns a random music Movie variable
Movie AudioPlayer::GetRandomMusic()
{
	char filePath[255];
	int song = rand() % 3 + 1;
	switch (song)
	{
		case 1:
			if (_music1 == NULL)
			{
				getFullPathForFile("tetris1.mid", filePath);
				_music1 = LoadMovie(filePath);
			}
			return _music1;
			break;
		case 2:
			if (_music2 == NULL)
			{
				getFullPathForFile("tetris2.mid", filePath);
				_music2 = LoadMovie(filePath);
			}
			return _music2;
			break;
		case 3:
			if (_music3 == NULL)
			{
				getFullPathForFile("tetris3.mid", filePath);
				_music3 = LoadMovie(filePath);
			}
			return _music3;
			break;
		default:
			if (_music1 == NULL)
			{
				getFullPathForFile("tetris1.mid", filePath);
				_music1 = LoadMovie(filePath);
			}
			return _music1;
			break;
	}
	return NULL;
}