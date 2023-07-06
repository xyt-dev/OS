header:
    program_length dd program_end - program_start
    start_addr dd program_start
; -------------- 文件头结束 --------------
body:
program_start:
    mov ax, 0x1234
    jmp $
program_end:
