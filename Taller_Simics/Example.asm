section .data
    initSeed db 65
    cant db 10
    addMemory dd 256

section .bss
    xorResult resb 1

section .text
global _start

_start:
    mov eax, [cant]
    mov ebx, [addMemory]
    mov al, [initSeed]
    mov [ebx, sp], al
    call calcXOR

    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80

calcXOR:
    push eax
    and al, 0b10000000
    shr al, 7
    and al, 0b00100000
    shr al, 5
    and al, 0b00010000
    shr al, 4
    and al, 0b00001000
    shr al, 3
    xor bl, al
    call moveXOR
    pop eax
    ret

moveXOR:
    push eax
    shr al, 1
    shl bl, 7
    or al, bl
    mov [xorResult], al
    pop eax
    call saveVAL
    ret

saveVAL:
    push ebx
    mov ebx, [addMemory]
    add ebx, 4
    
    ; Store the byte value
    mov al, [xorResult]
    mov [ebx], al
    
    pop ebx
    call compare
    ret

compare:
    sub word [cant], 1
    jz end
    call calcXOR
    ret

end:
    ret

