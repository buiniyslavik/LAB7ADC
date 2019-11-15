.include "m328pdef.inc" 
.def temp=r16 
.def razr1=r17 
.def razr2=r18 
.def package=r19 
.equ CLK=16000000  
.equ BAUD=9600  
.equ UBRR0_value = (CLK/(BAUD*16)) - 1  
.org 0 
  jmp Reset 
.org 0x002A 
  jmp ADC_conv 
Reset: 
  ldi package,0x4E 
  ldi temp,(0<<REFS1)|(1<<REFS0)|(1<<ADLAR)|(1<<MUX3) 
  sts ADMUX,temp 
  ldi temp,(1<<ADEN)|(1<<ADSC)|(1<<ADLAR)|(1<<ADIF)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0) 
  sts ADCSRA,temp 
  ldi r16, high(UBRR0_value)   
  sts UBRR0H, r16  
  ldi r16, low(UBRR0_value)  
  sts UBRR0L, r16  
  ldi r16,(1<<TXEN0)            
  sts UCSR0B,R16  
  ldi r16,(1<< UCSZ00)|(1<< UCSZ01)  
  sts UCSR0C,R16              
  sei 
  ldi r16, 0xff
;  sbi DDRD, 0
;  sbi DDRD, 1
;  sbi DDRB, 5
;  out ddrd, r16
;  out ddrb, r16
;  cbi PORTD, 0
;  cbi PORTD, 1
;  cbi PORTB, 5
main: jmp main 
ADC_conv: 
  lds razr1, ADCL 
  lds razr2, ADCH 
;  cpi razr2, 0xb5 
;  brge ThreeLeds
;  cpi razr2, 0x65
;  brge TwoLeds
;  cpi razr2, 0x15
;  brge OneLed
  ; no leds lol
  ;skip:
;  cbi PORTD, 0
;  cbi PORTD, 1
;  cbi PORTB, 5
  skip:
  sts UDR0,razr2  
  reti

  ThreeLeds:
	sbi PORTD, 0
	sbi PORTD, 1
	sbi PORTB, 5
	jmp skip

  TwoLeds:
;	sbi PORTD, 0
	sbi PORTD, 1
	sbi PORTB, 5
	jmp skip

  OneLed:
;	sbi PORTD, 0
;	sbi PORTD, 1
	sbi PORTB, 5
	jmp skip