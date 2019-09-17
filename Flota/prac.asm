.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C


TECLA_S EQU 115   ;ASCII letra s es el 115


.data          
teclaSalir DB 0




.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, sea: BYTE, taulell: BYTE, sunk: SDWORD, indexMat: SDWORD, tocat: SDWORD
extern C rowCur: SDWORD, colCur: BYTE, rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy:
   push ebp
   mov  ebp, esp
    Push_all
   

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
   mov eax,[colScreen]
   push eax
   mov eax,[rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
    Pop_all

   mov esp, ebp
   pop ebp
   ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch:
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funci� printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch:
   push ebp
   mov  ebp, esp
    
   Push_all

   call getch_C
   
   mov [carac2],al
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 7 
; i convertir el char de la columna (A..H) a un n�mero entre 0 i 7.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
; rowScreen = rowScreenIni + (row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; col       : columna per a accedir a la matriu sea
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1:
    push ebp
	mov  ebp, esp

	push eax
	
	mov  eax, [row]
	dec  eax
	shl eax,1
	add eax,[rowScreenIni]
	mov [rowScreen], eax

	mov eax,0
	mov  al, [col]
	sub al, 'A'
	shl eax,2
	add eax,[colScreenIni]
	mov [colScreen], eax
	call gotoxy

	
	pop eax
	
	mov esp, ebp
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', o la tecla espai
; i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
; op: Variable que indica en quina opci� del men� principal estem
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMoveP1:
   push ebp
   push eax

   mov  ebp, esp
bucle:   call getch
   mov eax,0
   mov al, [carac2]
   cmp al, ' '
   jne cond2
   mov [carac2],al
   jmp final
cond2:   cmp al,'i'
   jne cond3
   mov [carac2],al
   jmp final
cond3:   cmp al,'l'
   jne cond4
   mov [carac2],al
   jmp final
cond4:   cmp al,'j'
   jne cond5
   mov [carac2],al
   jmp final
cond5:   cmp al,'k'
   jne bucle
   mov [carac2],al
final:   mov esp, ebp

   pop eax
   pop ebp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (rowCur) i (colCur) en funci� de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, (rowCur) i (colCur) nom�s poden 
; prendre els valors [1..8] i [0..7]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : car�cter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; rowCur : fila del cursor a la matriu sea.
; colCur : columna del cursor a la matriu sea.
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorP1:
   push ebp
   mov  ebp, esp 

   cmp [carac2],'i'
   jne condicio2
   cmp [rowCur], 1
   je finalmoveCursorP1
   dec [rowCur]
   jmp finalmoveCursorP1
condicio2: cmp [carac2],'j'
   jne condicio3
   cmp [colCur], 'A'
   je finalmoveCursorP1
   dec [colCur]
   jmp finalmoveCursorP1
condicio3: cmp [carac2], 'k'
	jne condicio4
	cmp[rowCur], 8
	je finalmoveCursorP1
	inc [rowCur]
	jmp finalmoveCursorP1
condicio4: cmp [carac2], 'l'
	jne finalmoveCursorP1
	cmp [colCur],'H'
	je finalmoveCursorP1
	inc [colCur]


finalmoveCursorP1:   mov esp, ebp
   pop ebp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;		carac2   : variable on s�emmagatzema el car�cter llegit
;		rowCur   : Fila del cursor a la matriu sea
;		colCur   : Columna del cursor a la matriu sea
;		row      : Fila per a accedir a la matriu sea
;		col      : Columna per a accedir a la matriu sea
; 
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movContinuoP1:
	push ebp
	mov  ebp, esp
	
	bucleCont: call getch
	cmp [carac2],'s'
	je finalmoveContinuoP1
	cmp [carac2],' '
	je finalmoveContinuoP1
	cmp [carac2],'i'
	jne condicio5
	cmp [rowCur],1
	je bucleCont
	dec [row]
	dec [rowCur]
	call posCurScreenP1
	jmp bucleCont

condicio5: cmp [carac2],'j'
	jne condicio6
	cmp [colCur],'A'
	je bucleCont
	dec [colCur]
	dec [col]
	call posCurScreenP1
	jmp bucleCont

condicio6: cmp [carac2], 'k'
	jne condicio7
	cmp [rowCur],8
	je bucleCont
	inc [rowCur]
	inc [row]
	call posCurScreenP1
	jmp bucleCont

condicio7: cmp [carac2], 'l'
	jne bucleCont
	cmp [colCur],'H'
	je bucleCont
	inc [colCur]
	inc [col]
	call posCurScreenP1
	jmp bucleCont

finalmoveContinuoP1:

	mov esp, ebp
	pop ebp
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'�ndex per a accedir a les matrius en assemblador.
; sea[row][col] en C, �s [sea+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a n�mero).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; col       : columna per a accedir a la matriu sea
; indexMat	: �ndex per a accedir a la matriu sea
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndexP1:
	push ebp
	mov  ebp, esp
	
	push eax

	mov eax, [row]
	dec eax
	shl eax, 3
	mov [indexMat], eax
	mov eax,0
	mov  al, [col]
	sub al, 'A'
	add [indexMat], eax

	pop eax
	
	mov esp, ebp
	pop ebp
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrim una casella de la matriu sea
; En primer lloc calcular la posici� de la matriu corresponent a la
; posici� que ocupa el cursor a la pantalla, cridant a la 
; subrutina calcIndexP1 i mostrar 'T' si hi ha un barco o 'O' si �s aigua
; cridant a la subrutina printch. L'�ndex per a accedir
; a la matriu (sea) el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; rowCur	: fila actual del cursor a la matriu
; col       : columna per a accedir a la matriu sea
; colCur	: columna actual del cursor a la matriu
; indexMat	: �ndex per a accedir a la matriu sea
; tocat		: indica si em tocat un vaixell
; sea		: Matriu 8x8 on tenim les posicions dels borcos. 
; carac		: car�cter per a escriure a pantalla.
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openP1:
	push ebp
	mov  ebp, esp
	
	push ebx

	cmp [carac2], ' '
	jne finalOpenP1

	call calcIndexP1
	mov ebx, [indexMat]

	cmp [taulell+ebx], ' '
	jne finalOpenP1

	cmp [sea+ebx], 1
	jne condAigua

	mov [carac],'T'
	mov [taulell+ebx], 1
	call printch
	call posCurScreenP1
	call sunk_boat
	jmp finalOpenP1

condAigua: mov [carac],'O'
	mov [taulell+ebx], 0
	call printch
	call posCurScreenP1

	finalOpenP1:
	pop ebx

	mov esp, ebp
	pop ebp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l�obertura continua de caselles. S�ha d�utiliitzar
; la tecla espai per a obrir una casella i la 's' per a sortir. 
;
; Variables utilitzades: 
; carac2   : Car�cter introdu�t per l�usuari
; rowCur   : Fila del cursor a la matriu sea
; colCur   : Columna del cursor a la matriu sea
; row      : Fila per a accedir a la matriu sea
; col      : Columna per a accedir a la matriz sea
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openContinuousP1:
	push ebp
	mov  ebp, esp

	bucleOpenContinuous:

	call movContinuoP1
	cmp [carac2], ' '
	jne finalMovContinuoP1
	call openP1
	jmp bucleOpenContinuous

	finalMovContinuoP1:

	mov esp, ebp
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que comprova si un vaixell que hem tocat est� enfonsat
; i en cas afirmatiu marca totes les caselles del vaixell amb una H 
;
; Variables utilitzades: 
;	carac		: Car�cter a imprimir per pantalla
;	rowCur		: Fila del cursor a la matriu sea
;	colCur		: Columna del cursor a la matriu sea
;	row			: Fila per a accedir a la matriu sea
;	col			: Columna per a accedir a la matriz sea
;	sea			: Matriu en la que tenim emmagatzemats el mapa i els bracos
;	indexMat	: Variable que indica la posici� de la matriu sea a la que
;				  volem accedir
;	sunk		: Variable que indica si un barco ha estat enfonsat (1) o no (0)
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sunk_boat:
	push ebp
	mov  ebp, esp

	push eax
	push ebx
	push ecx

	mov eax, 0
	mov ecx, 0
	mov [sunk], 1

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	Comprovem si hem enfonsat el vaixell							  ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	comprova_esquerra:													  ;
	cmp [col], 'A'														  ;
	je comprova_dreta													  ;
	sub [col], 1														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
	cmp [sea+ebx], 1													  ;
	jne tornarCol														  ;
	mov al, [taulell+ebx]												  ;
	cmp al, [sea+ebx]													  ;
	jne canviSunk														  ;
	jmp comprova_esquerra												  ;
																		  ;
	tornarCol:															  ;
	mov cl, [colCur]													  ;
	mov [col], cl														  ;
																		  ;
	comprova_dreta:														  ;
	cmp [col], 'H'														  ;
	je comprova_adalt													  ;
	add [col], 1														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
	cmp [sea+ebx], 1													  ;
	jne tornarCol2														  ;
	mov al, [taulell+ebx]												  ;
	cmp al, [sea+ebx]													  ;
	jne canviSunk														  ;
	jmp comprova_dreta													  ;
																		  ;
	tornarCol2:															  ;
	mov cl, [colCur]													  ;
	mov [col], cl														  ;
																		  ;
	comprova_adalt:														  ;
	cmp [row], 1														  ;
	je comprova_abaix													  ;
	sub [row], 1														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
	cmp [sea+ebx], 1													  ;
	jne tornarRow														  ;
	mov al, [taulell+ebx]												  ;
	cmp al, [sea+ebx]													  ;
	jne canviSunk														  ;
	jmp comprova_adalt													  ;
																		  ;
	tornarRow:															  ;
	mov ecx, [rowCur]													  ;
	mov [row], ecx														  ;
																		  ;
	comprova_abaix:														  ;
	cmp [row], 8														  ;
	je vaixellEnfonsat													  ;
	add [row], 1														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
	cmp [sea+ebx], 1													  ;
	jne vaixellEnfonsat													  ;
	mov al, [taulell+ebx]												  ;
	cmp al, [sea+ebx]													  ;
	jne canviSunk														  ;
	jmp comprova_abaix													  ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	Si entra aqu� vol dir que el vaixell ha estat enfonsat			  ;
	;	Per tant, hem de pintar H als lloc de les T						  ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	vaixellEnfonsat:													  ;
	mov ecx, [rowCur]													  ;
	mov [row], ecx														  ;
																	      ;
	mov [carac], 'H'													  ;
	call posCurScreenP1													  ;
	call printch														  ;
																		  ;
																		  ;
	comprova_esquerra2:													  ;
	cmp [col], 'A'														  ;
	je comprova_dreta2													  ;
	sub [col], 1														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
																		  ;
	cmp [sea+ebx], 1													  ;
	jne tornarCol3														  ;
	call posCurScreenP1													  ;
	call printch														  ;
	jmp comprova_esquerra2												  ;
																		  ;
																		  ;
	tornarCol3:															  ;
	mov cl, [colCur]													  ;
	mov [col], cl														  ;
																		  ;
	comprova_dreta2:													  ;
	add [col], 1														  ;
	cmp [col], 'I'														  ;
	jge tornarCol4														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
																		  ;
	cmp [sea+ebx], 1													  ;
	jne tornarCol4														  ;
	call posCurScreenP1													  ;
	call printch													      ;
	jmp comprova_dreta2													  ;
																		  ;
	tornarCol4:															  ;
	mov cl, [colCur]													  ;
	mov [col], cl														  ;
																		  ;
	comprova_adalt2:													  ;
	sub [row], 1														  ;
	cmp [row], 1														  ;
	jl comprova_abaix2													  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
																		  ;
	cmp [sea+ebx], 1													  ;
	jne tornarRow3														  ;
	call posCurScreenP1													  ;
	call printch														  ;
	jmp comprova_adalt2													  ;
																		  ;
	tornarRow3:															  ;
	mov ecx, [rowCur]													  ;
	mov [row], ecx														  ;
																		  ;
	comprova_abaix2:													  ;
	add [row], 1														  ;
	cmp [row], 8														  ;
	jg finalSunk														  ;
	call calcIndexP1													  ;
	mov ebx, [indexMat]													  ;
																		  ;
	cmp [sea+ebx], 1													  ;
	jne finalSunk														  ;
	call posCurScreenP1													  ;
	call printch														  ;
	jmp comprova_abaix2													  ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	canviSunk:
	mov [sunk], 0

	finalSunk:
	mov cl, [colCur]
	mov [col], cl
	mov ecx, [rowCur]
	mov [row], ecx
	call posCurScreenP1
	cmp [sunk], 1
	jne continuar
	call border
	continuar:
	
	

	pop ecx
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que marca com aigua totes les caselles que envolten un 
; vaixell enfonsat 
;
; Variables utilitzades: 
;		carac    : Car�cter a imprimir per pantalla
;		rowCur   : Fila del cursor a la matriu sea
;		colCur   : Columna del cursor a la matriu sea
;		row      : Fila per a accedir a la matriu sea
;		col      : Columna per a accedir a la matriu sea
;		rowIni	 : Fila on hem fet la tirada
;		colIni	 : Columna on hem fet la tirada
;		sea		 : Matriu en la que tenim emmagatzemats el mapa i els bracos
;		indexMat : Variable que indica la posici� on est� emmagatzemada
;	               la cel�la de la matriu sea a la que volem accedir
;		indexMatIni: Variable que indica la posici� on est� emmagatzemada
;	                 la cel�la de la matriu sea a la que hem fet la tirada
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
border:
	push ebp
	mov  ebp, esp

	push eax
	push ebx
	push ecx

	
	mov [carac], 'O'
	mov eax, [row]
	mov ecx, 0
	mov cl, [col]
	
	cmp [col], 'A'
	je compararDreta10
	dec [col]
	call calcIndexP1
	mov ebx, [indexMat]
	cmp [sea+ebx], 1
	je aiguaHoritzontal
	compararDreta10:
	mov [row], eax
	mov [col], cl
	cmp [col], 'H'
	je aiguaVertical
	inc [col]
	call calcIndexP1
	mov ebx, [indexMat]
	cmp [sea+ebx], 1
	je aiguaHoritzontal
	jmp aiguaVertical

	
	aiguaHoritzontal:
	mov [row], eax
	mov [col], cl
	cmp [col], 'A'
	je continua10
	aiguaHoritzontal2:
	cmp [col], 'A'
	je continua10
	sub [col], 1
	call calcIndexP1
	mov ebx, [indexMat]
	cmp [sea+ebx], 1
	je aiguaHoritzontal2

	startHoritzontal:
	; Ja som a l'esquerra de tot del vaixell
	; Imprimim 3 aigues
	call posCurScreenP1
	call printch
	dec [row]
	cmp [row], 1
	jl pintarAsota
	call posCurScreenP1
	call printch
	pintarAsota:
	add [row], 2
	cmp [row], 8
	jg tornem
	call posCurScreenP1
	call printch
	; Tornem
	tornem:
	dec [row]
	inc [col]
	cmp [col], 'H'
	jg acabatHoritzontal
	continua10:
	call calcIndexP1
	mov ebx, [indexMat]
	cmp [sea+ebx], 1
	jne acabatHoritzontal
	dec [row]
	cmp [row], 1
	jl pintarAsota2
	call posCurScreenP1
	call printch
	pintarAsota2:
	add [row], 2
	cmp [row], 8
	jg tornem
	call posCurScreenP1
	call printch
	jmp tornem

	acabatHoritzontal:
	cmp [col], 'H'
	jg acabatFinal
	call posCurScreenP1
	call printch
	dec [row]
	cmp [row], 1
	jl pintarAsota3
	call posCurScreenP1
	call printch
	pintarAsota3:
	add [row], 2
	cmp [row], 8
	jg acabatFinal
	call posCurScreenP1
	call printch
	jmp acabatFinal

	aiguaVertical:
	mov [row], eax
	mov [col], cl
	cmp [row], 1
	je continua11
	aiguaVertical2:
	cmp [row], 1
	jl continua11
	sub [row], 1
	call calcIndexP1
	mov ebx, [indexMat]
	cmp [sea+ebx], 1
	je aiguaVertical2

	startVertical:
	; Ja som a l'esquerra de tot del vaixell
	; Imprimim 3 aigues
	call posCurScreenP1
	call printch
	dec [col]
	cmp [col], 'A'
	jl pintarDreta4
	call posCurScreenP1
	call printch
	pintarDreta4:
	add [col], 2
	cmp [col], 'H'
	jg tornem2
	call posCurScreenP1
	call printch
	; Tornem
	tornem2:
	dec [col]
	inc [row]
	cmp [row], 8
	jg acabatVertical
	continua11:
	call calcIndexP1
	mov ebx, [indexMat]
	cmp [sea+ebx], 1
	jne acabatVertical
	dec [col]
	cmp [col], 'A'
	jl pintarDreta5
	call posCurScreenP1
	call printch
	pintarDreta5:
	add [col], 2
	cmp [col], 'H'
	jg tornem2
	call posCurScreenP1
	call printch
	jmp tornem2

	acabatVertical:
	cmp [row], 8
	jg acabatFinal
	call posCurScreenP1
	call printch
	dec [col]
	cmp [col], 'A'
	jl pintarDreta6
	call posCurScreenP1
	call printch
	pintarDreta6:
	add [col], 2
	cmp [col], 'H'
	jg acabatFinal
	call posCurScreenP1
	call printch

	acabatFinal:
	mov [row], eax
	mov [col], cl
	call posCurScreenP1
	
	pop ecx
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

END
