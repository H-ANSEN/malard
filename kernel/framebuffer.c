#include "framebuffer.h"
#include "IO/io.h"

#define FB_START ((volatile unsigned short*) 0x000B8000)

#define FB_COMMAND_PORT 0x3D4
#define FB_DATA_PORT    0x3D5

#define FB_LOW_BYTE_COMMAND  0xF
#define FB_HIGH_BYTE_COMMAND 0xE

static unsigned short CURSOR_POS = 0;


/*<><> Text Writing <><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/
/* Functions writing text data to the framebuffer                             */

void fb_writecharpos(unsigned int pos, char c, fb_color fg, fb_color bg) {
    FB_START[pos] = (bg << 12) | (fg << 8) | c;
}

void fb_writepos(unsigned int pos, char *buf, unsigned int len) {
    for (unsigned int i = 0; i < len; i++) {
        unsigned int row = (pos + i) / FB_WIDTH;

        fb_writecharpos(pos + i, buf[i], WHITE, BLACK);

        if (row >= FB_HEIGHT) {
            fb_scroll();
            pos -= FB_WIDTH;
        } 
    }
}

void fb_writechar(char c, fb_color fg, fb_color bg) {
    fb_writecharpos(CURSOR_POS, c, fg, bg);
    fb_set_cursorpos(CURSOR_POS + 1);
}

void fb_write(char *buf, unsigned int len) {
    fb_writepos(CURSOR_POS, buf, len);
    fb_set_cursorpos(CURSOR_POS + len);
}

/*<><> Cursor <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/
/* Cursor manipulation functions, note that the cursor does not dictate where */
/* text is written and acts simply as a visual indicate that can be moved to  */
/* any point in the frame buffer                                              */

void fb_set_cursorpos(unsigned short pos) {
    unsigned char pos_high_byte = (pos >> 8) & 0xFF;
    unsigned char pos_low_byte = pos & 0xFF;

    outb(FB_COMMAND_PORT, FB_HIGH_BYTE_COMMAND);
    outb(FB_DATA_PORT, pos_high_byte);
    outb(FB_COMMAND_PORT, FB_LOW_BYTE_COMMAND);
    outb(FB_DATA_PORT, pos_low_byte);

    CURSOR_POS = pos;
}

unsigned short fb_get_cursorpos(void) {
    return CURSOR_POS; /* could fetch actual cursor pos here from hardware? */
}                      /* not sure if that would provide anythin extra      */

/*<><> Utility ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

void fb_clearline(unsigned short line) {
    volatile unsigned short *line_start = FB_START + (line * FB_WIDTH);
    for (int i = 0; i < FB_WIDTH; i++) {
        line_start[i] = 0;
    }
}

void fb_clear(void) {
    for (int i = 0; i < FB_WIDTH * FB_HEIGHT; i++) {
        fb_writecharpos(i, ' ', BLACK, BLACK);
    }
    fb_set_cursorpos(0);
}

void fb_scroll(void) {
    const int count = FB_WIDTH * (FB_HEIGHT - 1);
    volatile unsigned short *first_line_offset = FB_START;
    volatile unsigned short *second_line_offset = FB_START + FB_WIDTH;

    for (int i = 0; i < count; i++) {
        first_line_offset[i] = second_line_offset[i];
    }

    fb_clearline(FB_HEIGHT - 1);
    fb_set_cursorpos(CURSOR_POS - FB_WIDTH);
}
