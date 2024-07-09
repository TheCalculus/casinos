#include "include/io.h"
#include "include/types.h"

void outb(u16 port, u8 data) {
    __asm__ volatile(
        "outb %%al, %%dx"
        :: "a" (data), "d" (port)
    );
}

u8 inb(u16 port) {
    u8 result;

    __asm__ volatile(
        "inb %%dx, %%al"
        : "=a" (result) : "d" (port)
    );

    return result;
}
