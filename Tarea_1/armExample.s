.global _start
.section  .text
_start:
    ldrb r0, =11     @ Load the value 10 into r0
    ldr r9, =256     @ Load the memory address 0x100 into r9
    ldrb r2, =65     @ Load the value 65 into r2
    strb r2, [r9, sp]    @ Store the least significant byte of r2 at address [r9]

    bl calcXOR       @ Call the calcXOR function
    b end            @ Branch to the end label

calcXOR:
    and r3, r2, #0b10000000   @ Extract the 7th bit of r2 and store it in r3
    lsr r3, r3, #7            @ Shift r3 to the least significant bit

    and r4, r2, #0b00100000   @ Extract the 5th bit of r2 and store it in r4
    lsr r4, r4, #5            @ Shift r4 to the least significant bit

    and r5, r2, #0b00010000   @ Extract the 4th bit of r2 and store it in r5
    lsr r5, r5, #4            @ Shift r5 to the least significant bit

    and r6, r2, #0b00001000   @ Extract the 3rd bit of r2 and store it in r6
    lsr r6, r6, #3            @ Shift r6 to the least significant bit

    eor r7, r3, r4            @ XOR r3 and r4, store result in r7
    eor r7, r7, r5            @ XOR r7 and r5, store result in r7
    eor r7, r7, r6            @ XOR r7 and r6, store result in r7

    bl moveXOR               @ Call the moveXOR function
    bx lr                     

moveXOR:
    lsr r2, r2, #1            @ Shift r2 to the right by 1
    lsl r7, r7, #7            @ Shift r7 to the left by 7
    orr r2, r2, r7            @ Bitwise OR r2 and r7, store result in r2

    bl saveVAL               @ Call the saveVAL function
    bx lr                     

saveVAL:
    add r9, r9, #4            @ Increment the memory address stored in r9 by 4
    str r2, [r9, sp]              @ Store the value of r2 at the address [r9]

    bl compare               @ Call the compare function
    bx lr                     

compare:
    sub r0, r0, #1            @ Decrement the value of r0 by 1
    cmp r0, #0                @ Compare r0 with 0
    bne calcXOR              @ Branch to calcXOR if r0 is not equal to 0
    bx lr                     

end:
    mov r7, #10               @ Move the value 10 into r7
    swi 0                     @ Software interrupt to terminate the program
