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
vramLoc_Backgrnd	ds.b $4C2
			endmemory

			memory $5A0
vramLoc_Haruna		ds.b $24
vramLoc_Sisi		ds.b $10
			endmemory

; ====================================================================
; ------------------------------------------------------
; This screen's RAM
; ------------------------------------------------------

			memory RAM_ScrnBuff
RAM_TestFrame		ds.w 1
RAM_SC1_PickDispl	ds.w 1
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
		move.l	#obj_Player,d0
		bsr	Object_Make
	; ----------------------------------------------
		bsr	.show_counter				; Draw counter
		bsr	Video_DisplayOn
		bsr	Screen0_PickBackgrnd
	; ----------------------------------------------
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

		bsr	.show_counter				; Draw counter
		move.w	(Controller_1+on_press).w,d7
		andi.w	#JoyB,d7
		beq.s	.not_apress
		addq.w	#1,(RAM_SC1_PickDispl).w
		andi.w	#1,(RAM_SC1_PickDispl).w
		bsr	Screen0_PickBackgrnd
.not_apress:
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
		rts
		lea	str_NewCountr0(pc),a0
		moveq	#1,d0
		moveq	#3,d1
		move.w	#DEF_VRAM_FG,d2
		move.w	#DEF_HSIZE_64,d3
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

Screen0_PickBackgrnd:
		bsr	System_Render
		bsr	Video_DisplayOff
		bsr	Video_ClearScreen
		tst.w	(RAM_SC1_PickDispl).w
		bne	.pick_second
		moveq	#1,d0
		moveq	#%00,d1
		bsr	Video_Resolution
		lea	str_NikonaTest(pc),a0			; Print the title string
		moveq	#16,d0					; X/Y positions 1,1
		moveq	#1,d1
		move.w	#DEF_VRAM_FG,d2				; FG VRAM location
		move.w	#DEF_HSIZE_64,d3			; FG width
		bsr	Video_PrintW				; <-- Print BIG text
		lea	str_NikonaTest2(pc),a0			; Print the title string
		moveq	#15,d0					; X/Y positions 1,1
		moveq	#25,d1
		move.w	#DEF_VRAM_FG,d2				; FG VRAM location
		move.w	#DEF_HSIZE_64,d3			; FG width
		bsr	Video_PrintW

		lea	(Pal_TESTBG+color_indx(1)),a0		; a0 - Load palette (+2 skips first color)
		moveq	#1,d0					; d0 - Start at $01
		moveq	#15,d1					; d1 - 15 colors
		bsr	Video_FadePal				; Load palette to FADE buffer
		bsr	Video_LoadPal				; Load palette to FADE buffer
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
		move.w	#vramLoc_Backgrnd,d3			; d3 - Starting cell
		bsr	Video_LoadMap
		bra	Video_DisplayOn

.pick_second:
		moveq	#1,d0
		moveq	#%10,d1
		bsr	Video_Resolution
		lea	str_NikonaTest(pc),a0			; Print the title string
		moveq	#16,d0					; X/Y positions 1,1
		moveq	#1,d1
		move.w	#DEF_VRAM_FG,d2				; FG VRAM location
		move.w	#DEF_HSIZE_64,d3			; FG width
		bsr	Video_PrintW
		lea	str_NikonaTest2(pc),a0			; Print the title string
		moveq	#15,d0					; X/Y positions 1,1
		moveq	#26,d1
		move.w	#DEF_VRAM_FG,d2				; FG VRAM location
		move.w	#DEF_HSIZE_64,d3			; FG width
		bsr	Video_PrintW

		lea	(Pal_TESTBG2),a0			; a0 - Load palette (+2 skips first color)
		moveq	#0,d0					; d0 - Start at $01
		moveq	#16,d1					; d1 - 15 colors
		bsr	Video_LoadPal				; Load palette to FADE buffer
		move.l	#Art_TESTBG2,d0				; d0 - Graphics pointer (NOT a0 here)
		move.w	#cell_vram(vramLoc_Backgrnd),d1		; d1 - output VRAM location
		move.w	#Art_TESTBG2_e-Art_TESTBG2,d2		; d2 - Size: end-start
		bsr	Video_LoadArt
		lea	(Map_TESTBG2),a0			; a0 - Map data
		move.l	#splitw(0,0),d0				; d0 - X/Y Positions 0,0
		move.l	#splitw(320/8,448/8),d1			; d1 - Width and Height
		move.l	#splitw(DEF_HSIZE_64,DEF_VRAM_BG),d2	; d2 - Layer width / Layer output
		move.w	#vramLoc_Backgrnd,d3			; d3 - Starting cell
		bsr	Video_LoadMapV
		bra	Video_DisplayOn

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

str_NikonaTest:
		dc.b "** Top **"
		dc.b 0
		align 2
str_NikonaTest2:
		dc.b "** Bottom **"
		dc.b 0
		align 2
str_NewCountr0:
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
; 		dc.w 0
; ; 		binclude "game/data/mcd/stamps/haruna/pal.bin",2
; 		binclude "game/data/mcd/stamps/test/pal.bin",11*2
; 		align 2

; Object data:
; objPal_Haruna:	binclude "game/data/md/sprites/haruna/pal.bin"
; 		align 2
; objMap_Haruna:	binclude "game/data/md/sprites/haruna/map.bin"
; 		align 2
; objPlc_Haruna:	binclude "game/data/md/sprites/haruna/plc.bin"
; 		align 2

; ====================================================================
