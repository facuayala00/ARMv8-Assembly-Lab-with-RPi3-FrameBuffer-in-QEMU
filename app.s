
.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32
.equ RETARDO, 0xFFFFF // Retardo utilizado para que el movimiento de estrellas sea más lento (Modificar en caso de ser necesario)
.equ COLOR_FONDO, 0x33
.data
UBIC_ESTRELLASX1: .dword 472,519,411,627,286,315,170,21,69,600,159,108,350,218,48,440 // Posiciones iniciales en X de las estrellas blancas
UBIC_ESTRELLASY1: .dword 222,550,303,75,237,100,189,53,391,303,600,13,517,420,586,634 // Posiciones iniciales en Y de las estrellas blancas
UBIC_ESTRELLASX2: .dword 493,277,607,85,200,139,320,65,635,375,23,484,566,369,169,247 // Posiciones iniciales en X de las estrellas grises
UBIC_ESTRELLASY2: .dword 422,227,19,323,449,131,180,144,348,63,45,41,233,308,360,53 // Posiciones iniciales en Y de las estrellas grises
BASE_PIXELES: .dword 0,0,0,0,1,0,0,1,0,0,1,1,0,1,1,0,1,1,1,1,1,1,1,2,1,1,2,1,2,1,2,2,2,2,3,2,3,3,3,4,3,4,3,4,5,4,5,5,6,6,7,7,7,8,9,10,13,15,19 // Secuencia de números útilizada para graficar el semicirculo correspondiente a la base de la nave
CUPULA_PIXELES_ARRIBA: .dword 0,0,0,0,1,0,0,1,0,1,0,1,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,2,1,1,2,1,1,2,1,1,2,1,2,1,2,2,2,2,2,2,2,3,3,3,3,3,4,4,4,5,6,6,7,11,13,17
CUPULA_PIXELES_ABAJO: .dword 0,0,0,0,1,0,0,1,1,0,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,5,5,6,6,7,7,9,11,13,17
LUZ_PIXELES: .dword 0,1,0,1,0,1,1,2,2,3
UBIC_LUZ_X:	.dword 114, 507, 309, 159, 460, 206, 413, 258, 361
UBIC_LUZ_Y: .dword 286, 286, 336, 310, 310, 323, 323, 333, 333

.text

.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Guardar dirección base del framebuffer en x20
	mov x21, SCREEN_HEIGH // Guardar alto de la pantalla (cant pixeles) en x21
	mov x22, SCREEN_WIDTH // Guardar largo de la pantalla (cant pixeles) en x22
	mov x23, COLOR_FONDO // Guardar el color del fondo en x23

	bl pintar_fondo 	// Establecer el color del fondo al indicado

 	bl base_nave // Imprimir la base de la nave
	bl cupula_nave // Imprimir cupula de la nave

	bl luces_nave


	// Ahora inicia un loop que está constantemente corriendo las estrellas hacia un costado (Hace 3 ciclos de estrellas blancas y 1 de estrellas grises "por vuelta")
 	pintar_estrellas_grises: 
	movz x0, #0x7D7D
	movk x0, #0x007B, lsl 16 // Establezco el color en el que va a pintar las estrellas
	ldr x4, =UBIC_ESTRELLASX2 // Establezco que coordenadas en X va a utilizar para pintar las estrellas
	ldr x5, =UBIC_ESTRELLASY2 // Establezco que coordenadas en Y va a utilizar para pintar las estrellas
	bl pintar_estrellas // Pinto las estrellas

	mov x15, #3 // Escribo el indice de cuantos movimientos de estrellas blancas faltan
	pintar_estrellas_blancas:
	mov x0, #0xFFFFFF // Establezco el color en el que va a pintar las estrellas
	ldr x4, =UBIC_ESTRELLASX1 // Establezco que coordenadas en X va a utilizar para pintar las estrellas
	ldr x5, =UBIC_ESTRELLASY1 // Establezco que coordenadas en Y va a utilizar para pintar las estrellas
	bl pintar_estrellas // Pinto las estrellas
	bl arreglar_bug // Arreglo un bug gráfico en uno de los bordes
	mov x9, RETARDO // Guardo en x9 el valor del retardo
	// Bucle de retardo
	pausa:
	sub x9, x9, #1 
	cbnz x9, pausa
		
	sub x15, x15, #1 // Resto un movimiento de estrellas blancas
	cbnz x15, pintar_estrellas_blancas // Reviso si ya complete los 3 movimientos de estrellas blancas, para si no hacer el próximo

	b pintar_estrellas_grises // Vuelvo a comenzar el ciclo de movimiento de estrellas 

	b fin

