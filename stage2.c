__attribute__((used, section(".rodata")))
const char* msg_stage2_load = "stage2 load success\n\r";

extern void print(void);
extern void diskread(void);

void stage2_main() {
    __asm__ volatile
    (
        "lea (%0), %%si"
        : /* no */
        : "r" (msg_stage2_load)
    );

    print();
}

