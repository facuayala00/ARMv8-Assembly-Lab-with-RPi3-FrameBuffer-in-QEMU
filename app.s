
.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32
.equ RETARDO, 0xFFFFF
.data
UBIC_ESTRELLASX1: .dword 472,19,411,627,286,215,35,21,69,83,159,108,190,218,48,440
UBIC_ESTRELLASY1: .dword 222,140,303,75,237,262,189,53,391,303,2,13,517,420,586,634
UBIC_ESTRELLASX2: .dword 493,277,607,85,460,139,59,65,410,375,23,484,566,369,466,611
UBIC_ESTRELLASY2: .dword 422,227,19,129,449,131,387,144,348,63,45,41,233,308,93,53
SEMICIRCULO: .dword 0,0,0,0,1,0,0,1,0,0,1,1,0,1,1,0,1,1,1,1,1,1,1,2,1,1,2,1,2,1,2,2,2,2,3,2,3,3,3,4,3,4,3,4,5,4,5,5,6,6,7,7,7,8,9,10,13,15,19




.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Save framebuffer base address to x20
	mov x21, SCREEN_HEIGH
	mov x22, SCREEN_WIDTH
	//---------------- CODE HERE ------------------------------------

	mov x7, #0x33
	bl pintar_pantalla

	//bl base_nave
	movimiento:
	bl pintar_estrellas2

	bl pintar_estrellas1
	mov x9, RETARDO
	tiempo1:
	sub x9, x9, #1
	cbnz x9, tiempo1

	bl pintar_estrellas1
	mov x9, RETARDO
	tiempo2:
	sub x9, x9, #1
	cbnz x9, tiempo2

	bl pintar_estrellas1
	mov x9, RETARDO
	tiempo3:
	sub x9, x9, #1
	cbnz x9, tiempo3

	b movimiento
	b fin

    // ----- FIN MAIN

	// ----- ARGS UTILIZADOS
	// X7 : color que se utilizará para pintar
	// X1 : posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// X2 : posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	// X3 : cantidad de pixeles que se van a pintar
pintar_linea_horizontal:
	sub sp, sp, #24 // PUSH
	stur lr, [sp, #16] // PUSH
	stur x3, [sp, #8] // PUSH
	stur x1, [sp] // PUSH

	loop0:
	madd x9, x2, x22, x1 // x + (y * 640)
	add x9, x20, x9, lsl 2 // Dirección de inicio + 4 * [x + (y * 640)]
	stur w7, [x9] // Pintar pixel
	add x1, x1, #1
	sub x3, x3, #1
	cbnz x3, loop0


	ldur x1, [sp] // POP
	ldur x3, [sp, #8] // POP
	ldur lr, [sp, #16] // POP
	add sp,sp, #24 // POP
	br lr


	// ----- ARGS UTILIZADOS
	// X7 : color que se utilizará para pintar
pintar_pantalla:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH

	mov x3, SCREEN_WIDTH
	mov x1, #0
	mov x2, SCREEN_HEIGH
	sub x2, x2, 1

	loop1:
	bl pintar_linea_horizontal
	sub x2, x2, 1
	cbnz x2, loop1

	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr


	// ----- ARGS UTILIZADOS
	// X7 : color que se utilizará para pintar
	// X1 : posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// X2 : posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	// X3 : largo del lado del cuadrado
pintar_cuadrado:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH

	add x10, x2, x3
	loop3:
	bl pintar_linea_horizontal
	add x2, x2, #1
	cmp x10, x2
	b.gt loop3

	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr	

estrella:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH


	//bl pintar_linea_horizontal

	lsl x10, x22, #2

	madd x9, x2, x22, x1 // x + (y * 640)
	add x9, x20, x9, lsl 2 // Dirección de inicio + 4 * [x + (y * 640)]


	stur w7, [x9, #0]
	stur w7, [x9, #4]
	stur w7, [x9, #8]
	stur w7, [x9, #12]
	
	add x9, x9, x10
	stur w7, [x9, #0] // Pintar pixel
	stur w7, [x9, #4] // Pintar pixel
	stur w7, [x9, #8] // Pintar pixel
	stur w7, [x9, #12] // Pintar pixel
	add x9, x9, x10	

	stur w7, [x9, #0] // Pintar pixel
	stur w7, [x9, #4] // Pintar pixel
	stur w7, [x9, #8] // Pintar pixel
	stur w7, [x9, #12] // Pintar pixel
	add x9, x9, x10	
	stur w7, [x9, #0] // Pintar pixel
	stur w7, [x9, #4] // Pintar pixel
	stur w7, [x9, #8] // Pintar pixel
	stur w7, [x9, #12] // Pintar pixel	
	



	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr	



	// ----- ARGS UTILIZADOS
pintar_estrellas1:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH
	
	mov x3, #4
	mov x13, #16
	ldr x14, =UBIC_ESTRELLASX1
	ldr x15, =UBIC_ESTRELLASY1
	loop4:
	ldur x1, [x14, #0]
	ldur x2, [x15, #0]
	mov x7, #0x33
	bl estrella

	mov x7, #0xFFFFFF		
	sub x1, x1, #1
	bl estrella

	cbz x1, salto
	b salto2
	salto: 
	add x1, xzr, x22
	sub x1, x1, #1
	salto2:
	stur x1, [x14,#0]

	add x15, x15, #8
	add x14, x14, #8
	sub x13, x13, #1
	cbz x13, chau
	b loop4
	chau:







	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr	

pintar_estrellas2:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH
	
	mov x3, #4
	mov x13, #16
	ldr x14, =UBIC_ESTRELLASX2
	ldr x15, =UBIC_ESTRELLASY2
	loop42:
	ldur x1, [x14, #0]
	ldur x2, [x15, #0]
	mov x7, #0x33
	bl pintar_cuadrado
	movz x7, #0x7D7D
	movk x7, #0x007B, lsl 16		
	sub x1, x1, #1
	bl pintar_cuadrado

	cbz x1, salto222
	b salto22
	salto222: 
	add x1, xzr, x22
	sub x1, x1, #1
	salto22:
	stur x1, [x14,#0]

	add x15, x15, #8
	add x14, x14, #8
	sub x13, x13, #1
	cbz x13, chau2
	b loop42
	chau2:







	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr	



	// ----- ARGS UTILIZADOS
base_nave:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH	

	mov x7, #0xFFFFFF

	
	mov x1, #80
	mov x2, #300
	mov x3, #480
	mov x10, #60
	ldr x11, =SEMICIRCULO
	magia:
	ldur x12, [x11, #0]
	bl pintar_linea_horizontal
	add x1, x1, x12
	sub x2, x2, #1
	lsl x12, x12, #1
	sub x3, x3, x12

	sub x10, x10, #1
	add x11, x11 , #8
	cbnz x10, magia
	
	mov x1, #80
	mov x2, #300
	mov x3, #480
	mov x10, #60
	ldr x11, =SEMICIRCULO
	magia2:
	ldur x12, [x11, #0]
	bl pintar_linea_horizontal
	add x1, x1, x12
	add x2, x2, #1
	lsl x12, x12, #1
	sub x3, x3, x12

	sub x10, x10, #1
	add x11, x11 , #8
	cbnz x10, magia2


	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr	
fin:	
	b fin
