.include "m328Pdef.inc"  
.equ CLK=16000000  
.equ BAUD=9600 
.equ UBRR0_value = (CLK/(BAUD*16)) - 1 
.org 0  
  jmp Reset 
  Reset:
  ; stack
  ldi r16,low(RAMEND) 
  out spl,r16 
  ldi r16,high(RAMEND)  
  out sph,r16 

;UART things 
;установка частоты приёмо/передачи 
  ldi r16, high(UBRR0_value)  
  sts UBRR0H, r16  
  ldi r16, low(UBRR0_value)  
  sts UBRR0L, r16  
;разрешение передачи 
  ldi r16,(1<<TXEN0)  
  sts UCSR0B,R16  
;длина слова 8 бит 
  ldi r16,(1<< UCSZ00)|(1<< UCSZ01)  
  sts UCSR0C,R16  
;разрешение всех прерываний 
  sei 
; end of UART init

  ; enable internal Vref
  ldi r16,0x40 
  out ACSR,r16 

  ; set portB OUT
  ldi r16,0xFF 
  out DDRB,r16 

VoltOK: 
  in r17,ACSR 
  ; if 5th bit in R17 is set, don't jump
  sbrs r17,5 
	jmp voltlev
  ldi r16,0x00 
  out PORTB,r16 
;PASTED
 ldi zl,low(NorV<<1);память адресуется словами адрес старшие 15 бит, 
;а младший бит - определяет часть слова 
  ldi zh,high(NorV<<1);0 - младший байт, 1 - старший 
  ldi r18,0x07;количество байт в сообщении 
send: 
  lpm r16, Z+ ;чтение слово из таблицы из ПЗУ 
  sts UDR0,r16 ;отправка по uart 
  subi r18,0x01 ;вычитание 1 из счетчика букв 
repeat: 
  lds r17, UCSR0A;чтение содержание регистра 
  bst r17, 5;запись 5 бита (udre) регистра (ucsr0a) в бит t регистра sreg   
  brtc repeat ;если t=0 
  cpi r18,0x00 ;r18=0? 
  breq   VoltOK ;если да, то повторяем сообщение 
  jmp send ;если нет, то  следующий символ ;PASTED
  ; turn the LED off

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
;PASTED
 ldi zl,low(LowV<<1);память адресуется словами адрес старшие 15 бит, 
;а младший бит - определяет часть слова 
  ldi zh,high(LowV<<1);0 - младший байт, 1 - старший 
  ldi r18,0x07;количество байт в сообщении 
sendLow: 
  lpm r16, Z+ ;чтение слово из таблицы из ПЗУ 
  sts UDR0,r16 ;отправка по uart 
  subi r18,0x01 ;вычитание 1 из счетчика букв 
repeatLow: 
  lds r17, UCSR0A;чтение содержание регистра 
  bst r17, 5;запись 5 бита (udre) регистра (ucsr0a) в бит t регистра sreg   
  brtc repeat ;если t=0 
  cpi r18,0x00 ;r18=0? 
  breq   voltlev ;если да, то повторяем сообщение 
  jmp sendLow ;если нет, то  следующий символ 
;PASTED

jmp voltlev


.cseg ;работа с ПЗУ 
LowV: .db "Low Voltage",'\n' ;размещение сообщения в памяти ПЗУ 
NorV: .db "Normal",'\n' ; размещение сообщения в памяти ПЗУ 