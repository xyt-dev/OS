; print helloword in nasm
; 2017-10-10
; x86_64

global _start

section .data
    msg db "Hello, World!", 0x0a
    len equ $ - msg

section .text
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

