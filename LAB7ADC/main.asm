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
;��������� ������� �����/�������� 
  ldi r16, high(UBRR0_value)  
  sts UBRR0H, r16  
  ldi r16, low(UBRR0_value)  
  sts UBRR0L, r16  
;���������� �������� 
  ldi r16,(1<<TXEN0)  
  sts UCSR0B,R16  
;����� ����� 8 ��� 
  ldi r16,(1<< UCSZ00)|(1<< UCSZ01)  
  sts UCSR0C,R16  
;���������� ���� ���������� 
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
 ldi zl,low(NorV<<1);������ ���������� ������� ����� ������� 15 ���, 
;� ������� ��� - ���������� ����� ����� 
  ldi zh,high(NorV<<1);0 - ������� ����, 1 - ������� 
  ldi r18,0x07;���������� ���� � ��������� 
send: 
  lpm r16, Z+ ;������ ����� �� ������� �� ��� 
  sts UDR0,r16 ;�������� �� uart 
  subi r18,0x01 ;��������� 1 �� �������� ���� 
repeat: 
  lds r17, UCSR0A;������ ���������� �������� 
  bst r17, 5;������ 5 ���� (udre) �������� (ucsr0a) � ��� t �������� sreg   
  brtc repeat ;���� t=0 
  cpi r18,0x00 ;r18=0? 
  breq   VoltOK ;���� ��, �� ��������� ��������� 
  jmp send ;���� ���, ��  ��������� ������ ;PASTED
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
 ldi zl,low(LowV<<1);������ ���������� ������� ����� ������� 15 ���, 
;� ������� ��� - ���������� ����� ����� 
  ldi zh,high(LowV<<1);0 - ������� ����, 1 - ������� 
  ldi r18,0x07;���������� ���� � ��������� 
sendLow: 
  lpm r16, Z+ ;������ ����� �� ������� �� ��� 
  sts UDR0,r16 ;�������� �� uart 
  subi r18,0x01 ;��������� 1 �� �������� ���� 
repeatLow: 
  lds r17, UCSR0A;������ ���������� �������� 
  bst r17, 5;������ 5 ���� (udre) �������� (ucsr0a) � ��� t �������� sreg   
  brtc repeat ;���� t=0 
  cpi r18,0x00 ;r18=0? 
  breq   voltlev ;���� ��, �� ��������� ��������� 
  jmp sendLow ;���� ���, ��  ��������� ������ 
;PASTED

jmp voltlev


.cseg ;������ � ��� 
LowV: .db "Low Voltage",'\n' ;���������� ��������� � ������ ��� 
NorV: .db "Normal",'\n' ; ���������� ��������� � ������ ��� 