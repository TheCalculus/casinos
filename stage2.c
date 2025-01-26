extern void print(void);
extern void diskread(void);
void cprint(const char* string);

void stage2_main() {
    cprint("stage2 load success\n\r");
}

void cprint(const char* string) {
    __asm__ volatile
        (
         "lea (%0), %%si"
         : /* no */
         : "r" (string)
        );

    print();
}
