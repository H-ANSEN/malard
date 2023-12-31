;
; This is the entry point of the kernel whose job it is to ensure that the 
; kernels 'main' function is the first kernel code to execute.
;
; The bootloader transfers execution to the kernel by jumping to the address at 
; which the kernel was loaded to in memory. We cannot ensure that the 'main' 
; function of the kernel will always reside at this address, so the following 
; code is linked to the start of the kernel binary and will be the first bit of
; 'kernel' code that executes.
;
[bits 32]      ; Translate this code as 32-bit instructions
[extern kmain] ; decleare the kernel main function as an external symbol so the
               ; linker can correctly resolve addresses

call kmain     ; invoke the kernel main function

jmp $          ; infinite loop if/when the kernel returns
