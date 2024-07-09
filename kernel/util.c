#include "include/types.h"

void memcpy(char* source, char* dest, u32 no_bytes) {
    for (int i = 0; i < no_bytes; i++)
        *dest++ = *source++;
}
