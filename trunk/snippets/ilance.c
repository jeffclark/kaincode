#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <CoreFoundation/CoreFoundation.h>

int main()
{
	FILE *firmware = fopen("/Applications/Utilities/iPod Software Updater.localized/iPod Updater 2006-06-28.app/Contents/Resources/Updates/Firmware-14.5.2", "rb");
	int r = 0, fileLength = 0;
	char riff[5], wave[5];
	char *wavBytes = NULL;
	FILE *wavFile = NULL;
	char wavName[12], wavPath[256];
	
	riff[4] = 0;
	wave[4] = 0;
	
	system("mkdir wavs");
	
	while (!feof(firmware))
	{
		// scan for "RIFF", file length, "WAVE"
		riff[0] = fgetc(firmware);
		riff[1] = fgetc(firmware);
		riff[2] = fgetc(firmware);
		riff[3] = fgetc(firmware);
		fread(&fileLength, 4, 1, firmware);
		wave[0] = fgetc(firmware);
		wave[1] = fgetc(firmware);
		wave[2] = fgetc(firmware);
		wave[3] = fgetc(firmware);
			
		if (strcmp(riff, "RIFF") == 0 && strcmp(wave, "WAVE") == 0)
		{
			// swap the bytes from little endian to host endian
			fileLength = CFSwapInt32LittleToHost(fileLength);
			// subtract 8 bytes (see http://www.sonicspot.com/guide/wavefiles.html)
			fileLength -= 8;
		
			sprintf(wavName, "%02d.wav", r++);
			sprintf(wavPath, "wavs/%s", wavName);
			printf("%s (%d)\n", wavPath, fileLength);

			fseek(firmware, -12, SEEK_CUR); // go back 12 bytes to the beginning of the file
			wavBytes = malloc(fileLength);
			fread(wavBytes, 1, fileLength, firmware);
			wavFile = fopen(wavPath, "wb");
			fwrite(wavBytes, 1, fileLength, wavFile);
			fclose(wavFile);
			free(wavBytes);
			wavBytes = NULL;
			
			if (r == 285)
				break; // seems like only 285 .wavs in the firmware to me..
		}
		else
		{
			fseek(firmware, -11, SEEK_CUR);			
		}
		
		riff[0] = 0;
		wave[0] = 0;
	}
	
	fclose(firmware);
}