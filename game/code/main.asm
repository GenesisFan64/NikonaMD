; ===========================================================================
; ----------------------------------------------------------------
; SCREEN CODE
; ----------------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Variables
; ------------------------------------------------------

MAX_SC0_OPTIONS		equ 4

; ====================================================================
; ------------------------------------------------------
; Structs
; ------------------------------------------------------

; ----------------------------------------------
; VRAM Setup
; ----------------------------------------------

; 			memory 2		; Cell $0002
; vramLoc_Backgrnd	ds.b $4C2
; 			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_SC0_CurrOption	ds.w 1
RAM_SC0_OldOption	ds.w 1
.sizeof_this		ds.l 0
			endmemory
			erreport "This screen",.sizeof_this-RAM_ScrnBuff,MAX_ScrnBuff

; ====================================================================
; ------------------------------------------------------
; Init
; ------------------------------------------------------

		bsr	Video_DisplayOff			; Disable VDP Display
		bsr	System_Default				; Default system settings
	; ----------------------------------------------
	; Init/Load save
		bsr	System_SramInit				; Init/Load
		addq.l	#1,(RAM_Save_Counter).w			; Temporal counter
		bsr	System_SramSave				; Save to SRAM/BRAM
	; ----------------------------------------------
	; Init Print
		lea	file_scrn1_main(pc),a0			; Load MAIN DATA bank
		bsr	System_SetDataBank
		move.l	#ASCII_FONT,d0
		move.w	#DEF_PrintVram,d1
		bsr	Video_PrintInit
		move.l	#ASCII_FONT_W,d0
		move.w	#DEF_PrintVramW,d1
		bsr	Video_PrintInitW
		bsr	Video_PrintDefPal_Fade
	; ----------------------------------------------
		lea	str_MenuText(pc),a0
		moveq	#1,d0					; X/Y position 1,1
		moveq	#1,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2		; FG VRAM location
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; FG width
		bsr	Video_PrintW
		bsr	.loop_print				; Draw counter
	; ----------------------------------------------
		bsr	Video_DisplayOn				; Enable VDP Display
		bsr	Video_FadeIn_Full			; Full fade-in w/Delay

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	System_Render
		bsr	.loop_print

	; CD only, check ABC+Start "home" combo
	if MCD|MARSCD
		bsr	System_MdMcd_CheckHome
		bcs.s	.exit_shell
	endif
		lea	(Controller_1).w,a6
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.loop
		bsr	Video_FadeOut_Full
		move.w	#7,(RAM_ScreenMode).w			; Go to Screen $07: GEMA tester
		rts

; ------------------------------------------------------
; Show framecounter and input
; ------------------------------------------------------

.loop_print:
		lea	(RAM_Framecount),a0			; Memory location to print
		move.l	#3,a1					; Display type 3
		moveq	#1,d0					; X pos: 1
		moveq	#4,d1					; Y pos: 2
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2		; VRAM ascii location w/attr
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; VRAM output location and width size
		bsr	Video_PrintValW
		move.w	#DEF_PrintVram|DEF_PrintPal,d2		; small VRAM ver
		addi.w	#8+1,d0					; X pos + 9
		bra	Video_PrintVal

; ------------------------------------------------------
; SCD ONLY
; ------------------------------------------------------

	if MCD|MARSCD
.exit_shell:
		bsr	Video_FadeOut_Full
		bra	System_MdMcd_ExitShell
	endif

; ------------------------------------------------------
; BANK data location
; ------------------------------------------------------

file_scrn1_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2

; ====================================================================
; ------------------------------------------------------
; Objects
; ------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Custom VBlank
; ------------------------------------------------------

; ------------------------------------------------------
; Custom HBlank
; ------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Includes for this screen
; ------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Small data section
; ------------------------------------------------------

str_MenuText:
		dc.b "Nikona screen template",$0A
		dc.b 0
		align 2

; ====================================================================
