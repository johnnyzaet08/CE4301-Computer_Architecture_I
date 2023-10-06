.arch armv7-a
.fpu vfpv3
.eabi_attribute 67, "2.09"  @ EABI version 2.09
.eabi_attribute 6, 10      @ Hard float ABI


.section .data
    pi: .float 3.14159265359
    width: .float 640.0
    heigth: .float 480.0
    pordos: .float 2.0
    valueLxy: .float 75.0
    float_neg_0_16666666: .float 0.16666666
    float_0_00833333: .float 0.00833333
    float_neg_0_00019841: .float 0.00019841
    float_0_00000275: .float 0.00000275
    float_neg_0_00000002: .float 0.00000002
    float_0_00000000019841: .float 0.00000000019841
    name_input: 	.asciz "Binario"
    name_output: 	.asciz "Output"
    name_valueK:    .asciz "K"
    .align 1
    buffer_input: 	.space 307200
    buffer_output: 	.space 307200
    buffer_valuek:  .space 1


.section .text
.globl _start

_start:	
	    @ abrimos el archivo
	mov r7, #0x5
	ldr r0, =name_input         @ nombre del archivo
	mov r1, #2                  @ config para abrir
	mov r2, #0                  @ config para abrir
	swi 0                       @ syscall

	    @ leer archivo
	mov r7, #0x3
	ldr r1, =buffer_input @cargamos buffer
	ldr r2, =#307200
	swi 0  @sys call

	    @ cerrar archivo
	mov r7, #6
	swi 0 @sys call


        @ abrimos el archivo para K
    mov r7, #0x5
    ldr r0, =name_valueK        @ nombre del archivo
    mov r1, #2                  @ config para abrir
    mov r2, #0                  @ config para abrir
    swi 0                       @ syscall

        @leemos el archivo para K
    mov r7, #0x3
    ldr r1, =buffer_valuek      @ cargamos buffer
    ldr r2, =#1
    swi 0  @sys call

        @Cerramos el archivo para K
    mov r7, #6
    swi 0

        @ Saltar a load_values
    b load_values

load_values:
        @ Cargar m y n (dimensiones de la imagen) en s6 y s7
    mov r6, #640
    mov r7, #480
    ldr r0, =width
    vldr s12, [r0]
    ldr r0, =heigth
    vldr s13, [r0]
        @ Inicializar k en s20 con lo del archivo
    ldr r0, =buffer_valuek
    ldrb r5, [r0]
    vmov s20, r5
    vcvt.f32.s32  s20, s20
        @ Inicializar Lx y Ly en s21 con 75.0
    ldr r0, =valueLxy
    vldr s21, [r0]
        @ Inicializar Pi en s22
    ldr r0, =pi
    vldr s22, [r0]
        @ Inicializar 2.0 en s23
    ldr r0, =pordos
    vldr s23, [r0]
        @ Inicializar los terminos de la serie de Taylor, 7 terminos
    ldr r0, =float_neg_0_16666666                @ 1er termino
    vldr s24, [r0]
    ldr r0, =float_0_00833333                    @ 2do termino
    vldr s25, [r0]
    ldr r0, =float_neg_0_00019841                @ 3er termino
    vldr s26, [r0]
    ldr r0, =float_0_00000275                    @ 4to termino
    vldr s27, [r0]
    ldr r0, =float_neg_0_00000002                @ 5to termino
    vldr s28, [r0]
    ldr r0, =float_0_00000000019841              @ 6to termino
    vldr s29, [r0]


compare:
        @ Comparar s10 = x con r6 = ancho
    vmov s30, #1
    vmov s0, s10                @ Mover s10 a s0 como auxiliar
    vadd.f32 s0, s0, s30
    vcvt.s32.f32 s0, s0         @ Convert s0 (float) to s0 (signed 32-bit integer)
    vmov r3, s0                 @ Move the integer value in s0 to r3
    cmp r3, r6                  @ Comparar r3 que trae s10 con r6 que tiene m
    bgt loop_end_x
        @ Comparar s11 = y con r7 = largo
    vmov s30, #1
    vmov s0, s11                @ Mover s11 a s0 como auxiliar
    vadd.f32 s0, s0, s30
    vcvt.s32.f32 s0, s0         @ Convert s0 (float) to s0 (signed 32-bit integer)
    vmov r3, s0                 @ Move the integer value in s0 to r3
    cmp r3, r7                  @ Comparar r3 que trae s11 con r7 que tiene n
    bgt end

