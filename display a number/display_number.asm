; External Windows API functions
extern WriteFile       ; Used to write output to console
extern GetStdHandle   ; Gets standard input/output handle
extern ExitProcess    ; Terminates the program

section .data
    ; Message to display before the number
    msg db 'The number is: '
    msg_len equ $ - msg  ; Calculate message length automatically
    
    ; The number to be displayed (64-bit integer)
    x dq 98786424326
    
    ; Buffer to store the ASCII digits (20 bytes zero-initialized)
    input_buffer times 20 db 0    
    
    ; Variable to store how many bytes were actually written
    bytes_written dd 0    
    
    ; Standard output handle (64-bit in Windows x64)
    hOut dq 0                ; Correctly sized as 64-bit (dq)
    
    ; Length of the converted number string
    buffer_length dd 0 
    
section .text
global main
main:
    ; Get standard output handle
    mov rcx, -11             ; STD_OUTPUT_HANDLE = -11
    call GetStdHandle
    mov [rel hOut], rax      ; Store 64-bit handle correctly
    
    ; Display the initial message
    mov rcx, [rel hOut]      ; Handle
    lea rdx, [rel msg]       ; Pointer to message
    mov r8d, msg_len         ; Message length
    lea r9, [rel bytes_written] ; Where to store bytes written count
    sub rsp, 40              ; Shadow space + alignment
    mov qword [rsp + 32], 0  ; Reserved parameter (NULL)
    call WriteFile
	add rsp, 40
    
    ; Convert the number to ASCII string (reverse order)
    mov rsi, input_buffer    ; Point to buffer start
    mov rax, [rel x]         ; Load our number
add_in_buffer:
    mov rbx, 10              ; Divisor for base 10 conversion
    xor rdx, rdx             ; Clear upper part of dividend
    div rbx                  ; Divide RAX by 10, remainder in RDX
    add dl, '0'              ; Convert remainder to ASCII digit
    mov [rsi], dl            ; Store digit in buffer
    inc rsi                  ; Move buffer pointer forward
    inc dword [rel buffer_length] ; Increment digit count
    test rax, rax            ; Check if quotient is zero
    jnz add_in_buffer        ; Continue if not zero
    
    ; Reverse the string to get correct order
    mov rsi, 0               ; Start index
    mov edi, [rel buffer_length] ; End index (length - 1)
    dec rdi
    lea rbx, [rel input_buffer] ; Buffer address
reverse:
    mov al, [rbx + rsi]      ; Get character from start
    mov cl, [rbx + rdi]      ; Get character from end
    mov [rbx + rdi], al      ; Swap them
    mov [rbx + rsi], cl
    inc rsi                  ; Move start forward
    dec rdi                  ; Move end backward
    cmp rsi, rdi             ; Check if we've met in middle
    jl reverse; Continue if not done
    
    ; Display the converted number
    mov rcx, [rel hOut]      ; Standard output handle
    lea rdx, [rel input_buffer] ; Pointer to number string
    mov r8d, [rel buffer_length] ; Length of number string
    lea r9, [rel bytes_written] ; Bytes written count
    sub rsp, 40              ; Shadow space + alignment
    mov qword [rsp + 32], 0  ; Reserved parameter (NULL)
    call WriteFile
	add rsp, 40
   
    mov rcx, 0               ; Exit code (0 = success)
    call ExitProcess