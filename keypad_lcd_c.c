#define F_CPU 8000000UL 

#include <avr/io.h>
#include <util/delay.h>

#define RS PA5
#define RW PA6
#define EN PA7

char keypad_matrix[4][4] = {
	{'7', '8', '9', '/'},
	{'4', '5', '6', '*'},
	{'1', '2', '3', '-'},
	{'C', '0', '=', '+'}
};

// --- LCD Functions ---

void LCD_Command(unsigned char cmd) {
	PORTB = cmd;                 
	PORTA &= ~(1 << RS);        
	PORTA &= ~(1 << RW);         
	PORTA |= (1 << EN);           
	_delay_us(1);                 
	PORTA &= ~(1 << EN);          
	_delay_ms(3);                 
}

void LCD_Char(unsigned char data) {
	PORTB = data;               
	PORTA |= (1 << RS);    
	PORTA &= ~(1 << RW);          
	PORTA |= (1 << EN);        
	_delay_us(1);                 
	PORTA &= ~(1 << EN);          
	_delay_ms(1);                 
}

void LCD_Init() {
	DDRA |= (1 << RS) | (1 << RW) | (1 << EN); 
	DDRB = 0xFF;                               
	
	_delay_ms(20);                // LCD delay
	
	LCD_Command(0x38);           
	LCD_Command(0x0C);          
	LCD_Command(0x06);            
	LCD_Command(0x01);           
	_delay_ms(2);
}

void LCD_String(const char *str) {
	int i;
	for(i=0; str[i]!=0; i++) {
		LCD_Char(str[i]);
	}
}

void LCD_Clear() {
	LCD_Command(0x01);
	_delay_ms(2);
}

// --- Keypad Functions ---

void Keypad_Init() {
	DDRC = 0xF0;  
	PORTC = 0x0F; 
}

char Keypad_Scan() {
	while (1) {
		for (int row = 0; row < 4; row++) {
			PORTC = ~(1 << (row + 4)) | 0x0F;
			_delay_us(20); 

			// Check
			for (int col = 0; col < 4; col++) {
				if (!(PINC & (1 << col))) { 
					_delay_ms(20); 
					
					while (!(PINC & (1 << col)));
					
					return keypad_matrix[row][col];
				}
			}
		}
	}
}

// --- Main Program ---

int main(void) {
	// 1. Initialization
	LCD_Init();
	Keypad_Init();

	// Startup Message
	LCD_Command(0x80); 
	LCD_String("6730340401");
	
	LCD_Command(0xC0); 
	LCD_String("ANGELA ABOL");

	// Wait until the 'ON/C' button 
	while (Keypad_Scan() != 'C');

	// Clear and prepare for keypad input
	LCD_Clear();
	LCD_String("Key Pressed:");
	LCD_Command(0xC0); 
	
	char key;

	// 4. Infinite loop to scan and print
	while (1) {
		key = Keypad_Scan(); 
		
		if (key == 'C') { // C button to clear the screen
			LCD_Clear();
			LCD_String("Key Pressed:");
			LCD_Command(0xC0);
			} else {
			LCD_Char(key); // Print the pressed key
		}
	}

	return 0;
}
