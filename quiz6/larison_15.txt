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
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

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


loop:		jmp loop
			nop


;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
P1_ISR:
			bit.b #BIT1, &P1IFG				;S1 Pressed
			jnc check_s2
			xor.b #BIT7, &P9OUT
			bic.b #BIT1, &P1IFG

			jmp ret_ISR


check_s2:	bit.b #BIT2, &P1IFG				;S2 Pressed
			jnc ret_ISR
			xor.b #BIT0, &P1OUT
			bic.b #BIT2, &P1IFG


ret_ISR:
			reti

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack



;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect ".int37"
			.short P1_ISR

            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            

