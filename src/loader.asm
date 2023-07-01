%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
    LOADER_STACK_TOP equ LOADER_BASE_ADDR
    jmp loader_start

    ; ------ OLD LOADER ------
    ; mov ax, 0x0600
    ; mov bx, 0x0700
    ; mov cx, 0
    ; mov dx, 0x184f  ; (79, 24)
    ; int 0x10
    ;
    ; mov byte [gs:0x00], '2'
    ; mov byte [gs:0x01], 0xA4
    ; mov byte [gs:0x02], '.'
    ; mov byte [gs:0x03], 0xA4
    ; mov byte [gs:0x04], 'L'
    ; mov byte [gs:0x05], 0xA4
    ; mov byte [gs:0x06], 'O'
    ; mov byte [gs:0x07], 0xA4
    ; mov byte [gs:0x08], 'A'
    ; mov byte [gs:0x09], 0xA4
    ; mov byte [gs:0x0A], 'D'
    ; mov byte [gs:0x0B], 0xA4
    ; mov byte [gs:0x0C], 'E'
    ; mov byte [gs:0x0D], 0xA4
    ; mov byte [gs:0x0E], 'R'
    ; mov byte [gs:0x0F], 0xA4
    ;
    ; jmp $
    ; -----------------------

    GDT_BASE:
        dd 0x00000000
        dd 0x00000000
    CODE_DESC:
        dd 0x0000ffff
        dd DESK_CODE_HIGH4
    DATA_STACK_DECK:
        dd 0x0000ffff
        dd DESK_DATA_HIGH4
    VIDEO_DESC:
        dd 0x80000007
        dd DESK_VIDEO_HIGH4
    GDT_SIZE equ $ - GDT_BASE
    GDT_LIMIT equ GDT_SIZE - 1

    times 60 dq 0 ; 预留60个段描述符位置
    
    SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
    SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0 
    SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

    gdt_ptr: 
        dw GDT_LIMIT
        dd GDT_BASE

    loader_msg db "REAL LOADER."
    msg_length equ $ - loader_msg

loader_start:

;------------------------------------------------------------
; INT Ox1O 功能号： Ox13 功能描述：打印字符串
;------------------------------------------------------------
;输入：
;AH 子功能号＝ 13H
;BH ＝页码
;BL ＝属性（若AL=OOH 或OlH)
;CX＝字符串长度
; (DH 、DL ）＝坐标｛行、列）
;ES:BP＝字符串地址
;AL＝显示输出方式
; 0一一字符串中只含显示字符，其显示属性在BL 中
;   显示后，光标位置不变
; 1一一字符串中只含显示字符，其显示属性在BL 中
;   显示后，光标位置改变
; 2一一字符事中含显示字符和显示属性。显示后，光标位置不变
; 3一一字符串中含显示字符和显示属性。显示后，光标位置改变的J 无返回值

    mov sp, LOADER_BASE_ADDR
    mov bp, loader_msg
    mov cx, 12
    mov ax, 0x1301
    mov bx, 0x001f  ; 页码为0，属性为蓝底白字（BL = 1fh）
    mov dx, 0x1800
    int 0x10
            
; -------------------------- 进入保护模式 --------------------------------
; 1. 打开A20
; 2. 加载GDT
; 3. CR0置PE位为1
; ------------------------------------------------------------------------

;   ------ 打开A20 ------
    in al, 0x92
    or al, 0x02 ; 0000_0010B
    out 0x92, al

    ; ; ------ 加载GDT ------
    lgdt [gdt_ptr]

    ; ; ------ CR0置PE位为1 ------
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:0x160], 'P'

    jmp $
