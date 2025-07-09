global main                      ; Entry point of the program

extern GetStdHandle             ; Import GetStdHandle from kernel32.dll
extern ReadFile                 ; Import ReadFile
extern WriteFile                ; Import WriteFile
extern ExitProcess              ; Import ExitProcess

section .data
    msg db 'Enter text: '               ; Prompt message for user input
    msg_len equ $ - msg                 ; Length of the prompt message

    input_buffer times 100 db 0         ; Buffer to hold user input (max 100 bytes)
    input_len       dq 0                ; Number of bytes actually read
    bytes_written   dq 0                ; Number of bytes written to the console
    hIn             dq 0                ; Handle for standard input
    hOut            dq 0                ; Handle for standard output

section .text
main:
    ; === Get handle to standard input (STD_INPUT_HANDLE = -10)
    mov rcx, -10
    call GetStdHandle
    mov [rel hIn], rax

    ; === Get handle to standard output (STD_OUTPUT_HANDLE = -11)
    mov rcx, -11
    call GetStdHandle
    mov [rel hOut], rax

    ; === Display the prompt message to the console
    mov rcx, [rel hOut]                 ; HANDLE hFile
    lea rdx, [rel msg]                  ; LPCVOID lpBuffer (pointer to message)
    mov r8d, msg_len                    ; DWORD nNumberOfBytesToWrite
    lea r9, [rel bytes_written]         ; LPDWORD lpNumberOfBytesWritten
    sub rsp, 40                         ; Allocate shadow space
    mov qword [rsp + 32], 0            ; lpOverlapped = NULL
    call WriteFile
    add rsp, 40                         ; Restore stack

    ; === Read input from keyboard
    mov rcx, [rel hIn]                  ; HANDLE hFile
    lea rdx, [rel input_buffer]         ; LPVOID lpBuffer
    mov r8d, 100                        ; DWORD nNumberOfBytesToRead
    lea r9, [rel input_len]             ; LPDWORD lpNumberOfBytesRead
    sub rsp, 40                         ; Allocate shadow space
    mov qword [rsp + 32], 0            ; lpOverlapped = NULL
    call ReadFile
    add rsp, 40                         ; Restore stack

    ; === Convert lowercase letters (a–z) to uppercase (A–Z)
    lea rsi, [rel input_buffer]         ; Pointer to start of input
    mov rcx, [rel input_len]            ; Loop counter = number of bytes read

.convert_loop:
    mov al, [rsi]                       ; Load current character
    cmp al, 'a'                         ; Check if >= 'a'
    jb .no_change
    cmp al, 'z'                         ; Check if <= 'z'
    ja .no_change
    sub al, 32                          ; Convert to uppercase (A = a - 32)
.no_change:
    mov [rsi], al                       ; Store (possibly changed) character
    inc rsi                             ; Move to next character
    dec rcx                             ; Decrement counter
    jnz .convert_loop                   ; Repeat until all characters processed

    ; === Output the converted text to the console
    mov rcx, [rel hOut]                 ; HANDLE hFile
    lea rdx, [rel input_buffer]         ; LPCVOID lpBuffer
    mov r8d, dword [rel input_len]      ; DWORD nNumberOfBytesToWrite
    lea r9, [rel bytes_written]         ; LPDWORD lpNumberOfBytesWritten
    sub rsp, 40                         ; Allocate shadow space
    mov qword [rsp + 32], 0            ; lpOverlapped = NULL
    call WriteFile
    add rsp, 40                         ; Restore stack

    ; === Exit the process with exit code 0
    mov rcx, 0
    call ExitProcess
