#ifndef __SERIAL__
#define __SERIAL__

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#define COM_PORT_1 0x3F8
#define COM_PORT_2 0x2F8

bool serial_init(uint16_t com);
void serial_write(uint16_t com, const char *data);
size_t serial_read(uint16_t com, char *buffer, size_t length);

#endif /* __SERIAL__ */
