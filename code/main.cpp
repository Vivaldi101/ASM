#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>

#include "xor_main.h"

int main(int argc, char** argv)
{
	if (argc != 3)
	{
		fprintf(stderr, "Invalid use\n");
		fprintf(stderr, "Pass file to encrypt followed by name of the desired encrypted file\n");
		return -1;
	}

	return XorMain(argc, argv[1], argv[2]);
}
