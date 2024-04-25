;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
; ECE 2560 Final Exam -- Autumn 2023
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

; Configure Timer B0 to throw interrupts
			bis.w	#TBCLR, &TB0CTL				; reset timer
			bis.w	#TBSSEL__ACLK, &TB0CTL		; source is ACLK
			bis.w	#MC__CONTINUOUS, &TB0CTL	; continuous mode
			bis.w	#CNTL__12, &TB0CTL			; counter length = 12 bits
			bis.w	#ID__4, &TB0CTL				; divide freq. by 4
			bis.w	#TBIE, &TB0CTL 				; enable interrupts

; Add your code here
			bis.b #BIT0, &P1OUT				;Set Red
			bis.b #BIT0, &P1DIR				;Set direction

			bic.b #BIT7, &P9OUT				;Clear Green
			bis.b #BIT7, &P9DIR				;Set direction

			bic.w #LOCKLPM5, &PM5CTL0		;Enable power output

			nop
			bis.w #GIE|LPM3, SR				;Low power mode until interrupt
			nop

;-------------------------------------------------------------------------------
; Interrupt Service Routine
;-------------------------------------------------------------------------------
Timer_B0_ISR:

; Add your code here, do not forget to update the interrupt vector

			xor.b #BIT7, &P9OUT				;When B0 triggers interrupt,
			xor.b #BIT0, &P1OUT				;toggle the outputs

			bic.w #TBIFG, &TB0CTL
			reti



;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect ".int50"					;Timer ISR vector
			.short Timer_B0_ISR

            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