main_loop:
        @ Realizar las operaciones del valor constante
    vmul.f32 s5, s22, s23       @ s5 = 2 * pi
    vdiv.f32 s5, s5, s21        @ s5 = (2 * pi) / LyLx

        @ Cargar el valor de x en s1
    vmov s1, s11

        @ Aplicar mod a x
    vmov s19, s1
    vdiv.f32 s19, s19, s21            @ x = x / Lx
    vcvt.s32.f32  s19, s19            @ Parte entera de s19 en s19
    vcvt.f32.s32  s19, s19
    vmul.f32 s19, s19, s21                  @ r19 = r19 * Lx
    vsub.f32 s1, s1, s19                 @ x = x - x*Lx, donde r1 es la parte entera de s8/width

        @ Realizar la operacion del valor de X
    vmul.f32 s1, s1, s5         @ s1 = x * (2 * pi) / LyLx
        @ Guardar el valor original de x en s0
    vmov s0, s1
        @ Calcular sin(2 * pi * x / Ly)
    bl sin_approximation
        @ Mover el resultado a s8 (valor de sin)
    vmov s8, s0                 @ Valor para newy en s8

        @ Cargar el valor de y en s1
    vmov s1, s10

        @ Calcular mod a y
    vmov s19, s1
    vdiv.f32 s19, s19, s21            @ x = x / Lx
    vcvt.s32.f32  s19, s19            @ Parte entera de s19 en s19
    vcvt.f32.s32  s19, s19
    vmul.f32 s19, s19, s21                  @ r19 = r19 * Lx
    vsub.f32 s1, s1, s19                 @ x = x - x*Lx, donde r1 es la parte entera de s8/width

        @ Realizar la operacion del valor de y
    vmul.f32 s1, s1, s5         @ s1 = y * (2 * pi) / LyLx               
        @ Guardar el valor original de y en s0
    vmov s0, s1
        @ Calcular sin(2 * pi * y / Lx)
    bl sin_approximation
        @ Mover el resultado a s9 (valor de sin)
    vmov s9, s0                 @ Valor para newx en s9

        @ Calcular las nuevas coordenadas xnew e ynew
    vmul.f32 s8, s8, s20            @ s8 = Ax * sin(2 * pi * y / Lx)
    vmul.f32 s9, s9, s20            @ s9 = Ay * sin(2 * pi * x / Ly)
    vadd.f32 s8, s8, s10            @ s8 = xnew = x + Ax * sin(2 * pi * y / Lx)
    vadd.f32 s9, s9, s11            @ s9 = ynew = y + Ay * sin(2 * pi * x / Ly)

        @ Tomar la parte entera de xnew
    vmov s0, s8                 @ Move the float value of X in s0 like aux register
    vcvt.s32.f32 s0, s0         @ Convert r0 (float) to s0 (signed 32-bit integer)
    vmov r8, s0                 @ Move the integer value in s0 to r8
    mov r10, r8

        @ Tomar la parte entera de ynew
    vmov s0, s9                 @ Move the float value of Y in s0 like aux register
    vcvt.s32.f32 s0, s0         @ Convert r0 (float) to s0 (signed 32-bit integer)
    vmov r9, s0                 @ Move the integer value in s0 to r8
    mov r11, r9

        @ Calcular el mod de xnew segun m
    vmov s0, s8                     @ Mover para auxiliar
    vdiv.f32 s0, s0, s12            @ s8 = xnew / width
    vcvt.s32.f32 s0, s0             @ Parte entera de s0 en s0
    vmov r1, s0                     @ Mover parte entera a r1
    mul r1, r1, r6                  @ r1 = r1 * width
    subs r8, r8, r1                 @ r8 = r8 - r1 * width, donde r1 es la parte entera de s8/width

        @ Calcular el mod de ynew segun n
    vmov s0, s9                     @ Mover para auxiliar
    vdiv.f32 s0, s0, s13            @ s9 = xnew / heigth
    vcvt.s32.f32 s0, s0             @ Parte entera de s0 en s0
    vmov r1, s0                     @ Mover parte entera a r1
    mul r1, r1, r7                  @ r1 = r1 * heigth
    subs r9, r9, r1                 @ r9 = r9 - r1 * heigth, donde r1 es la parte entera de s8/width

        @ Comparar xnew == xaux y comparar ynew == yaux
    mov r1, #0
    mov r2, #0
    cmp r8, r10                  @ Compare ynew (r9) with 0
    moveq r1, #1                @ If ynew >= 0, set r1 to 1
    cmp r9, r11                 @ Compare ynew (r9) with 0
    moveq r2, #1                @ If ynew >= 0, set r1 to 1
    and r1, r1, r2
    cmp r1, #1
        @ Saltar a copy_pixel si son iguales o seguir
    beq copy_pixel
    b   loop_end_y


