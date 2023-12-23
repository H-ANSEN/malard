;
; For information on interrupts and there modes see:
; https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table
;
%define TTY_MODE 0x0e  ; tty mode for BIOS interrupt 0x10
%define INT_VIDEO 0x10 ; BIOS interrupt for video services



; *****************************************************************************
; print_string
; Prints a null-terminated string to the screen using BIOS interrupt 0x10. 
; 
; Parameters:
;     'bx' - pointer to a null-terminated string to print.
; *****************************************************************************
print_string:
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
; print_hex
; Prints a 16-bit number in hex to the screen using BIOS interrupt 0x10.
;
; Parameters:
;     'ax' - the number to print in hex
; *****************************************************************************
print_hex:
    pusha              ; push all registers to the stack
    mov bx, 16         ; divisor for hex conversion
    mov cx, 1028       ; counter (4 for low and 4 for high nibble of 'cx')

    .hex_loop:
        div bx             ; divide 'ax' by 16 (remainder goes to 'dx')
        push word dx       ; push remainder to the stack
        dec cl             ; decrement 'cx' to count down to 0
        jnz .hex_loop      ; jump to '.done' if 'ax' is zero

    .hex_print:
        pop ax             ; pop a hex digit from the stack into 'ax' 
        add al, 48
        mov ah, TTY_MODE   ; indicate tty mode as video service
        int INT_VIDEO
        dec ch
        jnz .hex_print

    .done:
        popa 
        ret
