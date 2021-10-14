;设置ss寄存器
mov ax,0x0000
mov ss,ax

;设置sp寄存器
mov sp,0x0000

push ax

pop ax
jmp $
times 510-($-$$) db 0
db 0x55,0xaa
