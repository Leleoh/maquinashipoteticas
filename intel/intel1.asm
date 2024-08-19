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
    board db 64 dup(64 dup(0))  ; Tabuleiro 64x64 inicializado com 0
    buffer db 100 dup(?)        ; Buffer com 100 bytes
	quantidadebytes dw ?

    ;Variáveis para Coordenadas e ID
    x_coord db 0
    y_coord db 0
    id_rainha db 0
	
	;Mensagem para exibir coordenadas e ID
	msg_id db 'ID: $'
    msg_x db 'X: $'
    msg_y db 'Y: $'
    newline db 13,10,'$'

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
    ;lodsb               ; Carregar byte de [SI] em AL e incrementar SI
    ;mov ah, 0Eh         ; Função para exibir caractere
    ;int 10h             ; Interrupção para exibir o caractere
    ;loop loop_impressao     ; Repetir para todos os caracteres lido
    ;Continua a leitura até o fim do arquivo  
	;lea si, buffer
	;mov cx, quantidadebytes
	
percorrendo_buffer:
	mov al, [si]
	cmp al, '#'		;Verifica se é uma linha de posição inicial
	jz 	lendoid_rainha
	inc si
	loop percorrendo_buffer
	jmp fim_programa
	
	
lendoid_rainha:
	;Lendo o ID da rainha
	inc si
	mov al, [si+1] ;Ler o ID da rainha, assumindo que está no índice 2
    sub al, '0'        ;Converter de ASCII para valor numérico
    mov id_rainha, al  ;Armazenar o ID da rainha em id_rainha

	;Pulando para a próxima linha
	;jmp leitura ;TESTAR REMOVER DEPOIS

imprimir:
	;Exibir ID
    lea dx, msg_id
    mov ah, 09h
    int 21h
    mov al, id_rainha
    add al, '0'        ; Converter valor numérico para ASCII
    mov ah, 0Eh        ; Função para exibir caractere
    int 10h            ; Interrupção para exibir o caractere
	
	;Forçando o ID da rainha a ser 5
	;mov al, 6            ; Coloca o valor 5 no registrador AL
	;mov [id_rainha], al   ; Armazena o valor 5 em id_rainha

	;Exibir ID lido para depuração
	;mov al, [id_rainha]
	;add al, '0'           ; Converter valor numérico para ASCII
	;mov ah, 0Eh           ; Função para exibir caractere
	;int 10h               ; Exibir o caractere

 
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



fim_programa:
    ; Fechar o arquivo (certifique-se de que BX ainda contém o handle do arquivo)
    mov ah, 3Eh         ; Função para fechar arquivo
    int 21h             ; Interrupção DOS para fechar arquivo

    ; Finalizar o programa
    mov ah, 4Ch         ; Função para terminar programa
    int 21h             ; Interrupção DOS para encerrar programa

main endp ; Fim do procedimento main
end main  ; Fim
