;设定循环次数
mov cx,100
mov ax,0x0000
;初始化ax寄存器

;循环体
start:
    add ax,cx
    loop start

;计算完毕后 ax寄存器的值为5050
jmp $
times 510-($-$$) db 0
db 0x55,0xaa