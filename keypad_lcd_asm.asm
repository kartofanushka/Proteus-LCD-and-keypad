.include "m32def.inc"

.equ RS = 5
.equ RW = 6
.equ EN = 7

.cseg
.org 0x0000
    rjmp Reset

Reset:
    ldi r16, high(RAMEND)
    out SPH, r16
    ldi r16, low(RAMEND)
    out SPL, r16

    rcall LCD_Init
    rcall Keypad_Init

    ldi r16, 0x80
    rcall LCD_Command
    ldi ZH, high(String_ID<<1)
    ldi ZL, low(String_ID<<1)
    rcall LCD_String

    ldi r16, 0xC0
    rcall LCD_Command
    ldi ZH, high(String_Name<<1)
    ldi ZL, low(String_Name<<1)
    rcall LCD_String

Wait_For_C:
    rcall Keypad_Scan
    cpi r16, 'C'
    brne Wait_For_C

Clear_And_Prompt:
    rcall LCD_Clear
    ldi ZH, high(String_Prompt<<1)
    ldi ZL, low(String_Prompt<<1)
    rcall LCD_String
    ldi r16, 0xC0
    rcall LCD_Command

Main_Loop:
    rcall Keypad_Scan
    cpi r16, 'C'
    breq Clear_And_Prompt
    rcall LCD_Char
    rjmp Main_Loop

LCD_Command:
    out PORTB, r16
    cbi PORTA, RS
    cbi PORTA, RW
    sbi PORTA, EN
    rcall Delay_1us
    cbi PORTA, EN
    ldi r16, 3
    rcall Delay_ms
    ret

LCD_Char:
    out PORTB, r16
    sbi PORTA, RS
    cbi PORTA, RW
    sbi PORTA, EN
    rcall Delay_1us
    cbi PORTA, EN
    ldi r16, 1
    rcall Delay_ms
    ret

LCD_Init:
    in r16, DDRA
    ori r16, (1<<RS)|(1<<RW)|(1<<EN)
    out DDRA, r16
    ldi r16, 0xFF
    out DDRB, r16
    
    ldi r16, 20
    rcall Delay_ms
    
    ldi r16, 0x38
    rcall LCD_Command
    ldi r16, 0x0C
    rcall LCD_Command
    ldi r16, 0x06
    rcall LCD_Command
    rcall LCD_Clear
    ret

LCD_String:
    lpm r16, Z+
    tst r16
    breq LCD_String_End
    rcall LCD_Char
    rjmp LCD_String
LCD_String_End:
    ret

LCD_Clear:
    ldi r16, 0x01
    rcall LCD_Command
    ldi r16, 2
    rcall Delay_ms
    ret

Keypad_Init:
    ldi r16, 0xF0
    out DDRC, r16
    ldi r16, 0x0F
    out PORTC, r16
    ret

Keypad_Scan:
    ldi r17, 0
    ldi r18, 0xEF
Scan_Row:
    out PORTC, r18
    rcall Delay_20us

    sbis PINC, 0
    rjmp Col_0
    sbis PINC, 1
    rjmp Col_1
    sbis PINC, 2
    rjmp Col_2
    sbis PINC, 3
    rjmp Col_3

    inc r17
    cpi r17, 1
    breq Set_Row_1
    cpi r17, 2
    breq Set_Row_2
    cpi r17, 3
    breq Set_Row_3
    rjmp Keypad_Scan 

Set_Row_1: ldi r18, 0xDF 
           rjmp Scan_Row
Set_Row_2: ldi r18, 0xBF 
           rjmp Scan_Row
Set_Row_3: ldi r18, 0x7F 
           rjmp Scan_Row

Col_0: ldi r20, 0 
       rjmp Key_Debounce
Col_1: ldi r20, 1 
       rjmp Key_Debounce
Col_2: ldi r20, 2 
       rjmp Key_Debounce
Col_3: ldi r20, 3 

Key_Debounce:
    ldi r16, 20
    rcall Delay_ms

Wait_Release:
    cpi r20, 0
    breq Wait_C0
    cpi r20, 1
    breq Wait_C1
    cpi r20, 2
    breq Wait_C2
Wait_C3:
    sbis PINC, 3
    rjmp Wait_Release
    rjmp Map_Key
Wait_C0:
    sbis PINC, 0
    rjmp Wait_Release
    rjmp Map_Key
Wait_C1:
    sbis PINC, 1
    rjmp Wait_Release
    rjmp Map_Key
Wait_C2:
    sbis PINC, 2
    rjmp Wait_Release

Map_Key:
    mov r16, r17
    lsl r16
    lsl r16
    add r16, r20
    ldi ZH, high(Keypad_Array<<1)
    ldi ZL, low(Keypad_Array<<1)
    add ZL, r16
    brcc Load_Char
    inc ZH
Load_Char:
    lpm r16, Z
    ret

Delay_ms:
Delay_ms_Loop:
    rcall Delay_1ms
    dec r16
    brne Delay_ms_Loop
    ret

Delay_1ms:
    ldi r24, low(1998)
    ldi r25, high(1998)
Delay_1ms_Inner:
    sbiw r24, 1
    brne Delay_1ms_Inner
    ret

Delay_20us:
    ldi r24, 53
Delay_20us_Loop:
    dec r24
    brne Delay_20us_Loop
    ret

Delay_1us:
    nop
    nop
    nop
    nop
    ret

Keypad_Array:
.db '7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', 'C', '0', '=', '+'

String_ID:
.db "6730340401", 0, 0

String_Name:
.db "ANGELA ABOL", 0

String_Prompt:
.db "Key Pressed:", 0, 0
