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

LENGTH		.set	2*20


SAD:		.word	0
array: 		.word 	-66, 0, 38, -27, -38, -22, 57, 82, -78, 90, -12, -6, 19, 53
			.word   -32, -31, 25, -44, -43, 44


;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
            .retainrefs                     ; And retain any sections that have

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
; add your code here, submit your results for the array defined above

			mov.w #0, R5					;Index variables
			mov.w #0, R6					;Checking equality of indeces
											;does not matter because
											;abs(x - x) = 0
outlp:		cmp.w #LENGTH, R5				;Checks if R5 end of list
			jz end

			cmp.w #LENGTH, R6				;Checks if R6 end of list
			jnz notMaxR6					;Jumps if R6 not max
			incd.w R5						;Incrememnts R5 if max R6 reached
			mov.w R5, R6					;Resets R6


notMaxR6:	mov.w array(R5), R8				;Moves element into R8
			sub.w array(R6), R8				;Subtracts next value
			jge addVal						;Jumps inverting steps

			inv.w R8						;Returns the absolute value of
			inc.w R8						;negative number

addVal:		add.w R8, SAD					;Adds value to SAD
			incd.w R6						;Move on to next val
			jmp outlp						;Return to top of loop




end:		jmp end							;End state reached if R5 index
			nop								;is at end of list




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
            
