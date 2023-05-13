#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>

extern "C"
{
    void AsmMain(void);
    void SSExor(const char* src, const char* padd, unsigned int ln);
};

int ReadLine(char* destination, int maxLineCount)
{
    assert(maxLineCount >= 2);

    int result = 0;

    char* readString = fgets(destination, maxLineCount, stdin);

    if (readString)
    {
        size_t stringLen = strlen(readString);
        if (stringLen > 0)
        {
            destination[stringLen - 1] = 0;
        }

        result = (int)stringLen;
        assert(!readString[stringLen - 1]);
    }

    return result;
}

int main(void)
{
    // ASM code here.

#define SIZE ((64*4) + 10)

    char source[SIZE];
    char oldSource[SIZE];
    char pad[SIZE];

    for (int i = 0; i < SIZE; ++i)
    {
        source[i] = 's';
        oldSource[i] = source[i];

        pad[i] = 's' + 3 - 10;
    }

    printf("Encrypting...\n");

    SSExor(source, pad, SIZE);

    printf("Decrypting...\n");

    SSExor(source, pad, SIZE);

    assert(memcmp(oldSource, source, SIZE) == 0);

    printf("Success SSExor!\n");

    return 0;
}
