#ifndef __IO__
#define __IO__

inline __attribute__((always_inline)) 
void outb(unsigned short port, unsigned char data) {
    asm volatile (
        "outb %0, %1"
        :
        : "a"(data), "Nd"(port)
    );
}

inline __attribute__((always_inline)) 
unsigned char inb(unsigned short port) {
    unsigned char result;
    asm volatile (
        "inb %1, %0"
        : "=a"(result)
        : "Nd"(port)
    );
    return result;
}

#endif /* __IO__ */
