; ===========================================================================
; ----------------------------------------------------------------
; SCREEN CODE
; ----------------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Variables
; ------------------------------------------------------

SFX_punch	equ 0
SFX_btnon	equ 1
SFX_btnoff	equ 2

; ====================================================================
; ------------------------------------------------------
; Structs
; ------------------------------------------------------

; ----------------------------------------------
; VRAM Setup
; ----------------------------------------------

			memory 2		; Cell $0002
vramLoc_Haruna		ds.b $140
vramLoc_Emily		ds.b $110
vramLoc_PushBlk		ds.b $40
vramLoc_Backgrnd	ds.b $3F7
			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_ShakeMe		ds.w 1
RAM_GotHitFrom		ds.w 1
RAM_WhoGotScore		ds.w 1
RAM_Cam_Xpos		ds.w 1
RAM_DoRedraw		ds.w 1
RAM_Score_Haru		ds.b 1
RAM_Score_Emily		ds.b 1
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
		lea	(Pal_Haruna+$02),a0
		moveq	#1,d0
		moveq	#16,d1
		bsr	Video_FadePal
		lea	(Pal_Emily),a0
		moveq	#16,d0
		moveq	#16,d1
		bsr	Video_FadePal

		lea	(Pal_BlkPuzzl),a0
		moveq	#32,d0
		moveq	#8,d1
		bsr	Video_FadePal
		lea	ArtList_scrn1(pc),a0
		bsr	Video_LoadArt_List
		move.l	#obj_Player,d0
		moveq	#0,d1
		bsr	Object_Make
		moveq	#1,d1
		bsr	Object_Make
		bsr	Screen0_PickBackgrnd
	; ----------------------------------------------
		bsr	Video_DisplayOn

		bsr	Scrn0_LoadMap
		bsr	Scrn0_DrawMapAll
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

		lea	(RAM_VerScroll).w,a0
		move.w	(RAM_ShakeMe).w,d3
		move.w	d3,d4
		lsr.w	#3,d3
		btst	#1,d4
		bne.s	.midshk
		neg.w	d3
.midshk:
		move.w	d3,(a0)+
		lsr.w	#1,d3
		move.w	d3,(a0)

		tst.w	(RAM_DoRedraw).w
		beq.s	.dont_redrw
		clr.w	(RAM_DoRedraw).w
		bsr	Scrn0_DrawMapAll
.dont_redrw:
		move.w	(RAM_ShakeMe).w,d7
		beq.s	.no_shake
		sub.w	#1,(RAM_ShakeMe).w
; 		bset	#0,(RAM_BoardUpd).w
		tst.w	(RAM_ShakeMe).w
		bne.s	.no_shake

		lea	(RAM_Score_Haru).w,a0
		tst.w	(RAM_WhoGotScore).w
		beq.s	.haruna_scor
		adda	#1,a0
.haruna_scor:
		move.b	(a0),d0
		moveq	#1,d1
		bsr	System_BCD_AddB
		move.b	d0,(a0)
		bsr	Scrn0_ResetMap
		bsr	Scrn0_DrawMapAll
.no_shake:
; 		move.w	(Controller_1+on_press).w,d7
; 		andi.w	#JoyX,d7
; 		beq.s	.not_x
; 		move.l	#obj_Ball,d0
; 		bsr	Object_Make
; .not_x:
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
		andi.w	#JoyMode,d7
		beq.s	.not_m
; 		move.w	#$38,(RAM_ShakeMe).w
		moveq	#$0F,d0
		moveq	#SFX_punch,d1
		moveq	#1,d2
		bsr	gemaPlaySeq
.not_m:

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

; ====================================================================
; ------------------------------------------------------
; DATA asset locations
; ------------------------------------------------------

file_scrn1_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2

ArtList_scrn1:
		dc.w 3
		dc.l Art_Haruna
		dc.w cell_vram(vramLoc_Haruna),Art_Haruna_e-Art_Haruna
		dc.l Art_Emily
		dc.w cell_vram(vramLoc_Emily),Art_Emily_e-Art_Emily
; 		dc.l Art_Sisi
; 		dc.w cell_vram(vramLoc_Sisi),Art_Sisi_e-Art_Sisi
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
		beq.s	.on_init
		tst.w	(RAM_ShakeMe).w
		bne	.show_me