// ===== FIN DEL MAIN =====




	// PINTAR FONDO
	// -------------------------------
pintar_fondo:
	add x9, x20, xzr // Copio en x9 la dirección base del framebuffer
	movz x11, #0xB000 
	movk x11, #0x0004, lsl 16 // Establezco x11 como la cantidad de pixeles a pintar


	pintar_pixel: // inicio el loop
	stur w23, [x9] // Pinto el pixel
	add x9, x9, #4 // Guardo en x9 la próxima dirección a pintar
	sub x11, x11, #1 // Resto uno a la cantidad de pixeles que debo pintar
	cbnz x11, pintar_pixel // Reviso si todavía tengo que pintar pixeles para decidir si seguir pintando o no
	
	br lr // Salida de la función



	// PINTAR LINEA HORIZONTAL
	// -------------------------------
	// Argumentos:
	// 	X0 - color que se utilizará para pintar
	// 	X1 - posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// 	X2 - posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	// 	X3 - cantidad de pixeles que se van a pintar. Mínimo 1
pintar_linea_horizontal:
	sub sp, sp, #24 // PUSH
	stur lr, [sp, #16] // PUSH
	stur x3, [sp, #8] // PUSH
	stur x1, [sp] // PUSH

	// Calculo el indice de la primera dirección donde debo pintar
	madd x9, x2, x22, x1 // x + (y * 640)
	add x9, x20, x9, lsl 2 // Dirección de inicio + 4 * [x + (y * 640)]

	pintar_pixel2: // inicio el loop
	stur w0, [x9] // Pinto el pixel
	add x9, x9, #4 // Guardo en x9 la próxima dirección a pintar
	sub x3, x3, #1 // Resto uno a la cantidad de pixeles que debo pintar
	cbnz x3, pintar_pixel2 // Reviso si todavía tengo que pintar pixeles para decidir si seguir pintando o no


	ldur x1, [sp] // POP
	ldur x3, [sp, #8] // POP
	ldur lr, [sp, #16] // POP
	add sp,sp, #24 // POP
	br lr // Salida de la función

	// PINTAR LINEA DEPENDIENDO DEL COLOR DEL PIXEL
	// -------------------------------
	// Argumentos:
	// 	X0 - color que se utilizará para pintar
	// 	X1 - posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// 	X2 - posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	// 	X3 - cantidad de pixeles que se van a pintar. Mínimo 1
	//	X4 - Color secundario que se utiliza si el pixel es de color X5
	//	X5 - Color de pixel a chequear
pintar_linea_dependiendo_del_color_del_pixel:
	sub sp, sp, #24 // PUSH
	stur lr, [sp, #16] // PUSH
	stur x3, [sp, #8] // PUSH
	stur x1, [sp] // PUSH

	// Calculo el indice de la primera dirección donde debo pintar
	madd x9, x2, x22, x1 // x + (y * 640)
	add x9, x20, x9, lsl 2 // Dirección de inicio + 4 * [x + (y * 640)]

	pintar_pixel_condicionalmente: // inicio el loop
	ldur w14, [x9] // Cargo a x11 con el color del pixel
	cmp w5, w14
	B.EQ pintar_pixel_de_color_secundario
	B pintar_pixel_de_color_primario

	pintar_pixel_de_color_secundario:
	stur w4, [x9] // Pinto el pixel
	B calcular_siguiente_direccion_de_memoria_de_pixel_condicional

	pintar_pixel_de_color_primario:
	stur w0, [x9] // Pinto el pixel

	calcular_siguiente_direccion_de_memoria_de_pixel_condicional:
	add x9, x9, #4 // Guardo en x9 la próxima dirección a pintar
	sub x3, x3, #1 // Resto uno a la cantidad de pixeles que debo pintar
	cbnz x3, pintar_pixel_condicionalmente // Reviso si todavía tengo que pintar pixeles para decidir si seguir pintando o no


	ldur x1, [sp] // POP
	ldur x3, [sp, #8] // POP
	ldur lr, [sp, #16] // POP
	add sp,sp, #24 // POP
	br lr // Salida de la función



	// PINTAR CUADRADO
	// -------------------------------
	// Argumentos:
	// 	X0 - color que se utilizará para pintar
	// 	X1 - posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// 	X2 - posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	// 	X3 - largo del lado del cuadrado
pintar_cuadrado:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH

	add x10, xzr, x3 // Establezco x10 como la cantidad de lineas que debo hacer (por ejemplo, si "x10 = 5" hago 5 lineas horizontales (una debajo de la otra) de 5 pixeles)
	loop: // Inicio del loop
	bl pintar_linea_horizontal // Llamo a pintar linea horizontal con el color x0, altura en X x1 y altura en Y x2
	sub x2, x2, #1 // Bajo una linea para que la próxima llamada se pinte la linea de abajo
	sub x10, x10, #1 // Disminuyo en 1 la cantidad de pixeles que debo pintar
	cbnz x10, loop // Reviso si todavía tengo que pintar pixeles para decidir si seguir pintando o no

	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr // Salida de la función	


	// ESTRELLA
	// -------------------------------
	// Explicación:
	// 	Pinta todos los pixeles de un cuadrado 4x4 que cumplan la condición de que son igual a un color
	// Argumentos:
	// 	X0 - color que se utilizará para pintar
	// 	X1 - posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// 	X2 - posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	// 	x7 - color necesario para sobrepintar ese pixel
estrella:
	// Calculo el indice de la primera dirección donde debo pintar
	madd x9, x2, x22, x1 // x + (y * 640)
	add x9, x20, x9, lsl 2 // Dirección de inicio + 4 * [x + (y * 640)]

	// Guardo en x10 cuanto debo saltar para llegar a la primera posición de la próxima linea
	mov x10, #636
	lsl x10, x10, #2

	mov x13, #4 // Guardo en x13 el indice de cuantas lineas debo pintar
	loop2:
	add x9, x9, x10 // Le sumo a x9 lo necesario para que ahora apunte al primer pixel de la próxima linea
	mov x12, #4 // Guardo en x12 el indice de cuantos pixeles debo pintar en esta linea
	
	pintar_pixel3: // Inicio el loop
	ldur w11, [x9] // Guardo en x11 el color del pixel que quiero pintar
	cmp w11, w7 // Reviso si es del color que tengo permitido pintar
	b.ne else // Si no son iguales, salto la próxima instrucción
	stur w0, [x9] // Pintar pixel requerido
	else:
	sub x12, x12, #1 // Resto un pixel a los pixeles pintados en esta linea
	add x9, x9, #4
	cbnz x12, pintar_pixel3 // Reviso si todavía tengo que pintar pixeles para decidir si seguir pintando o no
	
	sub x13, x13, #1 // Resto uno a la cantidad de lineas que debo pintar
	cbnz x13,loop2 // Reviso si todavía tengo que pintar lineas para decidir si seguir pintando o no

	br lr // Salida de la función	



	// PINTAR ESTRELLAS
	// -------------------------------
	// Argumentos:
	// 	X0 - color que se utilizará para pintar las estrellas
	// 	X1 - posición vertical (eje x) del pixel inicial. Posiciones validas [0-479]
	// 	X2 - posición horizontal (eje y) del pixel inicial. Posiciones validas [0-639]
	//	X4 - dirección de las coordenadas en X de las estrellas
	// 	X5 - dirección de las coordenadas en Y de las estrellas
pintar_estrellas:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH
	
	mov x14, #16 // Contador de cantidad de estrellas que debo pintar
	loop3: // Inicio del loop
	ldur x1, [x4, #0] // Asigno en x1 la dirección en X de la estrella que debo pintar
	ldur x2, [x5, #0] // Asigno en x2 la dirección en Y de la estrella que debo pintar

	// Despinto la estrella anterior
	add x7, xzr, x0
	mov x0, #0x33
	bl estrella

	// Pinto la nueva estrella
	add x0, xzr, x7
	mov x7, #0x33
	sub x1, x1, #1 // Resto uno a x1 para desplazar hacia la izquierda la posición de la estrella
	bl estrella
	
	// Si x1 es 2, le asigno a x1 (X) 480 para que vuelva a dar la vuelta y le asigno a x2 (Y) un número pseudoaleatorio entre 0 y 639 para que las estrellas no sean repetitivas
	cmp x1, #2 
	b.ne else1 // Reviso si x1 es diferente de 2 para saltearme todas las siguientes lineas

	add x1, xzr, x22 //guardo en x1 el 480
 	mov x16, #73 // Guardo el número 73 en x16 (elegido arbitrariamente por ser número de Sheldon)
	madd x16, x2, x16, x7 // Calculo random para obtener algo pseudoaleatorio
	udiv x2, x16, x21 // Divido x16 por 640 (División entera) y lo guardo en x2
	mul x2, x2, x21 // Multiplico la división anterior por 640  
	sub x2, x16, x2 // Guardo en x2 el modulo 640 del número pseudo aleatorio (Número - [Número div 640] * 640)
	stur x2, [x5] // Guardo el valor de x2 en el elemento correspondiente del arreglo

	else1:
	stur x1, [x4] // Guardo el valor de x1 en el elemento correspondiente del arreglo

	add x4, x4, #8 // Paso al siguiente elemento del arreglo de coordenadas en X
	add x5, x5, #8 // Paso al siguiente elemento del arreglo de coordenadas en Y
	sub x14, x14, #1 // Resto uno a la cantidad de estrellas que me faltan pintar
	cbnz x14, loop3 // Reviso si me faltan pintar estrellas todavia


	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr // Salida de la función		


	// ESTRELLA
	// -------------------------------
	// Explicación:
	// 	Hace una columna del color del fondo a la derecha para evitar uno errores graficos
arreglar_bug:
	mov x11, COLOR_FONDO
	mov x1, #638 // Dirección inicial del bug en Y
	mov x2, #0 // Dirección inicial del bug en X
	madd x10, x2, x22, x1 // x + (y * 640)
	add x10, x20, x10, lsl 2 // Dirección de inicio + 4 * [x + (y * 640)]
	mov x12, SCREEN_HEIGH // Cantidad de lineas que hay que pintar
	loop4: // Inicio bucle que pinta 4 pixeles de la linea
	stur w11, [x10]
	stur w11, [x10, #4]
	stur w11, [x10, #8]
	stur w11, [x10, #12]
	add x10, x10, #2560 // Sumo a x10 lo que necesita para llegar a la siguiente linea
	sub x12, x12, #1 // Resto 1 a la cantidad de lineas que me quedan por pintar
	cbnz x12, loop4 // Reviso si me quedan lineas por pintar


	br lr // Salida de la función

	// BASE NAVE
	// -------------------------------
	// Explicación:
	// 	Dibuja la base de la nave espacial (semicirculo)
base_nave:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH	

	movz x0, 0x7DFF
	movk x0, 0x00C7, lsl 16


	mov x1, #80 // Asigno a x1 las coordenadas en X de donde comienzo a dibujar la nave
	mov x2, #300 // Asigno a x2 las coordenadas en Y de donde comienzo a dibujar la nave
	mov x3, #480 // Asigno a x3 la cantidad de pixeles que va a tener la parte más amplia de la nave
	mov x10, #60 // Asigno a x10 la mitad de la cantidad de pixeles que va a tener de altura la nave
	ldr x11, =BASE_PIXELES // Guardo en x11 la dirección de los pasos para dibujar la circunferencia


	loop5: // Inicio el bucle para pintar la parte de abajo de la base de la nave
	ldur x12, [x11, #0] // Guardo en x12 el elemento del arreglo que corresponde
	bl pintar_linea_horizontal // Llamada a la función para pintar la linea
	add x1, x1, x12 // Agrego a la coordenada en X donde dibujo la linea la cantidad que diga segun los pasos para dibujar la circunferencia
	sub x2, x2, #1  // Bajo una coordenada en Y
	lsl x12, x12, #1 // Calculo auxiliar para la próxima linea
	sub x3, x3, x12 // Resto a x3 2 veces lo sumado a x1, para que me quede centrado (el punto más a la izquierda de la linea se corre hacia la derecha "z" pixeles y yo achico la cantidad de pixeles de la linea "2*z")

	sub x10, x10, #1 // Resto 1 a la cantidad de lineas que tengo que hacer
	add x11, x11 , #8 // Paso al siguiente elemento del arreglo de pasos para dibujar la circunferencia
	cbnz x10, loop5 // Reviso si ya hice todas las lineas
	

	mov x1, #80 // Asigno a x1 las coordenadas en X de donde comienzo a dibujar la nave
	mov x2, #300 // Asigno a x2 las coordenadas en Y de donde comienzo a dibujar la nave
	mov x3, #480 // Asigno a x3 la cantidad de pixeles que va a tener la parte más amplia de la nave
	mov x10, #60 // Asigno a x10 la mitad de la cantidad de pixeles que va a tener de altura la nave
	ldr x11, =BASE_PIXELES // Guardo en x11 la dirección de los pasos para dibujar la circunferencia

	loop6: // Inicio el bucle para pintar la parte de arriba de la base de la nave
	ldur x12, [x11, #0] // Guardo en x12 el elemento del arreglo que corresponde
	bl pintar_linea_horizontal // Llamada a la función para pintar la linea
	add x1, x1, x12 // Agrego a la coordenada en X donde dibujo la linea la cantidad que diga segun los pasos para dibujar la circunferencia
	add x2, x2, #1 // Subo una coordenada en Y
	lsl x12, x12, #1 // Calculo auxiliar para la próxima linea
	sub x3, x3, x12 // Resto a x3 2 veces lo sumado a x1, para que me quede centrado (el punto más a la izquierda de la linea se corre hacia la derecha "z" pixeles y yo achico la cantidad de pixeles de la linea "2*z")

	sub x10, x10, #1 // Resto 1 a la cantidad de lineas que tengo que hacer
	add x11, x11 , #8 // Paso al siguiente elemento del arreglo de pasos para dibujar la circunferencia
	cbnz x10, loop6 // Reviso si ya hice todas las lineas


	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr // Salida de la función

	// CUPULA NAVE
	// -------------------------------
	// Explicación:
	// 	Dibuja la cupula de la nave espacial (semicirculo)
cupula_nave:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH	

	movz x0, 0xCAFF
	movk x0, 0x00C0, lsl 16

	movz x4, 0x8db2
	movk x4, 0x86, lsl 16 // guardar color 0x868db2 en X4 para luego llamar a pintar_linea_dependiendo_del_color_del_pixel

	movz x5, 0x7DFF
	movk x5, 0x00C7, lsl 16 // guardar color 0xC77DFF en X5 para luego llamar a pintar_linea_dependiendo_del_color_del_pixel

	mov x1, #160 // Asigno a x1 las coordenadas en X de donde comienzo a dibujar la nave
	mov x2, #256 // Asigno a x2 las coordenadas en Y de donde comienzo a dibujar la nave
	mov x3, #320 // Asigno a x3 la cantidad de pixeles que va a tener la parte más amplia de la nave
	mov x10, #80 // Asigno a x10 la mitad de la cantidad de pixeles que va a tener de altura la nave
	ldr x11, =CUPULA_PIXELES_ARRIBA // Guardo en x11 la dirección de los pasos para dibujar la circunferencia


	loop7: // Inicio el bucle para pintar la parte de abajo de la base de la nave
	ldur x12, [x11, #0] // Guardo en x12 el elemento del arreglo que corresponde
	bl pintar_linea_dependiendo_del_color_del_pixel // Llamada a la función para pintar la linea
	add x1, x1, x12 // Agrego a la coordenada en X donde dibujo la linea la cantidad que diga segun los pasos para dibujar la circunferencia
	sub x2, x2, #1 // Subo una coordenada en Y
	lsl x12, x12, #1 // Calculo auxiliar para la próxima linea
	sub x3, x3, x12 // Resto a x3 2 veces lo sumado a x1, para que me quede centrado (el punto más a la izquierda de la linea se corre hacia la derecha "z" pixeles y yo achico la cantidad de pixeles de la linea "2*z")

	sub x10, x10, #1 // Resto 1 a la cantidad de lineas que tengo que hacer
	add x11, x11 , #8 // Paso al siguiente elemento del arreglo de pasos para dibujar la circunferencia
	cbnz x10, loop7 // Reviso si ya hice todas las lineas
	

	mov x1, #160 // Asigno a x1 las coordenadas en X de donde comienzo a dibujar la nave
	mov x2, #257 // Asigno a x2 las coordenadas en Y de donde comienzo a dibujar la nave
	mov x3, #320 // Asigno a x3 la cantidad de pixeles que va a tener la parte más amplia de la nave
	mov x10, #40 // Asigno a x10 la mitad de la cantidad de pixeles que va a tener de altura la nave
	ldr x11, =CUPULA_PIXELES_ABAJO // Guardo en x11 la dirección de los pasos para dibujar la circunferencia

	loop8: // Inicio el bucle para pintar la parte de arriba de la base de la nave
	ldur x12, [x11, #0] // Guardo en x12 el elemento del arreglo que corresponde
	bl pintar_linea_dependiendo_del_color_del_pixel // Llamada a la función para pintar la linea
	add x1, x1, x12 // Agrego a la coordenada en X donde dibujo la linea la cantidad que diga segun los pasos para dibujar la circunferencia
	add x2, x2, #1  // Bajo una coordenada en Y
	lsl x12, x12, #1 // Calculo auxiliar para la próxima linea
	sub x3, x3, x12 // Resto a x3 2 veces lo sumado a x1, para que me quede centrado (el punto más a la izquierda de la linea se corre hacia la derecha "z" pixeles y yo achico la cantidad de pixeles de la linea "2*z")

	sub x10, x10, #1 // Resto 1 a la cantidad de lineas que tengo que hacer
	add x11, x11 , #8 // Paso al siguiente elemento del arreglo de pasos para dibujar la circunferencia
	cbnz x10, loop8 // Reviso si ya hice todas las lineas


	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr // Salida de la función

luces_nave:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x5, [sp, #16] // PUSH
	stur x4, [sp, #8] // PUSH	
	stur x0, [sp] // PUSH

	ldr x4, =UBIC_LUZ_X
	ldr x5, =UBIC_LUZ_Y
	movz x0, 0xFF00
	movk x0, 0x00FF, lsl 16
	mov x14, #9
	loop11:
	bl pintar_luz_nave //Imprime las luces de la nave
	add x4, x4, #8
	add x5, x5, #8
	sub x14, x14, #1
	cbnz x14, loop11

	ldur x0, [sp] // POP
	ldur x4, [sp, #8] // POP
	ldur x5, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr

pintar_luz_nave:
	sub sp, sp, #32 // PUSH
	stur lr, [sp, #24] // PUSH
	stur x3, [sp, #16] // PUSH
	stur x2, [sp, #8] // PUSH	
	stur x1, [sp] // PUSH

	ldur x1, [x4, #0]
	ldur x2, [x5, #0]
	mov x3, #23 // Asigno a x3 la cantidad de pixeles que va a tener la parte más amplia del foco de la nave
	mov x10, #10 // Asigno a x10 la mitad de la cantidad de pixeles que va a tener de altura del foco de la nave
	ldr x11,=LUZ_PIXELES // Guardo en x11 la dirección de los pasos para dibujar las luces

	loop9: // Inicio el bucle para pintar la parte de abajo de la base de la luz
	ldur x12, [x11, #0] // Guardo en x12 el elemento del arreglo que corresponde
	bl pintar_linea_horizontal // Llamada a la función para pintar la linea
	add x1, x1, x12 // Agrego a la coordenada en X donde dibujo la linea la cantidad que diga segun los pasos para dibujar la circunferencia
	sub x2, x2, #1 // Subo una coordenada en Y
	lsl x12, x12, #1 // Calculo auxiliar para la próxima linea
	sub x3, x3, x12 // Resto a x3 2 veces lo sumado a x1, para que me quede centrado (el punto más a la izquierda de la linea se corre hacia la derecha "z" pixeles y yo achico la cantidad de pixeles de la linea "2*z")

	sub x10, x10, #1 // Resto 1 a la cantidad de lineas que tengo que hacer
	add x11, x11 , #8 // Paso al siguiente elemento del arreglo de pasos para dibujar la circunferencia
	cbnz x10, loop9 // Reviso si ya hice todas las lineas

	ldur x1, [x4, #0]
	ldur x2, [x5, #0]
	mov x3, #23 // Asigno a x3 la cantidad de pixeles que va a tener la parte más amplia del foco de la nave
	mov x10, #10 // Asigno a x10 la mitad de la cantidad de pixeles que va a tener de altura el foco de la nave
	ldr x11, =LUZ_PIXELES// Guardo en x11 la dirección de los pasos para dibujar la circunferencia

	loop10: // Inicio el bucle para pintar la parte de arriba de la base de la nave
	ldur x12, [x11, #0] // Guardo en x12 el elemento del arreglo que corresponde
	bl pintar_linea_horizontal // Llamada a la función para pintar la linea
	add x1, x1, x12 // Agrego a la coordenada en X donde dibujo la linea la cantidad que diga segun los pasos para dibujar la circunferencia
	add x2, x2, #1 // Subo una coordenada en Y
	lsl x12, x12, #1 // Calculo auxiliar para la próxima linea
	sub x3, x3, x12 // Resto a x3 2 veces lo sumado a x1, para que me quede centrado (el punto más a la izquierda de la linea se corre hacia la derecha "z" pixeles y yo achico la cantidad de pixeles de la linea "2*z")

	sub x10, x10, #1 // Resto 1 a la cantidad de lineas que tengo que hacer
	add x11, x11 , #8 // Paso al siguiente elemento del arreglo de pasos para dibujar la circunferencia
	cbnz x10, loop10 // Reviso si ya hice todas las lineas

	ldur x1, [sp] // POP
	ldur x2, [sp, #8] // POP
	ldur x3, [sp, #16] // POP
	ldur lr, [sp, #24] // POP
	add sp,sp, #32 // POP
	br lr

	// PINTA LUZ NAVE
	// -------------------------------
	// Explicación:
	// 	Dibuja un circulo que representa la luz de la nave.

fin:	
	b fin
	
