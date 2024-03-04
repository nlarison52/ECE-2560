;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .data                           ; Assemble into data memory.
            .retain                         ; Override ELF conditional linking
            .retainrefs                     ; And retain any sections that have

LENGTH		.set	2*6
MSB			.set 	32768
BITMASK		.set	0xffff

; All Levels must be able to find the # of iterations for this array
;x_array: 	.word 	559, 2063, 7898, 7899, 10044, 1

; This array is more challenging
; Level 2 needs to be able to handle it
; Level 3 must be able to find the # of iterations for this array
x_array: 	.word 	559, 2063, 7894, 7899, 10001, 1
;7894, 10001

k_array: 	.space	LENGTH
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			clr.w	R4

read_array:
			mov.w	x_array(R4), R5
			call	#Collatz
			mov.w	R5, k_array(R4)
			incd.w	R4
			cmp.w	#LENGTH, R4
			jlo		read_array





end:		jmp		end
			nop

;-------------------------------------------------------------------------------
; Subroutine: Collatz
; Input:  unsigned 16-bit number x in R5 -- changes R5
; Output: unsigned 16-bit number k in R5
; 			k is the number of Collatz iterations
; 				x <-- x/2    if x is even
; 				x <-- 3x+1   if x is odd
; 		    performed until x=1
;
; Changes R5 -- all other core registers in R4-R15 unchanged
; Does not access any addressed memory locations
;-------------------------------------------------------------------------------
Collatz:
			push R6							;Pushing to stack for retrieval
			push R7

			mov.w R5, R7					;R6, R7 serve as 2 word regisgter
			clr.w R5						;R5 is the counter register
			clr.w R6
											;MSW = most significant word
loop:		bit.w #BITMASK, R6				;Checks MSW is nonzero, skips cmp
			jnz skp_cmp
											;R7 = LSW, R6 = MSW
			cmp #1, R7						;Checks LSW == 1 and exits if so
			jz exit_srt

skp_cmp:	inc.w R5						;Incrementing counter

			bit.w #1, R7					;Check if R7 is odd
			jnz odd

			rra.w R7						;Divides the LSW
			rra.w R6						;Divides the MSW
			jnc skp_car						;Skips the carry operation if
											;MSW did not have a bit in in the
											;least significant bit

			bit.w #MSB, R7					;Checks the most sig bit in R7
			jnz loop						;if nonzero, it does not need to
											;be added

			add.w #MSB, R7					;If MSB is zero, it must be
			jmp loop						;incremented b/c the bit from
											;MSW bust be rolled over to LSW

skp_car:	bit.w #MSB, R7					;If no carry, MSB in LSW must be
			jz loop							;removed if present because it
			sub.w #MSB, R7					;was added as padding in rra
			jmp loop


odd:		call #x3plus1					;Odd case handled in subroutine
			jmp loop











exit_srt:
			pop R7							;Retrieving saved values
			pop R6
			ret

;-------------------------------------------------------------------------------
; Subroutine: x3plus1
; Input:  unsigned 16-bit number x in R7, R6 -- changes R7, R6
; Output: unsigned 16-bit number y in R5=7, R6 -- y = x + x + x + 1
;
; Changes R6 and R7. All other co
;-------------------------------------------------------------------------------
x3plus1:
			push R8
			push R9
			push R10
			mov.w #2, R8

			mov.w R6, R9
			mov.w R7, R10
lp:


			bit.w #BITMASK, R6
			jz empty_MSW

			add.w R9, R6
			add.w R10, R7
			jnc no_carry
			inc.w R6
			jmp no_carry



empty_MSW:
			add.w R10, R7
			jnc no_carry
			add.w #1, R6


no_carry:
			dec.w R8
			jnz lp

			inc.w R7
			jnc skp_add
			inc.w R6

skp_add:	pop R9
			pop R8
			pop R10
			ret

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
