;==============================================================
;Intel 24/1 - Leonel Hernandez - 585121 - Professor Sérgio
;==============================================================

; Definindo o modelo de memória (small)
.model small

.stack 

; Declarando as variáveis e o buffers
.data
    ArquivoLido db 'in.txt',0
    msgerroposicao db 'Posicao inicial invalida!',13,10,'$'
    msgerroabertura db 'Erro ao abrir arquivo!',13,10,'$'
	msgerroidrainha db 'Identificador de rainha invalido, deve ser um valor entre 0 e 9!',13,10,'$'
	posicaofinal db 'Posicao final $'
	msgbloqueio1 db ' Rainha $'
	msgbloqueio2 db ' bloqueada pela rainha $'
    board db 64 dup(64 dup(0))  ; Tabuleiro 64x64 inicializado com 0
    buffer db 100 dup(?)        ; Buffer com 100 bytes
	quantidadebytes dw ?

    ;Variáveis para Coordenadas e ID
    x_coord db 0
    y_coord db 0
    id_rainha db 0
	id_rainha_aux dw 0
	dez db 10
	
	;Mensagem para exibir coordenadas e ID
	msgok db "OK $"
	msg_id db 'ID: $'
    msg_x db ' X: $'
    msg_y db ' Y: $'
    newline db 13,10,'$'
	vetorx db ' Vetor X: $'
	vetory db ' Vetor Y: $'
	
	;Variáveis para armazenar as posições iniciais
    x_positions db 10 dup(0)    ; Armazena até 10 coordenadas para x
    y_positions db 10 dup(0)    ; Armazena até 10 coordenadas para y
    contador_pos db 0           ; Contador de posições armazenadas
	
	;Variáveis de movimentação
	qtdmovimentos db 0			;Armazena quantas casas serão movidas
	direcaomovimento db 0		;Armazena a direção de movimento que será feita

	;Variável para contagem de linhas
	linha_atual db 1			;Acompanha para ver em qual linha o evento ocorre (1° Dígito) 0X
	linha_atual2 db 0			;Acompanha para ver em qual linha o evento ocorre (2° Dígito) X0
	contador_loop db 10
;==============================================================
; SEÇÃO DE CÓDIGO ONDE SERÁ DESENVOLVIDO O PROGRAMA
;==============================================================
.code

; Início da main (PROCEDIMENTO PRINCIPAL)
main proc
    ; Inicializar os segmentos de dados
    mov ax, @data
    mov ds, ax

    ; Inicialização e abertura do arquivo
    mov ah, 3Dh         ; Função para abrir arquivo
    mov al, 0           ; Modo leitura
    lea dx, ArquivoLido ; Carrega o endereço do nome do arquivo
    int 21h             ; Interrupção do DOS
    jc erro_abertura    ; Se erro ao abrir, pular para erro_abertura
    mov bx, ax          ; Armazenar o handle do arquivo
	
    ;Leitura do arquivo
leitura:
    mov ah, 3Fh         ; Função para ler arquivo
    lea dx, buffer      ; Buffer para armazenar linha
    mov cx, 100         ; Tamanho do buffer para 100 bytes
    int 21h             ; Interrupção do DOS
    cmp ax, 0           ; Checar se fim do arquivo (Compara o número de bytes lidos com 0)
    ;je imprimir    	; Se AX for = 0, pula para fim_programa IMPRIMIR

	mov quantidadebytes, ax ; Número de bytes lidos
	mov cx, quantidadebytes
    lea si , buffer
	
percorrendo_buffer:
	mov al, [si]
	cmp al, "#"					;Verifica se é uma linha de posição inicial
	jz 	lendo_linha_inicial		;Manda para a leitura de linha de posição inicial
	cmp al, ":" 				;Verifica se é uma linha de movimentação
	jz lendo_linha_movimento	;Manda para a leitura de linha de movimento
	cmp al, 10					;Compara com \n
	je incrementa_linha
							;Avançar índice
volta_loop_buffer:
	inc si
	loop percorrendo_buffer		;Faz o loop para continuar lendo
	jmp fim_programa			;Terminar a leitura
	
incrementa_linha:
	inc linha_atual
	cmp linha_atual, 10
	je incrementa_linha2
	jmp volta_loop_buffer

incrementa_linha2:
	inc linha_atual2
	mov linha_atual, 0
	jmp volta_loop_buffer

