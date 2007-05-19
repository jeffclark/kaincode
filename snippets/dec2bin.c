#include <stdio.h>

int dec2bin(int num)
{
	int bin = 0, k = 1;
	
	while (num)
	{
		bin += (num % 2) * k;
		k *= 10;
		num /= 2;
	}
	
	return bin;
}

int main()
{
	int num = 0;
	
	printf("Enter a number: ");
	scanf("%d", &num);
	
	printf("%d in binary is %d\n", num, dec2bin(num));
	
	return 0;
}