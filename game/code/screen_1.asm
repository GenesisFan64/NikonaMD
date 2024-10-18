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

; ----------------------------------------------
; VRAM Setup
; ----------------------------------------------

			memory 2		; Cell $0002
vramLoc_Haruna		ds.b $30
vramLoc_Emily		ds.b $30
vramLoc_Sisi		ds.b $2C
vramLoc_PushBlk		ds.b $100

vramLoc_Backgrnd	ds.b $3F7
			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_Cam_Xpos		ds.w 1
RAM_DoRedraw		ds.w 1
RAM_BlocksBuff		ds.b 8*8
.sizeof_this		ds.l 0
			endmemory
			erreport "This screen",.sizeof_this-RAM_ScrnBuff,MAX_ScrnBuff

; ====================================================================
; ------------------------------------------------------
; Init
; ------------------------------------------------------

		bsr	Video_DisplayOff
		bsr	System_Default
		bsr	Video_ClearScreen
		moveq	#1,d0
		moveq	#%00,d1
		bsr	Video_Resolution
	; ----------------------------------------------
		lea	file_scrn1_main(pc),a0			; Load MAIN DATA bank
		bsr	System_SetDataBank
		bsr	System_SramInit
		addq.l	#1,(RAM_Save_Counter).w			; Temporal counter
		bsr	System_SramSave				; Save to SRAM/BRAM
	; ----------------------------------------------
	; Load PRINT
		move.l	#ASCII_FONT,d0				; d0 - Font data
		move.w	#DEF_PrintVram|DEF_PrintPal,d1
		bsr	Video_PrintInit
		move.l	#ASCII_FONT_W,d0
		move.w	#DEF_PrintVramW|DEF_PrintPal,d1
		bsr	Video_PrintInitW
		bsr	Video_PrintDefPal_Fade
	; ----------------------------------------------
		lea	(Pal_Haruna),a0
		moveq	#48,d0
		moveq	#16,d1
		bsr	Video_FadePal
		lea	(Pal_Sisi),a0
		moveq	#32,d0
		moveq	#16,d1
		bsr	Video_FadePal
		lea	(Pal_BlkPuzzl+$02),a0
		moveq	#1,d0
		moveq	#8,d1
		bsr	Video_FadePal
		lea	ArtList_scrn1(pc),a0
		bsr	Video_LoadArt_List
		move.l	#obj_Player,d0
		bsr	Object_Make
	; ----------------------------------------------
		bsr	.show_counter				; Draw counter
		bsr	Video_DisplayOn
		bsr	Screen0_PickBackgrnd
		bsr	Scrn0_LoadMap
		bsr	Scrn0_DrawMapAll
	; ----------------------------------------------

	; ----------------------------------------------
		moveq	#0,d0
		moveq	#0,d1
		bsr	gemaPlaySeq
		bsr	Object_Run
		bsr	Video_BuildSprites
		bsr	Video_FadeIn_Full

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	Object_Run
		bsr	Video_BuildSprites
		bsr	System_Render
		tst.w	(RAM_DoRedraw).w
		beq.s	.dont_redrw
		clr.w	(RAM_DoRedraw).w
		bsr	Scrn0_DrawMapAll
.dont_redrw:

		bsr	.show_counter
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyX,d7
		beq.s	.not_x
		move.l	#obj_Ball,d0
		bsr	Object_Make
.not_x:
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyY,d7
		beq.s	.not_y
		lea	(RAM_Objects),a0
		moveq	#0,d0
		moveq	#1,d1
		move.w	#(MAX_MDOBJ-1)-1,d7
.del_from:
		bsr	Object_Set
		addq.w	#1,d1
		dbf	d7,.del_from
.not_y:
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyZ,d7
		beq.s	.not_z
		moveq	#$0F,d0
		moveq	#1,d1
		moveq	#2,d2
		bsr	gemaPlaySeq
.not_z:

	; Copy variables
		move.w	(RAM_Cam_Xpos).w,d7
		move.w	d7,(RAM_SprOffsetX).w
		neg.w	d7
		move.w	d7,(RAM_HorScroll).w

	; Check START button
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyStart,d7
		beq	.loop
		bsr	Video_FadeOut_Full
	; Stop ALL sequences
		bsr	gemaStopAll
	rept 4
		bsr	System_Render		; Wait 4 frames...
	endm
		move.w	#0,(RAM_ScreenMode).w	; Set Screen Mode $07
		rts				; <-- RTS

