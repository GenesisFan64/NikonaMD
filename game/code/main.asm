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

; 			memory 2
; 			ds.b 2
; thisVram_BG		ds.b $419
; thisVram_BG_e		ds.b 0
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
; 		addq.l	#1,(RAM_Save_Counter).w
; 		bsr	System_SramSave				; Save to SRAM/BRAM
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
; 		move.l	#ART_TESTBG,d0
; 		move.w	#cell_num(thisVram_BG),d1
; 		move.w	#cell_num(thisVram_BG_e-thisVram_BG),d2
; 		bsr	Video_LoadArt
; 		lea	(MAP_TESTBG),a0
; 		move.l	#splitw(0,0),d0
; 		move.l	#splitw(320/8,224/8),d1
; 		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_BG),d2
; 		move.w	#thisVram_BG|$4000,d3
; 		bsr	Video_LoadMap
; 		lea	(PAL_TESTBG),a0
; 		moveq	#32,d0
; 		moveq	#16,d1
; 		bsr	Video_FadePal
	if MARS|MARSCD
		lea	(MPal_Test+2),a0
		moveq	#1,d0
		move.w	#255,d1
		moveq	#0,d2
		bsr	Video_MdMars_FadePal
		lea	(MVram_test),a0
		move.l	#0,a1
		move.w	#MVram_test_e-MVram_test,d0
		bsr	Video_MdMars_LoadVram
		lea	(RAM_MdMars_Models).w,a0
		move.l	#MarsObj_test,mmdl_data(a0)
		move.l	#-$200,mmdl_z_pos(a0)
		moveq	#2,d0
		bsr	Video_MdMars_VideoMode
	endif
	; ----------------------------------------------
		lea	str_MenuText(pc),a0
		moveq	#1,d0					; X/Y position: 1,1
		moveq	#1,d1
		move.w	#DEF_PrintVramW|DEF_PrintPal,d2		; FG VRAM location
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3	; FG width
		bsr	Video_PrintW
; 		lea	(RAM_Save_Counter).w,a0
; 		move.l	#3,a1
; 		moveq	#1,d0
; 		moveq	#3,d1
; 		move.w	#DEF_PrintVramW|DEF_PrintPal,d2
; 		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3
; 		bsr	Video_PrintValW
		bsr	.loop_print				; Draw counter
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
		bsr	.loop_print

	if MARS|MARSCD
		lea	(RAM_MdMars_Models).w,a0
		sub.l	#4,mmdl_y_rot(a0)
; 		sub.l	#1,mmdl_x_rot(a0)
	endif

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
		bsr	Video_FadeOut_Full
		move.w	#7,(RAM_ScreenMode).w			; Go to Screen $07: GEMA tester
		rts

; ------------------------------------------------------
; Show framecounter and input
; ------------------------------------------------------

.loop_print:
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
