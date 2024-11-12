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

		bsr	Video_DisplayOff
		bsr	System_Default
	; ----------------------------------------------
		lea	file_scrn1_main(pc),a0			; Load MAIN DATA bank
		bsr	System_SetDataBank
		bsr	System_SramInit
		addq.l	#1,(RAM_Save_Counter).w			; Temporal counter
		bsr	System_SramSave				; Save to SRAM/BRAM
	; ----------------------------------------------
	; Load PRINT
		move.l	#ASCII_FONT,d0				; d0 - Font data
		move.w	#DEF_PrintVram,d1
		bsr	Video_PrintInit
		move.l	#ASCII_FONT_W,d0
		move.w	#DEF_PrintVramW,d1
		bsr	Video_PrintInitW
		bsr	Video_PrintDefPal_Fade
	; ----------------------------------------------
		lea	str_MenuText(pc),a0			; Print the title string
		moveq	#1,d0					; X/Y positions 1,1
		moveq	#1,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2		; FG VRAM location
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; FG width
		bsr	Video_PrintW
		bsr	.print_cursor				; Draw counter
		bsr	Video_DisplayOn
	; ----------------------------------------------
		bsr	Video_FadeIn_Full

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	System_Render
		bsr	.print_cursor

	if MCD|MARSCD
		bsr	System_MdMcd_CheckHome
		bcs.s	.exit_shell
	endif
		lea	(Controller_1).w,a6
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.loop
		bsr	Video_FadeOut_Full
		moveq	#0,d0
		move.w	(RAM_SC0_CurrOption).w,d0
		add.w	d0,d0
		move.w	.ex_mode(pc,d0.w),(RAM_ScreenMode).w
		rts

.ex_mode:
		dc.w 7
		dc.w 7
		dc.w 7
		dc.w 7
		dc.w 7

; ------------------------------------------------------

.exit_shell:
		bsr	Video_FadeOut_Full
		bra	System_MdMcd_ExitShell

; ------------------------------------------------------
; Show framecounter and input
; ------------------------------------------------------

.print_cursor:
		lea	str_InputMe(pc),a0
		moveq	#1,d0
		moveq	#3,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; FG width
		bra	Video_PrintW

; ====================================================================
; ------------------------------------------------------
; DATA asset locations
; ------------------------------------------------------

file_scrn1_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2
; file_scrn1_mars:
; 		dc.l DATA_BANK1
; 		dc.b "BNK_MARS.BIN",0
; 		align 2

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

; str_MenuCursorOff:
; 		dc.b "   ",0
; 		align 2
; str_MenuCursor:
; 		dc.b "-->",0
; 		align 2

str_MenuText:
		dc.b "Nikona screen template",$0A
		dc.b 0
		align 2
str_InputMe:
		dc.l pstr_mem(3,RAM_Framecount)
		dc.b " "
		dc.l pstr_mem(1,Controller_1+on_hold)
		dc.b " "
		dc.l pstr_mem(1,Controller_2+on_hold)
		dc.b 0
		align 2

; ====================================================================
