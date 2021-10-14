mov ax, 0b800h
mov ds,ax

mov byte [0x00],'h'
mov byte [0x02],'e'
mov byte [0x04],'l'
mov byte [0x06],'l'
mov byte [0x08],'o'
mov byte [0x0a],'!'
mov byte [0x0c],'!'

jmp $


times 510-($-$$) db 0
db 0x55,0xaa 
