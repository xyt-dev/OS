; nasm
; linux
section MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

; 显存位置
    mov ax, 0xb800
    mov gs, ax

; 清屏
; AH: 功能号 0x06
; AL: 上卷行数 (0表示全部)
; BH: 上卷属性
; (CL, CH): 窗口左上角(X, Y)
; (DL, DH): 窗口右下角(X, Y)
    mov ax, 0x0600
    mov bx, 0x0700
    mov cx, 0
    mov dx, 0x184f  ; (79, 24)
    int 0x10

; ; 获取光标位置
; ; 功能号0x03： 获取光标位置
;     mov ah, 0x03
;     mov bh, 0 ; 默认页号
;     int 0x10
; ; 输出: dh = 光标所在行， dl = 光标所在列
    
; ; 打印字符串
;     mov ax, message
;     mov bp, ax
;     mov cx, 10
;     mov ax, 0x1301
;     mov bx, 0x3 ; 绿色 bh: 页号  bl: 字符颜色
;     int 0x10

; 直接向显存打印字符
    mov byte [gs:0], 'H'
    mov byte [gs:1], 0xA4
    mov byte [gs:2], 'e'
    mov byte [gs:3], 0xA4
    mov byte [gs:4], 'l'
    mov byte [gs:5], 0xA4
    mov byte [gs:6], 'l'
    mov byte [gs:7], 0xA4
    mov byte [gs:8], 'o'
    mov byte [gs:9], 0xA4
    mov byte [gs:10], ' '
    mov byte [gs:12], 'M'
    mov byte [gs:13], 0xC1
    mov byte [gs:14], 'B'
    mov byte [gs:15], 0xC1
    mov byte [gs:16], 'R'
    mov byte [gs:17], 0xC1


; 悬挂
    jmp $

    message db "Hello MBR"

; 填充
    times 510-($-$$) db 0

; 引导标记
    db 0x55, 0xaa

; 编译：
; nasm -f bin mbr.asm -o mbr.bin
; 输入：
; dd if=mbr.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc
