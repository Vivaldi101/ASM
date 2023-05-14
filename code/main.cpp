#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>

extern "C"
{
    // Unused atm.
    void AsmMain(void);
    void SSExor(const char* src, const char* padd, unsigned int ln);
};

int main(int argc, char** argv)
{
    if (argc != 3)
    {
        fprintf(stderr, "Invalid use\n");
        fprintf(stdout, "Pass file to encrypt followed by name of the desired encrypted file\n");
        return -1;
    }

    fprintf(stdout, "XORing file: %s to %s\n", argv[1], argv[2]);

    FILE* fileInput = fopen(argv[1], "rb");
    FILE* fileOutput = fopen(argv[2], "wb");

    if (!fileInput || !fileOutput)
    {
        fprintf(stderr, "Error opening files\n");
        return -1;
    }

    fseek(fileInput, 0, SEEK_END);
    const unsigned int fileSize = ftell(fileInput);
    fseek(fileInput, 0, SEEK_SET);

    char* source = (char*)malloc(fileSize);
    char* oldSource = (char*)malloc(fileSize);
    char* pad = (char*)malloc(fileSize);

    if (!source || !oldSource || !pad)
    {
        fprintf(stderr, "Bad malloc\n");
        return -1;
    }

    fread(source, 1, fileSize, fileInput);

    fclose(fileInput);

    source[fileSize-1] = 0;

    memcpy(pad, source, fileSize);
    memcpy(oldSource, source, fileSize);

    printf("XORing %s...\n", argv[1]);

    SSExor(source, pad, fileSize);

    printf("XORing %s...\n", argv[1]);

    SSExor(source, pad, fileSize);

    fwrite(source, 1, fileSize, fileOutput);
    fclose(fileOutput);

    assert(memcmp(oldSource, source, fileSize) == 0);

    free(source);
    free(oldSource);
    free(pad);

    printf("Success SSExor!\n");

    return 0;
}
