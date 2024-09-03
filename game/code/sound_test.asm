; ===========================================================================
; ----------------------------------------------------------------
; GEMA SOUND TESTER
; ----------------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Variables
; ------------------------------------------------------

MAX_SNDPICK		equ 7

; ====================================================================
; ------------------------------------------------------
; Structs
; ------------------------------------------------------

; test 			struct
; x_pos			ds.w 1
; y_pos			ds.w 1
; 			endstuct

; ====================================================================
; ------------------------------------------------------
; This mode's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_MapScrlBuff		ds.b $200
RAM_CurrPick		ds.w 1
RAM_LastPick		ds.w 1
RAM_GemaArg0		ds.w 1
RAM_GemaArg1		ds.w 1
RAM_GemaArg2		ds.w 1
RAM_GemaArg3		ds.w 1
RAM_GemaArg4		ds.w 1
RAM_GemaArg5		ds.w 1
RAM_GemaArg6		ds.w 1
RAM_ChnlLinks		ds.w 26
sizeof_thisbuff		ds.l 0
			endmemory

	erreport "THIS SCREEN",sizeof_thisbuff-RAM_ScrnBuff,MAX_ScrnBuff

; ====================================================================
; ------------------------------------------------------
; Init
; ------------------------------------------------------

		bsr	Video_DisplayOff
		bsr	System_Default
	; ----------------------------------------------
	; Load assets

		lea	file_scrn1_main(pc),a0		; ** LOAD BANK **
		bsr	System_SetDataBank
	; ----------------------------------------------
		move.l	#ASCII_FONT,d0			; Load and setup PRINT system
		move.w	#DEF_PrintVram|$6000,d1
		bsr	Video_PrintInit
		move.l	#ASCII_FONT_W,d0
		move.w	#DEF_PrintVramW|$6000,d1
		bsr	Video_PrintInitW
		lea	(RAM_PaletteFade+$60).w,a0	; Palette line 4:
		move.w	#$0000,(a0)+			; black (background)
		move.w	#$0EEE,(a0)+			; white
		move.w	#$0888,(a0)+			; gray

		lea	str_TesterTitle(pc),a0
		moveq	#1,d0
		moveq	#1,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bsr	Video_PrintW
		lea	str_TesterInfo(pc),a0
		moveq	#1,d0
		moveq	#5,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bsr	Video_Print
		bsr	.show_cursor

	; ----------------------------------------------
		bsr	gemaReset				; Load default GEMA sound data
		move.w	#215,(RAM_GemaArg6).w
		move.w	#215,d0
		bsr	gemaSetBeats
; 		moveq	#1,d0
; 		bsr	gemaPlaySeq

	; ----------------------------------------------
		bsr	.show_me
; 		bsr	.steal_vars
		bsr	Object_Run
	; ----------------------------------------------
		bsr	Video_DisplayOn
		bsr	Video_FadeIn_Full

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	System_Render
		bsr	.show_cursor
; 		bsr	Object_Run
; 		lea	str_Info(pc),a0
; 		moveq	#31,d0
; 		moveq	#26,d1
; 		move.w	#DEF_VRAM_FG,d2
; 		move.w	#DEF_HSIZE_64,d3
; 		bsr	Video_Print

; 	; Controls

		lea	(Controller_1).w,a6
		lea	(RAM_CurrPick).w,a5
	; UP/DOWN
		move.w	on_hold(a6),d7
		andi.w	#JoyA+JoyB+JoyC,d7
		bne.s	.n_up
		move.w	on_press(a6),d7
		btst	#bitJoyDown,d7
		beq.s	.n_down
		addq.w	#1,(a5)
		cmp.w	#MAX_SNDPICK,(a5)		; MAX OPTIONS
		ble.s	.n_downd
		clr.w	(a5)
.n_downd:
		bsr.s	.show_me
.n_down:
		move.w	on_press(a6),d7
		btst	#bitJoyUp,d7
		beq.s	.n_up
		subq.w	#1,(a5)
		bpl.s	.n_ups
		move.w	#MAX_SNDPICK,(a5)
.n_ups:
		bsr.s	.show_me
.n_up:
		move.w	(RAM_CurrPick).w,d7
		lsl.w	#2,d7
		jsr	.jump_list(pc,d7.w)
		tst.w	(RAM_ScreenMode).w	; Check -1
		bpl.s	.n_cbtn
		bsr	gemaStopAll
		bsr	Video_FadeOut_Full
		move.w	#0,(RAM_ScreenMode).w	; Return to mode 0
		rts				; EXIT
.n_cbtn:
		bra	.loop

; ------------------------------------------------------

.show_cursor:
		move.w	(RAM_LastPick).w,d7
		cmp.w	(RAM_CurrPick).w,d7
		beq.s	.last_pick
		lea	str_CursorDel(pc),a0
		moveq	#1,d0
		moveq	#5,d1
		add.w	(RAM_LastPick).w,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bsr	Video_Print
		move.w	(RAM_CurrPick).w,(RAM_LastPick).w
