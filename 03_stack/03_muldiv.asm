;8位乘法
mov al,0x04
mov ah,0x02
mul ah

nop

;16位乘法
mov ax,0xf000
mov bx,0x0002
mul bx

nop

;16位除法
mov ax,0x0004
mov bl,0x02
div bl
;商在ax中,余数在dx中

nop

;32位除法
mov dx,0x0008
mov ax,0x0006
mov cx,0x0002
div cx

jmp $
times 510-($-$$) db 0
db 0x55,0xaa

