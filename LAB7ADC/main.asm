.include "m328Pdef.inc"  
  ldi r16,0x40 
  out ACSR,r16 
  ldi r16,0xFF 
  sts DDRB,r16 
main: 
  in r17,ACSR 
  sbrs r17,5 
  jmp voltlev 
  ldi r16,0x00 
  out PORTB,r16 
  jmp main  
voltlev: 
  ldi r16,0xFF 
  out PORTB,r16 
  in r17,ACSR 
  sbrc r17,5 
  ret 
jmp voltlev