;POSIÇÃO INICIAL/IDENTIFICAÇÃO
lendo_linha_inicial:
	
	lea dx, msgok	;Carrega a mensagem de ID inválido
	mov ah, 09h		;Função para exibir string
	int 21h			
	
	add si, 2		;Bota 2 no SI para pegar o índice 2
	mov al, [si] 	;Ler o ID da rainha, assumindo que está no índice 2
    sub al, "0" 	;Converter de ASCII para valor numérico

	;Verifica se o ID da rainha é um número entre 0 e 9 
	;cmp al, 0 			;Compara o valor atual com 0
	;jl erro_id			;Se for menor que 0, pula para erro ID
	;cmp al, 9			;Compara o valor atual com 9
	;jg erro_id			;Se for maior do que 9, pula para erro ID
   
    mov id_rainha, al  	;Armazenar o ID da rainha em id_rainha
	mov ah, 0			;0 na parte "alta de ah para fazer ax"
	mov di, ax			;Salva o ID rainha em di
	
	add si, 2			;Soma dois no si
	mov ax, 0

;Lendo a coordenada X
loop_leX: 
	mul dez
	add al, [si]	;Pegando o primeiro dígito de x, assumindo que ele está no índice 2
	sub al, "0"		;Transformar de ASCII
	inc si			;Avança um índice
	mov dl, [si]	;Salva o índice em dl
	cmp dl, ","		;Compara dl com vírgula
	jnz loop_leX	;Se não for igual, faz o loop
	lea bx, x_positions		;Salva o índice base em bx
	mov [bx+di], al			;Salva x no índice atual da rainha
		
	inc si
	mov ax, 0

;Lendo a coordenada Y
loop_leY:		
	mul dez
	add al, [si]		;Salva o índice atual em al
    sub al, "0"        	;Converte ASCII
    inc si              ;Avança posição
    mov dl, [si]		;Salva posição em dl
	cmp dl, 13			;Compara dl com \r
	jnz loop_leY		;Repete o loop caso a condição
	lea bx, y_positions	;Salva a base do y_positions em bx
	mov [bx+di], al		;Salva o y no índice atual do vetor y
	
	jmp percorrendo_buffer

;MOVIMENTAÇÃO

lendo_linha_movimento:
	;Ler o ID da rainha, assumindo que está no índice 2
	add si, 2		;Índice 2
	mov al, [si] 	;Salva o índice atual em al
    sub al, "0" 	;Converter de ASCII para valor numérico
	
	;Verifica se o ID da rainha é um número entre 0 e 9   (NÃO FUNCIONA PARA DOIS DÍGITOS)
	cmp al, 0 	;Compara o valor atual com 0
	jl erro_id	;Se for menor que 0, pula para erro ID
	cmp al, 9	;Compara o valor atual com 9
	jg erro_id	;Se for maior do que 9, pula para erro ID
   
    mov id_rainha, al   ;Armazenar o ID da rainha em id_rainha
	mov ah, 0			;Preenche o registrador
	mov di, ax			;Move o id_rainha para di
	
	add si, 2			;Índice recebe 2
	mov ax, 0			
	
;Quantidade de casas que serão movidas
loop_distancia: 
	mul dez
	add al, [si]		;Pegando a quantidade de casas que será movida
	sub al, "0"			;Converte ASCII
	inc si				;Próximo índice
	mov dl, [si]		;Salva índice em dl
	cmp dl, ","			;Compara com vírgula
	jnz loop_distancia	;Se não for igual, faz de novo
	mov qtdmovimentos, al	;Salva a quantidade que deverá ser movimentada em qtdmovimentos
	
;Direção de movimento que será percorrida
	inc si				;Avança para o próximo índice
	mov al, [si]		;Salva o índice em al
	cmp al, "N"			;Compara al com Norte
	je movimento_norte	;Pula para movimento norte
	cmp al, "S"			;Compara al com Sul
	je movimento_sul	;Pula para movimento sul
	cmp al, "O"			;Compara al com Oeste
	je movimento_oeste	;Pula para movimento oeste
	cmp al, "L"			;Compara al com Leste
	je movimento_leste	;Pula para movimento leste

;-------------------------------------------------------------
;MOVIMENTA NORTE
movimento_norte:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	cmp al, "E"					;Se for igual a "E", é porque existe +"este"
	je movimento_nordeste		;Verifica se é para o nordeste
	cmp al, "O"					;Se for igual a "O", é porque existe +"oeste"
	je movimento_noroeste		;Verifica se é para o noroeste
	
	lea bx, x_positions
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_norte:
	inc dl					;Aumenta a posição atual de Y, indo para o norte
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica:
	cmp dl, [bx + di]
	je colisao_detectada	;Pula para o tratamento de colisão
jump_colisao:
	inc di					;Próximo índice
	dec contador_loop		;Decrementa contador
	jne loop_verifica		;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_norte			;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, y_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dl		;Salva a posição final em bx
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao
;-----------------------------------------------------------------------
;MOVIMENTA SUL
movimento_sul:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	cmp al, "E"					;Se for igual a "E", é porque existe +"este"
	je movimento_sudeste		;Verifica se é para o nordeste
	cmp al, "O"					;Se for igual a "O", é porque existe +"oeste"
	je movimento_sudoeste		;Verifica se é para o noroeste
	
	lea bx, x_positions
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_sul:
	dec dl					;Diminui a posição atual de Y, indo para o sul
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_sul:
	cmp dl, [bx + di]
	je colisao_detectada_sul	;Pula para o tratamento de colisão
jump_colisao_sul:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_sul		;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_sul		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, y_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dl		;Salva a posição final em bx
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_sul:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_sul
;---------------------------------------------------------------------------
;MOVIMENTO OESTE
movimento_oeste:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	
	lea bx, x_positions
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_oeste:
	dec dh					;Diminui a posição atual de X, indo para o oeste
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_oeste:
	cmp dl, [bx + di]
	je colisao_detectada_oeste	;Pula para o tratamento de colisão
	
jump_colisao_oeste:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_oeste		;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_oeste		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, x_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dh		;Salva a posição final em bx
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_oeste:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_oeste
;------------------------------------------------------------------
;MOVIMENTO LESTE
movimento_leste:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	
	lea bx, x_positions
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_leste:
	inc dh					;Diminui a posição atual de X, indo para o oeste
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_leste:
	cmp dl, [bx + di]
	je colisao_detectada_leste	;Pula para o tratamento de colisão
	
jump_colisao_leste:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_leste		;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_leste		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, x_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dh		;Salva a posição final em bx
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_leste:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_leste
;----------------------------------------------------------------
;MOVIMENTO NORDESTE
movimento_nordeste:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	
	lea bx, x_positions
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_nordeste:
	inc dl					;Incrementa Y
	inc dh					;Incrementa X
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_nordeste:
	cmp dl, [bx + di]
	je colisao_detectada_nordeste	;Pula para o tratamento de colisão
	
jump_colisao_nordeste:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_nordeste		;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_nordeste		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, x_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dh		;Salva a posição final em bx
	lea bx, y_positions
	mov [bx + di], dl
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_nordeste:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_nordeste
;------------------------------------------------------------
;MOVIMENTO NOROESTE
movimento_noroeste:				;NOROESTE
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	
	lea bx, x_positions			
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_noroeste:
	inc dl					;Incrementa Y
	dec dh					;Incrementa X
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_noroeste:
	cmp dl, [bx + di]
	je colisao_detectada_noroeste	;Pula para o tratamento de colisão
	
jump_colisao_noroeste:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_noroeste	;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_noroeste		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, x_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dh		;Salva a posição final em bx
	lea bx, y_positions
	mov [bx + di], dl
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_noroeste:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_noroeste
;---------------------------------------------------------
;MOVIMENTO SUDESTE
movimento_sudeste:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	
	lea bx, x_positions			
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_sudeste:
	dec dl					;Incrementa Y
	inc dh					;Incrementa X
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_sudeste:
	cmp dl, [bx + di]
	je colisao_detectada_sudeste	;Pula para o tratamento de colisão
	
jump_colisao_sudeste:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_sudeste	;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_sudeste		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, x_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dh		;Salva a posição final em bx
	lea bx, y_positions
	mov [bx + di], dl
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_sudeste:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_sudeste
;--------------------------------------------------------
;MOVIMENTO SUDOESTE
movimento_sudoeste:
	mov id_rainha_aux, di
	inc si						;Avança para ver se existe próxima letra E/O
	mov al, [si]				;Salva o índice atual em al
	
	lea bx, x_positions			
	mov dh, [bx + di]
	lea bx, y_positions			;Bota em bx o índice 0 do vetor y
	mov dl, [bx + di]			;Carrega em DL o Y da rainha atual
	mov cx, 0					;
	mov cl, qtdmovimentos		;Salva em CX quantas casas devem ser percorridas
	lea bx, y_positions			;Move para bx o índice base do y_positions
	
