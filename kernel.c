typedef unsigned char size_t;

int main() {
    size_t* VIDEO_MEMORY = (size_t*)0xb8000;

    for (int i = 0; i < 10; i++)
        *(VIDEO_MEMORY + i) = 'H' + i;

    return 0;
}
