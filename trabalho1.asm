.data
resultado:  .word 0   
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
    la t0, no_atual
    sw zero, 0(t0) 

    # lê o primeiro numero na inicialização
    li a7, 5 # serviço para ler int
    ecall
    
    # guardo a primeira entrada em resultado
    la t1, resultado
    sw a0, 0(t1)
	
loop_calculadora:
    # lê o operador (ou comando 'u' ou 'f')
    li a7, 12 # serviço para ler char
    ecall
    
    addi t1, a0, 0
    ecall # essa ecall a mais é para "eliminar" o \n
    addi  a0, t1, 0 # por causa do ultimo ecall, eu faço isso aqui para colocar a operação no a0 denovo (porque senao seria só o \n nele)

    # verifica se é comando
    li t0, 'f'
    beq t1, t0, finalizar
    li t0, 'u'
    beq t1, t0, undo
    
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
    la t1, operador
    sb a0, 0(t1) # armazena o operador
    
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
    la t1, resultado
    sw t2, 0(t1) # armazena resultado 
    
    jal aloca_no
    beqz a0, sem_memoria

    # para printar o resultado
    li a7, 1 
    addi a0, t2, 0
    ecall
    
    j loop_calculadora

undo:
    # aqui nos dá um jeito de implementar o undo com os ponteiros	
    j loop_calculadora

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
