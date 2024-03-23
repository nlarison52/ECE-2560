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
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
            .retainrefs                     ; And retain any sections that have


LENGTH:		.set 	256 					; Length of arrays in bytes

sin_Q7: 	.space LENGTH
cos_Q7: 	.space LENGTH
product_Q7: .space LENGTH


;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

;			mov.w	#sin_Q7, R6				; R6 points to sin_Q7
;			mov.w	#cos_Q7, R7				; R7 points to cos_Q7
;			mov.w	#product_Q7, R8 		; R8 points to product_Q7
;			mov.w	#LENGTH/2, R9 			; R9 is number of elements in arrays
;			mov.w	#7, R10 				; R10 is the Q-value
;
;			call	#array_multiply_Qm
			push #-8
			push #-6
			push #0
			call #signed_x_times_y
			pop R4
			add.w #4, SP

main: 		jmp		main


;-------------------------------------------------------------------------------
; Subroutine: array_multiply_Qm
;
; Input: pointer to word array x in R6 -- R6 allowed to be modified
; 		 pointer to word array y in R7 -- R7 allowed to be modified
; 		 pointer to word array z in R8 -- R8 allowed to be modified
;        number of  elements N of x, y, z in R9  -- R9 allowed to be modified
; 		 Q-value for arrays x, y, z in R10 -- R10 is NOT allowed to be modified
;
; Output: subroutine performs pointwise multiplication of the elements
; 		  in arrays x, y, corrects for the m-value, and writes the results to
; 		  array z
; 		  In particular z(i) = x(i)*y(i)/2^m  for 1 <= i <= N
;
; Subroutine is allowed to modify core registers R6, R7, R8, and R9
; Subroutine is not allowed modify any other core registers in R4 – R15
; Subroutine does not access variables defined in .data or .text
;-------------------------------------------------------------------------------
array_multiply_Qm:




;-------------------------------------------------------------------------------
; Subroutine: signed_x_times_y
;
; Stack frame:
; 			-------------
; 			|	  PC	| with call #signed_x_times_y 4(SP)
; 			-------------
; 			|	 x*y	| Output: signed 16-bit number x*y 6(SP)
; 			-------------
; 			|	  y		-8| Input: signed 16-bit number y, abs(y) <= 181 8(SP)
; 			-------------
; 			|	  x 	2| Input: signed 16-bit number x, abs(x) <= 181 10(SP)
; 			-------------
;
; Subroutine does not USE any core registers in R4-R15, only the stack
; Subroutine does not access variables defined in .data or .text
; Caller cleans up the stack
;-------------------------------------------------------------------------------
signed_x_times_y:
			push #0							;2(SP) will be negative flag
			push #1							;0(SP) will be bitmask
			clr.w 6(SP)						;Clearing accumulator
			tst.w 10(SP)
			jge lp							;If negative x, invert
											;Negative y is left alone
			mov.w #1, 2(SP)					;Set negative flag
			inv.w 10(SP)
			inc.w 10(SP)


lp:			bit.w 0(SP), 10(SP)
			jz rolls
			add.w 8(SP), 6(SP)

rolls:		rla.w 8(SP)
			rla.w 0(SP)
			jnc lp


			tst.w 2(SP)						;If negative flag set,
			jz end							;invert result
			inv.w 6(SP)
			inc.w 6(SP)

end:		add.w #4, SP					;Clean up locals
			ret







;-------------------------------------------------------------------------------
; Subroutine: x_div_2powerP
;
; Inputs: signed number x in R12 -- modified by subroutine
;         unsigned number p in R10 -- returned unchanged
;
; Output: signed number in R12 -- R12 = Floor(R12 / 2^R10)
;
; Modifies R12 -- All other core registers in R4-R15 unchanged
;-------------------------------------------------------------------------------
x_div_2powerP:

			push	R10

; Shift x in R12 R6=p times to the right
; Make a loop with R6 as counter
repeat_div_by2:
			tst.w	R10						; Possible to have R10=p=0
			jz 		end_x_div_2powerP		; corresponding to dividing by 1

			rra.w	R12						; shift R12 once
			dec.w	R10 					; account for the shift
			jnz		repeat_div_by2

end_x_div_2powerP:

			pop		R10
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
            
