;==============================================================
;Intel 24/1 - Leonel Hernandez - 585121 - Professor Sérgio
;==============================================================

; Definindo o modelo de memória (small)
.model small

; Definindo o tamanho da pilha para 256 bytes (H100)
.stack 100h

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
	
	;Mensagem para exibir coordenadas e ID
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
    je imprimir    	; Se AX for = 0, pula para fim_programa IMPRIMIR

    ; Exibir o conteúdo lido do arquivo na tela
    mov cx, ax          ; Número de bytes lidos
	mov quantidadebytes, ax
    mov si, offset buffer
	
loop_impressao:
    lodsb               ; Carregar byte de [SI] em AL e incrementar SI
    mov ah, 0Eh         ; Função para exibir caractere
    int 10h             ; Interrupção para exibir o caractere
    loop loop_impressao     ; Repetir para todos os caracteres lido
    ;Continua a leitura até o fim do arquivo  
	lea si, buffer
	mov cx, quantidadebytes
	
percorrendo_buffer:
	mov al, [si]
	cmp al, '#'		;Verifica se é uma linha de posição inicial
	jz 	lendo_linha_inicial
	inc si
	loop percorrendo_buffer
	jmp fim_programa
	
	
lendo_linha_inicial:
	;Lendo o ID da rainha
	inc si
	mov al, [si+1] ;Ler o ID da rainha, assumindo que está no índice 2
    sub al, '0'        ;Converter de ASCII para valor numérico
	;Verifica se o ID da rainha é um número entre 0 e 9   (NÃO FUNCIONA PARA DOIS DÍGITOS)
	cmp id_rainha, 0 	;Compara o valor atual com 0
	jl erro_id			;Se for menor que 0, pula para erro ID
	cmp id_rainha, 9	;Compara o valor atual com 9
	jg erro_id			;Se for maior do que 9, pula para erro ID
    mov id_rainha, al  ;Armazenar o ID da rainha em id_rainha
	
	;Lendo coordenada x
	mov al, [si+3]	;Pegando o primeiro dígito de x, assumindo que ele está no índice 2
	sub al, '0'
	mov x_coord, al
	;Armazenando x_coord no vetor x_positions
	mov bx, contador_pos
	mov [x_positions + bx], al
		
	;Verificando se existe segundo dígito em x
    ;inc si
    ;mov ah, [si]         
    ;cmp ah, ','          
    ;jne ler_segundo_digito_x
	
	;Lendo coordenada y se não houver segundo dígito para X
	;inc si
	;inc si
	;mov al, [si]
	;sub al, '0'
	;mov y_coord, al
	;jmp imprimir
	
;ler_segundo_digito_x:
	;sub ah, '0'         
    ;mov al, x_coord
    ;imul al, 10          ; Multiplicar o primeiro dígito por 10
    ;add al, ah           ; Adicionar o segundo dígito
    ;mov x_coord, al      ; Armazenar a coordenada X completa
	
	; Lendo a coordenada Y
    mov al, [si+5]         ; Ler o primeiro dígito da coordenada Y
    sub al, '0'          ; Converter de ASCII para valor numérico
    mov y_coord, al      ; Armazenar o primeiro dígito em y_coord
	
	;Armazenando y_coord no vetor y_positions
	mov bx, contador_pos
	mov [y_positions + bx], al
	
	
	; Armazenando coordenadas nos vetores
	;Incrementando contador para a próxima rainha
	inc contador_pos
	

	;Verificando se existe segundo dígito em y
	
	
imprimir:
	;Exibir ID, coordenada x e coordenada y
    lea dx, msg_id
    mov ah, 09h
    int 21h
    mov al, id_rainha
    add al, '0'        ; Converter valor numérico para ASCII
    mov ah, 0Eh        ; Função para exibir caractere
    int 10h            ; Interrupção para exibir o caractere
	
	;Exibindo coordenada x
	lea dx, msg_x
	mov ah, 09h
	int 21h
	mov al, x_coord
	add al, '0'
	mov ah, 0Eh
	int 10h
	
	;Exibindo coordenada y
	lea dx, msg_y
	mov ah, 09h
	int 21h
	mov al, y_coord
	add al, '0'
	mov ah, 0Eh
	int 10h
	
	;Exibindo vetor X
	lea dx, vetorx
	mov ah, 09h
	int 21h
	mov al, [x_positions + bx]
	add al, '0'
	mov ah, 0Eh
	int 10h
	
	;Exibindo vetor Y
	lea dx, vetory
	mov ah, 09h
	int 21h
	mov al, [y_positions + bx]
	add al, '0'
	mov ah, 0Eh
	int 10h
	
    ;Pulando para a próxima linha
    lea dx, newline
    mov ah, 09h
    int 21h
	jmp percorrendo_buffer


erro_abertura:
    ; Exibir mensagem de erro ao abrir o arquivo
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
	lea bx, x_positions
	mov dh, [bx + 1]
	lea bx, y_positions
	mov dl, [bx + 1]
    ; Finalizar o programa
    mov ah, 4Ch         ; Função para terminar programa
    int 21h             ; Interrupção DOS para encerrar programa

main endp ; Fim do procedimento main
end main  ; Fim
