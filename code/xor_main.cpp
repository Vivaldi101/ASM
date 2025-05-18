#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>
#include <intrin.h>

#include "xor_main.h"

extern "C"
{
	static void PrintError()
	{
		fprintf(stderr, "Invalid use\n");
		fprintf(stderr, "Pass file to encrypt followed by name of the desired encrypted file or -simd to print supported simd versions\n");
	}

	static void PrintSIMDSupport()
	{
		int cpuInfo[4];

		// CPUID function 1: basic SIMD features (SSE, AVX)
		__cpuid(cpuInfo, 1);

		if (cpuInfo[3] & (1 << 25))
			printf("SSE supported\n");
		if (cpuInfo[3] & (1 << 26))
			printf("SSE2 supported\n");
		if (cpuInfo[2] & (1 << 0))
			printf("SSE3 supported\n");
		if (cpuInfo[2] & (1 << 9))
			printf("SSSE3 supported\n");
		if (cpuInfo[2] & (1 << 19))
			printf("SSE4.1 supported\n");
		if (cpuInfo[2] & (1 << 20))
			printf("SSE4.2 supported\n");
		if (cpuInfo[2] & (1 << 28))
			printf("AVX supported\n");

		// CPUID function 7, subfunction 0: newer SIMD like AVX2, AVX-512
		__cpuidex(cpuInfo, 7, 0);

		if (cpuInfo[1] & (1 << 5))
			printf("AVX2 supported\n");
		if (cpuInfo[1] & (1 << 16))
			printf("AVX-512F supported\n");
	}

	// Unused atm.
	void AsmMain(void);

	void SSEPad(const char* src, unsigned int ln);
	void SSEXor(const char* src, const char* pad, unsigned int ln);
	bool SSEIsAllZero(const char* src, unsigned int ln);

	EXPORT int XorMain(const char* from, const char* to)
	{
		if(strcmp(from, "-simd") == 0)
		{
			PrintSIMDSupport();
			return 0;
		}

		fprintf(stderr, "Correct number of parameters given.\n");
		fprintf(stderr, "Trying to xor file: %s to %s\n", from, to);

		FILE* fileInput = fopen(from, "rb");
		FILE* fileOutput = fopen(to, "wb");

		if (!fileInput || !fileOutput)
		{
			fprintf(stderr, "Error opening files - do they exist?\n");
			return -1;
		}

		fseek(fileInput, 0, SEEK_END);
		const unsigned int fileSize = ftell(fileInput);
		if (fileSize == 0)
		{
			fprintf(stderr, "Bad file\n");
			return -1;
		}
		fseek(fileInput, 0, SEEK_SET);

		const size_t alignment = 64;
		char* source = (char*)_aligned_malloc(fileSize, alignment);
		char* pad = (char*)_aligned_malloc(fileSize, alignment);

		// Random key pad for XOR
		// TODO: Do this in asm

		if (!source || !pad)
		{
			fprintf(stderr, "Bad malloc\n");
			return -1;
		}

		assert((size_t)source % alignment == 0);
		assert((size_t)pad % alignment == 0);

		assert(((size_t)source & (alignment-1)) == 0);
		assert(((size_t)pad & (alignment-1)) == 0);

		for (unsigned int i = 0; i < fileSize; ++i)
		{
			pad[i] = (i & 1) == 1 ? '1' : '0';
		}

		fread(source, 1, fileSize, fileInput);

		fclose(fileInput);

		//source[fileSize-1] = 0;

		//printf("xoring %s...\n", from);

		SSEXor(source, pad, fileSize);

		fwrite(source, 1, fileSize, fileOutput);
		fclose(fileOutput);

		assert(!SSEIsAllZero(source, fileSize));

		_aligned_free(source);
		_aligned_free(pad);

		printf("Success xoring!\n");

		return 0;
	}
};
