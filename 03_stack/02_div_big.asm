;被除数:dx:ax=0x00090006
mov dx,0x0009
mov ax,0x0006

;除数:0x0002
mov cx,0x0002

;保存ax(除数低16位)
push ax

;将除数的高16位存入ax
mov ax,dx
mov dx,0x0000

;第一次除法运算(高16位)商保存在ax,余数在dx
div cx
;将ax中高16位的运算结果保存在bx中
mov bx,ax

;第二次除法运算(低16位)
pop ax
div cx
;由于我们的高16位运算得到的商存在bx
;低16位的商存在ax, 余数在dx中
;因此我们最后的结果就是 bx:ax为商 dx为余数
;即->bx:ax=0x00048003  余数dx=0x0000

jmp $
times 510-($-$$) db 0
db 0x55,0xaa

