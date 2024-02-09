typedef unsigned char size_t;

int main() {
    size_t* VIDEO_MEMORY = (size_t*)0xb8000;

    *VIDEO_MEMORY = 'H';

    return 0;
}
