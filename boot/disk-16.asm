%ifndef __DISK16_ASM__
%define __DISK16_ASM__

%define READ_SECTOR 0x02
%define INT_DISK 0x13

%include "print-16.asm"



; *****************************************************************************
; read_n_sectors 
; Reads n sectors from the disk into memory. 
;
; Parameters:
;   'dh' - number of sectors to read into memory 
;   'dl' - drive number to read from
;   'es:bx' - memory address to read sectors into
; *****************************************************************************
read_n_sectors:
    push dx      ; store number of sectors to read on the stack

    mov al, dh   ; number of sectors to read

    ; set up CHS scheme for reading
    mov ch, 0x00 ; reading on (C)ylinder 0
    mov dh, 0x00 ; reading using (H)ead 0
    mov cl, 0x02 ; begin reading at (S)ector 2 (our boot sector is at sector 1)

    mov ah, READ_SECTOR ; set parameters for interrupt
    int INT_DISK        ; call BIOS interrupt for low-level disk read

    jc .disk_read_error ; if carry flag is set, an error occurred while reading

    pop dx              ; restore number of sectors to read
    cmp dh, al          ; compare number of sectors read to number requested
    jne .disk_read_error; if not equal an error occurred while reading
    ret                 ; otherwise return

    .disk_read_error:
        mov bx, DISK_ERROR_MSG ; load error message for print string call
        call print_string_16   ; print error message 
        call print_hex_16      ; print error code
        jmp $                  ; infinite loop on error

    ; Data
    DISK_ERROR_MSG: db "DISK READ ERROR: 0x", 0

%endif ; __DISK16_ASM__
