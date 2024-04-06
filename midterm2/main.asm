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
			.data
index:		.byte 0							;Play ptr
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.


RED: 		.set	0
GREEN:		.set	1
LENGTH: 	.set 	20

; note the play sequence is a byte array!
play_sqnc: 	.byte	1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1


;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------




			bic.b #BIT0, &P1OUT				;Clear Red
			bis.b #BIT0, &P1DIR				;Set direction

			bic.b #BIT7, &P9OUT				;Clear Green
			bis.b #BIT7, &P9DIR				;Set direction

			bic.w #LOCKLPM5, &PM5CTL0

			bis.b #BIT1, &P1REN				;Configure buttons
			bis.b #BIT1, &P1OUT
			bis.b #BIT1, &P1IE

			bis.b #BIT2, &P1REN
			bis.b #BIT2, &P1OUT
			bis.b #BIT2, &P1IE
			clr.b &P1IFG

			nop
			eint
			nop

			mov.w #0, R4					;Sets initial color
			cmp.b #GREEN, play_sqnc(R4)		;based on first item in sequence
			jnz first_red
			bis.b #BIT7, &P9OUT
			jmp loop

first_red:	bis.b #BIT0, &P1OUT






loop:		jmp loop
			nop


;-------------------------------------------------------------------------------
; Subroutine: delay
;-------------------------------------------------------------------------------
delay:
			push 	#0
countdown:
			decd.w	0(SP)
			jnz		countdown

			add.w	#2, SP
			ret

;-------------------------------------------------------------------------------
; Subroutine: Blink_RED
;-------------------------------------------------------------------------------
blink_RED:
			bis.b #BIT0, &P1OUT				;sets and clears bit
			call #delay
			bic.b #BIT0, &P1OUT
			ret



;-------------------------------------------------------------------------------
; Subroutine: Blink_GREEN
;-------------------------------------------------------------------------------
blink_GREEN:
			bis.b #BIT7, &P9OUT				;sets and clears bit
			call #delay
			bic.b #BIT7, &P9OUT
			ret


;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
P1_ISR:		push R4							;initializes R4 to be an index
			mov.b &index, R4

			cmp.b #GREEN, play_sqnc(R4)		;selects which button to check
			jz	check_red
			bit.b #BIT1, &P1IFG				;checks switch 1 and jumps based
			jnc incorrect					;on the correct answer
			jmp correct




check_red:
			bit.b #BIT2, &P1IFG				;checks switch 2
			jnc incorrect

correct:
			bic.b #BIT0, &P1OUT				;turns off both lights and cycles
			bic.b #BIT7, &P9OUT				;the green
			call #blink_GREEN
			call #delay
			call #blink_GREEN
			call #delay
			call #blink_GREEN
			call #delay
			jmp end_blinks

incorrect:
			bic.b #BIT0, &P1OUT				;turns off both lights and cycles
			bic.b #BIT7, &P9OUT				;red led
			call #blink_RED
			call #delay
			call #blink_RED
			call #delay
			call #blink_RED
			call #delay


end_blinks
			inc.w R4						;increments the index and resets
			cmp.w #LENGTH, R4				;if at max length
			jl not_end
			clr.w R4

not_end:
			cmp.b #GREEN, play_sqnc(R4)		;sets the next light color
			jnz red
			bis.b #BIT7, &P9OUT
			jmp ret_ISR

red:		bis.b #BIT0, &P1OUT


ret_ISR:	mov.w R4, &index				;moves the index back into ram
			pop R4							;and restores R4
			bic.b #BIT1, &P1IFG
			bic.b #BIT2, &P1IFG
			reti
;these will probably be used at some point

;			bit.b #BIT1, &P1IFG				;S1 Pressed g
;			jnc check_s2


;check_s2:	bit.b #BIT2, &P1IFG				;S2 Pressed r
;			jnc ret_ISR
;
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect ".int37"					;ISR vector
			.short P1_ISR

            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
