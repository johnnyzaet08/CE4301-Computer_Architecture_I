.global _start
.section .text

_start:
    li a0, 10
    li a1, 256
    li a2, 65
    add a1, a1, sp
    sw a2, (a1)
    jal ra, calcXOR
calcXOR:
    andi s2, a2, 0b10000000
    srli s2, s2, 7
    andi s3, a2, 0b00100000
    srli s3, s3, 5
    andi s4, a2, 0b00010000
    srli s4, s4, 4
    andi s5, a2, 0b00001000
    srli s5, s5, 3
    xor s6, s2, s3
    xor s6, s6, s4
    xor s6, s6, s5
    jal ra, moveXOR
moveXOR:
    srli a2, a2, 1
    slli s6, s6, 7
    or a2, a2, s6
    jal ra, saveVAL

saveVAL:
    addi a1, a1, 4
    sw a2, (a1)
    jal ra, compare
compare:
    addi a0, a0, -1
    beq a0, zero, end
    jal ra, calcXOR

end:
    li a7, 10
    ecall
