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
vramLoc_Backgrnd	ds.b $300
vramLoc_Haruna		ds.b $24
vramLoc_Sisi		ds.b $10
			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_TestFrame		ds.w 1
RAM_TempStampVars	ds.l 2
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
		move.w	#DEF_PrintVram|DEF_PrintPal,d1
		bsr	Video_PrintInit
		move.l	#ASCII_FONT_W,d0
		move.w	#DEF_PrintVramW|DEF_PrintPal,d1
		bsr	Video_PrintInitW
		bsr	Video_PrintDefPal_Fade
	; ----------------------------------------------
		lea	(Pal_StampTest),a0
		moveq	#0,d0
		moveq	#16,d1
		bsr	Video_FadePal
		lea	(Pal_Haruna),a0
		moveq	#16,d0
		moveq	#16,d1
		bsr	Video_FadePal
		lea	(Pal_Sisi),a0
		moveq	#32,d0
		moveq	#16,d1
		bsr	Video_FadePal
		move.l	#Art_Sisi,d0
		move.w	#cell_vram(vramLoc_Sisi),d1
		move.w	#Art_Sisi_e-Art_Sisi,d2
		bsr	Video_LoadArt

		lea	str_MidemeEsta(pc),a0
		moveq	#0,d0
		moveq	#26,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bsr	Video_Print

	; ----------------------------------------------
	if MCD|MARSCD
		lea	file_scrn2_stamps(pc),a0			; Load STAMPS bank from Disc
		bsr	System_SetDataBank
		lea	(SC2_OutCells),a0
		move.l	#splitw(256,192),d0				; Dot-screen Width/Height 128x128
		move.w	#vramLoc_Backgrnd,d1				; VRAM location
		moveq	#0,d2						; Single buffer mode
		move.w	#DEF_MaxStampCOut,d3				; Size of temporal cells
; 		move.w	#$280,d3
		lea	(SC2_OutCells),a0				; Location for the temporal cells
		bsr	Video_MdMcd_StampEnable
		move.l	#splitw($0000,$0002),d0				; Map position 0,2
		move.l	#splitw(256/8,192/8),d1				; Size 128x128 in cells
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_BG),d2		; Map scroll width / Foreground
		move.w	(RAM_MdMcd_StampSett+mdstmp_vramMain).w,d3	; Get Auto-VRAM set by _StampEnable
		bsr	Video_MdMcd_StampDotMap
; 		move.l	#splitw($0000+$20,$0002),d0			; Map position 0,2
; 		move.w	(RAM_MdMcd_StampSett+mdstmp_vramSec).w,d3	; Get Auto-VRAM set by _StampEnable
; 		bsr	Video_MdMcd_StampDotMap

	; TEMPORAL MAP
		bsr	System_MdMcd_WaitWRAM
		lea	MapStamp_Test(pc),a0
		lea	(sysmcd_wram+WRAM_MdMapTable).l,a1
		move.w	#((192/16))-1,d7
.y_draw:
		move.w	#((256/16))-1,d6
		move.l	a1,a2
.x_draw:
		move.w	(a0)+,(a2)+
		dbf	d6,.x_draw
		adda	#(256/16)*2,a1
		dbf	d7,.y_draw

; 		movem.l	(a6)+,d0-d3/a0-a3
; 		movem.l	d0-d3/a0-a3,(a5)
; 		adda	#$20,a5
; 		dbf	d7,.copy_paste

		moveq	#0,d0
		moveq	#0,d1
		bsr	Video_Resolution
	endif
	; ----------------------------------------------
		bsr	.show_counter				; Draw counter
		bsr	Video_DisplayOn
	; ----------------------------------------------
	if MCD|MARSCD
		bsr	.make_stamp
		lea	(GemaTracks_Scr2),a0
		bsr	gemaSetMasterList
		bsr	System_Render
		move.w	#192,d0
		bsr	gemaSetBeats
		moveq	#-1,d0
		moveq	#0,d1
		moveq	#0,d2
		bsr	gemaPlaySeq
; 		moveq	#2,d0
; 		bsr	System_MdMcd_CddaPlayL
		bsr	Video_MdMcd_StampInit
	endif
		bsr	Object_Run
		bsr	Video_BuildSprites
		bsr	Video_FadeIn_Full

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	Sound_Update
		bsr	System_Render
		bsr	Object_Run
		bsr	Video_BuildSprites
		bsr	Sound_Update
	if MCD|MARSCD
		bsr	Video_MdMcd_StampRender
		bcc.s	.keep_frame
		add.w	#$100,(RAM_HorScroll+2).w
.keep_frame:

		bsr	.make_stamp
		lea	(Controller_1).w,a5
; 		move.w	on_press(a5),d7
		move.w	on_hold(a5),d7
		btst	#bitJoyRight,d7
		beq.s	.not_right
		addq.w	#1,(RAM_TempStampVars).w
