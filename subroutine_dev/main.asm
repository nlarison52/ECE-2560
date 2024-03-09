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

			push #4
			push #6

			call #x_plus_y

			add.w #4, SP










main:		jmp main
			nop
;-------------------------------------------------------------------------------
; Subroutine: x_times_y
; Stack Frame:
;				|	PC	| <-SP
; 				|  f[n] | <-4(SP)
; 				|	x	| <-8(SP)
; 				|	y	| <-12(SP)
;
;
; Function takes two 32 bit signed integers in the stack and returns a 32 bit
; signed int to the stack
;-------------------------------------------------------------------------------
x_times_y:
			decd.w SP
			clr.w 4(SP)
			clr.w 6(SP)

loop:
			tst 10(SP)
			jnz skp_tst
			tst 8(SP)
			jz end
skp_tst:
			bit.w #1, 8(SP)
			jz rolls

			add.w 12(SP), 4(SP)
			addc.w 14(SP), 6(SP)

rolls:

			rra.w 10(SP)
			rrc.w 8(SP)

			clrc
			rlc.w 12(SP)
			rlc.w 14(SP)
			jmp loop


end:
			incd.w SP
			ret






;-------------------------------------------------------------------------------
; Subroutine: x_plus_y
; Stack Frame:
;
;				| loc x |<- -4(EBP)
;				| loc y |<- -2(EBP)
;				|EBP/R15|<-EBP/R15
;				|	PC	|<-2(EBP)
; 				|	x	|<-4(EBP)
; 				|	y	| <-6(EBP)
;
;
; Function takes two 32 bit signed integers in the stack and returns a 32 bit
; signed int to the stack
;-------------------------------------------------------------------------------

x_plus_y:	push R15
			mov.w SP, R15
			sub.w #4, SP

			mov.w 4(R15), R4
			mov.w R4, -4(R15)

			mov.w 6(R15), R4
			mov.w R4, -2(R15)

			mov.w -4(R15), R4
			add.w -2(R15), R4





			mov.w R15, SP
			pop R15
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
            