; ------------------------------------------------------
; Show framecounter and input
; ------------------------------------------------------

.show_counter:
		rts
; 		lea	str_NewCountr0(pc),a0
; 		moveq	#0,d0
; 		moveq	#0,d1
; 		move.w	#DEF_PrintVram|DEF_PrintPal,d2
; 		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3
; 		bra	Video_Print

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


ArtList_scrn1:
		dc.w 2
		dc.l Art_Sisi
		dc.w cell_vram(vramLoc_Sisi),Art_Sisi_e-Art_Sisi
		dc.l Art_BlkPuzzl
		dc.w cell_vram(vramLoc_PushBlk),cell_vram($20)
		align 2

; ====================================================================
; ------------------------------------------------------
; Objects
; ------------------------------------------------------

; --------------------------------------------------
; Test object
; --------------------------------------------------

obj_Player:
		moveq	#0,d0
		move.b	obj_index(a6),d0
		add.w	d0,d0
		move.w	.list(pc,d0.w),d1
		jmp	.list(pc,d1.w)
; ----------------------------------------------
.list:		dc.w .init-.list
		dc.w .main-.list
; ----------------------------------------------
.init:
		addq.b	#1,obj_index(a6)
		bsr	object_ResetAnim	; Init/Reset animation
		move.w	#$0202,obj_size_x(a6)
		move.w	#$0303,obj_size_y(a6)
		move.w	#$0101,obj_size_z(a6)
		move.w	#0,obj_x(a6)		; Set Object's X/Y position
		move.w	#0,obj_y(a6)
		lea	obj_ram(a6),a5
		clr.l	(a5)+
		clr.l	(a5)+
		clr.w	(a5)+
		move.w	#0,4(a5)
		move.w	#0,6(a5)

; ----------------------------------------------
.main:
		lea	obj_ram(a6),a5
		lea	(Controller_1).w,a4

		tst.w	8(a5)
		bne.s	.on_timer
		move.w	on_hold(a4),d7
		btst	#bitJoyRight,d7
		beq.s	.n_rtmr
		move.w	#1,(a5)
		move.w	#0,2(a5)
		addq.w	#1,4(a5)
		move.w	#$20,8(a5)
.n_rtmr:	btst	#bitJoyLeft,d7
		beq.s	.n_ltmr
		move.w	#-1,(a5)
		move.w	#0,2(a5)
		subq.w	#1,4(a5)
		move.w	#$20,8(a5)
.n_ltmr:	btst	#bitJoyDown,d7
		beq.s	.d_rtmr
		move.w	#0,(a5)
		move.w	#1,2(a5)
		addq.w	#1,6(a5)
		move.w	#$18,8(a5)
.d_rtmr:	btst	#bitJoyUp,d7
		beq.s	.u_ltmr
		move.w	#0,(a5)
		move.w	#-1,2(a5)
		subq.w	#1,6(a5)
		move.w	#$18,8(a5)
.u_ltmr:
		bra.s	.no_timer

.on_timer:
		move.w	(a5),d0
		move.w	2(a5),d1
		add.w	d0,obj_x(a6)
		add.w	d1,obj_y(a6)
		subq.w	#1,8(a5)
		bne.s	.no_timer

		moveq	#0,d0
		move.w	obj_x(a6),d0
		beq.s	.no_timer
		asr.w	#5,d0
		subq.w	#1,d0
		cmp.w	#5,d0
		bge.s	.no_timer
		move.w	obj_y(a6),d1
		beq.s	.no_tmry
		divu.w	#$18,d1
		subq.w	#1,d1
		cmp.w	#5,d1
		bge.s	.no_tmry
		lsl.w	#3,d1
		add.w	d1,d0
.no_tmry
		lea	(RAM_BlocksBuff),a0
		adda	d0,a0
		move.b	#$02,(a0)
		st.b	(RAM_DoRedraw).w
.no_timer:

; ----------------------------------------------
; Show the object...

; 		tst.w	d3
; 		beq.s	.no_anim
; 		lea	.anim_data(pc),a0	; Do animation
; 		bsr	object_Animate
; .no_anim:
; 		clr.l	(RAM_TestTouch).w
; 		bsr	object_Touch
; 		tst.l	d0
; 		beq.s	.lel
; 		move.l	d0,(RAM_TestTouch).w
; .lel:
		move.l	#0,a0
		lea	(Map_Haruna),a1
		lea	(Plc_Haruna),a2
		lea	(Art_Haruna),a3
		moveq	#0,d2
		move.w	obj_x(a6),d0
		move.w	obj_y(a6),d1
		addi.w	#16+$30,d0
		addi.w	#$20-4,d1
		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
		lsl.w	#8,d2
		lsl.w	#3,d2				; %000vh000 00000000
		add.w	#vramLoc_Haruna|$6000,d2 	; +VRAM+$2000(use second palette line)
		move.w	obj_frame(a6),d3		; Current frame set by _Animate
		bra	Video_MakeSprMap_DMA

