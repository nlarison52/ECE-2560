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

; All Levels must be able to find the # of iterations for this array
x_array: 	.word 	559, 2063, 7898, 7899, 10044, 1

; This array is more challenging
; Level 2 needs to be able to handle it
; Level 3 must be able to find the # of iterations for this array
;x_array: 	.word 	559, 2063, 7894, 7899, 10001, 1
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
			push R4
			clr.w R4

loop:		cmp #1, R5
			jeq exit
			inc.w R4

			bit.w #1, R5
			jnz odd
			rra.w R5

			bit.w #32768, R5				;This subtracts the leftmost bit
			jz loop							;after rolling due to 1 padding
			sub.w #32768, R5

			jmp loop


odd:		call #x_times_3
			inc.w R5
			jmp loop


exit:		mov.w R4, R5
			pop R4
			ret

;-------------------------------------------------------------------------------
; Subroutine: x_times_3
; Input:  unsigned 16-bit number x in R5 -- changes R5
; Output: unsigned 16-bit number y in R5 -- y = x + x + x
;
; Changes R5 -- all other core registers in R4-R15 unchanged
;-------------------------------------------------------------------------------
x_times_3:
			push 	R6

			mov.w	R5, R6					; R6 = x
			add.w	R6, R6					; R6 = 2x
			add.w	R6, R5					; R5 = 3x

			pop		R6
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
            
