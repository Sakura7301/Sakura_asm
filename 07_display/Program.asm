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
    mov bl,[ds:si]
    ;判断并输出回车
    cmp bl,0x0d
    jz .putCR
    ;判断并输出换行
    cmp bl,0x0a
    jz .putLF
    ;实际输出字符
    or bl, NULL
    jz .return
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

    call SetCursor
    jmp .loopEnd

    ;回车函数
    .putCR:
    mov bl,160
    mov ax,di
    div bl
    ;二进制位右移8位,即ah->al
    shr ax,8
    sub di,ax
    call SetCursor
    inc si
    jmp .loopEnd

    ;换行函数
    .putLF:
    add di,160
    call SetCursor
    inc si
    jmp .loopEnd

    ;否,继续循环
    .loopEnd:
    loop .ptintchar

    ;返回指令的标号
    .return:
    mov bx,di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;设置光标函数
SetCursor:
    push dx
    push bx
    push ax

    mov ax,di
    mov dx,0
    mov bx,2
    div bx

    mov bx,ax
    ;设置端口号,下发要写入的寄存器编号0x0e
    mov dx,0x3d4
    mov al,0x0e
    out dx,al
    mov dx,0x3d5
    mov al,ah
    out dx,al

    ;设置端口号,下发要写入的寄存器编号0x0f
    mov dx,0x3d4
    mov al,0x0f
    out dx,al

    mov al, bl
    mov dx,0x3d5
    out dx,al

    pop ax
    pop bx
    pop dx
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