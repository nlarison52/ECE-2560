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
            .data                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
            .retainrefs                     ; And retain any sections that have

single: 	.word 0
nums: 		.word 17336, 0x1886, 0x1D6B, 9275, -6454, 0xD5, -21006, 6278
			.word 0x755, 1316, 0x15DE, 0x1D6B, 11488, 0x1D54, 0x4049, 16457
			.word 7508, 60763, 0x269B, 3307, 0x43B8, 0x39C, -4773, 1877
			.word 22479, 0xCEB, 924, 0x6731, 0x57CF, 0xE6CA, -11215, 8121
			.word 0x524, 9883, 0x243B, 44530, 0x1FB9, 24059, 26417, 5598
			.word 0x2CE0, 0x5DFB, 213
new:		.word 0

LENGTH		.set 2*43

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

; Enter your code here
			mov.w #LENGTH, R4


loop:		decd.w R4
			cmp #0, R4
			jn main

			mov.w nums(R4), new(R4)
			jmp loop







main:		jmp main
			nop

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
            
