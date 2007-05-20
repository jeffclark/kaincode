#include <stdio.h>
#include <string.h>
#include <stdbool.h>

void trimSpaces(char *str)
{
	while (str[strlen(str)-1] == ' ')
	{
		str[strlen(str)-1] = 0;
	}
	
	while (str[0] == ' ')
	{
		// shift characters down
		int i;
		for (i=1; i<strlen(str); i++)
		{
			str[i-1] = str[i];
		}
		str[i-1] = 0;
	}
}

void parseLine(const char *line)
{
	char lineCopy[100];
	strcpy(lineCopy, line);
	
	// skip empty lines or commented lines (#)
	trimSpaces(lineCopy);
	if (strlen(lineCopy) == 0 || line[0] == '#')
		return;
	
	char property[100], value[100];
	bool prop = true;
	int index = 0, i;
	
	property[0] = 0;
	value[0] = 0;

	for (i=0; i<strlen(lineCopy); i++)
	{
		char c = lineCopy[i];

		if (c == '=')
		{
			prop = false;
			property[index] = 0;
			index = 0;
		}
		else
		{
			if (prop)
				property[index] = c;
			else
				value[index] = c;
				
			index++;
		}
	}
	
	value[index] = 0;
	
	trimSpaces(property);
	trimSpaces(value);

	printf("property: %s\n", property);
	printf("value: %s\n\n", value);
}

void parseFile(const char *fileName)
{
	FILE *file = fopen(fileName, "r");
	if (file == NULL)
	{
		printf("Can't open file!\n");
		return;
	}

	char c;
	char line[100];
	int index = 0;

	while (c = fgetc(file))
	{
		if (c == '\n' || c == '\r' || c == EOF)
		{
			line[index] = 0;
			parseLine(line);

			if (c == EOF)
				break;

			index = 0;
		}
		else
		{
			line[index] = c;
			index++;
		}
	}
	
	fclose(file);
}

int main(int argc, const char *argv[])
{
	if (argc < 2)
	{
		printf("You must enter the path to the .config file!\n");
		return 0;
	}

	parseFile(argv[1]);
	
	return 0;
}