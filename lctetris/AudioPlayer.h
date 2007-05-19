/*
 *  PAudioPlayer.h
 *  LCTetris
 *
 *  Handles playing music and audio files via QuickTime
 *
 */

#include "Includes.h"

class AudioPlayer
{
private:
	Movie _currentMusic, _music1, _music2, _music3;
	Movie _gameOver;
	bool _musicPaused;
	
	Movie LoadMovie(char *filePath);
	void getFullPathForFile(const char *fileName, char *fullPath);
	void getMusicFileName(char *filePath);
	Movie GetRandomMusic();
	void LoadRandomMusic();

#ifdef __TETRIS_WINDOWS__
	static void * pObject;
	static void CALLBACK TimerProc_Wrapper( HWND hwnd, UINT uMsg, UINT idEvent, DWORD dwTime );
	void CALLBACK TimerProc( HWND hwnd,UINT uMsg, UINT idEvent, DWORD dwTime );
	static void CALLBACK AudioPlayer::TaskMovie(HWND hwnd, UINT uMsg, UINT idEvent, DWORD dwTime);
	void DoTaskMovie();
#endif
	
public:
	AudioPlayer();
	~AudioPlayer();
	
	void CheckForStoppedMusic();
	void PlayMusic();
	void StopMusic();
	void PauseMusic();
	
	void PlayGameOver();	
};
