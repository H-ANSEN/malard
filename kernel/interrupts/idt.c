#include <stdint.h>

/** IA-32 intel architecture reserves interrupt vectors 0-31 leaving the 
 * remaining 32-255 for `user` defined interrupts */
#define IDT_SIZE 0x100

/** 
 * An interrupt descriptor defines 3 major rules for a single interrupt:
 *   1. Who handles a given interrupt
 *   2. CPU privilege levels of a given interrupt (ignored by HW interrupts)
 *   3. How an interrupt is served and recovered from 
 *
 * The case of who handles the given interrupt is set by a 32-bit address of a
 * function capiable of handling the interrupt. This address is split into two
 * 16-bit fields `offset_low` and `offset_high`.
 *
 * CPU privilege levels are set in the `flags` byte where the handler can be 
 * enabled and disabled with the present bit `p`, the privilege level can be set
 * with the 2-bit `DPL`, and the size of the gate can be set with the `D` bit.
 *
 * How an interrupt is served and recovered from is determined by the `gate 
 * type` (also set in the `flags` byte). There are three kinds of gates:
 *   1. TRAP GATE 
 *   A trap gate should be used to handle exceptions. In a trap gate the address 
 *   of the currently executing instruction is stored. This allows any execption 
 *   to be handled and for the executing instruction to be tried again. 
 *   Additionally, while handling an exception in a trap gate it is still 
 *   possible to recieve interrupts!
 *   2. INTERRUPT GATE  
 *   A interrupt gate is used to specify a ISR, in this gate the address of the 
 *   next instruction to execute is stored. Additionally, all interrupts are
 *   disabled
 *   3. TASK GATE
 *   A task gate is for hardware task switching and will be irrelevant to this
 *   OS so we can ignore it :)
 */
struct idt_descriptor_t {
    uint16_t offset_low;       /* low 16-bits of ISR entry point address      */
    uint16_t segment_selector; /* must point to a vaild 'code' segment in GDT */
    uint8_t zero;              /* unused/reserved byte                        */
    uint8_t flags;             /* flags P, DPL, gate type                     */
    uint16_t offset_high;      /* high 16-bits of ISR entry point address     */
} __attribute__((packed));

/**
 * Structure to be stored in the IDTR register providing the cpu with 
 * information on where the IDT is stored and its size
 */
struct idtr_t {
    uint16_t limit; /* the size of the IDT in bytes minus one */
    uintptr_t base; /* base address of the IDT                */
} __attribute__((packed)) idtr;

/** per IA-32 dev manual the base address of the IDT should be aligned on an
 * 8-byte boundry to maximize preformance of cache line fills */
static struct idt_descriptor_t _idt[IDT_SIZE] __attribute__((aligned(0x8)));
static struct idtr_t _idt_r;



static void _idt_load(struct idtr_t *idt_r);

void idt_init(void) {
    _idt_r.base = (uintptr_t)&_idt[0];
    _idt_r.limit = (uint16_t)sizeof(struct idt_descriptor_t) * IDT_SIZE - 1;
    _idt_load(&_idt_r);
}

void idt_set_descriptor(uint8_t vector, uintptr_t isr, uint8_t flags) {
    struct idt_descriptor_t *desc = &_idt[vector];
    desc->offset_low = isr & 0xFFFF;
    desc->offset_high = isr >> 16;
    desc->segment_selector = 0;
    desc->flags = flags;
    desc->zero = 0;
}

static inline void _idt_load(struct idtr_t *idt_r) {
    asm volatile (
        "lidt %0"
        :
        :
        "m"(*idt_r)
    );
}