; ----------------------------------------------

.anim_data:
		dc.w .anim_down-.anim_data
		dc.w .anim_up-.anim_data
		dc.w .anim_right-.anim_data
		dc.w .anim_left-.anim_data

.anim_down:
		dc.w 8
		dc.w 0,1,0,2
		dc.w -2
		align 2
.anim_up:
		dc.w 8
		dc.w 3,4,3,5
		dc.w -2
		align 2
.anim_right:
		dc.w 8
		dc.w 6,7,6,8
		dc.w -2
		align 2
.anim_left:
		dc.w 8
		dc.w 9,10,9,11
		dc.w -2
		align 2

; --------------------------------------------------
; Test object
; --------------------------------------------------

obj_Ball:
		moveq	#0,d0
		move.b	obj_index(a6),d0
		add.w	d0,d0
		move.w	.list(pc,d0.w),d1
		jmp	.list(pc,d1.w)
; ----------------------------------------------
.list:		dc.w .init-.list
		dc.w .main-.list
; ----------------------------------------------
.init:
		addq.b	#1,obj_index(a6)
		bsr	object_ResetAnim	; Init/Reset animation
		move.w	#$0202,obj_size_x(a6)
		move.w	#$0303,obj_size_y(a6)
		move.w	#$0101,obj_size_z(a6)
		move.w	#0,obj_anim_num(a6)

		move.w	#$20,obj_x(a6)		; Set Object's X/Y position
		move.w	#$10,obj_y(a6)
		move.w	#$48+1,d0
		bsr	System_DiceRoll
		lsl.w	#1,d0
		add.w	d0,obj_x(a6)
		add.w	d0,obj_y(a6)
		lsl.w	#4,d0
		move.w	d0,obj_x_spd(a6)
		move.w	d0,obj_y_spd(a6)

		bset	#0,obj_attr(a6)
		bsr	System_Random
		move.l	(RAM_SysRandom).w,d7
		lsr.w	#1,d7
		bcc.s	.x_random
		neg.w	obj_x_spd(a6)
		bchg	#0,obj_attr(a6)
.x_random:
		lsr.w	#1,d7
		bcc.s	.y_random
		neg.w	obj_y_spd(a6)
.y_random:
		rts

; ----------------------------------------------
.main:
		move.w	(RAM_VdpRegSetC).w,d2
		btst	#2,d2
		bne.s	.y_fix
		cmpi.w	#240,obj_y(a6)
		blt.s	.y_fix
		sub.w	#240,obj_y(a6)
.y_fix:

		move.w	#224,d1
		move.w	(RAM_VdpRegSetC).w,d2
		btst	#2,d2
		beq.s	.y_double
		add.w	d1,d1
.y_double:
		move.w	#320,d0
		move.w	obj_x(a6),d2
		tst.w	d2
		bpl.s	.x_back
		neg.w	obj_x_spd(a6)
		bsr.s	.play_bump
		bchg	#0,obj_attr(a6)
.x_back:
		cmp.w	d0,d2
		blt.s	.x_foward
		neg.w	obj_x_spd(a6)
		bchg	#0,obj_attr(a6)
		bsr.s	.play_bump
.x_foward:
		move.w	d2,obj_x(a6)

		move.w	obj_y(a6),d2
		tst.w	d2
		bpl.s	.y_back
		bsr.s	.play_bump
		neg.w	obj_y_spd(a6)
.y_back:
		cmp.w	d1,d2
		blt.s	.y_foward
		bsr.s	.play_bump
		neg.w	obj_y_spd(a6)
.y_foward:
		move.w	d2,obj_y(a6)
		bsr	object_Speed

; ----------------------------------------------
; Show the object...

		lea	.anim_data(pc),a0	; Do animation
		bsr	object_Animate
		lea	(Map_Sisi),a1
		moveq	#0,d2
		move.w	obj_x(a6),d0
		move.w	obj_y(a6),d1
		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
		lsl.w	#8,d2
		lsl.w	#3,d2				; %000vh000 00000000
		add.w	#vramLoc_Sisi|$4000,d2 		; +VRAM+$2000(use second palette line)
		move.w	obj_frame(a6),d3		; Current frame set by _Animate
		bra	Video_MakeSprMap

