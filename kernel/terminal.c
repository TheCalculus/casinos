#include "io.h"
#include "screen.h"
#include "types.h"

void enable_cursor(u8 start, u8 end) {
    outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | start);

	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3D5) & 0xE0) | end);
}

void disable_cursor() {
	outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}

void set_cursor(int x, int y) {
	u16 pos = y * MAX_COLS + x;

	outb(0x3D4, 0x0F);
	outb(0x3D5, (u8)(pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (u8)((pos >> 8) & 0xFF));
}

u16 get_cursor() {
    u16 offset = 0;

    outb(0x3D4, 0x0F);
    offset = inb(0x3D5) << 8;
    
    outb(0x3D4, 0x0E);
    offset += (u16)inb(0x3D5) << 8;

    return offset * 2;
}

void print(char* string) {
    volatile u8* video = (volatile u8*)VIDEO_ADDRESS;

    int row = 0, col = 0;
    int offset;

    while (*string != 0) {
        if (col >= MAX_COLS) {
            col = 0;
            row++;
        }

        offset = SCREEN_OFFSET(row, col);

        if (*string == '\n') {
            offset += MAX_COLS;
            col = 0;
            row++;
        }
        
        video[offset] = *string;
        video[offset + 1] = 0x0f;

        offset += 2;
        col++;
        string++;
    }
}
