%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

    LOADER_STACK_TOP equ LOADER_BASE_ADDR

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

    ; ---------- GDT ----------
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

    ; ---------- selector ----------
    SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
    SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0 
    SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0


; total_mem_bytes 用于保存内存容量，以字节为单位，此位置比较好记
; 当前偏移loader.bin 文件头Ox200 字节
; loader. bin 的加载地址是Ox900
; 故total mem_bytes 内存中的地址是OxbO0(可在bochs中使用 xp 0xb00 检查)
; 将来在内核中咱们会引用此地址
    total_mem_bytes dd 0 ; 4

    gdt_ptr: ; 6
        dw GDT_LIMIT
        dd GDT_BASE
    
    ; 4 + 6 + 244 + 2 = 256 bytes （对齐好看）
    ards_buf times 244 db 0
    ards_nr dw 0

    loader_msg db "REAL LOADER."
    msg_length equ $ - loader_msg

loader_start:

; ------------ int 15h ax = EBOlh 获取内存大小 ------------
; 获取物理内存容量
; int 15h eax = 0000E820h edx = 534D4150h ('SMAP')
    xor ebx, ebx ; 第一次调用 ebx 设置为0
    mov edx, 0x534d4150
    mov di, ards_buf

.e820_mem_get_loop:
    mov eax, 0x0000e820 ; 每次执行int 15h 后eax都会被设置为0x534d4150，需要重新赋值
    mov ecx, 20 ; ARDS 地址范围描述符结构 大小是20字节
    int 0x15
    ; jc .e820_failed_so_try_e801 ; cf为1说明有错误发生，尝试e801功能(暂时不用)
    add di, cx ; di += 20 bytes 指向下一个ARDS结构保存位置
    inc word [ards_nr]
    cmp ebx, 0 ; cf不为1时ebx为0表示这是最后一个ARDS
    jnz .e820_mem_get_loop

; 在所有ards中找出(base_addr_low + length_low)的最大值，即内存容量
    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx, edx ; 用 edx 记录最大内存容量
    
.find_max_mem_area:
    ; 无需判断type，最大内存块一定能被使用(除非安装物理内存极小，否则不会出现较大内存区不可用情况)
    mov eax, [ebx]
    add eax, [ebx + 8] ; 查看内存上限
    add ebx, 20
    cmp edx, eax
    jge .next_ards
    mov edx, eax
.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

.mem_get_ok:
    mov [total_mem_bytes], edx
; 另外两个子功能暂时不用

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
    mov cx, msg_length
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
    ; ---------- 保护模式下的初始化 ----------
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:0x160], 'P'

    ; ---------- 初始化页表 ----------
    call setup_page ; 创建页目录和页表
    sgdt [gdt_ptr] ; 将描述符表地址[47~16]、界限[15~0]存入gdt_ptr
    mov ebx, [gdt_ptr + 2] ; 描述符表基地址
    or dword [ebx + 0x18 + 4], 0xc0000000 ; 视频段是第3个描述符(3 * 8 = 0x18)，给高4字节的最高字节+0xc0
    add dword [gdt_ptr + 2], 0xc0000000 ; 给gdt_ptr的基地址+0xc0000000
    add esp, 0xc0000000 ; 栈指针同样映射到内核地址
    ; 页目录表的地址存入cr3
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax
    ; 打开cr0的PG位(第31位)，开启分页
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [gdt_ptr] ; 用gdt新地址重新加载
    mov byte [gs:0x162], 'V'

    jmp $

; -------------------------- 建立页表 --------------------------------
setup_page:
    ; 页目录占用内存空间逐字节清0
    mov ecx, 4096
    mov esi, 0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

; 创建页目录表(PDE)
.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000 ; 第一个页表位置
    mov ebx, eax ; 为create_pte做准备，ebx为基址
    ; 页目录项0和0xc00都存为第一个页表的地址，每个页表表示4MB内存
    or eax, PG_US_U | PG_RW_W | PG_P ; 第一个页表属性
    mov [PAGE_DIR_TABLE_POS + 0x0], eax
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax ; 0xc00 表示第 768 个页表占用的目录项，0xc00以上目录项属于内核空间(768 * 1024 * 4KB = 3GB，即虚拟内存3GB以上空间为内核空间)
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax ; 最后一个目录项（+4092）指向页目录表自己的地址

; 创建页表(PTE)
    mov ecx, 256 ; 1M低端内存 / 4KB = 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx + esi * 4], edx
    add edx, 4096
    inc esi
    loop .create_pte

; 创建内核其它页表的PDE，提前把内核所有页目录定下来，方便实现内核完全共享
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000 ; 第二个页表位置
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254 ; 范围为第 769 ~ 1022 个目录项
    mov esi, 769
.create_kernel_pde:
    mov [ebx + esi * 4], eax
    inc esi
    add eax, 0x1000 ; 目录项与页表地址顺序对应
    loop .create_kernel_pde
    ret
