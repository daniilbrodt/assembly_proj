; -----------------------------------------------------------
; Microcontroller Based Systems homework example
; Author name: Brodt Daniil
; Neptun code: HF14R8
; -------------------------------------------------------------------
; Task description: 
;   Counting the number of "0" bits in a 128 bit pattern being in the internal memory.
;   Input: Start address of the pattern (pointer)
;   Output: The number of "0" bits in 1 register
; -------------------------------------------------------------------


; Definitions
; -------------------------------------------------------------------

; Address symbols for creating pointers

BITFIELD_LEN  EQU 16
BITFIELD_ADDR_IRAM  EQU 0x40

; Test data for input parameters
; (Try also other values while testing your code.)

; Store the bitfield as bytes in the code memory

ORG 0x0070 ; Move if more code memory is required for the program code
BITFIELD_ADDR_CODE:
DB 0x42, 0x1A,  0x7F, 0x80,  0x55, 0xAA,  0xA0, 0xCC,  0x12, 0x13,  0x11, 0x10,  0x05, 0xAA,  0x42, 0x34
; TODO convert hex to bin and count the "0" bits manually to compare results

; Interrupt jump table
ORG 0x0000;
    SJMP  MAIN                  ; Reset vector



; Beginning of the user program, move it freely if needed
ORG 0x0010

; -------------------------------------------------------------------
; MAIN program
; -------------------------------------------------------------------
; Purpose: Prepare the inputs and call the subroutines
; -------------------------------------------------------------------

MAIN:

    ; Prepare input parameters for the subroutine
	MOV R5, #HIGH(BITFIELD_ADDR_CODE)
	MOV R6, #LOW(BITFIELD_ADDR_CODE)
	MOV R7, #BITFIELD_ADDR_IRAM
	CALL CODE2IRAM ; Copy the bitfield from code memory to internal memory
	
	MOV R7, #BITFIELD_ADDR_IRAM
; Infinite loop: Call the subroutine repeatedly

LOOP:
    
    CALL COUNT_0 ; Call Count 0s subroutine
    
    SJMP  LOOP




; ===================================================================           
;                           SUBROUTINE(S)
; ===================================================================           


; -------------------------------------------------------------------
; CODE2IRAM
; -------------------------------------------------------------------
; Purpose: Copy the bitfield from code memory to internal memory
; -------------------------------------------------------------------
; INPUT(S):
;   R5 - Base address of the bitfield in code memory (high byte)
;   R6 - Base address of the bitfield in code memory (low byte)
;   R7 - Base address of the bitfield in the internal memory
; OUTPUT(S): 
;   -
; MODIFIES:
;   [TODO]
; A
; R0
; DPTR
; R2
; -------------------------------------------------------------------

CODE2IRAM:

 mov A, R7 ; move IRAM address to ACC
 mov R0, A ; make an indirect addressing to IRAM address

 mov R2,#BITFIELD_LEN ; using constant for LOOP1 

 mov A, R5 ; high byte to ACC
 mov DPH, A ; set high byte to DPH for DPTR

 mov A, R6 ; low byte to ACC
 mov DPL, A ; ; set low byte to DPL for DPTR


LOOP1:

 CLR A ; to avoid jumping over a cell
 MOVC A, @A+DPTR ; move data from the base address in external memory
 MOV @R0,A ; move data to base address of internal memory via R0

 INC DPTR ; next cell in external memory
 INC R0 ; next cell in internal memory

 DJNZ R2, LOOP1 ; do cycle untill we are done with all 16 bytes of data(HEX numbers)
 
 
; [TODO: Place your code here]
    
    RET

; -------------------------------------------------------------------
; COUNT_0
; -------------------------------------------------------------------
; Purpose: Count "0" bits in the 128 bit wide bitfield
; -------------------------------------------------------------------
; INPUT(S):
;   R7 - Base address of the 128-bit bitfield in the internal memory
; OUTPUT(S): 
;   R5 - Number of "0" bits in the bitfield
; MODIFIES:
;   [TODO]
; R2
; A
; R0
; R5
; R3
; -------------------------------------------------------------------

COUNT_0:

 MOV R5, #0x00 ; reset R5 to 0 count
 MOV R2, #BITFIELD_LEN
 MOV A, R7
 MOV R0, A

 LOOP2:
 
 MOV A, @R0 ; we retrieve data to ACC
 
 MOV R3, #08h ; 1 byte = 8 bits

 LOOP3:

 RLC A ; rotate A to receive a bit for future comparison (zero or one)
 JC NOT_ZERO
 INC R5 ; increments only if zero

 NOT_ZERO: DJNZ R3, LOOP3 ; we have bits left, jump back
 INC R0 ; point next cell

 DJNZ R2, LOOP2 ; loop untill all HEX numbers are covered


; [TODO: Place your code here]
    
    RET

; [TODO: You can also create other subroutines if needed.]


 


; End of the source file
END
