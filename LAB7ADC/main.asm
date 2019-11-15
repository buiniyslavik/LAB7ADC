.include "m328Pdef.inc"  

  ; stack
  ldi r16,low(RAMEND) 
  out spl,r16 
  ldi r16,high(RAMEND)  
  out sph,r16 

  ; allow interrupts
  ldi r16, 0x0f 
  sts EICRA, r16 
  ldi r16, 0x03 
  out EIMSK, r16 

  ; enable internal Vref
  ldi r16,0x40 
  out ACSR,r16 

  ; set portB OUT
  ldi r16,0xFF 
  sts DDRB,r16 

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