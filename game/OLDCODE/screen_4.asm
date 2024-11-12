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
vramLoc_Backgrnd	ds.b $32A
vramLoc_Haruna		ds.b $12A
vramLoc_Haruna2		ds.b $12A
			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_TestTouch		ds.l 1
RAM_Camera_Xpos		ds.l 1
RAM_Camera_Zpos		ds.l 1
RAM_Camera_Rot		ds.w 1
RAM_Camera_TRot		ds.w 1
RAM_Camera_TRotD	ds.w 1
RAM_ModelPick		ds.w 1
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
		lea	file_scrn4_mars(pc),a0			; Load DATA BANK for 32X stuff
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
		lea	(RAM_MdMars_Models).w,a0
		bsr	.pick_model
		bsr	Camera_Update
		moveq	#2,d0					; 32X 3D mode
		bsr	Video_MdMars_VideoMode
	endif
	; ----------------------------------------------
		lea	file_scrn4_main(pc),a0			; Load MAIN DATA bank
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
	; ----------------------------------------------
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
	if MARS|MARSCD
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyC,d7
		beq.s	.not_b
		move.l	#obj_Ball,d0
		bsr	Object_Make
.not_b:
		move.w	(Controller_1+on_hold).w,d7
		andi.w	#JoyA,d7
		beq	.no_rot_l
		sub.w	#1,(RAM_Camera_Rot).w
		bsr	Camera_Update
.no_rot_l:
		move.w	(Controller_1+on_hold).w,d7
		andi.w	#JoyB,d7
		beq	.no_rot_r
		add.w	#1,(RAM_Camera_Rot).w
		bsr	Camera_Update
.no_rot_r:
	endif

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
		moveq	#1,d1
		move.w	#DEF_PrintVram|DEF_PrintPal,d2
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_FG),d3
		bra	Video_Print

; ------------------------------------------------------

.pick_model:
	if MARS|MARSCD
		move.w	(RAM_ModelPick).w,d0
		lsl.w	#2,d0
		lea	(RAM_MdMars_Models).w,a0
		move.l	.mdl_list(pc,d0.w),mmdl_data(a0)
		move.l	#12,mmdl_y_pos(a0)
		rts
.mdl_list:
		dc.l MarsObj_test
		dc.l MarsObj_test_2
	else
		rts
	endif

; ====================================================================
; ------------------------------------------------------
; DATA asset locations
; ------------------------------------------------------

file_scrn4_main:
		dc.l DATA_BANK0
		dc.b "BNK_MAIN.BIN",0
		align 2
file_scrn4_mars:
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

	if MARS|MARSCD
		move.w	#0,obj_x(a6)
		move.w	#0,obj_y(a6)
		move.w	#0,obj_z(a6)
	else
		move.w	#320/2,obj_x(a6)	; Set Object's X/Y position
		move.w	#224/2,obj_y(a6)
	endif

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
	if MARS|MARSCD
		lea	(RAM_MdMars_MdlCamera).w,a0
		add.l	d0,mcam_x_pos(a0)
		add.l	d1,mcam_z_pos(a0)
		add.w	d0,obj_x(a6)
		add.w	d1,obj_z(a6)
	else
		sub.w	d0,(RAM_HorScroll+2).w
		add.w	d1,(RAM_VerScroll+2).w
		add.w	d0,obj_x(a6)
		add.w	d1,obj_y(a6)
	endif

		move.w	d2,obj_anim_num(a6)

; ----------------------------------------------
; Show the object...

		tst.w	d3
		beq.s	.no_anim
		lea	.anim_data(pc),a0	; Do animation
		bsr	object_Animate
.no_anim:
		clr.l	(RAM_TestTouch).w
		bsr	object_Touch
		tst.l	d0
		beq.s	.lel
		move.l	d0,(RAM_TestTouch).w
.lel:

	if MARS|MARSCD
		lea	(Textr_Haruna),a1		; a0 - Texture location
		moveq	#%11,d1
		bsr	object_MdMars_GetSprInfo
		move.l	#splitw(40,56),d2		; Size Width / Height
		move.l	#splitw(40,192),d3		; Texture width / Index
; 		bra	Video_MdMars_MakeSpr3D
		move.l	#0,a0
		bra	Video_MdMars_SetSpr3D
	endif
		rts

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

		move.w	#-$80,obj_x(a6)	; Set Object's X/Y position
		move.w	#-$80,obj_z(a6)
		move.w	#$100+1,d0
		bsr	System_DiceRoll
		move.w	d0,d4
		move.w	#$80+1,d0
		bsr	System_DiceRoll
		lsl.w	#1,d0
		lsl.w	#1,d4
		add.w	d0,obj_x(a6)
		add.w	d4,obj_z(a6)

		bsr	System_Random
		move.l	(RAM_SysRandom).w,d7
		lsr.w	#1,d7
		bcs.s	.x_random
		neg.w	obj_x_spd(a6)