.not_right:
		btst	#bitJoyLeft,d7
		beq.s	.not_left
		subq.w	#1,(RAM_TempStampVars).w
.not_left:
		btst	#bitJoyDown,d7
		beq.s	.not_down
		addq.w	#1,(RAM_TempStampVars+2).w
.not_down:
		btst	#bitJoyUp,d7
		beq.s	.not_up
		subq.w	#1,(RAM_TempStampVars+2).w
.not_up:

		btst	#bitJoyX,d7
		beq.s	.not_xx
		addq.w	#1,(RAM_TempStampVars+4).w
.not_xx:
		btst	#bitJoyY,d7
		beq.s	.not_y
		lea	(RAM_MdMcd_Stamps),a0
		subq.w	#1,cdstamp_rot(a0)
.not_y:

		btst	#bitJoyA,d7
		beq.s	.not_a
		subq.w	#1,(RAM_TempStampVars+6).w
.not_a:
		btst	#bitJoyB,d7
		beq.s	.not_bb
		addq.w	#1,(RAM_TempStampVars+6).w
.not_bb:
	endif
		bsr	.show_counter				; Draw counter

		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyC,d7
		beq.s	.not_b
		move.l	#obj_Ball,d0
		bsr	Object_Make
.not_b:

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
	if MCD|MARSCD
		lea	str_NikonaTest(pc),a0
		moveq	#1,d0
		moveq	#1,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bsr	Video_Print
	endif
		lea	str_NewCountr0(pc),a0
		moveq	#23,d0
		moveq	#1,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bra	Video_Print

.make_stamp:
;  rts
	if MCD|MARSCD
		move.l	#0,a0
		move.l	#0,a1
		move.l	(RAM_TempStampVars).w,d0
		move.l	(RAM_TempStampVars+4).w,d1
		move.l	#splitw(256,192),d2
		move.l	#splitw(256/2,192/2),d3			; Stamp X/Y center
		moveq	#31-1,d7
.pain_test:
		bsr	Video_MdMcd_SetStamp
		add.l	#$00100000,d1
; 		adda	#1,a0
; 		dbf	d7,.pain_test
	endif
		rts

; ====================================================================
; ------------------------------------------------------
; DATA asset locations
; ------------------------------------------------------

file_scrn1_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2
file_scrn2_stamps:
		dc.l -1
		dc.b "STAMPS_0.BIN",0
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
		move.w	#256/2,obj_x(a6)	; Set Object's X/Y position
		move.w	#224/2,obj_y(a6)

; ----------------------------------------------
.main:
		lea	(Controller_1).w,a0	; a0 - Input 1 buffer
		move.w	on_hold(a0),d7		; d7 - Read HOLDING buttons on Port 1
		moveq	#0,d0			; d0 - Reset X increment
		moveq	#0,d1			; d1 - Reset Y increment
		moveq	#0,d2
		moveq	#0,d3
		btst	#bitJoyRight,d7
		beq.s	.not_right
		moveq	#1,d0			; X right
; 		bset	#0,obj_attr(a6)		; Set X flip
		moveq	#2,d2
		addq.w	#1,d3
.not_right:
		btst	#bitJoyLeft,d7
		beq.s	.not_left
		moveq	#-1,d0			; X left
; 		bclr	#0,obj_attr(a6)		; Reset X flip
		moveq	#3,d2
		addq.w	#1,d3
.not_left:
		btst	#bitJoyDown,d7
		beq.s	.not_down
		moveq	#1,d1			; Y down
		moveq	#0,d2
		addq.w	#1,d3
.not_down:
		btst	#bitJoyUp,d7
		beq.s	.not_up
		moveq	#-1,d1			; Y up
		moveq	#1,d2
		addq.w	#1,d3
.not_up:
; 	if MARS|MARSCD
; 		lea	(RAM_MdMars_MdlCamera).w,a0
; 		add.l	d0,cam_x_pos(a0)
; 		add.l	d1,cam_z_pos(a0)
; 		add.w	d0,obj_x(a6)
; 		add.w	d1,obj_z(a6)
; 	else
; 		sub.w	d0,(RAM_HorScroll+2).w
; 		add.w	d1,(RAM_VerScroll+2).w
		add.w	d0,obj_x(a6)
		add.w	d1,obj_y(a6)
; 	endif

		move.w	d2,obj_anim_num(a6)

; ----------------------------------------------
; Show the object...

		tst.w	d3
		beq.s	.no_anim
		lea	.anim_data(pc),a0	; Do animation
		bsr	object_Animate
