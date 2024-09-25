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

		move.w	#MAX_SC0_OPTIONS,d4
		lea	(Controller_1).w,a6
		lea	(RAM_SC0_CurrOption).w,a5
		move.w	on_press(a6),d7
		btst	#bitJoyDown,d7
		beq.s	.not_down
		addq.w	#1,(a5)
		move.w	(a5),d6
		cmp.w	d4,d6
		ble.s	.not_down
		clr.w	(a5)
.not_down:
		move.w	on_press(a6),d7
		btst	#bitJoyUp,d7
		beq.s	.not_up
		subq.w	#1,(a5)
		tst.w	(a5)
		bpl.s	.not_up
		move.w	d4,(a5)
.not_up:
		move.w	(a5),d0
		move.w	2(a5),d1
		cmp.w	d1,d0
		beq.s	.no_change
		bsr	.print_full
		move.w	(RAM_SC0_CurrOption).w,(RAM_SC0_OldOption).w
.no_change:
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
		dc.w 1
		dc.w 2
		dc.w 3
		dc.w 4
		dc.w 7

; ------------------------------------------------------

.exit_shell:
		bsr	Video_FadeOut_Full
		bra	System_MdMcd_ExitShell

; ------------------------------------------------------
; Show framecounter and input
; ------------------------------------------------------

.print_full:
		lea	str_MenuCursorOff(pc),a0
		moveq	#1,d0
		moveq	#5,d1
		move.w	(RAM_SC0_OldOption).w,d2
		add.w	d2,d2
		add.w	d2,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; FG width
		bsr	Video_PrintW

.print_cursor:
		lea	str_MenuCursor(pc),a0
		moveq	#1,d0
		moveq	#5,d1
		move.w	(RAM_SC0_CurrOption).w,d2
		add.w	d2,d2
		add.w	d2,d1
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

str_MenuCursorOff:
		dc.b "   ",0
		align 2
str_MenuCursor:
		dc.b "-->",0
		align 2

str_MenuText:
		dc.b "Nikona test menu       ROM: \{DATE}",$0A
		dc.b $0A
		dc.b "    Genesis VDP",$0A
		dc.b "    Sega CD stamps",$0A
		dc.b "    32X 2D mode",$0A
		dc.b "    32X 3D mode",$0A
		dc.b "    GEMA sound test"
		dc.b 0
		align 2

; str_InputMe:
; 	if MARS|MARSCD
; 		dc.l pstr_mem(0,sysmars_reg+comm0)
; 		dc.b " "
; 		dc.l pstr_mem(0,sysmars_reg+comm1)
; 		dc.b " "
; 		dc.l pstr_mem(3,RAM_Framecount)
; 	else
; 		dc.b " "
; 	endif
; 		dc.b 0
; 		align 2

; ====================================================================
