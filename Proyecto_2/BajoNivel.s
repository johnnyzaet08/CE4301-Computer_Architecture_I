.arch armv7-a
.fpu vfpv3
.eabi_attribute 67, "2.09"  @ EABI version 2.09
.eabi_attribute 6, 10      @ Hard float ABI


.section .data
    alpha:          .float 0.6
    k_sinfs:        .float 0.05
    name_input: 	.asciz "Binario_Xylophon"
    name_output: 	.asciz "Output_Xylophon"
    .align 1
    buffer_input: 	.space 291456
    buffer_output: 	.space 291456

.section .text
.globl _start

start:
    ; Inicialización
    LDR r0, =direccion_base_del_archivo
    LDR r1, =alpha
    LDR r2, =k_sinfs
    MUL r3, r2, fs  ; r3 = k
    MOV r4, #0      ; r4 = índice para polos

init_loop:
    ; Array de polos[k] = 0
    CMP r4, r3
    BGE init_done
    STR r4, [r0, r4] ; polos[i] = 0
    ADD r4, r4, #1
    B init_loop

init_done:
    STR r1, [r0]      ; polos[0] = alpha
    STR r1, [r0, r3-1] ; polos[k-1] = alpha
    SUB r5, #1, r1    ; r5 = ceros = 1 - alpha

    ; Llamada a custom_lfilter
    BL custom_lfilter

    ; Terminar el programa
    B end

custom_lfilter:
    cmp r5, r4
    bge end_loop_n        ; Si n >= longitud máxima, salir del bucle

    ; Calcular sum([b[k] * x[n-k] for k in range(M) if n-k >= 0])
    mov r7, #0            ; Acumulador para la suma
    mov r6, #0            ; Reiniciar índice k

loop_k_b:
    cmp r6, r4
    bge end_loop_k_b      ; Si k >= longitud máxima, salir del bucle

    ; Calcular n-k
    sub r8, r5, r6
    cmp r8, #0
    blt end_loop_k_b      ; Si n-k < 0, salir del bucle

    ; Realizar multiplicación y suma
    ldr r9, [r0, r6, lsl #2]   ; Cargar b[k]
    ldr r10, [r2, r8, lsl #2]  ; Cargar x[n-k]
    mul r11, r9, r10
    add r7, r7, r11

    ; Incrementar k y continuar bucle
    add r6, r6, #1
    b loop_k_b

end_loop_k_b:
    ; Calcular sum([a[k] * y[n-k] for k in range(1, N) if n-k >= 0])
    mov r6, #1            ; Reiniciar índice k a 1

loop_k_a:
    cmp r6, r4
    bge end_loop_k_a      ; Si k >= longitud máxima, salir del bucle

    ; Calcular n-k
    sub r8, r5, r6
    cmp r8, #0
    blt end_loop_k_a      ; Si n-k < 0, salir del bucle

    ; Realizar multiplicación y resta
    ldr r9, [r1, r6, lsl #2]   ; Cargar a[k]
    ldr r10, [r3, r8, lsl #2]  ; Cargar y[n-k]
    mul r11, r9, r10
    sub r7, r7, r11

    ; Incrementar k y continuar bucle
    add r6, r6, #1
    b loop_k_a

end_loop_k_a:
    ; Guardar resultado en y[n]
    str r7, [r3, r5, lsl #2]

    ; Incrementar n y continuar bucle
    add r5, r5, #1
    b custom_lfilter

end:
    ; Finalizar el programa
    END
