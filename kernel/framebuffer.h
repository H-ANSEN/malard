#ifndef __FRAMEBUFFER__
#define __FRAMEBUFFER__

#define FB_WIDTH  80
#define FB_HEIGHT 25
#define FB_POS(x, y) ((y) * FB_WIDTH + (x))

typedef enum {
    BLACK         = 0x0,
    BLUE          = 0x1,
    GREEN         = 0x2,
    CYAN          = 0x3,
    RED           = 0x4,
    MAGENTA       = 0x5,
    BROWN         = 0x6,
    LIGHT_GREY    = 0x7,
    DARK_GREY     = 0x8,
    LIGHT_BLUE    = 0x9,
    LIGHT_GREEN   = 0xA,
    LIGHT_CYAN    = 0xB,
    LIGHT_RED     = 0xC,
    LIGHT_MAGENTA = 0xD,
    LIGHT_BROWN   = 0xE,
    WHITE         = 0xF
} fb_color;

void fb_writecharpos(unsigned int pos, char c, fb_color fg, fb_color bg);
void fb_writepos(unsigned int pos, char *buf, unsigned int len);
void fb_writechar(char c, fb_color fg, fb_color bg);
void fb_write(char *buf, unsigned int len);
void fb_scroll();
void fb_clear(void);
void fb_clearline(unsigned short line);

void fb_set_cursorpos(unsigned short pos);
unsigned short fb_get_cursorpos(void);

#endif /* __FRAMEBUFFER__ */