.on_init:
		add.w	d0,d0
		lea	obj_ram(a6),a5
		move.w	.list(pc,d0.w),d1
		jmp	.list(pc,d1.w)
; ----------------------------------------------
.list:		dc.w .init-.list	; $00
		dc.w .main-.list	; $01
		dc.w .move_lr-.list	; $02
		dc.w .move_down-.list	; $03
		dc.w .move_up-.list	; $04
; ----------------------------------------------
.init:
		addq.b	#1,obj_index(a6)
		bsr	object_ResetAnim	; Init/Reset animation
		move.w	#$0202,obj_size_x(a6)
		move.w	#$0303,obj_size_y(a6)
		move.w	#$0101,obj_size_z(a6)
		move.w	#0,obj_x(a6)		; Set Object's X/Y position
		move.w	#$18*3,obj_y(a6)
; 		move.w	#0,obj_y(a6)
		tst.b	obj_subid(a6)
		beq.s	.first_plyr
		move.w	#$C0,obj_x(a6)
.first_plyr:

; ----------------------------------------------
; Main read
; ----------------------------------------------

.main:
		lea	(Controller_1).w,a4
		tst.b	obj_subid(a6)
		beq.s	.first_inpu
		lea	(Controller_2).w,a4
.first_inpu:
		move.w	on_press(a4),d7
		cmp.w	#$20*6,obj_x(a6)
		bge.s	.go_right
		btst	#bitJoyRight,d7
		beq.s	.go_right
		move.w	#$200+8,obj_x_spd(a6)
		move.w	#-$100,obj_y_spd(a6)
		move.w	obj_x(a6),d0
		add.w	#$20,d0
		move.w	d0,(a5)
		move.w	obj_y(a6),2(a5)
		move.b	#2,obj_index(a6)
		move.w	#2,obj_anim_num(a6)
		bra	.show_me
.go_right:
		tst.w	obj_x(a6)
		beq.s	.go_left
		btst	#bitJoyLeft,d7
		beq.s	.go_left
		move.w	#-$200+8,obj_x_spd(a6)
		move.w	#-$100,obj_y_spd(a6)
		move.w	obj_x(a6),d0
		sub.w	#$20,d0
		move.w	d0,(a5)
		move.w	obj_y(a6),2(a5)
		move.b	#2,obj_index(a6)
		move.w	#3,obj_anim_num(a6)
		bra	.show_me
.go_left:
		cmp.w	#$18*6,obj_y(a6)
		bge.s	.go_down
		btst	#bitJoyDown,d7
		beq.s	.go_down
		move.w	#-$80,obj_y_spd(a6)
		move.w	obj_y(a6),d0
		add.w	#$18,d0
		move.w	d0,2(a5)
		move.w	obj_x(a6),(a5)
		move.b	#3,obj_index(a6)
		move.w	#0,obj_anim_num(a6)
		bra	.show_me
.go_down:
		tst.w	obj_y(a6)
		beq.s	.cant_move
		btst	#bitJoyUp,d7
		beq.s	.cant_move
		move.w	#-$180-$100,obj_y_spd(a6)
		move.w	obj_y(a6),d0
		sub.w	#$18,d0
		move.w	d0,2(a5)
		move.w	obj_x(a6),(a5)
		move.b	#4,obj_index(a6)
		move.w	#1,obj_anim_num(a6)
		bra	.show_me
.cant_move:
		bra	.show_me

; ----------------------------------------------
; Left/Right
; ----------------------------------------------

.move_lr:
		tst.w	obj_x_spd(a6)
		bmi.s	.x_left
		subi.w	#$10,obj_x_spd(a6)
		bpl.s	.x_jnone
		bra.s	.x_jset
.x_left:
		addi.w	#$10,obj_x_spd(a6)
		bmi.s	.x_jnone
.x_jset:
		bsr	.set_fpos
		bra	.show_me
.x_jnone:
		addi.w	#$10,obj_y_spd(a6)
		bsr	object_Speed
.ret_main:
		bra	.anima_me

; ----------------------------------------------
; Down
; ----------------------------------------------

.move_down:
		lea	obj_ram(a6),a5
		addi.w	#$10,obj_y_spd(a6)
		bsr	object_Speed
		move.w	obj_y(a6),d0
		cmp.w	2(a5),d0
		blt	.anima_me
		bsr	.set_fpos
		bra	.show_me

