#ifndef SCREEN_H
#define SCREEN_H

#define VIDEO_ADDRESS   0xb8000
#define MAX_ROWS        25
#define MAX_COLS        80

#define SCREEN_OFFSET(row, col) (row * MAX_COLS + col) * 2

void print(char* string, int x, int y);
void printatcursor(char* string);
void clearscr();

#endif
