#define ASMDEF(T, name, args)  \
    extern T name(void);       \
    T c##name args;

ASMDEF(void, diskread, ());
ASMDEF(void, hexprint, (const int));
ASMDEF(void, print, (const char*));

extern int _multiboot_info_addr;
extern int _e820_map_addr;

void stage2_main() {
    cprint("stage2 load success\n\r");
    chexprint((int)&_multiboot_info_addr);
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

void chexprint(const int hex) {
    __asm__ volatile
        (
         "mov (%0), %%di"
         : /* no */
         : "r" (hex)
        );

    hexprint();
}
