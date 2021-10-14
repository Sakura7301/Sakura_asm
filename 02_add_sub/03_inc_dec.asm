
mov ax,0x0000

mov cx,5
;循环5次,做++运算
test_add:
    inc ax
    loop test_add

;循环5次,做--运算
mov cx,5
test_sub:
    dec ax
    loop test_sub

jmp $
times 510-($-$$) db 0
db 0x55,0xaa