[org 0x7c00] ; tell the assembler where the BIOS loads this code

mov bp, 0x8000 ; set the base of the stack at 0x8000
mov sp, bp     ; set stack pointer to base of the stack (sp grows downwards)

mov ax, 0x1234
call print_hex

jmp $ ; jump to current address (infinite loop) needed to prevent the CPU from 
      ; executing our data and the magic number as instructions

%include "print.asm"

;
; Data section (strings, constants, etc.)
;
HELLO_MSG: db "Hello, World!", 0
GOODBYE_MSG: db "Goodbye, World!", 0

;
; Padding and BIOS magic number
;
times 510-($-$$) db 0 ; pad the bootsector out to 510 bytes
dw 0xaa55             ; define the magic BIOS number
