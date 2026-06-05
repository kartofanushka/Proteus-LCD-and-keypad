# AVR ATmega32 Keypad to LCD Interfacing System

This repository contains the AVR Assembly firmware and hardware simulation for a matrix keypad scanning and character display system. The project reads input from a $4 \times 4$ matrix keypad, processes the pressed keys via synchronous scanning on an **ATmega32** microcontroller, and displays the corresponding characters on a $16 \times 2$ character LCD (LM016L).

## Features

* **Matrix Keypad Scanning:** Implements sequential row-grounding and column-polling with hardware debounce for a 16-key matrix.
* **Liquid Crystal Display Driver:** Controls an alphanumeric $16 \times 2$ LCD in 8-bit data mode.
* **Persistent Display Tracking:** Dynamically appends inputs onto the LCD grid with character clearing and screen resetting triggered via the 'C' key.
* **Pure Assembly Delays:** Utilizes accurate, cycle-counted delay loops tailored for an 8.0 MHz target clock speed to handle LCD command execution windows.

---
## Simulation Preview

https://github.com/user-attachments/assets/c64bbc58-5c82-4604-a470-b0d61a66d4e7


---

## Hardware Architecture & Configuration

The schematic, modeled and simulated in Proteus (as demonstrated in the file `week9_C.mp4`), uses the following pin mapping configurations:

### 1. Matrix Keypad ($4 \times 4$)

* **Connection:** Wired entirely to **PORTC (PC0 - PC7)**.
* **Pins PC4 - PC7 (Rows):** Configured as outputs. Rows are sequentially pulled down to 0V during the scan phase.
* **Pins PC0 - PC3 (Columns):** Configured as inputs with internal pull-up resistors active. A pressed key grounds the respective column line.

### 2. LCD Display (LM016L)

* **Data Bus:** Connected to **PORTB (PB0 - PB7)** operating in 8-bit interface mode.
* **Control Bus:** Connected to **PORTA** pins:
* `PA5` ➡️ **Register Select (RS)**
* `PA6` ➡️ **Read/Write (RW)**
* `PA7` ➡️ **Enable (EN)**



---

## System Logic Flow

* **Boot Phase:** The system initializes stack pointers, data direction registers, and establishes the LCD operating modes (8-bit bus, multi-line display, cursor configuration).
* **Splash Screen:** Displays a default identification numeric string (`String_ID`) on line 1 and a text string (`String_Name`) on line 2.
* **State Interlock:** The program halts until the user hits the clear key ('C'). Once pressed, the screen wipes and prints the default tracking text (`Key Pressed:`).
* **Polling Loop:** The firmware continuously cycles through the matrix rows. When a low state is caught on a column pin, it triggers a 20ms debounce routine, blocks execution until key release is confirmed, maps the row/column index to an ASCII lookup table, and prints the matching glyph directly onto the cursor's current position.

---

## Memory & Lookup Tables

Character translation and message data are stored directly inside the program memory (.cseg) flash boundaries:

| Structure | Target Data Content / Purpose | Alignment padding |
| --- | --- | --- |
| `Keypad_Array` | `'7'`, `'8'`, `'9'`, `'/'`, `'4'`, `'5'`, `'6'`, `'*'`, `'1'`, `'2'`, `'3'`, `'-'`, `'C'`, `'0'`, `'='`, `'+'` | Implicit array mapping |
| `String_Prompt` | `"Key Pressed:"` | Null-terminated with alignment padding |
