%include "boot.inc"
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

    mov eax, LOADER_START_SECTOR    ;起始扇区LBA地址
    mov bx, LOADER_BASE_ADDR        ;写入的内存地址
    ;mov cx, 1                      ;读取扇区数
    mov cx, 4                       ;(变动)改为4个扇区
    call rd_disk_m_16               ;以下读取程序的起始部分

    jmp LOADER_BASE_ADDR + 0x300    ;跳转到程序的起始部分 -> 改为跳转到loader_start

rd_disk_m_16:
; 读取硬盘n个扇区
; eax = LBA扇区号
; cx = 读入的扇区数

    mov esi, eax                    ;备份eax
    mov di, cx                      ;备份cx

; 1.设置读取扇区数
    mov dx, 0x1F2
    mov al, cl
    out dx, al
    mov eax, esi                    ;恢复eax

; 2.将LBA地址存入0x1F3 ~ 0x1F6
    mov dx, 0x1F3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1F4
    out dx, al

    shr eax, cl
    mov dx, 0x1F5
    out dx, al

    shr eax, cl
    and al, 0x0F
    or al, 0xE0         ;高4位设置为1110,第5位和第7位固定为1,第6位0表示CHS模式,为1表示LBA模式
    mov dx, 0x1F6
    out dx, al

; 3.向0x1f7端口写入读命令0x20
    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

; 4.检测硬盘状态
    .not_ready:
        nop
        nop
        nop             ;小延迟
        in al, dx
        and al, 0x88    ;第3位：是否准备好数据传送 第7位：是否忙
        cmp al, 0x08
        jnz .not_ready


; 5.从0x1f0端口读取数据
    mov ax, di
    mov dx, 256        ;一次读一个字(16位)，一个扇区512字节，要读256次
    mul dx
    mov cx, ax
    mov dx, 0x1F0

    .go_on_read:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop .go_on_read
        ret


times 510-($-$$) db 0
db 0x55, 0xAA
