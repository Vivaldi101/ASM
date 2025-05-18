#ifndef XOR_MAIN_H
#define XOR_MAIN_H

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

extern "C"
{
	EXPORT int XorMain(int argc, const char* from, const char* to);
}

#endif
