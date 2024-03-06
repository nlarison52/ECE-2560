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


; All Levels must be able to find the # of iterations for this array
;x_array: 	.word 	559, 2063, 7898, 7899, 10044, 1

; This array is more challenging
; Level 2 needs to be able to handle it
; Level 3 must be able to find the # of iterations for this array
x_array: 	.word 	559, 2063, 7894, 7899, 10001, 1


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
			jnz read_array





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
loop:		bit.w #0xffff, R6				;Checks MSW is nonzero, skips cmp
			jnz skp_cmp
											;R7 = LSW, R6 = MSW
			cmp #1, R7						;Checks LSW == 1 and exits if so
			jz exit_srt

skp_cmp:	inc.w R5						;Incrementing counter

			bit.w #1, R7					;Check if R7 is odd
			jnz odd

			clrc
			rrc.w R6
			rrc.w R7
			jmp loop


odd:		call #xtimes3					;Odd case handled in subroutine
			inc.w R7
			adc.w R6
			jmp loop

exit_srt:
			pop R7							;Retrieving saved values
			pop R6
			ret

;-------------------------------------------------------------------------------
; Subroutine: x3plus1
; Input:  unsigned 32-bit number x in R7, R6 -- changes R7, R6
; Output: unsigned 32-bit number y in R7, R6 -- y = x + x + x
;
; Changes R6 and R7. All other core registers remain the same
;-------------------------------------------------------------------------------
xtimes3:
					;Preserving registers
			push R9
			push R10
			mov.w #2, R8					;R8 used as loop counter due for
											;code simplifications
			mov.w R6, R9					;Saving values of MSW and LSW
			mov.w R7, R10



			add.w R10, R7					;value (occurs twice)
			addc.w R9, R6
			add.w R10, R7
			addc.w R9, R6


skp_add:	pop R9							;Retrieving values
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
            
