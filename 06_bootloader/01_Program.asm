;常量区
NULL equ 0x00
SETCHAR equ 0x07
VIDEOMEM equ 0xb800
STRINGLEN equ 0xffff

section head align=16 vstart=0
    Size dd ProgramEnd;4字节,偏移地址0x00
    SegmentAddr:
    CodeSeg dd section.code.start;4字节,偏移地址0x04
    DataSeg dd section.data.start;4字节,偏移地址0x08
    StackSeg dd section.stack.start;;4字节,偏移地址0x0c
    SegmnetNum:
    SegNum db (SegmnetNum-SegmentAddr)/4;1字节,偏移地址0x10
    Entry dw CodeStart;2字节,偏移地址0x11
            dd section.code.start;4字节,偏移地址0x13
section code align=16 vstart=0
CodeStart:
    mov ax,[DataSeg]
    mov ds,ax
    xor si,si 
    call printstring
    jmp $

;打印字符串函数
printstring:
    .setup:
    push ax
    push bx
    push cx
    push dx
    ;初始化字符写入的目的地址
    mov ax,VIDEOMEM
    mov es,ax
    xor di,di

    ;设置字符属性->0x07为黑底白字
    mov bh,SETCHAR
    ;设置循环次数(字符串长度)cx
    mov cx,STRINGLEN

    .ptintchar:
    ;取字符地址存入bl, 基址+段内偏移
    mov bl,[ds:si]
    ;si+1,指向下个字符
    inc si

    ;把取到的字符写入显存
    mov [es:di],bl
    ;di+1,指向下一个待写入的位置
    inc di

    ;写入字符属性
    mov [es:di],bh
    ;di+1,指向下一个待写入的位置
    inc di

    ;判断bl是否为0x00,即字符串结束位置
    or bl,NULL
    ;结果为0,字符串读取完毕,跳出循环
    jz .return
    ;否,继续循环
    loop .ptintchar

    ;返回指令的标号
    .return:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

section data align=16 vstart=0
    Hello db 'Hello, I come from program on sector 1,loaded by bootloader!'
section stack align=16 vstart=0
    resb 128
section end align=16 
    ProgramEnd: