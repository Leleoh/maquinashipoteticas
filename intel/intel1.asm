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
    board db 64 dup(64 dup(0))  ; Tabuleiro 64x64 inicializado com 0
    buffer db 100 dup(?)        ; Buffer com 100 bytes
	quantidadebytes dw ?

    ;Variáveis para Coordenadas e ID
    x_coord db 0
    y_coord db 0
    id_rainha db 0
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
    contador_pos dw 0           ; Contador de posições armazenadas

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
	cmp al, "#"	;Verifica se é uma linha de posição inicial
	jz 	lendo_linha_inicial
	inc si
	loop percorrendo_buffer
	jmp fim_programa
	
	
lendo_linha_inicial:
	
	lea dx, msgok	;Carrega a mensagem de ID inválido
	mov ah, 09h					;Função para exibir string
	int 21h			
	
	add si, 2
	mov al, [si] ;Ler o ID da rainha, assumindo que está no índice 2
    sub al, "0" 
	;Converter de ASCII para valor numérico
	;Verifica se o ID da rainha é um número entre 0 e 9   (NÃO FUNCIONA PARA DOIS DÍGITOS)
	cmp al, 0 	;Compara o valor atual com 0
	jl erro_id			;Se for menor que 0, pula para erro ID
	cmp al, 9	;Compara o valor atual com 9
	jg erro_id			;Se for maior do que 9, pula para erro ID
   
    mov id_rainha, al  ;Armazenar o ID da rainha em id_rainha
	mov ah, 0
	mov di, ax
	
	
	add si, 2
	mov ax, 0
loop_leX: ;Lendo a coordenada X
	mul dez
	add al, [si];Pegando o primeiro dígito de x, assumindo que ele está no índice 2
	sub al, "0"
	inc si
	mov dl, [si]
	cmp dl, ","
	jnz loop_leX
	lea bx, x_positions
	mov [bx+di], al
	
	
	inc si
	mov ax, 0
loop_leY:		;Lendo a coordenada Y
	mul dez
	add al, [si]
    sub al, "0"        ; Ler o primeiro dígito da coordenada Y
    inc si                   ; Converter de ASCII para valor numérico
    mov dl, [si]
	cmp dl, 13
	jnz loop_leY
	lea bx, y_positions
	mov [bx+di], al
	
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
    ; Fechar o arquivo (certifique-se de que BX ainda contém o handle do arquivo)
    mov ah, 3Eh         ; Função para fechar arquivo
    int 21h             ; Interrupção DOS para fechar arquivo
	lea bx, y_positions
	mov cl, [bx+7]	
	lea bx, x_positions
	mov ch, [bx+7]
	
	
	;Encerra programa
    mov ah, 4Ch         ; Função para terminar programa
    int 21h             ; Interrupção DOS para encerrar programa

main endp ; Fim do procedimento main
end main  ; Fim