sin_approximation:
    @ Entrada:
    @ - Valor de x en registros de punto flotante s0
    @ Salida:
    @ - Valor aproximado de sin(x) en s0

    @ Guardar el valor original de x en s1
    vmov s1, s0

    @ Inicializar el resultado en s0, es X
    vmov s0, s1

    @ x^2
    vmul.f32 s1, s1, s1

    @ Restar el segundo termino (-x^3/6)
    vmul.f32 s2, s1, s0     @s2 = x^2 * x = x^3
    vmul.f32 s3, s2, s24    @s3 = x^3 * 1/6
    vsub.f32 s0, s0, s3     @s0 = x - x^3 * 1/6

    @ Sumar el tercer termino (x^5/120)
    vmul.f32 s2, s2, s1     @s2 = x^3 * x^2 = x^5
    vmul.f32 s3, s2, s25    @s3 = x^5 * 1/120
    vadd.f32 s0, s0, s3     @s0 = x + x^5 * 1/2

    @ Restar el cuarto termino (x^7/5040)
    vmul.f32 s2, s2, s1     @s2 = x^5 * x^2 = x^7
    vmul.f32 s3, s2, s26    @s3 = x^7 * 1/5040
    vsub.f32 s0, s0, s3     @s0 = x - x^7 * 1/5040

    @ Sumar el quinto termino (x^9/362880)
    vmul.f32 s2, s2, s1     @s2 = x^7 * x^2 = x^9
    vmul.f32 s3, s2, s27    @s3 = x^9 * 1/362880
    vadd.f32 s0, s0, s3     @s0 = x - x^9 * 1/362880

    @ Restar el quinto termino (x^11/39916800)
    vmul.f32 s2, s2, s1     @s2 = x^9 * x^2 = x^11
    vmul.f32 s3, s2, s28    @s3 = x^11 * 1/39916800
    vsub.f32 s0, s0, s3     @s0 = x - x^11 * 1/39916800

    @ Sumar el quinto termino (x^13/6227020800)
    vmul.f32 s2, s2, s1     @s2 = x^11 * x^2 = x^13
    vmul.f32 s3, s2, s29    @s3 = x^13 * 1/6227020800
    vadd.f32 s0, s0, s3     @s0 = x - x^13 * 1/6227020800

    bx lr

copy_pixel:
        @ Copiar el pixel de A a B
    vmul.f32 s7, s11, s12       @ Obtener la direccion de memoria con X y Y
    vadd.f32 s7, s7, s10       @ Obtener la direccion de memoria con X y Y
    vmov s0, s7                 @ Mover s7 a s0 como auxiliar
    vcvt.s32.f32 s0, s0         @ Convert s0 (float) to s0 (signed 32-bit integer)
    vmov r3, s0                 @ Move the integer value in s0 to r3
    ldr r5, =buffer_input       @ cargamos direccion de img en r5
    add r3, r3, r5              @ Sumar la direccion + r5 que contiene donde inicia la imagen vieja
    ldrb r2, [r3]                @ Cargar el valor
        @ Almacenar el pixel 
    mul r3, r9, r6         @ Obtener la direccion de memoria con newX y newY
    add r3, r3, r8
    ldr r5, =buffer_output      @ Cargamos dirrecion de img nueva en r5
    add r3, r3, r5              @ Sumar la direccion + r5 que contiene donde inicia la imagen nueva
    strb r2, [r3]                @ Copiar A[r2] a B[xnew][ynew]

loop_end_y:
        @ Incrementar X en 1.0
    vmov s30, #1.0
    vadd.f32 s10, s10, s30
        @ Regresar al loop principal de X
    b compare

loop_end_x:
        @ Volver X a 1.0
    vmov s30, #1.0
    vmov s10, #1.0
    vsub.f32 s10, s10, s30
        @ Incrementar Y en 1.0
    vadd.f32 s11, s11, s30
        @ Volver al ciclo
    b compare

end:
	    @abrimos el archivo PARA ESCRIBIR
	mov r7, #0x5
	ldr r0, =name_output        @nombre del archivo 
	mov r1, #2                  @config para abrir
	mov r2, #100                @config para abrir
	swi 0                       @syscall

	    @escribir archivo
	mov r7, #0x4
	ldr r1, =buffer_output      @cargamos buffer SE DEBE CAMBIAR POR OUTPUT
	ldr r2, =#307200
	swi 0                       @sys call

	    @cerrar archivo
	mov r7, #6
	swi 0 @sys call

        @ Terminar programa
    mov r7, #1                  @ System call for program exit
    swi 0                       @ Software interrupt to terminate the program