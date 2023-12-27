%ifndef __PRINT16_ASM__
%define __PRINT16_ASM__

;
; 16-bit real mode functions for printing to the screen.
;
[bits 16]

;
; For information on interrupts and there modes see:
; https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table
;
%define TTY_MODE 0x0e  ; tty mode for BIOS interrupt 0x10
%define INT_VIDEO 0x10 ; BIOS interrupt for video services



; *****************************************************************************
; print_string_16
; Prints a null-terminated string to the screen using BIOS interrupt 0x10. This
; function is meant to only be called from 16-bit real mode.
; 
; Parameters:
;     'bx' - pointer to a null-terminated string to print.
; *****************************************************************************
print_string_16:
    pusha                ; push all registers to the stack
    mov ah, TTY_MODE     ; indicate tty mode as video service 

    .print_loop:
        mov al, [bx]     ; move the character pointed to by 'bx' into al
        cmp al, 0        ; is 'al' the null character?
        je .done         ; jump to '.done' if whole string has been printed
        int INT_VIDEO    ; otherwise print character in 'al'
        inc bx           ; increment 'bx' to point to next character
        jmp .print_loop  ; loop to print next character

    .done:
        popa             ; restore registers from the stack
        ret              ; return from function




; *****************************************************************************
; print_hex_16
; Prints a 16-bit number in hex to the screen using BIOS interrupt 0x10. This 
; function is meant to only be called from 16-bit real mode.
;
; Parameters:
;     'ax' - the number to print in hexadecimal format.
; *****************************************************************************
print_hex_16:
    pusha                    ; push all registers to the stack
    mov cx, 0x0404           ; counters for loops (ch=4, cl=4)

    .push_remainder:
        mov dx, ax           ; copy register 'ax' to 'dx'
        and dx, 0x000f       ; mask out the last 4 bits
        push dx              ; push the remainder to the stack
        shr ax, 0x4          ; divide by 16
        dec ch               ; decrement the counter
        jnz .push_remainder  ; push remainder and divide again

    .pop_and_print:
        pop ax               ; pop a hex digit from the stack
        cmp ax, 0xA          ; is the digit a number or a letter? 
        jb .is_digit         ; if less than 10, it's a number and we jump
        add al, '7'          ; otherwise, add 7 to get the correct ASCII letter
        jmp .print           ; jump to '.print' to print the letter

    .is_digit:
        add al, '0'          ; add 0 to get the correct ASCII number

    .print:
        mov ah, TTY_MODE     ; indicate tty mode as video service
        int INT_VIDEO        ; print the character in 'al'
        dec cl               ; decrement the counter
        jnz .pop_and_print   ; pop and print the next digit if not zero
        popa                 ; restore registers from the stack
        ret                  ; return from function

%endif ; __PRINT16_ASM__