.last_pick:
		lea	str_Cursor(pc),a0
		moveq	#1,d0
		moveq	#5,d1
		add.w	(RAM_CurrPick).w,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bra	Video_Print

; ------------------------------------------------------

.show_me:
		lea	str_ShowMe(pc),a0
		moveq	#23,d0
		moveq	#6,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bra	Video_Print

; ------------------------------------------------------

.jump_list:
		bra.w	.nothing
		bra.w	.option_1
		bra.w	.option_2
		bra.w	.option_3
		bra.w	.option_4
		bra.w	.option_5
		bra.w	.option_6
		bra.w	.option_7

; ------------------------------------------------------
; OPTION 0
; ------------------------------------------------------

.nothing:
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.no_press
		bsr.s	.show_me
		bra	gemaTest
.no_press:
		rts

; ------------------------------------------------------
; OPTION 1
; ------------------------------------------------------

.option_1:
		lea	(RAM_GemaArg0).w,a5
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.option1_args
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		bsr	gemaPlaySeq
		move.w	(RAM_GemaArg1).w,d0
		move.w	d0,d1
		add.w	d1,d1
		lea	.extnal_beats(pc),a0
		move.w	(a0,d1.w),d0
		bra	gemaSetBeats
; 		bra.s	.show_me
.option1_args:
		move.w	on_hold(a6),d7
		move.w	d7,d6
		andi.w	#JoyA+JoyB+JoyC,d6
		beq.s	.no_press
		btst	#bitJoyB,d7
		beq.s	.d2_opt
		adda	#2,a5
.d2_opt:
		btst	#bitJoyC,d7
		beq.s	.d3_opt
		adda	#4,a5
.d3_opt:
		move.w	on_press(a6),d7
		btst	#bitJoyRight,d7
		beq.s	.op1_right
		addq.w	#1,(a5)
		bra	.show_me
.op1_right:
		btst	#bitJoyLeft,d7
		beq.s	.op1_left
		subq.w	#1,(a5)
		bra	.show_me
.op1_left:
		move.w	on_hold(a6),d7
		btst	#bitJoyUp,d7
		beq.s	.op1_down
		addq.w	#1,(a5)
		bra	.show_me
.op1_down:
		btst	#bitJoyDown,d7
		beq.s	.op1_up
		subq.w	#1,(a5)
		bra	.show_me
.op1_up:

		rts

; ------------------------------------------------------
; OPTION 2
; ------------------------------------------------------

.option_2:
		lea	(RAM_GemaArg0).w,a5
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.option1_args
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		bra	gemaStopSeq

; ------------------------------------------------------
; OPTION 3
; ------------------------------------------------------

.option_3:
		lea	(RAM_GemaArg3).w,a5
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq	.option1_args
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		bra	gemaFadeSeq

; ------------------------------------------------------
; OPTION 4
; ------------------------------------------------------

.option_4:
		lea	(RAM_GemaArg3).w,a5
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq	.option1_args
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		bra	gemaSetSeqVol

; ------------------------------------------------------
; OPTION 5
; ------------------------------------------------------

.option_5:
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.no_press2
		bsr	.show_me
		bra	gemaStopAll
.no_press2:
		rts

; ------------------------------------------------------
; OPTION 6
; ------------------------------------------------------

.option_6:
		lea	(RAM_GemaArg6).w,a5
		move.w	on_hold(a6),d7
		andi.w	#JoyA,d7
		beq.s	.no_press2
		move.w	on_press(a6),d7
		btst	#bitJoyRight,d7
		beq.s	.op2_right
		addq.w	#1,(a5)
		bra	.show_me_2
.op2_right:
		btst	#bitJoyLeft,d7
		beq.s	.op2_left
		subq.w	#1,(a5)
		bsr	.show_me_2
.op2_left:
		move.w	on_hold(a6),d7
		btst	#bitJoyDown,d7
		beq.s	.op2_down
		addq.w	#1,(a5)
		bsr	.show_me_2
.op2_down:
		btst	#bitJoyUp,d7
		beq.s	.op2_up
		subq.w	#1,(a5)
		bsr	.show_me_2
.op2_up:
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.no_press2
.show_me_2:
		bsr	.show_me
		move.w	(a5),d0
		bra	gemaSetBeats

; ------------------------------------------------------
; OPTION 7
; ------------------------------------------------------

.option_7:
		move.w	on_press(a6),d7
		btst	#bitJoyStart,d7
		beq.s	.no_press2
		move.w	#-1,(RAM_ScreenMode).w	; risky but works.
		rts

; ------------------------------------------------------
; EXTERNAL BEATS FOR EACH TRACK
; ------------------------------------------------------

.extnal_beats:
	dc.w 192
	dc.w 192
	dc.w 192
	dc.w 192
	dc.w 215
	dc.w $00B8
	dc.w 192
	dc.w 192
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215
	dc.w 215

; ====================================================================
; ------------------------------------------------------
; DATA asset locations
; ------------------------------------------------------

file_scrn1_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2

; ====================================================================
; ------------------------------------------------------
; Objects
; ------------------------------------------------------

