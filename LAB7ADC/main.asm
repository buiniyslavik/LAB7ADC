.include "m328Pdef.inc"  

  ; stack
  ldi r16,low(RAMEND) 
  out spl,r16 
  ldi r16,high(RAMEND)  
  out sph,r16 

;UART things 
  ; allow interrupts
  ldi r16, 0x0f 
  sts EICRA, r16 
  ldi r16, 0x03 
  out EIMSK, r16 

  ; set speed
  .equ CLK=16000000 
  .equ BAUD=9600 
  .equ UBRR0_value = (CLK/(BAUD*16)) - 1 
  ldi r16, high(UBRR0_value) 
  sts UBRR0H, r16 
  ldi r16, low(UBRR0_value) 
  sts UBRR0L, r16

  ; turn on UART
  ldi r16, (1<<TXEN0)|(1<<RXEN0)|(1<<RXCIE0)           
  sts UCSR0B,R16 
  ldi r16,(1<< UCSZ00)|(1<< UCSZ01)
; end of UART init

  ; enable internal Vref
  ldi r16,0x40 
  out ACSR,r16 

  ; set portB OUT
  ldi r16,0xFF 
  out DDRB,r16 

main: 
  ; read compare result
  in r17,ACSR 
  ; if 5th bit in R17 is set, don't jump
  sbrs r17,5 
	jmp voltlev 

  ; turn the LED off
  ldi r16,0x00 
  out PORTB,r16 
  jmp main  

  ; LED ON state
voltlev: 
  ; turn on the LED
  ldi r16,0xFF 
  out PORTB,r16 

  ; read the result
  in r17,ACSR 
  ; if 5th bit is clear, don't return and stay in voltlev
  sbrc r17,5 
	ret 
jmp voltlev