.play_bump:
		movem.l	d0-d2,-(sp)
		moveq	#$0F,d0
		moveq	#$00,d1
		moveq	#1,d2
		bsr	gemaPlaySeq
		movem.l	(sp)+,d0-d2
		rts

; ----------------------------------------------

.anim_data:
		dc.w .maind-.anim_data
.maind:
		dc.w 7
		dc.w 0,1,2,1
		dc.w -2
		align 2

; ====================================================================
; ------------------------------------------------------
; Subroutines
; ------------------------------------------------------

Screen0_PickBackgrnd:
		lea	(Pal_TESTBG),a0				; a0 - Load palette (+2 skips first color)
		moveq	#16,d0					; d0 - Start at $01
		moveq	#15,d1					; d1 - 15 colors
		bsr	Video_FadePal				; Load palette to FADE buffer
		clr.w	(RAM_Palette).w
		clr.w	(RAM_PaletteFade).w
		move.l	#Art_TESTBG,d0				; d0 - Graphics pointer (NOT a0 here)
		move.w	#cell_vram(vramLoc_Backgrnd),d1		; d1 - output VRAM location
		move.w	#Art_TESTBG_e-Art_TESTBG,d2		; d2 - Size: end-start
		bsr	Video_LoadArt
		lea	(Map_TESTBG),a0				; a0 - Map data
		move.l	#splitw(0,0),d0				; d0 - X/Y Positions 0,0
		move.l	#splitw(320/8,224/8),d1			; d1 - Width and Height
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_BG),d2	; d2 - Layer width / Layer output
		move.w	#vramLoc_Backgrnd|$2000,d3		; d3 - Starting cell
		bsr	Video_LoadMap
		bra	Video_DisplayOn

Scrn0_LoadMap:
		lea	layout_PushBlk(pc),a0
		lea	(RAM_BlocksBuff).w,a1
		move.w	#(8*8)-1,d0
.copy_base:
		move.b	(a0)+,(a1)+
		dbf	d0,.copy_base
		rts

Scrn0_DrawMapAll:
		lea	(RAM_BlocksBuff).w,a1
		move.l	#splitw(32/8,32/8),d1			; d1 - Width and Height
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d2	; d2 - Layer width / Layer output
		move.w	#vramLoc_PushBlk,d3			; d3 - Starting cell
		moveq	#8-1,d7
		move.l	#$000A0008,d6
.y_read:
		swap	d7
		move.l	d6,d0
		move.w	#8-1,d7
.x_read:
		lea	map_PushBlk(pc),a0			; a0 - Map data
		moveq	#0,d5
		move.b	(a1)+,d5
		beq.s	.not_blk
		subq.w	#1,d5
		lsl.l	#5,d5
		adda	d5,a0
		bsr	Video_LoadMap
.not_blk
		add.l	#$00040000,d0
		dbf	d7,.x_read
		add.l	#$00000003,d6
		swap	d7
		dbf	d7,.y_read
		rts

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

; str_NikonaTest:
; 		dc.b "GEMA testing"
; 		dc.b 0
; 		align 2
; str_NewCountr0:
; 		dc.l pstr_mem(1,RAM_Objects+obj_x)
; 		dc.b " "
; 		dc.l pstr_mem(1,RAM_Objects+obj_y)
; 		dc.b 0
; 		align 2
map_PushBlk:
		dc.w $0000,$0001,$0002,$0003
		dc.w $0004,$0005,$0006,$0007
		dc.w $0008,$0009,$000A,$000B
		dc.w $000C,$000D,$000E,$000F
		dc.w $0010,$0011,$0012,$0013
		dc.w $0014,$0015,$0016,$0017
		dc.w $0018,$0019,$001A,$001B
		dc.w $001C,$001D,$001E,$001F
		align 2
layout_PushBlk:
		dc.b $01,$01,$01,$01,$01,$00,$00,$00
		dc.b $01,$01,$01,$01,$01,$00,$00,$00
		dc.b $01,$01,$01,$01,$01,$00,$00,$00
		dc.b $01,$01,$01,$01,$01,$00,$00,$00
		dc.b $01,$01,$01,$01,$01,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		align 2

; ====================================================================
