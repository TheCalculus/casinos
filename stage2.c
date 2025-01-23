void stage2_main() {
    asm("movb $0, %ah");
    asm("int $0x10");
}
