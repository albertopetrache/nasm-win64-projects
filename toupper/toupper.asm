global main

extern GetStdHandle
extern WriteFile
extern ExitProcess

section .data
	message db "Hello, World!", 13, 10        ; Message to print (with newline)
	message_len equ $ - message               ; Calculate message length
	bytes_written dq 0                        ; Reserve 8 bytes to store number of bytes written
	hOut dq 0                                 ; Reserve 8 bytes for the handle to stdout

section .text
main:
	mov rcx, -11                              ; STD_OUTPUT_HANDLE = -11
	call GetStdHandle                         ; Call WinAPI to get handle to standard output
	mov [rel hOut], rax                       ; Store returned handle in hOut

	mov rcx, message_len                      ; RCX = number of characters to process
	mov rsi, message                          ; RSI = pointer to start of message
convert:
	mov al, [rsi]                             ; Load current character
	cmp al, 'a'                               ; If char < 'a'
	jb no_change                              ;   skip conversion
	cmp al, 'z'                               ; If char > 'z'
	ja no_change                              ;   skip conversion
	sub al, 32                                ; Convert lowercase to uppercase
no_change:
	mov [rsi], al                             ; Store possibly modified char back
	inc rsi                                   ; Move to next character
	dec rcx                                   ; Decrement loop counter
	cmp rcx, 0                                ; Are we done?
	jnz convert                               ; If not, repeat

	; Prepare arguments for WriteFile(
	;     HANDLE hFile = hOut,
	;     LPCVOID lpBuffer = message,
	;     DWORD nNumberOfBytesToWrite = message_len,
	;     LPDWORD lpNumberOfBytesWritten = &bytes_written,
	;     LPOVERLAPPED lpOverlapped = NULL
	; )
	mov rcx, [rel hOut]                       ; First param: handle to stdout
	lea rdx, [rel message]                    ; Second param: pointer to message
	mov r8d, message_len                      ; Third param: length of message (DWORD)
	lea r9, [rel bytes_written]              ; Fourth param: pointer to bytes_written

	sub rsp, 40                               ; Shadow space for Windows x64 calling convention
	mov qword [rsp + 32], 0                   ; Fifth param (lpOverlapped) = NULL
	call WriteFile                            ; Call WinAPI WriteFile

	add rsp, 40                               ; Restore stack (cleanup shadow space)

	mov rcx, 0                                ; Exit code = 0
	call ExitProcess                          ; Call ExitProcess(0) to terminate program
