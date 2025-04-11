.data
resultado:  .word 0   
ponteiro_topo_lista:  .word -1
msg_erro:   .asciz "Entrada inválida!\n"
digite_operador: .asciz "digita o operador:"
barra_ene: .asciz "\n "
digite_numero: .asciz "digite o outro numero:"
nao_pd_zero: .asciz "não pode ser 0\n"
digite_primeiro_numero: .asciz "digite o primeiro numero:"
resultado_e: .asciz "o resultado é:"
.text
.align 2
.globl main

main: 
	la a0,digite_primeiro_numero #carrega string para printar
	li a7,4 #syscall para printar string
	ecall
	
	li a7,5 #syscall para ler int
	ecall
	la s0, resultado #carrega endereço em que será armazenado o resultado
	sw a0,0(s0) #salva o primeiro operando digitado como primeiro resultado
	
loop_calculadora:
	li a7, 4 #syscall para printar string
	la a0, digite_operador #carrega string para printar
	ecall 
	
	#leitura do caracter da operação ou comando
	li a7,12 #syscall para leitura de char
	ecall
	
	#armazena o operador em t0
	mv t0,a0

	#printa quebra de linha
	la a0,barra_ene
	li a7,4
	ecall

	#se for 'f' finaliza o programa
	li t1,'f'
	beq t0, t1,finalizar 
	#se for 'u' realiza o undo
	li t1,'u'
	beq t0,t1,undo
	

	#adiciona na pilha caso não for comando u ou f
	jal adicionar_resultado_na_pilha
	
	#soma
	li t1,'+'
	beq t0,t1,soma	
	#subtração
	li t1,'-'
	beq t0,t1,subtracao	
	#multiplicação
	li t1,'*'
	beq t0,t1,multiplicacao	
	#divisão
	li t1,'/'
	beq t0,t1,divisao	
	#caso não atenda a nenhum dos outros caso vai ao caso de entrada invalida
	jal entrada_invalida

finalizar:
	#encerra o programa
	li a7,10
	ecall

undo:
	#carrega em t1 o ponteiro de topo da lista
	lw t1,ponteiro_topo_lista
	#armazena -1 em t2 para utilizar o valor
	addi t2,zero,-1
	#caso a pilha esteja vazia(ponteiro valor -1) não faz alteração nela
	beq t1,t2, printa_resultado

	#armazena o endereço do ponteiro do topo da lista em t1
	la t1,ponteiro_topo_lista
	#armazena em t2 o valor do ponteiro do topo da lista
	lw t2,0(t1) 
	#carrega em t3 o valor do ponteiro para o penúltimo nó adicionado
	lw t3,0(t2)
	#torna o penúltimo nó o mais recente(topo da pilha)
	sw t3,0(t1)
	#armazena o resultado novo em a0
	lw a0,4(t2)
	j atualiza_resultado



soma:
	#chama função para realizar os procedimentos comuns a todas operações
	jal operacao
	lw t2,0(s0) #carrega o resultado anterior em t2
	add a0,t2,t0 #a0 = t2(resultado velho) + t0(operando)
	j atualiza_resultado

subtracao:
	jal operacao #função comum
	lw t2,0(s0) #carrega o resultado anterior em t2
	sub a0,t2,t0 #a0 = t2(resultado velho) - t0(operando)
	j atualiza_resultado

multiplicacao:
	jal operacao #função comum
	lw t2,0(s0) #carrega o resultado anterior em t2
	mul a0,t2,t0 #a0 = t2(resultado velho) * t0(operando)
	j atualiza_resultado

caso0:#caso tente fazer divisão por 0 
	la a0,nao_pd_zero
	li a7,4 
	ecall

divisao:
	jal operacao #função comum
	beq a0,zero,caso0 #verifica se é divisao por 0
	lw t2,0(s0) #carrega o resultado anterior em t2
	div a0,t2,t0 #a0 = t2(resultado velho) / t0(operando)
	j atualiza_resultado

operacao:
	#printa a mensagem
	la a0, digite_numero
    li a7, 4
    ecall
    
    # lê o proximo int para a operação
    li a7, 5            
    ecall

	#armazena o numero em t0
	mv t0,a0

	#printa quebra de linha 
	la a0,barra_ene
	li a7,4
	ecall
	
	#retorna da função
	jr ra

atualiza_resultado:
	#armazena o endereço de resultado em t1
	la t1, resultado
	#atualiza o resultado
	sw a0,0(t1)
printa_resultado:
	#armazena em t2 o último resultado
	lw t2,resultado
	#printa "o resultado eh"
	la a0,resultado_e
	li a7,4
	ecall

	#printa o resultado
	addi a0,t2,0
	li a7,1
	ecall

	#printa \n
	la a0,barra_ene
	li a7,4
	ecall
	j loop_calculadora

adicionar_resultado_na_pilha:
	#syscall para alocar memória
	li a7,9
	#número de bits a serem alocados(2 words: um ponteiro e um valor)
	li a0,8
	ecall
	#a0 passa a armazenar o endereço da memória alocada

	#carrega o ponteiro do topo da lista t2
	lw t2,ponteiro_topo_lista
	#armazena no novo nó o ponteiro do antigo topo
	sw t2,0(a0)
	#carrega em t2 o último resultado
	lw t2,resultado
	#armazena no novo nó o último resultado
	sw t2,4(a0)
	#carrega em t2 o endereço para o ponteiro do topo da pilha
	la t2, ponteiro_topo_lista
	#autualiza o ponteiro do topo da lista para o endereço do novo no
	sw a0,0(t2)
	#retorna da função
	jr ra

entrada_invalida:
	#printa mensagem de erro
	li a7, 4
	la a0, msg_erro
	ecall
	#faz novamente o loop da calculadora
	j loop_calculadora
    	
    	
    	
    	
