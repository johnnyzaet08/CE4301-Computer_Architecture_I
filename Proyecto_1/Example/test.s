.section .data
    pi: .float 3.14159265359

.section .text
.globl main

main:
        @ Cargar la dirección de la imagen A en R0
    mov r0, #0ximagen
        @ Cargar m y n (dimensiones de la imagen) en R1 y R2
    mov r1, #640
    mov r2, #480
        @ Inicializar k en R3 con 5
    mov r3, #5
        @ Inicializar Lx y Ly en 75
    mov r4, #75

loop_start:
        @ Direccion de memoria para guardar nueva imagen
    mov r5, #0ximagen
        @ Iniciar bucle para recorrer la imagen
    mov r6, #0              @ Valor inicial de X
    mov r7, #0              @ Valor inicial de Y

inner_loop_x:
    cmp r6, r1              @ Comprobar si x >= m (fin de la imagen)
    bge loop_end_x
    mov r7, #0

inner_loop_y:
    cmp r7, r2              @ Comprobar si y >= n (fin de la imagen)
    bge loop_end_y

        @ Cargar los valores en registros de punto flotante
    flds s0, r4             @ Cargar el valor de Ly en s0
    flds s1, r6             @ Cargar el valor de x en s1
    flds s2, [pi]           @ Cargar el valor de pi en s2 desde la .section .data
    .flt s3, 2.0            @ Cargar 2.0 en s3
        @ Realizar las operaciones
    fmuls s1, s1, s2        @ s1 = pi * x
    fmuls s1, s1, s3        @ s1 = 2 * (pi * x)
    fdivs s1, s1, s0        @ s1 = (2 * pi * x) / Ly
        @ Guardar el valor original de x en s0
    fcpy s0, s1
        @ Calcular sin(2 * pi * x / Ly)
    bl sin_approximation
        @ Mover el resultado a s8 (valor de sin)
    fmsr s8, s0             @ Valor para newy en s8

        @ Cargar los valores en registros de punto flotante
    flds s0, r4             @ Cargar el valor de Ly en s0
    flds s1, r7             @ Cargar el valor de y en s1
    flds s2, [pi]           @ Cargar el valor de pi en s2 desde la .section .data
    .flt s3, 2.0            @ Cargar 2.0 en s3
        @ Realizar las operaciones
    fmuls s1, s1, s2        @ s1 = pi * y
    fmuls s1, s1, s3        @ s1 = 2 * (pi * y)
    fdivs s1, s1, s0        @ s1 = (2 * pi * y) / Lx
        @ Guardar el valor original de x en s0
    fcpy s0, s1
        @ Calcular sin(2 * pi * y / Lx)
    bl sin_approximation
        @ Mover el resultado a s5 (valor de sin)
    fmsr s9, s0             @ Valor para newx en s9

        @ Calcular las nuevas coordenadas xnew e ynew
    flds s1, r6             @ Cargar el valor de x en s1
    fadds s11, s9, s1       @ xnew = x + Ax * sin(2 * pi * y / Lx)
    flds s1, r7             @ Cargar el valor de y en s2
    fadds s12, s8, s2       @ ynew = y + Ay * sin(2 * pi * x / Ly)

        @ Redondear xnew e ynew a enteros
    fcvtsi s11, s11
    fcvtsi s12, s12

        @ Tomar la parte entera de xnew e ynew
    fcvtzs r8, s11
    fcvtzs r9, s12

        @ Calcular xaux y yaux
    fsubs s13, s11, s9      @ xaux = xnew - Ax * sin(2 * pi * y / Lx)
    fsubs s14, s12, s8      @ yaux = ynew - Ay * sin(2 * pi * x / Ly)

    fcmps s11, s13          @ Comprobar si xnew == xaux
    fcmps s12, s14          @ Comprobar si ynew == yaux
    fcmps s11, s13
    fcmps s12, s14

        @ Si xnew == xaux y ynew == yaux, copiar el píxel
    fcmpes s11, s13
    fcmpes s12, s14
    fcmpes s11, s13
    fcmpes s12, s14

        @ Copiar el píxel si se cumplen las condiciones
    beq copy_pixel

loop_end_y:
        @ Incrementar y
    add r7, r7, #1
    b inner_loop_y

loop_end_x:
        @ Incrementar x
    add r6, r6, #1
    b inner_loop_x
        @ Incrementar k en 5
    add r3, r3, #5
        @ Saltar al bucle principal
    b loop_start

sin_approximation:
        @ Entrada:
        @ - Valor de x en registros de punto flotante s0
        @ Salida:
        @ - Valor aproximado de sin(x) en s0

        @ Definir los coeficientes de la serie de Taylor para sin(x)
    .float 1.0
    .float -1.0/6.0
    .float 1.0/120.0
    .float -1.0/5040.0
    .float 1.0/362880.0

        @ Guardar el valor original de x en s1
    fcpy s1, s0

        @ Inicializar el resultado en s0
    fcpy s0, s1

        @ Calcular los términos de la serie de Taylor
    fmsr s2, 2.0
    fmsr s3, 4.0
    fmsr s4, 6.0
    fmsr s5, 8.0

        @ x^2
    fmul s1, s1, s1

        @ Sumar el segundo término (-x^3/6)
    fdiv s2, s1, s2
    fmul s2, s2, s1
    fadds s0, s0, s2

        @ Restar el tercer término (x^5/120)
    fdiv s3, s1, s3
    fmul s3, s3, s1
    fsubs s0, s0, s3

        @ Sumar el cuarto término (-x^7/5040)
    fdiv s4, s1, s4
    fmul s4, s4, s1
    fadds s0, s0, s4

        @ Restar el quinto término (x^9/362880)
    fdiv s5, s1, s5
    fmul s5, s5, s1
    fsubs s0, s0, s5

    bx lr

copy_pixel:
        @ Copiar el píxel de A a B
    mul r9, r9, r8              @ Obtener la direccion de memoria con xnew y ynew
    mul r12, r6, r7             @ Obtener la direccion de memoria con X y Y
    ldr r10, [r0, r12]
    str r10, [r10, r9]    @ Copiar A[r10] a B[xnew][ynew]

    str
