; nasm
; linux
section MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

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

; 获取光标位置
; 功能号0x03： 获取光标位置
    mov ah, 0x03
    mov bh, 0 ; 默认页号
    int 0x10
; 输出: dh = 光标所在行， dl = 光标所在列
    
; 打印字符串
    mov ax, message
    mov bp, ax
    mov cx, 10
    mov ax, 0x1301
    mov bx, 0x3 ; 绿色 bh: 页号  bl: 字符颜色
    int 0x10


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