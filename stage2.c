#define ASMDEF(T, name, args)  \
    extern T name(void);       \
    T c##name args;

ASMDEF(void, diskread, ());
ASMDEF(void, hexprint, (const int));
ASMDEF(void, print, (const char*));

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

typedef struct dapack {
    u8 size;
    u8 _res;
    u16 sectors;
    u32 transfer;
    u32 lba_low;
    u32 lba_high;
} __attribute__((aligned(16))) dapack_t;

typedef struct SMAP_entry {
    u32 base_low;
    u32 base_high;
    u32 length_low;
    u32 length_high;
    u32 type;
    u32 ACPI;
} __attribute__((packed)) SMAP_entry_t;

extern int dapack;

#define E820_MAP_ADDR 0x3000

int __attribute__((noinline)) __attribute__((regparm(3))) e820(SMAP_entry_t* buffer, int maxentries);

void stage2_main() {
    cprint("stage2 load success\n\r");
    SMAP_entry_t* smap = (SMAP_entry_t*)E820_MAP_ADDR;
    const int smap_size = 0x2000;
    const int entry_count = e820(smap, smap_size / sizeof(SMAP_entry_t));
    if (entry_count == -1) {
        cprint("entry_count == -1\n\r");
	} else {
        for (int i = 0; i < entry_count; i++) {
            SMAP_entry_t* entry = &smap[i];
            chexprint((int)&entry->base_low);
            chexprint((int)&entry->base_high);
            chexprint((int)&entry->length_low);
            chexprint((int)&entry->length_high);
            chexprint((int)&entry->type);
            chexprint((int)&entry->ACPI);
        }
	}
}

int
__attribute__((noinline))
__attribute__((regparm(3)))
e820(SMAP_entry_t* buffer, int maxentries) {
	int contID = 0;
	int entries = 0, signature, bytes;
	do {
		__asm__ __volatile__ ("int  $0x15" 
				: "=a"(signature), "=c"(bytes), "=b"(contID)
				: "a"(0xE820), "b"(contID), "c"(24), "d"(0x534D4150), "D"(buffer));
		if (signature != 0x534D4150) 
			return -1; // error
		if (bytes > 20 && (buffer->ACPI & 0x0001) == 0)
		{
			// ignore this entry
		}
		else {
			buffer++;
			entries++;
		}
	} 
	while (contID != 0 && entries < maxentries);
	return entries;
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
