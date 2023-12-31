[org 0x7c00] ; tell the assembler where the BIOS loads this code
[bits 16]    ; tell the assembler to use 16 bit mode

KERNEL_OFFSET equ 0x1000 ; memory offset where the kernel is loaded

mov [BOOT_DRIVE], dl     ; store the boot drive number in a global variable

mov bp, 0x9000           ; set the base of the stack at 0x9000
mov sp, bp               ; set stack pointer to base of the stack 

mov bx, MSG_REAL_MODE    ; set the message to print to the real mode message
call print_string_16     ; call our print routine

call load_kernel         ; call our routine to load the kernel into memory
call switch_to_pm        ; switch to 32-bit protected mode, this routine should 
                         ; never return

jmp $                    ; infinite loop to ensure random code is not exectued



; *****************************************************************************
; load_kernel
; Loads the kernel from the disk into memory
;
; *****************************************************************************
load_kernel:
    mov bx, MSG_LOAD_KERNEL ; set info message to print
    call print_string_16    ; call our print routine

    mov bx, KERNEL_OFFSET   ; Set parameters for 'read_n_sectors' routine call,
    mov dh, 16              ; we read 15 sectors from the boot dirve to the 
    mov dl, [BOOT_DRIVE]    ; memory address 'KERNEL_OFFSET'
    call read_n_sectors     ; call our routine to read sectors

    ret                     ; return control to caller



; *****************************************************************************
; switch_to_pm
; Switches the CPU into protected mode, and jumps to the 32-bit code segment 
; disabling all real-mode interrupts.
;
; *****************************************************************************
switch_to_pm:
    cli                   ; disable interrupts
    lgdt [gdt_descriptor] ; load the GDT descriptor into the GDTR register

    mov eax, cr0          ; get the value of the control register 'cr0'
    or eax, 0x1           ; set the first bit of the control register 'cr0'
    mov cr0, eax          ; set the value of the control register 'cr0'

    ;
    ; Jump to 32-bit code segment. This also casuses a flush of any prefeched 
    ; instructions in the pipeline which could be 16-bit instructions 
    ; disallowed once we make the switch to protected mode. 
    ;
    jmp GDT_CODE_SEGMENT:initialize_prot_mode



; *****************************************************************************
; initialize_prot_mode
; This routine is where execution in 32-bit protected mode begins after the 
; switch has been made from 16-bit real mode using routine 'switch_to_pm". This
; routine sets up registers and the stack and then transfers execution to 
; kernel code.
;
; *****************************************************************************
[bits 32]

initialize_prot_mode:
    mov ax, GDT_DATA_SEGMENT ; point all segment registers to the data segment
    mov ds, ax               ; defined in the GDT
    mov ss, ax           
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000         ; set the base of the stack to 0x90000
    mov esp, ebp             ; set the stack pointer to the base of the stack

    mov ebx, MSG_PROT_MODE
    call print_string_32

    call KERNEL_OFFSET       ; jump to the address of the kernel that has been 
                             ; loaded into memory. This should not return

    jmp $                    ; infinite loop to ensure random code is not run



; *****************************************************************************
; global variables and helper functions 
;
; *****************************************************************************
%include "disk-16.asm"
%include "print-16.asm"
%include "print-32.asm"
%include "gdt.asm"


;
; Global variables and data
;
BOOT_DRIVE: db 0x0
MSG_LOAD_KERNEL: db "Loading kernel into memory.", 0x0D, 0xA, 0x0
MSG_REAL_MODE: db "Successfully started in 16-bit real mode.", 0x0D, 0xA, 0x0
MSG_INIT_PROT_MODE: db "Initializing protected mode.", 0x0D, 0xA, 0x0
MSG_PROT_MODE: db "Successfully switched to 32-bit protected mode.", 0x0

; Padding and BIOS magic number
times 510-($-$$) db 0 ; pad the bootsector out to 510 bytes
dw 0xaa55             ; define the magic BIOS number
