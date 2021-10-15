;常量声明
HDDPORT equ 0x1f0
NULL equ 0x00
SETCHAR equ 0x07
VIDEOMEM equ 0xb800
STRINGLEN equ 0xffff

section code align=16 vstart=0x7c00

;扇区号28位,需要用两个16位寄存器来保存
mov si,[READSTART]
mov cx,[READSTART+0x02]

;读取的扇区数,我们用一个八位寄存器保存
mov al,[SECTORNUM]
;后面还会用到ax,所以先入栈保存
push ax

;转为逻辑地址
;高位放在ax,低位放在dx
mov ax,[DESTMEN]
mov dx,[DESTMEN+0x02]
;16字节对齐,所以除16
mov bx,16
div bx

;商存入ds,作为目标内存区域的段地址
mov ds,ax
xor di,di
pop ax

call readHdd
xor si,si
call printstring
jmp end

;读取硬盘函数
readHdd:
    push ax
    push bx
    push cx
    push dx

    ;写入读取的扇区数
    mov dx,HDDPORT+2
    out dx,al

    ;写入7~0位
    mov dx,HDDPORT+3
    mov ax,si
    out dx,al

    ;写入15~8位
    mov dx,HDDPORT+4
    mov al,ah
    out dx,al
    
    ;写入23~16
    mov dx,HDDPORT+5
    mov ax,cx
    out dx,al

    ;写入27~24位以及硬盘参数
    mov dx,HDDPORT+6
    mov al,ah
    ;LBA模式,读取主硬盘,因此是0xe0
    mov ah,0xe0
    or al,ah
    out dx,al

    ;写入0x20到0x1f7端口,表示我们要读取硬盘
    mov dx,HDDPORT+7
    mov al,0x20
    out dx,al

    .waits:
    ;读取0x1f7端口,得到一个八位状态字节
    in al,dx
    ;除3,7位全部置为0
    and al,0x88
    ;判断第7位是否为0(硬盘不忙)
    ;第3位位1(硬盘已准备好)
    cmp al,0x08
    jnz .waits

    ;开始读取,端口号为0x1f0,一次读取2字节
    mov dx,HDDPORT
    ;一个扇区512字节,因此cx存入次数256
    mov cx,256

    .readWord:
    in ax,dx
    mov [ds:di],ax
    add di,0x02
    or ah,0x00
    jnz .readWord

    .return:
    pop ax
    pop bx
    pop cx
    pop dx

    ret

;打印字符串函数
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


;硬盘读取起始扇区号:我们读取第十个扇区
;读一个扇区
READSTART dd 10
SECTORNUM dd 1 
;保存到内存的位置,起始位置设定为0x10000
DESTMEN dd 0x10000

end:jmp end
times 510-($-$$) db 0
    db 0x55,0xaa