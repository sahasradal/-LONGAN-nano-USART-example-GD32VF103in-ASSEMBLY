include gd32vf103.asm
STACK = 0x20008000
fclk = 8000000   # 8Mhz
baud1_115200 = 4	# integer part of baud
baud2_115200 = 6	# fraction of baud
# 8000000/(16 x 115200)=   8000000/1843200 = 4.340
# mantissa = 4
# fraction = 0.340
# 0.340 x 16 = 5.44 rounded to 6
#==============================================
sp_init:
    	li sp, STACK

USART_INIT:

#Enable portA and portb clocks
        
    	#RCU->APB2EN |= RCU_APB2EN_PAEN | RCU_APB2EN_PBEN;
    	li s0, RCU_BASE_ADDR
    	lw a5, RCU_APB2EN_OFFSET(s0)
    	ori a5, a5, ( (1<<RCU_APB2EN_PAEN_BIT) | (1<<RCU_APB2EN_PBEN_BIT))
    	sw a5, RCU_APB2EN_OFFSET(s0)

#Enable alternate function clock in APB2 register
    
    	#RCU->APB2EN |= RCU_APB2EN_AFEN ;
    	lw a4, RCU_APB2EN_OFFSET(s0)
    	li a5, (1<<RCU_APB2EN_AFEN_BIT) 
    	or a4, a4, a5
    	sw a4, RCU_APB2EN_OFFSET(s0)

#Enable USART1 periphral clock in APB1EN register
    
    	#RCU->APB1EN |=  RCU_APB1EN_USART1EN;
    	lw a4, RCU_APB1EN_OFFSET(s0)
    	li a5, (1<<17)        			#(1<<USART1EN) =  #(1<<17) enable APB1 clock for USART1 by shifting 1 to bit 17
   	or a4, a4, a5
    	sw a4, RCU_APB1EN_OFFSET(s0) 
  

# GPIOB  PA3 configuring as  AF PP input for RX ,GPIOB PA2  configuring as  AF PP output TX
    	li s2, GPIO_BASE_ADDR_A							# PORTA
    	li a1, (1 << 2) | (1 << 3)						# PA2 , PA3
    	sw a1, GPIO_BOP_OFFSET(s2)						# seting PA3 will enable internal pullup resistor		
    	li a1, ((GPIO_MODE_IN_PULL << 12) | (GPIO_MODE_AF_PP_50MHZ << 8))	# GPIO mode enable , PA3 RX input ,PA2 TX alternate function output
    	sw a1, GPIO_CTL0_OFFSET(s2)




#USART config  
    	li a5, USART1_BASE_ADDR 
	li a2,((baud1_115200<<4) | (baud2_115200<<0))		# Baud rate 115200 ,see calculation at the begining of the document
	sw a2, USART_BAUD_OFFSET(a5)		
	li a3, (1<<2)|(1<<3)    				# 0<<WL,1<<REN,1<<TEN , word length = 8 , enable receive , enable transmit
	sw a3, USART_CTL0_OFFSET(a5)
	li a2, (1<<13)						# 1<<UEN enable USART peripheral
	or a3,a3,a2			
	sw a3, USART_CTL0_OFFSET(a5)


loop:
	
	li t0, message						# address of the message label where the string is stored
TX_TX:
	lb a0,0(t0)						# load byte pointed by 0 offset of t0 register to a0 register
	beqz a0,here						# if loaded value in a0 = 0 branch to label "here"
	call USART_TX						# call USART_TX subroutine to transmit a byte
	addi t0,t0,1						# increase address pointer t0 by 1
	j TX_TX							# loop to label TX_TX till a null terminator is loaded
here:
	call delay						# call delay subroutine
	j loop							# repeat again


###USART--FUNCTIONS================================================================================================================

USART_TX:				# transmit a byte
	li a5, USART1_BASE_ADDR
L0:
	lw a1, USART_STAT_OFFSET(a5)
	andi a1,a1, (1<<7)		# 1<<TBE
	beqz a1,L0			# wait till TBE bit is set
	sw a0, USART_DATA_OFFSET(a5)	# load data to data register
	ret
###===============================================================================	
	
USART_RX:  				#receive (single byte)
	li t1,buffer
	li a5, USART1_BASE_ADDR
L1:
	lw a1, USART_STAT_OFFSET(a5)
	andi a1,a1,(1<<5)		# wait till RXNE is set
	beqz a1,L1
	lw a0, I2C_DATA_OFFSET(a5) 	#read data byte from I2C data register
	sw a0, 0(t1)		        #store byte in a0 to memory location buffer
	ret
###=================================================================================
delay:					# delay routine
	li t1,2000000			# load an arbitarary value 20000000 to t1 register		
dloop:
	addi t1,t1,-1			# subtract 1 from t1
	bne t1,zero,dloop		# if t1 not equal to 0 branch to label loop
	ret	
	
###===============================================================================
message:   
string  "My first UART assembly code!"	
EOL:
bytes 0x0d,0x0a,0x00			# '\r','\n',0  (carriage return , newline,null terminator)

	

	align 2 