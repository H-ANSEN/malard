%ifndef __PRINT32_ASM__
%define __PRINT32_ASM__

;
; 32-bit protected mode functions for printing to the screen.
;
[bits 32]

%define VIDEO_MEM 0xb8000 ; starting address of VGA text mode memory block
%define WHITE_BLACK 0x0f  ; white text on black background


; *****************************************************************************
; print_string_32
; Prints a null-terminted string to the screen using VGA memory. This function 
; is meant to only be called from 32-bit protected mode.
; 
; Parameters:
;    'ebx' - pointer to the string to be printed
; *****************************************************************************
print_string_32:
    pusha               ; save all registers on the stack
    mov edx, VIDEO_MEM  ; set edx to the starting address of the video memory
    mov ah, WHITE_BLACK ; set ah to the attribute byte

    .print_loop:
        mov al, [ebx]   ; move the character to be printed into al
        cmp al, 0       ; see if the character is null
        je .print_done  ; if the character is null, we're done

        mov [edx], ax   ; mov char and attrib into VGA memory to display
        add ebx, 1      ; increment string pointer to point to the next char
        add edx, 2      ; increment video memory pointer to next character cell

        jmp .print_loop ; jump back to print the next character

    .print_done:
        popa            ; restore all registers from the stack
        ret             ; return to the calling function

%endif ; __PRINT32_ASM__
