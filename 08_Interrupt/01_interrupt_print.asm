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
    mov ax,[StackSeg]
    mov ss,ax
    mov sp,StackEnd
    xor si,si 
    call printLines
    jmp $

;使用BIOS的0x10号中断进行字符串打印
printLines:
    mov cx,HelloEnd-Hello
    xor si, si
    .putchar:
    mov al, [si]
    inc si
    mov ah, 0x0e
    ;调用0x10号中断
    int 0x10
    loop .putchar
    ret

section data align=16 vstart=0
  Hello db 'Hello,I come from program on sector 1,loaded by bootloader!'
        db 0x0d, 0x0a
        db 'Haha,This is a new line!'
        db 0x0d,0x0a
        db 'Helloworld!'
        db 0x0a
        db 'Just 0x0a'
        db 0x0d
        db 'Just 0x0d'
        db 0x0d, 0x0a
        db 0x00
  HelloEnd:
section stack align=16 vstart=0
    times 128 db 0
    StackEnd:
section end align=16 
    ProgramEnd: