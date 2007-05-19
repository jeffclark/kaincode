#include <stdio.h>
#include <strings.h>
#include <dirent.h>

int main(int argc, char *argv[])
{
	int args = argc-1;
	if (args != 1)
	{
		printf("usage: RenameBins <folder>\n");
		return 0;
	}
	
	chdir(argv[1]);
	
	FILE *file = fopen("XF_.rc", "r");
	if (file == NULL)
	{
		printf("Couldn't open XF_.rc\n");
		return 0;
	}
	
	char line[255];
	char cmd[255];
	while (!feof(file))
	{
		fgets(line, 255, file);
		if (line[0] == '\r')
			continue;
		
		line[strlen(line)-2] = 0; // remove \r\n from end of line..
		
		char ico[100], bin[100];
		char *part;
		part = strtok(line, " ");
		int i = 0;
		while (part != NULL)
		{
			if (i == 0)
				strcpy(ico, part);
			else if (i == 2)
			{
				strcpy(bin, part+1);
				bin[strlen(bin)-1] = 0; // remove quote at end
			}
			part = strtok(NULL, " ");
			i++;
		}

		sprintf(cmd, "mv %s %s", bin, ico);
		system(cmd);
	}
	
	return 0;
}
