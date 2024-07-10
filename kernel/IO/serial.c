#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "serial.h"
#include "io.h"

/* the following four regsisters share the same address space and can be 
 * switched between by toggling the divisor latch access bit (DLAB) which is the
 * seventh bit of the line control register */
#define REG_DATA_BUF(com_port)          ((com_port) + 0) /* DLAB must be 0 */
#define REG_INTERRUPT_ENABLE(com_port)  ((com_port) + 1) /* DLAB must be 0 */
#define REG_BAUD_DIVISOR_LOW(com_port)  ((com_port) + 0) /* DLAB must be 1 */
#define REG_BAUD_DIVISOR_HIGH(com_port) ((com_port) + 1) /* DLAB must be 1 */

#define REG_INTERRUPT_IDENT(com_port) ((com_port) + 2) /* read  */
#define REG_FIFO_CTRL(com_port)       ((com_port) + 2) /* write */
#define REG_LINE_CTRL(com_port)       ((com_port) + 3)
#define REG_MODEM_CTRL(com_port)      ((com_port) + 4)
#define REG_LINE_STAT(com_port)       ((com_port) + 5)
#define REG_MODEM_STAT(com_port)      ((com_port) + 6)
#define REG_SCRATCH(com_port)         ((com_port) + 7)

#define LINE_CTRL_DLAB 0x80

static void _com_set_divisor(uint16_t com, uint16_t divisor);
static bool _com_test_write(uint16_t com);

bool serial_init(uint16_t com) {
    outb(REG_INTERRUPT_ENABLE(com), 0x00); /* disable interrupts             */
    _com_set_divisor(com, 0x03);           /* set baud rate to 38400         */
    outb(REG_LINE_CTRL(com), 0x03);        /* 8bits, no parity, one stop bit */
    outb(REG_FIFO_CTRL(com), 0xC7);        /* enable fifo, clear bufs, 14int */
    outb(REG_MODEM_CTRL(com), 0x0B);       /* IRQ enable, RTS/DSR set        */

    return _com_test_write(com);
}

void serial_write(uint16_t com, const char *data) {
    while (*data != '\0') {
        /* wait for transmitter holding register to empty */
        while ((inb(REG_LINE_STAT(com)) & 0x20) == 0);
        outb(REG_DATA_BUF(com), *data);
        data++;
    }
}

size_t serial_read(uint16_t com, char *buffer, size_t length) {
    size_t count = 0;
    while (count < length) {
        /* check if there is data available to read */    
        if (inb(REG_LINE_STAT(com)) & 0x01) {
            buffer[count] = inb(REG_DATA_BUF(com));
            count++;
        }
    }
    return count;
}

static void _com_set_divisor(uint16_t com, uint16_t divisor) {
    uint8_t divisor_high_byte = (divisor >> 8) & 0x00FF;
    uint8_t divisor_low_byte = divisor & 0x00FF;
    uint8_t line_control = inb(REG_LINE_CTRL(com));

    line_control |= LINE_CTRL_DLAB; /* enable DLAB */
    outb(REG_LINE_CTRL(com), line_control); 
    outb(REG_BAUD_DIVISOR_LOW(com), divisor_low_byte);
    outb(REG_BAUD_DIVISOR_HIGH(com), divisor_high_byte);

    line_control &= ~LINE_CTRL_DLAB; /* disable DLAB */
    outb(REG_LINE_CTRL(com), line_control);
}

static bool _com_test_write(uint16_t com) {
    outb(REG_SCRATCH(com), 0xAE);
    uint8_t retuned_value = inb(REG_SCRATCH(com));
    return (retuned_value == 0xAE);
}