; ----------------------------------------------
; Up
; ----------------------------------------------

.move_up:
		addi.w	#$10+8,obj_y_spd(a6)
		bsr	object_Speed
		tst.w	obj_y_spd(a6)
		bmi.s	.anima_me
		move.w	obj_y(a6),d0
		cmp.w	2(a5),d0
		blt.s	.anima_me
		bsr	.set_fpos
		bra	.show_me

; --------------------------------------

.set_fpos:
		move.b	#1,obj_index(a6)
		bsr	object_ResetAnim
		clr.w	obj_frame(a6)
		move.w	(a5),obj_x(a6)
		move.w	2(a5),obj_y(a6)
		clr.w	obj_x_spd(a6)
		clr.w	obj_y_spd(a6)
		moveq	#0,d0
		move.w	obj_x(a6),d0
		beq.s	.no_timer
		asr.w	#5,d0
		subq.w	#1,d0
		cmp.w	#5,d0
		bge.s	.no_timer
		moveq	#0,d1
		move.w	obj_y(a6),d1
		beq.s	.no_timer
		divu.w	#$18,d1
		subq.w	#1,d1
		cmp.w	#5,d1
		bge.s	.no_timer
		lsl.w	#3,d1
		add.w	d1,d0
.no_tmry:
		lea	(RAM_BlocksBuff),a0
		adda	d0,a0
		moveq	#$0F,d0				; Seq $0F
		moveq	#2,d2				; Slot 2
		moveq	#SFX_btnoff,d1			; Block sfx 1
		moveq	#1,d3
		eor.b	d3,(a0)
		beq.s	.its_off
		moveq	#SFX_btnon,d1			; Block sfx 2
		move.b	obj_subid(a6),d3
		move.b	d3,(RAM_WhoGotScore).w
.its_off:
		bsr	gemaPlaySeq
		st.b	(RAM_DoRedraw).w
.no_timer:
		rts

; ----------------------------------------------

.anima_me:
		lea	.anim_data(pc),a0
		bsr	object_Animate
.show_me:
		move.l	#0,a0
		lea	(Map_Haruna),a1
		tst.b	obj_subid(a6)
		beq.s	.is_harun
		lea	(Map_Emily),a1
.is_harun:
		moveq	#0,d2
		move.w	obj_x(a6),d0
		move.w	obj_y(a6),d1
		move.w	(RAM_ShakeMe).w,d3
		move.w	d3,d4
		lsr.w	#3,d3
		btst	#1,d4
		beq.s	.midshk
		sub.w	d3,d1
.midshk:
		addi.w	#16+$30,d0
		addi.w	#$20-4,d1
		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
		lsl.w	#8,d2
		lsl.w	#3,d2				; %000vh000 00000000
		move.w	#vramLoc_Haruna,d3 	; +VRAM+$2000(use second palette line)
		tst.b	obj_subid(a6)
		beq.s	.first_dma
		move.w	#vramLoc_Emily|$2000,d3
.first_dma:
		add.w	d3,d2
		move.w	obj_frame(a6),d3		; Current frame set by _Animate
		bra	Video_MakeSprMap

; ----------------------------------------------

.anim_data:
		dc.w .anim_down-.anim_data
		dc.w .anim_up-.anim_data
		dc.w .anim_right-.anim_data
		dc.w .anim_left-.anim_data
.anim_down:
		dc.w 4
		dc.w 0,1,2
		dc.w -1
		align 2
.anim_up:
		dc.w 4
		dc.w 3,4,5
		dc.w -1
		align 2
.anim_right:
		dc.w 4
		dc.w 6,7,8
		dc.w -1
		align 2
.anim_left:
		dc.w 4
		dc.w 9,10,11
		dc.w -1
		align 2

; --------------------------------------------------
; Test object
; --------------------------------------------------