; ; --------------------------------------------------
; ; Sisi
; ; --------------------------------------------------
;
; Object_Sisi:
; 		moveq	#0,d0
; 		move.b	obj_index(a6),d0
; 		add.w	d0,d0
; 		move.w	.list(pc,d0.w),d1
; 		jmp	.list(pc,d1.w)
; ; ----------------------------------------------
; .list:		dc.w .init-.list
; 		dc.w .main-.list
; ; ----------------------------------------------
; .init:
; 		move.b	#1,obj_index(a6)
; 		clr.w	obj_frame(a6)
; 		bsr	object_ResetAnim
;
; ; ----------------------------------------------
; .main:
; 		moveq	#0,d0
; 		move.w	(RAM_CurrPick).w,d1
; 		lsl.w	#3,d1
; 		addi.w	#$18,d0
; 		addi.w	#$20,d1
; 		move.w	d0,obj_x(a6)
; 		move.w	d1,obj_y(a6)
; .dont_link:
; 		lea	.anim_data(pc),a0
; 		bsr	object_Animate
; 		lea	(objMap_Sisi),a0
; 		move.w	obj_x(a6),d0
; 		move.w	obj_y(a6),d1
; 		move.w	#setVramST_Sisi,d2
; 		or.w	#$800,d2
; 		move.w	obj_frame(a6),d3
; 		bra	Video_MkSprMap
;
; ; ----------------------------------------------
;
; .anim_data:
; 		dc.w .anim_00-.anim_data
; 		dc.w .anim_00-.anim_data
; 		dc.w .anim_00-.anim_data
; 		dc.w .anim_00-.anim_data
; .anim_00:
; 		dc.w 8
; 		dc.w 0,1,2,1
; 		dc.w -2
; 		align 2

; ====================================================================
; ------------------------------------------------------
; Subroutines
; ------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Includes for this screen
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
; Small data section
; ------------------------------------------------------

; str_ShowPsg:	dc.b "\\w \\w \\w \\w",0
; 		dc.l RAM_ChnlLinks,RAM_ChnlLinks+2,RAM_ChnlLinks+4,RAM_ChnlLinks+6
; 		align 2
; str_ShowFm:	dc.b "\\w \\w \\w \\w \\w \\w",0
; 		dc.l RAM_ChnlLinks+8,RAM_ChnlLinks+10,RAM_ChnlLinks+12
; 		dc.l RAM_ChnlLinks+14,RAM_ChnlLinks+16,RAM_ChnlLinks+18
; 		align 2
; str_ShowPcm:	dc.b "\\w \\w \\w \\w",$0A
; 		dc.b "\\w \\w \\w \\w",0
; 		dc.l RAM_ChnlLinks+20,RAM_ChnlLinks+22,RAM_ChnlLinks+24,RAM_ChnlLinks+26
; 		dc.l RAM_ChnlLinks+28,RAM_ChnlLinks+30,RAM_ChnlLinks+32,RAM_ChnlLinks+34
; 		align 2
; str_ShowPwm:	dc.b "\\w \\w \\w \\w",$0A
; 		dc.b "\\w \\w \\w",0
; 		dc.l RAM_ChnlLinks+36,RAM_ChnlLinks+38,RAM_ChnlLinks+40,RAM_ChnlLinks+42
; 		dc.l RAM_ChnlLinks+44,RAM_ChnlLinks+46,RAM_ChnlLinks+48,RAM_ChnlLinks+50
; 		align 2

str_Cursor:	dc.b "-->",0
		align 2
str_CursorDel:	dc.b "   ",0
		align 2

str_TesterTitle:
		dc.b "GEMA Sound driver tester",0
		align 2

str_TesterInfo:
		dc.b "    gemaTest          Slot Seq  Blk",$0A
		dc.b "    gemaPlaySeq",$0A
		dc.b "    gemaStopSeq",$0A
		dc.b "    gemaFadeSeq",$0A
		dc.b "    gemaSetSeqVol",$0A
		dc.b "    gemaStopAll       Beat",$0A
		dc.b "    gemaSetBeats",$0A
		dc.b "    EXIT to Screen 00",$0A
; 		dc.b $0A
; 		dc.b $0A
; 		dc.b "    (START) - Process",$0A,$0A
; 		dc.b "    Hold (A)(B)(C) + UDLR:",$0A
; 		dc.b "    Edit values",0
		dc.b 0
		align 2
str_ShowMe:
		dc.l pstr_mem(1,RAM_GemaArg0)
		dc.b " "
		dc.l pstr_mem(1,RAM_GemaArg1)
		dc.b " "
		dc.l pstr_mem(1,RAM_GemaArg2)
		dc.b $0A,$0A
		dc.l pstr_mem(1,RAM_GemaArg3)
		dc.b " "
		dc.l pstr_mem(1,RAM_GemaArg4)
		dc.b " "
		dc.l pstr_mem(1,RAM_GemaArg5)
		dc.b $0A,$0A,$0A
		dc.l pstr_mem(1,RAM_GemaArg6)
		dc.b 0
		align 2
; str_Info:
; 		dc.l pstr_mem(3,RAM_Framecount)
; 		dc.b 0
; 		align 2