loop_sudoeste:
	dec dl					;Incrementa Y
	dec dh					;Incrementa X
	mov di, 0				;Zera di
	mov contador_loop, 10	;Deixa contador com 10
	
;Loop para verificar a igualdade do Y
loop_verifica_sudoeste:
	cmp dl, [bx + di]
	je colisao_detectada_sudeste	;Pula para o tratamento de colisão
	
jump_colisao_sudoeste:
	inc di						;Próximo índice
	dec contador_loop			;Decrementa contador
	jne loop_verifica_sudoeste	;Se não for igual, itera o vetor novamente
	
	;Se não há colisão, segue o jogo
	loop loop_sudeste		;Continua o loop, decrementando até que cx (qtd movimento) chegue a 0
	
	;Atualiza a posição final após o movimento no vetor
	lea bx, x_positions		;Carrega o y_positions em bx
	mov di, id_rainha_aux
	mov [bx + di], dh		;Salva a posição final em bx
	lea bx, y_positions
	mov [bx + di], dl
	jmp fim_movimento		;Termina a movimentação
	
colisao_detectada_sudoeste:
	;Lógica para lidar com a colisão
	lea bx, x_positions
	mov al, [bx + di]		;Movendo para AL o x da rainha que estou decrementado
	cmp dh, al				;Se der 0 é porque o x é o mesmo, colisão certa
	je mensagem_colisao		;Pula para avisar qual rainha/linha deu erro
	jmp jump_colisao_sudoeste
;----------------------------------------------------------------------------


mensagem_colisao:
	;Exibindo a mensagem de colisão	
	mov dl, 13
	mov ah, 02h
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h
	
	mov dl, "["
	mov ah, 02h					
	int 21h						
	mov dl, linha_atual2
	add dl, "0"
	mov ah, 02h
	int 21h
	
	mov dl, linha_atual
	add dl, "0"
	mov ah, 02h
	int 21h
	
	mov dl, "]"
	mov ah, 02h					
	int 21h	
	
	lea dx, msgbloqueio1
	mov ah, 09h
	int 21h
	mov dx, id_rainha_aux
	add dx, '0'
	mov ah, 02h
	int 21h
	
	lea dx, msgbloqueio2
	mov ah, 09h
	int 21h
	
	mov dx, di
	add dx, '0'
	mov ah, 02h
	int 21h

	jmp fim_movimento

fim_movimento:
	jmp percorrendo_buffer
;==========================================================
	
erro_abertura:
   ;Exibir mensagem de erro ao abrir o arquivo
   lea dx, msgerroabertura
   mov ah, 9h
   int 21h
   jmp fim_programa

erro_id:
	;Exibir mensagem de erro para ID inválido
	lea dx, msgerroidrainha		;Carrega a mensagem de ID inválido
	mov ah, 09h					;Função para exibir string
	int 21h						;Interrupção para exibir o Erro
	jmp fim_programa


	

	
fim_programa:

imprimindo_posicoes_finais:
	mov cx, 10
	mov si, 0
	
	lea dx, posicaofinal
	mov ah, 09h
	int 21h
	
	
	
loop_posicoes_finais:

	mov dl, 13
	mov ah, 02h
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h
	
	lea dx, msgbloqueio1
	mov ah, 09h
	int 21h
	
	mov dx, si
	add dl, '0'
	mov ah, 02h
	int 21h
	
	mov dl, "("
	mov ah, 02h					
	int 21h			
	
	
	
	
	
	
	
	lea bx, x_positions

	mov dl, [bx + si]
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, ','
	mov ah, 02h
	int 21h
	lea bx, y_positions

	mov dl, [bx + si]
	add dl, '0'
	mov ah, 02h
	int 21h
	mov dl, ")"
	mov ah, 02h					
	int 21h	
	inc si
	loop loop_posicoes_finais
	
	
	








    ; Fechar o arquivo (certifique-se de que BX ainda contém o handle do arquivo)
    mov ah, 3Eh         ; Função para fechar arquivo
    int 21h             ; Interrupção DOS para fechar arquivo
	lea bx, y_positions
	mov cl, [bx+7]	
	lea bx, x_positions
	mov ch, [bx+7]
	
	;mov dl, qtdmovimentos
	;mov dl, linha_atual
	;Encerra programa
    mov ah, 4Ch         ; Função para terminar programa
    int 21h             ; Interrupção DOS para encerrar programa

main endp ; Fim do procedimento main
end main  ; Fim
