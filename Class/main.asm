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
			.data							; Assemble into RAM


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

			mov.w #2, R5
			mov.w #7, R6
			call #x_times_y


main:		jmp main
			nop




;-------------------------------------------------------------------------------
; Subroutine: x_times_y
; Input: 	16 bit signed number in R5 and R6
; Output: 	16 bit signed number in R4
;-------------------------------------------------------------------------------
x_times_y:
			push R5							;pushing data to stack
			push R6

			clr.w R4						;clearing result register

test:		bit.w #1, R6					;checks least sig bit in R6
			jz rolls						;if zero, jump to rolls
			add.w R5, R4					;otherwise, add R5 to output
rolls:		rla.w R5						;roll R5 left and R6 right
			rra.w R6
			bit.w #-1, R6					;bit test with 0xffff
			jnz test						;and terminate subroutine if
											;zero is returned due to
											;no 1s left in R6

			pop R6							;retrieving data from stack
			pop R5
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
            
