#include <stdint.h>

enum {
    VGA_WIDTH = 80,
    VGA_HEIGHT = 25,
    VGA_MEMORY = 0xB8000,
    VGA_COLOR = 0x07
};

static volatile uint16_t *const vga_buffer = (uint16_t *)VGA_MEMORY;

static void clear_screen(void) {
    for (uint32_t row = 0; row < VGA_HEIGHT; row++) {
        for (uint32_t column = 0; column < VGA_WIDTH; column++) {
            const uint32_t index = row * VGA_WIDTH + column;
            vga_buffer[index] = ((uint16_t)VGA_COLOR << 8) | ' ';
        }
    }
}

static void write_string(const char *text) {
    uint32_t column = 0;
    while (text[column] != '\0' && column < VGA_WIDTH) {
        vga_buffer[column] = ((uint16_t)VGA_COLOR << 8) | (uint8_t)text[column];
        column++;
    }
}

void kernel_main(void) {
    clear_screen();
    write_string("Hello, kernel!");
}
