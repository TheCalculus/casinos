#include "include/framebuffer.h"
#include "include/io.h"
#include "include/types.h"
#include "include/util.h"

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

void set_cursor(int offset) {
//  u16 pos = y * MAX_COLS + x;
    u16 pos = offset;
    
    outb(0x3D4, 0x0F);
    outb(0x3D5, (u8)(pos & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (u8)((pos >> 8) & 0xFF));
}

u16 get_cursor() {
    u16 offset = 0;

    outb(0x3D4, 0x0F);
    offset |= inb(0x3D5);
    
    outb(0x3D4, 0x0E);
    offset |= ((u16)inb(0x3D5)) << 8;
    
    return offset;
}

#define ADVANCE_LINE(row, col) { col = 0; row++; }

void print(char* string, int x, int y) {
    volatile u8* video = (volatile u8*)VIDEO_ADDRESS;

    int row = x, col = y;
    int offset;

    while (*string != 0) {
        if (col >= MAX_COLS) ADVANCE_LINE(row, col);
        if (row >= MAX_ROWS) {
            // handle scroll
            for (int i = 1; i < MAX_ROWS; i++) {
                memcpy((char*)video + SCREEN_OFFSET(0, i),
                       (char*)video + SCREEN_OFFSET(0, i - 1), MAX_COLS * 2);
            }

            volatile u8* final = video + SCREEN_OFFSET(0, MAX_ROWS - 1);

            for (int i = 0; i < MAX_COLS * 2; i++)
                final[i] = 0; 
        }

        if (*string == '\n') {
            ADVANCE_LINE(row, col);
            offset = SCREEN_OFFSET(row, col);

            goto skip_display;
        }

        offset = SCREEN_OFFSET(row, col);

        video[offset]     = *string;
        video[offset + 1] = 0x0f;

        offset += 2;

    skip_display:
        col++;
        string++;
    }
}

void printatcursor(char* string) {
    volatile u8* video = (volatile u8*)VIDEO_ADDRESS;

    int offset = get_cursor();

    while (*string != 0) {
        if (*string == '\n') {
            offset += MAX_COLS;
            goto skip_display;
        }
        
        video[offset] = *string;
        video[offset + 1] = 0x0f;

        offset += 2;

    skip_display:
        string++;
        set_cursor(offset);
    }
}

void clearscr() {
    volatile u8* video = (volatile u8*)VIDEO_ADDRESS;
    for (int col = 0; col < MAX_COLS; col++)
        for (int row = 0; row < MAX_ROWS; row++) {
            video[SCREEN_OFFSET(row, col)] = ' ';
            video[SCREEN_OFFSET(row, col) + 1] = 0x0f;
        }
}
