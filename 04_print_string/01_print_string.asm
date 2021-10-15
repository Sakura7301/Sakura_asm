NULL equ 0x00
SETCHAR equ 0x07
VIDEOMEM equ 0xb800
STRINGLEN equ 0xffff

;section分段,align是内存对齐,vstart是偏移地址
section code align=16 vstart=0x7c00

    mov si,sayHello
    ;di清零
    xor di,di
    call printstring
    mov si,sayByebye
    call printstring
    jmp end

printstring:
    .setup:
    ;初始化字符写入的目的地址
    mov ax,VIDEOMEM
    mov es,ax

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
    ret

sayHello db 'OnlieProgramming server, client and instructions.'
            db 0x00
sayByebye db 'byebye!'
            db 0x00

end: jmp end
times 510-($-$$) db 0
    db 0x55,0xaa

