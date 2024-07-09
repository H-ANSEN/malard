#ifndef __IDT__
#define __IDT__

#include <stdint.h>

/*
 * Masks for the `flags` byte of `idt_set_descriptor` see section 5.11 for info
 */
#define INT_FLAG_P    0xF /* 1-bit segment present used to enable/disable ISR */
#define INT_FLAG_DPL  0xD /* 2-bit descriptor privilege level (0,1,2,3)       */
#define INT_FLAG_TYPE 0x8 /* 5-bit value indicating gate size and type        */


/*
 * ISR types to be used with the `INT_FLAG_TYPE` mask to set the gate type in a
 * call to `idt_set_descriptor`
 */
#define INT_TYPE_TASK_GATE    0x5 /* ISR is a task gate             */
#define INT_TYPE_INT_GATE_16  0x6 /* ISR is a 16-bit interrupt gate */
#define INT_TYPE_TRAP_GATE_16 0x7 /* ISR is a 16-bit trap gate      */
#define INT_TYPE_INT_GATE_32  0xE /* ISR is a 32-bit interrupt gate */
#define INT_TYPE_TRAP_GATE_32 0xF /* ISR is a 32-bit trap gate      */


struct register_state {
    uint32_t edi; /* destination index               */
    uint32_t esi; /* source index                    */
    uint32_t ebp; /* frame pointer                   */
    uint32_t esp; /* stack pointer                   */
    uint32_t ebx; /* general purpose data register B */
    uint32_t edx; /* general purpose data register D */
    uint32_t ecx; /* general purpose data register C */
    uint32_t eax; /* general purpose data register A */
} __attribute__((packed));

struct interrupt_frame {
    uint32_t eip;        /* address realative to `cs` of an instruction */
    uint32_t cs;         /* address of the code segment                 */
    uint32_t eflags;     /* Section 2.3 System Flags and Fields         */
    struct register_state registers;
} __attribute__((packed));


void idt_init(void);
void idt_set_descriptor(uint8_t vector, void *isr, uint8_t flags);

#endif /* __IDT__ */
