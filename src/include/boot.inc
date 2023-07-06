; ----------------- loader & kernel -----------------

LOADER_BASE_ADDR equ 0x900  ;实模式从0x500~0x7BFF都是可用地址,0x900当然也可以a,随意
LOADER_START_SECTOR equ 0x2   ;LBA从0开始,0x1可以用,0x2当然也可以,随意

; ----------------- gdt 描述符属性 ------------------

DESK_G_4K equ           1000_0000_0000_0000_0000_0000b
DESK_D_32 equ            100_0000_0000_0000_0000_0000b
DESK_L equ                00_0000_0000_0000_0000_0000b ; 64位代码标记 设为0即可
DESK_AVL equ               0_0000_0000_0000_0000_0000b
DESK_LIMIT_CODE2 equ         1111_0000_0000_0000_0000b
DESK_LIMIT_DATA2 equ         DESK_LIMIT_CODE2
DESK_LIMIT_VIDEO2 equ        0000_0000_0000_0000_0000b
DESK_P equ                        1000_0000_0000_0000b
DESK_DPL0 equ                      000_0000_0000_0000b
DESK_DPL1 equ                      010_0000_0000_0000b
DESK_DPL2 equ                      100_0000_0000_0000b
DESK_DPL3 equ                      110_0000_0000_0000b
DESK_S_CODE equ                      1_0000_0000_0000b
DESK_S_DATA equ                      DESK_S_CODE
DESK_S_SYS equ                       0_0000_0000_0000b
DESK_TYPE_CODE equ                     1000_0000_0000b ; x = 1, c = 0, r = 0, a = 0
DESK_TYPE_DATA equ                     0010_0000_0000b ; x = 0, w = 0, e = 1, a = 0
BASE_16_23 equ                              0000_0000b

DESK_CODE_HIGH4 equ (0x00 << 24) + (DESK_G_4K) + (DESK_D_32) + (DESK_L) + (DESK_AVL) + (DESK_LIMIT_CODE2) + (DESK_P) + (DESK_DPL0) + (DESK_S_CODE) + (DESK_TYPE_CODE) + 0x00
DESK_DATA_HIGH4 equ (0x00 << 24) + (DESK_G_4K) + (DESK_D_32) + (DESK_L) + (DESK_AVL) + (DESK_LIMIT_DATA2) + (DESK_P) + (DESK_DPL0) + (DESK_S_DATA) + (DESK_TYPE_DATA) + 0x00
DESK_VIDEO_HIGH4 equ (0x00 << 24) + (DESK_G_4K) + (DESK_D_32) + (DESK_L) + (DESK_AVL) + (DESK_LIMIT_VIDEO2) + (DESK_P) + (DESK_DPL0) + (DESK_S_DATA) + (DESK_TYPE_DATA) + 0x0B ; 0x00还是0x0B? 实测应该为0x0B

; ----------------- selector 属性 ------------------

RPL0 equ 00b
RPL1 equ 01b
RPL2 equ 10b
RPL3 equ 11b
TI_GDT equ 000b
TI_LDT equ 100b

; ----------------- 页目录表基址 ------------------

PAGE_DIR_TABLE_POS equ 0x100000 ; 1MB

; ----------------- 页表属性 -------------------

PG_P equ 1b
PG_RW_R equ 00b
PG_RW_W equ 10b
PG_US_S equ 000b
PG_US_U equ 100b

; ----------------- 加载内核 -------------------

KERNEL_START_SECTOR equ 0x9
KERNEL_BIN_BASE_ADDR equ 0x70000
KERNEL_ENTRY_POINT equ 0xc0001500

PT_NULL equ 0