.no_anim:
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
		add.w	(RAM_HorScroll+2).w,d0
		sub.w	(RAM_VerScroll+2).w,d1
		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
		lsl.w	#8,d2
		lsl.w	#3,d2				; %000vh000 00000000
		add.w	#vramLoc_Haruna|$2000,d2 	; +VRAM+$2000(use second palette line)
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

		move.w	#$20,obj_x(a6)	; Set Object's X/Y position
		move.w	#$10,obj_y(a6)
		move.w	#$48+1,d0
		bsr	System_DiceRoll
		lsl.w	#1,d0
		add.w	d0,obj_x(a6)
		add.w	d0,obj_y(a6)
		lsl.w	#3,d0
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
		move.w	#256,d0
		move.w	obj_x(a6),d2
		tst.w	d2
		bpl.s	.x_back
		neg.w	obj_x_spd(a6)
		bchg	#0,obj_attr(a6)
.x_back:
		cmp.w	d0,d2
		blt.s	.x_foward
		neg.w	obj_x_spd(a6)
		bchg	#0,obj_attr(a6)
.x_foward:
		move.w	d2,obj_x(a6)

		move.w	obj_y(a6),d2
		tst.w	d2
		bpl.s	.y_back
		neg.w	obj_y_spd(a6)
.y_back:
		cmp.w	d1,d2
		blt.s	.y_foward
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
		add.w	#vramLoc_Sisi|$4000,d2 	; +VRAM+$2000(use second palette line)
		move.w	obj_frame(a6),d3		; Current frame set by _Animate
		bra	Video_MakeSprMap

; ----------------------------------------------

.anim_data:
		dc.w .maind-.anim_data
.maind:
		dc.w 8
		dc.w 0,1,2,1
		dc.w -2
		align 2

; ====================================================================
; ------------------------------------------------------
; Subroutines
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

	if MCD|MARSCD
str_NikonaTest:
		dc.l pstr_mem(1,RAM_TempStampVars)
		dc.b " "
		dc.l pstr_mem(1,RAM_TempStampVars+2)
		dc.b " "
		dc.l pstr_mem(1,RAM_TempStampVars+4)
		dc.b " "
		dc.l pstr_mem(1,RAM_TempStampVars+6)
		dc.b " "
		dc.b 0
		align 2
	endif

str_NewCountr0:
		dc.l pstr_mem(3,RAM_Framecount)
		dc.b 0
		align 2

str_MidemeEsta:
		dc.b "0o1o2o3o4o5o6o7o8o9oAoBoCoDoEoFo",$0A
		dc.b 0
		align 2

; ----------------------------------------------------------------
; Everything else...
; ----------------------------------------------------------------

Pal_Haruna:	binclude "game/data/md/sprites/haruna/pal.bin"
		align 2
Map_Haruna:	binclude "game/data/md/sprites/haruna/map.bin"
		align 2
Plc_Haruna:	binclude "game/data/md/sprites/haruna/plc.bin"
		align 2

Pal_Sisi:	binclude "game/data/md/sprites/sisi/pal.bin"
		align 2
Map_Sisi:	binclude "game/data/md/sprites/sisi/map.bin"
		align 2

Pal_StampTest:
		binclude "game/data/mcd/stamps/test/pal.bin"
		align 2

; ----------------------------------------------------------------

MapStamp_Test:
		binclude "game/data/mcd/stamps/test/map.bin"
		align 2

; ====================================================================
; ------------------------------------------------------
; Sound bank
; ------------------------------------------------------

	if MCD|MARSCD
		gemaList GemaTracks_Scr2
		gemaTrk 1,5,gtrk_NadieCd_2

; ----------------------------------------------------

gtrk_NadieCd_2:
		gemaHead .blk,.pat,.ins,11
.blk:
		binclude "sound/tracks/nadie_cd_blk.bin"
.pat:
		binclude "sound/tracks/nadie_cd_patt.bin"
.ins:
		gInsPcm 0,PcmIns_Nadie_L,0
		gInsFm -36,FmIns_Piano_Aqua
		gInsFm -12,FmIns_HBeat_tom
		gInsPcm -5,PcmIns_PKick,%00
		gInsPsg 0,$30,$20,$00,$02,$04,0
		gInsFm 0,FmIns_Trumpet_1
		gInsPcm 0,PcmIns_Piano,%00
		gInsPcm -12,PcmIns_PTom,%00
		gInsNull
		gInsPcm 0,PcmIns_Nadie_R,0

; ----------------------------------------------------

FmIns_Piano_Aqua:
		binclude "sound/instr/fm/piano_aqua.gsx",$2478,$20
FmIns_HBeat_tom:
		binclude "sound/instr/fm/nadia_tom.gsx",$2478,$20
FmIns_Trumpet_1:
		binclude "sound/instr/fm/trumpet_1.gsx",$2478,$20
	endif

; ====================================================================
; ------------------------------------------------------
; Stamp cell temporal storage
; ------------------------------------------------------

		align 2
SC2_OutCells:
		ds.b DEF_MaxStampCOut*$20	; <-- auto-label
