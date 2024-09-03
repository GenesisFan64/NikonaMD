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

			memory 1		; Cell $0001
vramLoc_Haruna		ds.b $24
vramLoc_Sisi		ds.b $10
			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_ThisSpeed		ds.w 1
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
	; 32X only:
	if MARS|MARSCD
		lea	file_scrn3_mars(pc),a0			; Load DATA BANK for 32X stuff
		bsr	System_SetDataBank
		lea	(PalMars_Test+color_indx(1)),a0
		moveq	#1,d0
		move.w	#192,d1
		moveq	#0,d2
		bsr	Video_MdMars_FadePal
		lea	(PalMars_Haruna),a0
		move.w	#192,d0
		moveq	#16,d1
		moveq	#0,d2
		bsr	Video_MdMars_FadePal
		lea	(PalMars_Sisi),a0
		move.w	#208,d0
		moveq	#16,d1
		moveq	#0,d2
		bsr	Video_MdMars_FadePal
		lea	(ArtMars_Test2D),a0
		move.l	#0,a1
		move.l	#ArtMars_Test2D_e-ArtMars_Test2D,d0
		bsr	Video_MdMars_LoadVram
		lea	(MapMars_Test),a0
		move.l	#ArtMars_TestArt,a1
		moveq	#0,d0
		moveq	#0,d1
		move.w	#512/16,d2
		move.w	#256/16,d3
		moveq	#0,d4
		bsr	Video_MdMars_LoadMap
		moveq	#1,d0					; 32X 3D mode
		bsr	Video_MdMars_VideoMode
	endif
	; ----------------------------------------------
		lea	file_scrn3_main(pc),a0			; Load MAIN DATA bank
		bsr	System_SetDataBank
		bsr	System_SramInit
		addq.l	#1,(RAM_Save_Counter).w			; Temporal counter
		bsr	System_SramSave				; Save to SRAM/BRAM
	; ----------------------------------------------
	; Load PRINT
		move.l	#ASCII_FONT,d0				; d0 - Font data
		move.w	#DEF_PrintVram|$6000,d1			; Default_VRAM|Pallete 3
		bsr	Video_PrintInit
		move.l	#ASCII_FONT_W,d0
		move.w	#DEF_PrintVramW|$6000,d1
		bsr	Video_PrintInitW
		bsr	Video_PrintDefPal_Fade
	; ----------------------------------------------
		move.l	#obj_Player,d0
		bsr	Object_Make				; Make MD object
		lea	(objPal_Haruna),a0
		moveq	#16,d0					; d0 - Start at color index 16
		moveq	#16,d1					; d1 - Numof colors 16
		bsr	Video_FadePal
; 		lea	str_NikonaTest(pc),a0			; Print the title string
; 		moveq	#1,d0					; X/Y positions 1,1
; 		moveq	#1,d1
; 		move.w	#DEF_VRAM_FG,d2				; FG VRAM location
; 		move.w	#DEF_HSIZE_64,d3			; FG width
; 		bsr	Video_PrintW				; <-- Print BIG text
		lea	(Pal_Sisi+color_indx(1)),a0
		moveq	#1,d0
		moveq	#15,d1
		bsr	Video_FadePal
		move.l	#Art_Sisi,d0
		move.w	#cell_vram(vramLoc_Sisi),d1
		move.w	#Art_Sisi_e-Art_Sisi,d2
		bsr	Video_LoadArt
	; ----------------------------------------------
		move.w	#1,(RAM_ThisSpeed).w
		bsr	.show_counter				; Draw counter
		bsr	Video_DisplayOn
	; ----------------------------------------------
		bsr	Object_Run
		bsr	Video_FadeIn_Full

; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

.loop:
		bsr	Object_Run
		bsr	Video_BuildSprites
		bsr	System_Render

		bsr	.show_counter
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyB,d7
		beq	.b_update
		add.w	#1,(RAM_ThisSpeed).w
		cmp.w	#$10,(RAM_ThisSpeed).w
		bne.s	.b_update
		move.w	#1,(RAM_ThisSpeed).w
.b_update:
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyC,d7
		beq.s	.not_b
		move.l	#obj_Ball,d0
		bsr	Object_Make
.not_b:

; 	if MARS|MARSCD
; 		move.w	(Controller_1+on_press).w,d7
; 		andi.w	#JoyA,d7
; 		beq.s	.not_a
; 		moveq	#1,d0					; 32X 3D mode
; 		bsr	Video_MdMars_VideoMode
; .not_a:
; 	endif

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
		lea	str_NewCountr0(pc),a0
		moveq	#1,d0
		moveq	#24,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
		bra	Video_Print

; ====================================================================
; ------------------------------------------------------
; DATA asset locations
; ------------------------------------------------------

file_scrn3_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2
file_scrn3_mars:
		dc.l DATA_BANK1
		dc.b "BNK_MARS.BIN",0
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

		move.w	#320/2,obj_x(a6)	; Set Object's X/Y position
		move.w	#224/2,obj_y(a6)
		bset	#0,obj_attr(a6)		; Set X flip

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
		move.w	(RAM_ThisSpeed).w,d0	; X right

		moveq	#2,d2
		addq.w	#1,d3
