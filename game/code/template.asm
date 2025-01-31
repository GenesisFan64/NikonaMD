; ===========================================================================
; ----------------------------------------------------------------
; SCREEN CODE
; ----------------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Variables
; ------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Structs
; ------------------------------------------------------

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
	; Init Print
		move.l	#DATA_BANK0,d0				; Load MAIN DATA bank
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
		moveq	#1,d0					; X/Y position: 1,1
		moveq	#1,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2		; FG VRAM location
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; FG width
		bsr	Video_PrintW
		bsr	.draw_counter				; Draw counter
; 		moveq	#0,d0
; 		moveq	#0,d1
; 		bsr	gemaPlaySeqAuto
	; ----------------------------------------------
		bsr	Video_DisplayOn				; Enable VDP Display
		bsr	Video_FadeIn_Full			; Full fade-in w/Delay

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	System_Render
		bsr	.draw_counter

	; CD only
	; check ABC+Start "home" combo
	if MCD|MARSCD
		bsr	System_MdMcd_CheckHome
		bcs.s	.exit_shell
	endif
		lea	(Controller_1).w,a6
		move.w	pad_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.loop

		bsr	Video_FadeOut_Full			; Fade-out FULL
		move.w	#0,(RAM_ScreenMode).w			; Go to Screen $00
		rts

; ------------------------------------------------------
; Show framecounter and input
; ------------------------------------------------------

.draw_counter:
		lea	(RAM_Framecount).w,a0			; Memory location to print
		move.l	#3,a1					; Display type 3
		moveq	#31,d0
		moveq	#1,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2		; VRAM ascii location w/attr
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; VRAM output location and width size
		bra	Video_PrintValW

; ------------------------------------------------------
; SCD ONLY
; ------------------------------------------------------

	if MCD|MARSCD
.exit_shell:
		bsr	Video_FadeOut_Full
		bra	System_MdMcd_ExitShell
	endif

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
