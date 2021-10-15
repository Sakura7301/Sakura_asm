;常量声明
HDDPORT equ 0x1f0

section code align=16 vstart=0x7c00

;扇区号28位,需要用两个16位寄存器来保存
    mov si,[READSTART]
    mov cx,[READSTART+2]

    ;读取的扇区数,我们用一个八位寄存器保存
    mov al,[SECTORNUM]
    ;后面还会用到ax,所以先入栈保存
    push ax

    ;转为逻辑地址
    ;高位放在ax,低位放在dx
    mov ax,[DESTMEN]
    mov dx,[DESTMEN+2]
    ;16字节对齐,所以除16
    mov bx,16
    div bx

    ;商存入ds,作为目标内存区域的段地址
    mov ds,ax
    xor di,di
    pop ax
    call ReadHdd

;处理段地址
ResetSegment:
    mov bx,0x04
    ;段总个数再0x10内存处
    mov cl,[0x10]


    ;重新计算段地址
    .reset:
    ;1.取出地址(高位->dx, 低位->ax)
    mov ax,[bx]
    mov dx,[bx+2]
    ;2.加上实际的物理地址
    add ax,[cs:DESTMEN]
    adc dx,[cs:DESTMEN+2]
    ;3.右移四位得到段地址
    mov si,16
    ;使用除法将相加后的地址右移四位得到段地址
    div si
    ;除法得到的商就是正确的16位段地址
    mov [bx],ax
    ;4.把计算的正确结果写回内存0x04偏移处
    add bx,4
    loop .reset

;入口地址重定位(code段)
ReseEntry:
    mov ax,[0x13]
    mov dx,[0x15]
    add ax,[cs:DESTMEN]
    adc dx,[cs:DESTMEN+2]

    mov si,16
    div si
    mov [0x13],ax

    ;跳转至入口开始执行(因为跳转位置不在bootloader内,所以加far)
    jmp far [0x11]



;读取硬盘函数
ReadHdd:
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
    add di,2
    ;or ah,0x00
    ;jnz .readWord
    loop .readWord

    .return:
    pop ax
    pop bx
    pop cx
    pop dx
    ret


    ;硬盘读取起始扇区号:我们读取第1个扇区
    ;读取数量:一个扇区
    READSTART dd 1
    SECTORNUM dd 1 
    ;保存到内存的位置,起始位置设定为0x10000
    DESTMEN dd 0x10000

    
End:jmp End
times 510-($-$$) db 0
    db 0x55,0xaa