.not_right:
		btst	#bitJoyLeft,d7
		beq.s	.not_left
		move.w	(RAM_ThisSpeed).w,d0	; X right
		neg.w	d0
; 		moveq	#-1,d0			; X left
; 		bclr	#0,obj_attr(a6)		; Reset X flip
		moveq	#3,d2
		addq.w	#1,d3
.not_left:
		btst	#bitJoyDown,d7
		beq.s	.not_down
		move.w	(RAM_ThisSpeed).w,d1
		moveq	#0,d2
		addq.w	#1,d3
.not_down:
		btst	#bitJoyUp,d7
		beq.s	.not_up
		move.w	(RAM_ThisSpeed).w,d1
		neg.w	d1
; 		moveq	#-1,d1			; Y up
		moveq	#1,d2
		addq.w	#1,d3
.not_up:
	if MARS|MARSCD
		lea	(RAM_MdMars_ScrlSett).w,a0
		add.w	d0,sscrl_x_pos(a0)
		add.w	d1,sscrl_y_pos(a0)
; 		lea	(RAM_MdMars_MdlCamera).w,a0
; 		add.l	d0,cam_x_pos(a0)
; 		add.l	d1,cam_z_pos(a0)
; 		add.w	d0,obj_x(a6)
; 		add.w	d1,obj_z(a6)
; 	else
; 		sub.w	d0,(RAM_HorScroll+2).w
; 		add.w	d1,(RAM_VerScroll+2).w
; 		add.w	d0,obj_x(a6)
; 		add.w	d1,obj_y(a6)
	endif
		move.w	d2,obj_anim_num(a6)

; ----------------------------------------------
; Show the object...

		tst.w	d3
		beq.s	.no_anim
		lea	.anim_data(pc),a0	; Do animation
		bsr	object_Animate
.no_anim:
	if MARS|MARSCD
		move.l	#0,a0
		lea	(Textr_Haruna),a1		; a0 - Texture location
		moveq	#0,d0
		move.w	#40/2,d0
		swap	d0
		move.w	#56/2,d0
		moveq	#%00,d1
		bsr	object_MdMars_GetSprInfo
		move.l	#splitw(40,56),d2		; Size Width / Height
		move.l	#splitw(40,192),d3		; Texture width / Index
		bra	Video_MdMars_SetSpr2D
	else
		rts
	endif

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
		move.w	#224,d1
		move.w	#320,d0
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

	if MARS|MARSCD
		move.l	#0,a0
		lea	(ArtMars_Sisi),a1		; a0 - Texture location
		moveq	#0,d0
		move.w	#32/2,d0
		swap	d0
		move.w	#48/2,d0
		move.b	obj_attr(a6),d1
		bsr	object_MdMars_GetSprInfo
		move.l	#splitw(32,32),d2		; Size Width / Height
		move.l	#splitw(32,192+16),d3		; Texture width / Index
		bra	Video_MdMars_MakeSpr2D
	else
		lea	(Map_Sisi),a1
		moveq	#0,d2
		move.w	obj_x(a6),d0
		move.w	obj_y(a6),d1
		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
		lsl.w	#8,d2
		lsl.w	#3,d2				; %000vh000 00000000
		add.w	#vramLoc_Sisi,d2
		move.w	obj_frame(a6),d3		; Current frame set by _Animate
		bra	Video_MakeSprMap
	endif

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

; str_NikonaTest:
; 		dc.b "32X 2D test"
; 		dc.b 0
; 		align 2
str_NewCountr0:
	if MARS|MARSCD
		dc.l pstr_mem(1,RAM_MdMars_ScrlSett+sscrl_x_pos)
		dc.b " "
		dc.l pstr_mem(1,RAM_MdMars_ScrlSett+sscrl_y_pos)
		dc.b $0A,$0A
	endif
		dc.l pstr_mem(1,RAM_ThisSpeed)
		dc.b " "
		dc.l pstr_mem(3,RAM_Framecount)
		dc.b 0
		align 2

str_InputMe:
	if MARS|MARSCD
		dc.l pstr_mem(0,sysmars_reg+comm0)
		dc.b " "
		dc.l pstr_mem(0,sysmars_reg+comm1)
		dc.b " "
		dc.l pstr_mem(3,RAM_Framecount)
	else
		dc.b " "
	endif
		dc.b 0
		align 2

Pal_TestStamp:
		dc.w 0
; 		binclude "game/data/mcd/stamps/haruna/pal.bin",2
		binclude "game/data/mcd/stamps/test/pal.bin",11*2
		align 2

; Object data:
objPal_Haruna:	binclude "game/data/md/sprites/haruna/pal.bin"
		align 2
objMap_Haruna:	binclude "game/data/md/sprites/haruna/map.bin"
		align 2
objPlc_Haruna:	binclude "game/data/md/sprites/haruna/plc.bin"
		align 2

; ====================================================================
