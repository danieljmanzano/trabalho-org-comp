.data
resultado:  .word 0   
ponteiro_topo_lista:  .word -1
operador:   .byte 0 # guarda o operador atual
msg_erro:   .asciz "Entrada inválida!\n"
msg_memoria:.asciz "Erro de alocação de memória. encerrando o programa\n"
digite_operador: .asciz "digita o operador:"
barra_ene: .asciz "\n "
digite_numero: .asciz "digite o outro numero:"
digite_primeiro_numero: .asciz "digite o primeiro numero:"
resultado_e: .asciz "o resultado é:"
.text
.globl main

main: 
    la a0, digite_primeiro_numero
    addi a7, zero, 4
    ecall


    # lê o primeiro numero na inicialização
    li a7, 5 # serviço para ler int
    ecall
    
    # guardo a primeira entrada em resultado
    la t1, resultado 
    sw a0, 0(t1)
    #esta guardado em t1 o inteiro lido
loop_calculadora:

    jal printar_digite_operador
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
    
    #ele adiciona na pilha só apos verificar se é comando pois se for, o numero digitado não conta como resultado anterior, se fizesse isso antes, o undo ia sempre voltar no meso
    jal adicionar_resultado_na_pilha
    
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
    
    la a0, digite_numero
    addi a7, zero, 4
    ecall
    
    # lê o proximo int
    li a7, 5            
    ecall
    addi t3, a0, 0 # t3 = novo número 
    
    
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
atualiza_resultado:	
    add t2, zero, a0
    la a0, resultado_e
    addi a7, zero, 4
    ecall
    #depende de que o resultado esteja em t2 (por algum motivo)
    la t1, resultado
    sw t2, 0(t1) # armazena resultado 
    
    # para printar o resultado
    li a7, 1 
    add a0, zero, t2
    ecall
    
    la a0, barra_ene
    addi a7, zero, 4
    ecall
    
    j loop_calculadora

# operações ----------
soma:
    add a0, t2, t3
    j atualiza_resultado

subtracao:
    sub a0, t2, t3
    j atualiza_resultado

multiplicacao:
    mul a0, t2, t3
    j atualiza_resultado

divisao:
    div a0, t2, t3 # divisão inteira
    j atualiza_resultado
# ------nao comandos
undo:
    #nao quer parametros 
    lw t1, ponteiro_topo_lista
    
    addi t3, zero -1
    la t2, resultado
    lw a0, 0(t2)
    beq t1, t3, atualiza_resultado
    
    la t1, ponteiro_topo_lista
    lw t2, 0(t1) # t2 é um ponteiro pro começo do ultimo item da lista
    #precisamos por o ponteiro da lista pra apontar pro anterior 
    lw t3, 0(t2)
    sw t3, 0(t1)
    #ponteiro_topo_lista = primeiros 4 bytes do endereco apontado por ele
    #falta guardar o resultado anterior em resultado
    lw a0, 4(t2) #pronto, atualiza resultado guarda em resultado o que estiver em t2, por algum motivo
    
    # aqui nos dá um jeito de implementar o undo com os ponteiros	
    j atualiza_resultado

entrada_invalida:
    li a7, 4
    la a0, msg_erro
    ecall
    j loop_calculadora

printar_digite_operador:
    addi a7, zero, 4
    la a0, digite_operador
    ecall
    jr ra

finalizar:
    li a7, 10
    ecall
    
adicionar_resultado_na_pilha:
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
    jr ra
    
# progresso ate o momento: as entradas estao funcionando show da bola e as operaçoes tao sendo feitas bem. basicamente é a calculadora sem o undo
# agora é fazer a parte dificil só rsrs
