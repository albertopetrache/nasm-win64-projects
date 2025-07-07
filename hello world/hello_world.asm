global main                ; Declare the main function as global (entry point)

extern GetStdHandle        ; Import Windows API function: GetStdHandle
extern WriteFile           ; Import Windows API function: WriteFile
extern ExitProcess         ; Import Windows API function: ExitProcess

section .data
    message db 'Hello, World!', 13, 10    ; The message string with CR+LF (carriage return + line feed)
    message_len equ $ - message            ; Calculate length of the message string
    bytes_written dq 0                     ; Reserve 8 bytes to store number of bytes written by WriteFile (64-bit)
    hOut dq 0                             ; Reserve 8 bytes to store the console output handle

section .text
main:
    ; Get handle to the standard output (console)
    mov rcx, -11                          ; STD_OUTPUT_HANDLE = -11, put into RCX (1st parameter)
    call GetStdHandle                    ; Call GetStdHandle, returns handle in RAX
    mov [rel hOut], rax                  ; Save the returned handle into hOut variable

    ; Prepare parameters to call WriteFile
    mov rcx, [rel hOut]                  ; HANDLE hFile (console handle) in RCX (1st parameter)
    lea rdx, [rel message]               ; Pointer to the message buffer in RDX (2nd parameter)
    mov r8d, message_len                 ; Number of bytes to write in R8D (lower 32 bits of R8) (3rd parameter)
    lea r9, [rel bytes_written]          ; Pointer to bytes_written variable in R9 (4th parameter)

    sub rsp, 40                         ; Allocate 32 bytes shadow space + 8 bytes stack alignment
    mov qword [rsp+32], 0               ; lpOverlapped = NULL (5th parameter), stored on the stack after shadow space

    call WriteFile                      ; Call WriteFile API

    add rsp, 40                        ; Clean up the stack after the call

    ; Exit the process with exit code 0
    mov rcx, 0                         ; Exit code 0 in RCX (1st parameter)
    call ExitProcess                   ; Call ExitProcess API
