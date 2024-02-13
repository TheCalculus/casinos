|           what           |                 how                 |
| ------------------------ | ----------------------------------- |
| build boot sector        | `nasm main.s -fbin -o boot_sect.bin`                                                  |
| 'run' bare boot sector   | `qemu-system-x86_64 -fda boot_sect.bin`                                               |
| build kernel entry       | `nasm enter_kernel.s -felf -o enter_kernel.o`                                         |
| link entry with source   | `ld -o kernel.bin -m elf_i386 -Ttext 0x1000 enter_kernel.o kernel.o --oformat binary` |
| compile kernel source    | `gcc -ffreestanding -m32 -fno-pie -c kernel.c -o kernel.o`                            |
| construct kernel image   | `cat boot_sect.bin kernel.bin > os-image`                                             |
| everything automatically | `make` / `make run` / `make [target]`                                                 |
  
https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf
