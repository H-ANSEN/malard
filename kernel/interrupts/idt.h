#ifndef __IDT__
#define __IDT__

#include <stdint.h>

#define INT_FLAG_P    0xF
#define INT_FLAG_DPL  0xD
#define INT_FLAG_D    0xB
#define INT_FLAG_TYPE 0x8

#define INT_TYPE_TASK_GATE 0x5
#define INT_TYPE_INT_GATE_16  0x6
#define INT_TYPE_TRAP_GATE_16 0x7
#define INT_TYPE_INT_GATE_32  0xE
#define INT_TYPE_TRAP_GATE_32 0xF

struct interrupt_frame {
    uint32_t error_code; /* error code used when exception condition is */
                         /* related to a specific segment               */

    uint32_t eip;        /* address realative to `cs` of an instruction */
    uint32_t cs;         /* address of the code segment                 */
    uint32_t eflags;     /* Section 2.3 System Flags and Fields         */
} __attribute__((packed));



void idt_init(void);
void idt_set_descriptor(uint8_t vector, void *isr, uint8_t flags);

#endif /* __IDT__ */