obj_Ball:
	rts
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
; 		addq.b	#1,obj_index(a6)
; 		bsr	object_ResetAnim	; Init/Reset animation
; 		move.w	#$0202,obj_size_x(a6)
; 		move.w	#$0303,obj_size_y(a6)
; 		move.w	#$0101,obj_size_z(a6)
; 		move.w	#0,obj_anim_num(a6)
;
; 		move.w	#$20,obj_x(a6)		; Set Object's X/Y position
; 		move.w	#$10,obj_y(a6)
; 		move.w	#$48+1,d0
; 		bsr	System_DiceRoll
; 		lsl.w	#1,d0
; 		add.w	d0,obj_x(a6)
; 		add.w	d0,obj_y(a6)
; 		lsl.w	#4,d0
; 		move.w	d0,obj_x_spd(a6)
; 		move.w	d0,obj_y_spd(a6)
;
; 		bset	#0,obj_attr(a6)
; 		bsr	System_Random
; 		move.l	(RAM_SysRandom).w,d7
; 		lsr.w	#1,d7
; 		bcc.s	.x_random
; 		neg.w	obj_x_spd(a6)
; 		bchg	#0,obj_attr(a6)
; .x_random:
; 		lsr.w	#1,d7
; 		bcc.s	.y_random
; 		neg.w	obj_y_spd(a6)
; .y_random:
; 		rts
;
; ; ----------------------------------------------
; .main:
; 		move.w	(RAM_VdpRegSetC).w,d2
; 		btst	#2,d2
; 		bne.s	.y_fix
; 		cmpi.w	#240,obj_y(a6)
; 		blt.s	.y_fix
; 		sub.w	#240,obj_y(a6)
; .y_fix:
;
; 		move.w	#224,d1
; 		move.w	(RAM_VdpRegSetC).w,d2
; 		btst	#2,d2
; 		beq.s	.y_double
; 		add.w	d1,d1
; .y_double:
; 		move.w	#320,d0
; 		move.w	obj_x(a6),d2
; 		tst.w	d2
; 		bpl.s	.x_back
; 		neg.w	obj_x_spd(a6)
; 		bsr.s	.play_bump
; 		bchg	#0,obj_attr(a6)
; .x_back:
; 		cmp.w	d0,d2
; 		blt.s	.x_foward
; 		neg.w	obj_x_spd(a6)
; 		bchg	#0,obj_attr(a6)
; 		bsr.s	.play_bump
; .x_foward:
; 		move.w	d2,obj_x(a6)
;
; 		move.w	obj_y(a6),d2
; 		tst.w	d2
; 		bpl.s	.y_back
; 		bsr.s	.play_bump
; 		neg.w	obj_y_spd(a6)
; .y_back:
; 		cmp.w	d1,d2
; 		blt.s	.y_foward
; 		bsr.s	.play_bump
; 		neg.w	obj_y_spd(a6)
; .y_foward:
; 		move.w	d2,obj_y(a6)
; 		bsr	object_Speed
;
; ; ----------------------------------------------
; ; Show the object...
;
; 		lea	.anim_data(pc),a0	; Do animation
; 		bsr	object_Animate
; 		lea	(Map_Sisi),a1
; 		moveq	#0,d2
; 		move.w	obj_x(a6),d0
; 		move.w	obj_y(a6),d1
; 		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
; 		lsl.w	#8,d2
; 		lsl.w	#3,d2				; %000vh000 00000000
; 		add.w	#vramLoc_Sisi|$4000,d2 		; +VRAM+$2000(use second palette line)
; 		move.w	obj_frame(a6),d3		; Current frame set by _Animate
; 		bra	Video_MakeSprMap
;
; .play_bump:
; 		movem.l	d0-d2,-(sp)
; 		moveq	#$0F,d0
; 		moveq	#SFX_punch,d1
; 		moveq	#1,d2
; 		bsr	gemaPlaySeq
; 		movem.l	(sp)+,d0-d2
; 		rts
;
; ; ----------------------------------------------
;
; .anim_data:
; 		dc.w .maind-.anim_data
; .maind:
; 		dc.w 7
; 		dc.w 0,1,2,1
; 		dc.w -2
; 		align 2

; ====================================================================
; ------------------------------------------------------
; Subroutines
; ------------------------------------------------------

Screen0_PickBackgrnd:
		lea	(Pal_TESTBG),a0				; a0 - Load palette (+2 skips first color)
		moveq	#48,d0					; d0 - Start at $01
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
		move.w	#vramLoc_Backgrnd|$6000,d3		; d3 - Starting cell
		bsr	Video_LoadMap
		rts

Scrn0_LoadMap:
		lea	layout_PushBlk(pc),a0
		lea	(RAM_BlocksBuff).w,a1
		move.w	#(8*8)-1,d0
