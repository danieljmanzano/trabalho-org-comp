.data
resultado:  .word 0   
ponteiro_topo_lista:  .word -1
operador:   .byte 0 # guarda o operador atual
msg_erro:   .asciz "Entrada inválida!\n"
msg_memoria:.asciz "Erro de alocação de memória. encerrando o programa\n"

historico:  .word 0 # cabeça da lista (endereço do primeiro nó)
no_atual:   .word 0 # nó sendo usado no momento (comentario pertinente)

.text
.globl main

main: 
    # incialização da lista e do nó
    la t0, historico
    sw zero, 0(t0)        
    la t0, no_atual # endereco da descricao do no atual
    sw zero, 0(t0) # guardar o primeiro byte do no atual

    # lê o primeiro numero na inicialização
    li a7, 5 # serviço para ler int
    ecall
    
    # guardo a primeira entrada em resultado
    la t1, resultado 
    sw a0, 0(t1)
    #esta guardado em t1 o inteiro lido
loop_calculadora:
    # lê o operador (ou comando 'u' ou 'f')
    li a7, 12 # serviço para ler char
    ecall
    
    addi t1, a0, 0
    ecall # essa ecall a mais é para "eliminar" o \n
    addi  a0, t1, 0 # por causa do ultimo ecall, eu faço isso aqui para colocar a operação no a0 denovo (porque senao seria só o \n nele)
    
    la t6, operador
    sb a0, 0(t6) 



    # verifica se é comando
    li t0, 'f'
    beq t1, t0, finalizar
    li t0, 'u'
    beq t1, t0, undo
    #adiciona nos aqui vvvvvvvv
    
    # DEPENDE DE RESULTADO ARMAZENAR O RESULTADO
    
    addi a0, zero, 8 #o tamanho de cada no da lista é 8 (o ponterio pro anterior e o resultado)
    addi a7, zero, 9
    ecall
    
    lw t2, ponteiro_topo_lista
    sw t2, 0(a0) #armazena o ponteiro pro ultimo na vaga pro ponteiro pro anterior
    lw t2, resultado
    sw t2, 4(a0) #armazena o resultado na vaga pro resultado
    la t2, ponteiro_topo_lista
    sw a0, 0(t2)
    
    #adicionar nos aqui ^^^^^^^^^
    
    #só dps que digita o operador que ele salva o que vem antes, ou seja se ta 3+2 ele tem salvo 3 até digitar 5(-) se ele digitar U ele ainda tem 3 como topo da lista
    
    # verifica se é operador válido
    li t0, '+'
    beq t1, t0, operacao
    li t0, '-'
    beq t1, t0, operacao
    li t0, '*'
    beq t1, t0, operacao
    li t0, '/'
    beq t1, t0, operacao
     
    j entrada_invalida
    
operacao:
    
    # lê o proximo int
    li a7, 5            
    ecall
    addi t3, a0, 0 # t3 = novo número 
    
    # executa operação
    la t1, resultado
    lw t2, 0(t1) # carrega o acumulador (resultado)
    la t1, operador
    lb t4, 0(t1) # pega o operador
    
    # decide a operação
    li t1, '+'
    beq t4, t1, soma
    li t1, '-'
    beq t4, t1, subtracao
    li t1, '*'
    beq t4, t1, multiplicacao
    li t1, '/'
    beq t4, t1, divisao
	
    

# operações ----------
soma:
    add t2, t2, t3
    j atualiza_resultado

subtracao:
    sub t2, t2, t3
    j atualiza_resultado

multiplicacao:
    mul t2, t2, t3
    j atualiza_resultado

divisao:
    div t2, t2, t3 # divisão inteira

# -------------------
    
    
atualiza_resultado:
#depende de que o resultado esteja em t2 (por algum motivo)

    la t1, resultado
    sw t2, 0(t1) # armazena resultado 
    
    # para printar o resultado
    li a7, 1 
    addi a0, t2, 0
    ecall
    
    #la t1, ponteiro_topo_lista
    #lw t1, 0(t1)
    #lw a0, 4(t1)
    #ecall
    
    j loop_calculadora

undo:
    lw t1, ponteiro_topo_lista
    
    addi t3, zero -1
    la t2, resultado
    lw t2, 0(t2)
    beq t1, t3, atualiza_resultado
    
    la t1, ponteiro_topo_lista
    lw t2, 0(t1) # t2 é um ponteiro pro começo do ultimo item da lista
    #precisamos por o ponteiro da lista pra apontar pro anterior 
    lw t3, 0(t2)
    sw t3, 0(t1)
    #ponteiro_topo_lista = primeiros 4 bytes do endereco apontado por ele
    #falta guardar o resultado anterior em resultado
    lw t2, 4(t2) #pronto, atualiza resultado guarda em resultado o que estiver em t2, por algum motivo
    
    # aqui nos dá um jeito de implementar o undo com os ponteiros	
    j atualiza_resultado

entrada_invalida:
    li a7, 4
    la a0, msg_erro
    ecall
    j loop_calculadora
    	
aloca_no:
    li a7, 9 # serviço para alocação
    li a0, 16 # numero de bytes para alocar
    # detalhando o numero de bytes usado por nó:
    # o primeiro numero (float) ocupa 4 bytes, o operador 1, o segundo numero 4 tambem e o ponteiro para o nó anterior ocupa 4 (totaliza 13)
    # os outros 3 bytes inclusos na conta ficam após o operador para que todos os campos do nó estejam alinhados em palavras (meio que faz com que o operador esteja ocupando 4 bytes)
    ecall
    jr ra
    
sem_memoria:
    li a7, 4
    la a0, msg_memoria
    ecall

finalizar:
    li a7, 10
    ecall
    
# progresso ate o momento: as entradas estao funcionando show da bola e as operaçoes tao sendo feitas bem. basicamente é a calculadora sem o undo
# agora é fazer a parte dificil só rsrs
