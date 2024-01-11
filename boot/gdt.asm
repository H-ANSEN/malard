;
; The Global Descriptor Table (GDT) is a data structure conaining entries that
; describe memory segments for the CPU. The GDT is loaded into the GDTR 
; register using the LGDT assembly instruction. Each entry in the GDT has a 
; length of 8 bytes. Each entry in the GDT is called a descriptor sense an 
; entry exists to describe the attributes of a segment of memory.
;
[bits 16]


gdt_start: ; starting address of the GDT --------------------------------------


; 
; The first entry in the GDT should always be NULL and NEVER contain any data.
; The purpose of this entry is help with error checking in the case that  
; a segment register is loaded with a NULL selector.
;
gdt_null_descriptor:
    dd 0x0
    dd 0x0



gdt_code_segment:
    dw 0xffff     ; segment size (bits 0-15)
    dw 0x0        ; base address (bits 0-15)
    db 0x0        ; base address (bits 16-23)

    ; access byte (described left to right)
    ; 
    ; bit 7:   present bit (present in memory?) (1 = yes, 0 = no)
    ; bit 6-5: privilege level (0 = highest, 3 = lowest)
    ; bit 4:   descriptor type (0 = system, 1 = code or data)
    ; bit 3-0: segment type (0b1010 = code segment)
    db 0b10011010 

    ; flags (described left to right)
    ;
    ; bit 7:   granularity (0 = 1 byte, 1 = 1kbyte) 4GB of mem
    ; bit 6:   operand size (0 = 16 bit, 1 = 32 bit)
    ; bit 5:   64-bit code segment (0 = no, 1 = yes)  
    ; bit 4:   available for use by system software
    ; bit 3-0: segment length (bits 16-19)
    db 0b11001111
    db 0x0        ; base address (bits 24-31)



gdt_data_segment:
    dw 0xffff     ; segment size (bits 0-15)
    dw 0x0        ; base address (bits 0-15)
    db 0x0        ; base address (bits 16-23)

    ; access byte (described left to right)
    ; 
    ; bit 7:   present bit (present in memory?) (1 = yes, 0 = no)
    ; bit 6-5: privilege level (0 = highest, 3 = lowest)
    ; bit 4:   descriptor type (0 = system, 1 = code or data)
    ; bit 3-0: segment type (0b0010 = data segment)
    db 0b10010010 

    ; flags (described left to right)
    ;
    ; bit 7:   granularity (0 = 1 byte, 1 = 1kbyte) 4GB of mem
    ; bit 6:   operand size (0 = 16 bit, 1 = 32 bit)
    ; bit 5:   64-bit code segment (0 = no, 1 = yes)  
    ; bit 4:   available for use by system software
    ; bit 3-0: segment length (bits 16-19)
    db 0b11001111
    db 0x0        ; base address (bits 24-31)


gdt_end: ; ending address of the GDT ------------------------------------------


;
; The GDT descriptor is a data structure that describes the GDT defined above, 
; and is what is loaded into the GDTR register. The GDT descriptor is 6 bytes
; long and defined as follows:
;   - 16-bit limit (bits 0-15)
;   - 32-bit base address (bits 0-31)
;
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size of the GDT
    dd gdt_start               ; starting address of the GDT


GDT_CODE_SEGMENT equ gdt_code_segment - gdt_start
GDT_DATA_SEGMENT equ gdt_data_segment - gdt_start