.x_random:
		lsr.w	#1,d7
		bcs.s	.y_random
		neg.w	obj_z_spd(a6)
.y_random:
		rts

; ----------------------------------------------
.main:
; 		move.w	#224,d1
; 		move.w	#320,d0
; 		move.w	obj_x(a6),d2
; 		tst.w	d2
; 		bpl.s	.x_back
; 		neg.w	obj_x_spd(a6)
; 		bchg	#0,obj_attr(a6)
; .x_back:
; 		cmp.w	d0,d2
; 		blt.s	.x_foward
; 		neg.w	obj_x_spd(a6)
; 		bchg	#0,obj_attr(a6)
; .x_foward:
; 		move.w	d2,obj_x(a6)
;
; 		move.w	obj_y(a6),d2
; 		tst.w	d2
; 		bpl.s	.y_back
; 		neg.w	obj_y_spd(a6)
; .y_back:
; 		cmp.w	d1,d2
; 		blt.s	.y_foward
; 		neg.w	obj_y_spd(a6)
; .y_foward:
; 		move.w	d2,obj_y(a6)
;
; 		bsr	object_Speed

; ----------------------------------------------
; Show the object...
		lea	.anim_data(pc),a0	; Do animation
		bsr	object_Animate

	if MARS|MARSCD
		move.l	#0,a0
		lea	(ArtMars_Sisi),a1		; a0 - Texture location
		moveq	#0,d0
		moveq	#%11,d1
		bsr	object_MdMars_GetSprInfo
		move.l	#splitw(32,32),d2		; Size Width / Height
		move.l	#splitw(32,192+16),d3		; Texture width / Index
		bra	Video_MdMars_MakeSpr3D
	else
		rts
; 		lea	(Map_Sisi),a1
; 		moveq	#0,d2
; 		move.w	obj_x(a6),d0
; 		move.w	obj_y(a6),d1
; 		move.b	obj_attr(a6),d2			; <-- Quick attribute bits
; 		lsl.w	#8,d2
; 		lsl.w	#3,d2				; %000vh000 00000000
; 		add.w	#vramLoc_Sisi,d2
; 		move.w	obj_frame(a6),d3		; Current frame set by _Animate
; 		bra	Video_MakeSprMap
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

Camera_Update:
	if MARS|MARSCD
		lea	(RAM_MdMars_MSprites).w,a0
		lea	(RAM_MdMars_MdlCamera).w,a1
		moveq	#0,d3
		moveq	#0,d4
		move.w	mspr_x_pos(a0),d3
		move.w	mspr_z_pos(a0),d4
		ext.l	d3
		ext.l	d4
		move.w	#36*4,d5
		move.w	(RAM_Camera_Rot).w,d0
		bsr	System_SineWave_Cos
		muls.w	d5,d1
		asr.l	#8,d1
		ext.l	d1
		add.l	d1,d4
		move.w	(RAM_Camera_Rot).w,d0
		bsr	System_SineWave
		muls.w	d5,d1
		asr.l	#8,d1
		ext.l	d1
		add.l	d1,d3
		move.w	(RAM_Camera_Rot).w,d0
		lsl.l	#3,d0
		ext.l	d0
		neg.l	d0
		move.l	d0,mcam_y_rot(a1)

		move.l	d3,mcam_x_pos(a1)
		move.l	d4,mcam_z_pos(a1)
	endif
		rts

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

str_NewCountr0:
	if MARS|MARSCD
		dc.l pstr_mem(3,RAM_Objects+obj_x)
		dc.b " "
		dc.l pstr_mem(3,RAM_Objects+obj_y)
		dc.b " "
		dc.l pstr_mem(3,RAM_Objects+obj_z)
		dc.b " "
		dc.l pstr_mem(3,RAM_TestTouch)
		dc.b $0A
		dc.l pstr_mem(3,RAM_MdMars_MdlCamera+mcam_x_rot)
		dc.b " "
		dc.l pstr_mem(3,RAM_MdMars_MdlCamera+mcam_y_rot)
		dc.b " "
		dc.l pstr_mem(3,RAM_MdMars_MdlCamera+mcam_z_rot)
		dc.b " "
		dc.l pstr_mem(3,RAM_Framecount)
	else
		dc.l pstr_mem(3,RAM_Framecount)
	endif
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

; ====================================================================
