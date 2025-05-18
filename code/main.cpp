#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <string.h>

#include "xor_main.h"

void PrintError()
{
	fprintf(stderr, "Invalid use\n");
	fprintf(stderr, "Pass file to encrypt followed by name of the desired encrypted file or -simd to print supported simd versions\n");
}

int main(int argc, char** argv)
{
	if(argc == 2)
	{
		if(strcmp(argv[1], "-simd") == 0)
			return XorMain(argv[1], argv[2]);
		else
		{
			PrintError();
			return -1;
		}
	}
	if (argc != 3)
	{
		PrintError();
		return -1;
	}

	return XorMain(argv[1], argv[2]);
}