.copy_base:
		move.b	(a0)+,(a1)+
		dbf	d0,.copy_base
		rts

Scrn0_DrawMapAll:
		bsr	.show_score			; Draw counter
		lea	(RAM_BlocksBuff).w,a2
		move.l	#splitw(32/8,32/8),d1			; d1 - Width and Height
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d2	; d2 - Layer width / Layer output
		move.w	#vramLoc_PushBlk|$4000,d3		; d3 - Starting cell
		moveq	#5-1,d7
		move.l	#$000A0008,d6
.y_read:
		move.l	a2,a1
		swap	d7
		move.l	d6,d0
		move.w	#5-1,d7
.x_read:
		lea	map_PushBlk(pc),a0			; a0 - Map data
		moveq	#0,d5
		move.b	(a1)+,d5
		andi.w	#$7F,d5
; 		andi.w	#1,d5
; 		beq.s	.not_blk
; 		subq.w	#1,d5
		lsl.l	#5,d5
		adda	d5,a0
		bsr	Video_LoadMap
.not_blk
		add.l	#$00040000,d0
		dbf	d7,.x_read
		adda	#8,a2
		add.l	#$00000003,d6
		swap	d7
		dbf	d7,.y_read
	; horizontal
		lea	(RAM_BlocksBuff).w,a6
		moveq	#0,d3
		move	#5-1,d6
.x_chk_n:
		move.l	a6,a5
		move.w	#5-1,d7
		moveq	#0,d5
.x_chk:
		add.b	(a5)+,d5
		dbf	d7,.x_chk
		cmp.b	#5,d5
		bne.s	.x_off
		move.l	a5,a4
		moveq	#5-1,d4
.mk_hor:
		or.b	#$80,-(a4)
		dbf	d4,.mk_hor
		add.w	#1,d3
.x_off:
		adda	#8,a6
		dbf	d6,.x_chk_n
	; vertical
		lea	(RAM_BlocksBuff).w,a6
		move	#5-1,d6
.y_chk_n:
		move.l	a6,a5
		move.w	#5-1,d7
		moveq	#0,d5
.y_chk:
		move.b	(a5),d4
		andi.w	#$7F,d4
		add.b	d4,d5
		adda	#8,a5
		dbf	d7,.y_chk
		cmp.b	#5,d5
		bne.s	.y_off
		move.l	a5,a4
		suba	#8,a4
		moveq	#5-1,d4
.mk_vert:
		or.b	#$80,(a4)
		suba	#8,a4
		dbf	d4,.mk_vert
		add.w	#1,d3

.y_off:
		adda	#1,a6
		dbf	d6,.y_chk_n
		tst.w	d3
		beq.s	.xs_off
		move.w	#$38,(RAM_ShakeMe).w
; 		move.b	obj_subid(a6),d0
; 		or.w	#$80,d0
; 		move.w	d0,(RAM_GotHitFrom).w
		moveq	#$0F,d0
		moveq	#SFX_punch,d1
		moveq	#1,d2
		bsr	gemaPlaySeq
.xs_off:
		rts

.show_score:
		lea	str_NewCountr0(pc),a0
		moveq	#1,d0
		moveq	#1,d1
		move.w	#DEF_PrintVramW|$4000,d2
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3
		bsr	Video_PrintW
		lea	str_NewCountr1(pc),a0
		moveq	#37,d0
		bra	Video_PrintW

Scrn0_ResetMap:
		lea	(RAM_BlocksBuff).w,a6
		moveq	#0,d3
		move	#5-1,d6
.x_chk_n:
		move.l	a6,a5
		move.w	#5-1,d7
		moveq	#0,d5
.x_chk:
		btst	#7,(a5)
		beq.s	.x_off
		clr.b	(a5)
.x_off:
		adda	#1,a5
		dbf	d7,.x_chk
		adda	#8,a6
		dbf	d6,.x_chk_n
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
str_NewCountr0:
		dc.l pstr_mem(0,RAM_Score_Haru)
		dc.b 0
		align 2
str_NewCountr1:
		dc.l pstr_mem(0,RAM_Score_Emily)
		dc.b 0
		align 2

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
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		dc.b $00,$00,$00,$00,$00,$00,$00,$00
		align 2

; ====================================================================
