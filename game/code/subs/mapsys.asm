; ====================================================================
; ----------------------------------------------------------------
; MapSys code
; ----------------------------------------------------------------

; ------------------------------------------------
; RAM_MapScrl
			strct 0
map_blk			ds.l 1		; Block data
map_low			ds.l 1		; Layout map LOW priority
map_hi			ds.l 1		; Layout map HI priority (OPTIONAL)
map_col			ds.l 1		; Collision map (OPTIONAL)
map_cmap		ds.l 1		; Collision slope data
map_vram		ds.l 1		; VRAM input location (Genesis: read as map_vram+2)
map_vout		ds.w 1		; VRAM output location
map_width		ds.w 1		; FULL Width in pixels
map_height		ds.w 1		; FULL Height in pixels
map_x			ds.w 1		; X position
map_y			ds.w 1		; Y position
map_x_old		ds.w 1		; OLD X position
map_y_old		ds.w 1		; OLD Y position
map_x_inc		ds.w 1		; X-increment
map_y_inc		ds.w 1		; Y-increment
map_flags		ds.w 1		; Drawing flag bits (BYTE)
map_x_set		ds.b 1
map_y_set		ds.b 1
sizeof_mapscrl		ds.l 0
			endstrct
; ----------------------------------------
; map_flags
bitDrwR			set 0
bitDrwL			set 1
bitDrwD			set 2
bitDrwU			set 3
bitBgOn			set 7

			strct RAM_MapScrlBuff
RAM_MapScrl		ds.b sizeof_mapscrl*2		; **** Map scrolling buffer, Genesis side (2 layers)
RAM_MapScrl_Mars	ds.b sizeof_mapscrl		; **** '' same but for 32X
			endstrct

; ----------------------------------------------------------------
; MAP layout system for Genesis and 32X
;
; Handles both Genesis PlaneA, PlaneB and
; 32X's scrolling area in pseudo-Video mode $01.
;
; Maps are built on 16x16 blocks ONLY,
; map width and height can be on any size, only watch out
; for limited memory storage.
;
; Genesis VDP:
; - Supports LOW and HI priority blocks
; - Plane size MUST be set to H64, H32.
;
; 32X SVDP:
; - Designed for Pseudo-Video mode $01.
; ----------------------------------------------------------------

; EXAMPLE CODES:
; Loading data:
; 		bsr	MapScrl_Init
; 		lea	(ScBlkFG_MD).l,a0		; Block data
; 		lea	(ScMapFGL_MD).l,a1		; Map LOW layout data
; 		lea	(ScMapFGH_MD).l,a2		; High data
; 		lea	(ScMapCol_MD).l,a3		; COLLISION data
; 		moveq	#0,d0				; Slot 0
; 		move.w	#$2000|thisVram_FG,d1		; VRAM input
; 		move.w	#$C000,d2			; VRAM output
; 		move.l	#(64*16)<<16|(32*16),d3		; Width|Height
; 		bsr	MapScrl_Set
;
; Mainloop:
; 		bsr	MapScrl_ShowScroll		; Set Map's X/Y camera to VDP and SVDP
; 		bsr	MapScrl_Mars_DrawScrl		; Draw SVDP off-screen changes
; 		bsr	System_Render			; Render frame
; 		bsr	MapScrl_DrawScrl		; [VBlank] Draw VDP off-screen changes
; 		bsr	Objects_Run			; Run objects
; 		bsr	MapScrl_Update			; Update map changes
;		bra	MainLoop

; --------------------------------------------------------
; MapScrl_Init
;
; Initialize ALL maps
; --------------------------------------------------------

MapScrl_Init:
		movem.l	d6-d7/a6,-(sp)
		lea	(RAM_MapScrl).w,a6
		move.w	#((sizeof_mapscrl*3)/2)-1,d7
		moveq	#0,d6
.clr:
		move.w	d6,(a6)+
		dbf	d7,.clr
		movem.l	(sp)+,d6-d7/a6
		rts

; --------------------------------------------------------
; MapScrl_Update
;
; Call this BEFORE System_Render to update
; scroll variables for the next frame.
; --------------------------------------------------------

MapScrl_Update:
		lea	(RAM_MapScrl).w,a6
		bsr.s	.this_bg
		adda	#sizeof_mapscrl,a6
		bsr.s	.this_bg
	if MARS|MARSCD
		lea	(RAM_MapScrl_Mars).w,a6
		bsr.s	.this_bg
	endif
		rts

; ------------------------------------------------

.this_bg:
		btst	#7,map_flags(a6)
		beq	.no_bg
		moveq	#0,d1
		moveq	#0,d2
		move.b	map_flags(a6),d7
		move.w	map_x(a6),d3
		move.w	map_x_old(a6),d0
		cmp.w	d0,d3
		beq.s	.x_stay
		move.w	map_x(a6),map_x_old(a6)
		move.w	d3,d1
		sub.w	d0,d1
.x_stay:
		move.w	map_y(a6),d3
		move.w	map_y_old(a6),d0
		cmp.w	d0,d3
		beq.s	.y_stay
		move.w	map_y(a6),map_y_old(a6)
		move.w	d3,d2
		sub.w	d0,d2
.y_stay:
	; Increment draw beam pointers
	; d1 - X incr
	; d2 - Y incr
		move.w	d1,d0
		move.w	map_width(a6),d5
		move.w	map_x_inc(a6),d4
		bsr.s	.beam_incr
		move.w	d4,map_x_inc(a6)
		move.w	d2,d0
		move.w	map_height(a6),d5
		move.w	map_y_inc(a6),d4
		bsr.s	.beam_incr
		move.w	d4,map_y_inc(a6)

	; Write direction drawing bits
		move.b	map_x_set(a6),d7
		add.b	d1,d7
		move.w	d7,d6
		andi.b	#-$10,d6
		beq.s	.x_k
		tst.w	d1
		beq.s	.x_k
		moveq	#bitDrwR,d5
		tst.w	d1
		bpl.s	.x_r
		moveq	#bitDrwL,d5
.x_r:
		bset	d5,map_flags(a6)
.x_k:
		andi.b	#$0F,d7
		move.b	d7,map_x_set(a6)
		move.b	map_y_set(a6),d7
		add.b	d2,d7
		move.w	d7,d6
		andi.b	#-$10,d6
		beq.s	.y_k
		tst.w	d2
		beq.s	.no_bg
		moveq	#bitDrwD,d5
		tst.w	d2
		bpl.s	.y_d
		moveq	#bitDrwU,d5
.y_d:
		bset	d5,map_flags(a6)
.y_k:
		andi.b	#$0F,d7
		move.b	d7,map_y_set(a6)

.no_bg:
		rts

; ----------------------------------------
; d0 - Increment value
; d4 - X/Y beam
; d5 - Max Width or Height
.beam_incr:
		add.w	d0,d4
.xd_l:		tst.w	d4
		bpl.s	.xd_g
		add.w	d5,d4
		bra.s	.xd_l
.xd_g:		cmp.w	d5,d4
		blt.s	.val_h
		sub.w	d5,d4
		bra.s	.xd_g
.val_h:
		rts

; --------------------------------------------------------
; MapScrl_ShowScroll
;
; Generate scroll data for VDP and SVDP
; VDP: assumes Slot 0 is Foreground and
; Slot 1 if Background
;
; Call this AFTER MapScrl_Run
; --------------------------------------------------------

MapScrl_ShowScroll:
	if MARS|MARSCD
		lea	(RAM_MapScrl_Mars).w,a6
		btst	#7,map_flags(a6)
		beq.s	.no_mars
		lea	(RAM_MdMars_ScrlBuff).w,a5
		move.w	map_x(a6),mscrl_Xpos(a5)
		move.w	map_y(a6),mscrl_Ypos(a5)
.no_mars:
	endif
		lea	(RAM_MapScrl).w,a6
		lea	(RAM_HorScroll).w,a5
		lea	(RAM_VerScroll).w,a4
		bsr	.this_bg
		adda	#sizeof_mapscrl,a6
		adda	#2,a5
		adda	#2,a4
.this_bg:
		btst	#7,map_flags(a6)
		beq.s	.not_used
		move.l	a5,a0
		move.l	a4,a1
		move.w	#224-1,d7
		move.w	#(320/16)-1,d6
		move.w	map_x(a6),d0
		move.w	map_y(a6),d1
		neg.w	d0
.set_x:
		move.w	d0,(a0)
		adda	#4,a0
		dbf	d7,.set_x
.set_y:
		move.w	d1,(a1)
		adda	#4,a1
		dbf	d6,.set_y
.not_used:
		rts

; --------------------------------------------------------
; MdMap_DrawAll
;
; Draws ALL maps on the screen, SLOW.
;
; Notes:
; - Call this on DISPLAY ONLY, VDP's display must be
;   OFF for better performance.
; - 32X/CD32X: After calling this reset psd-Video mode
;   $01 to apply changes
; --------------------------------------------------------

MapScrl_DrawAll:
; 		movem.l	d6-d7/a6,-(sp)
		lea	(RAM_MapScrl).w,a6
		bsr	.this_bg
		adda	#sizeof_mapscrl,a6
		bsr	.this_bg
	if MARS|MARSCD
		adda	#sizeof_mapscrl,a6
		bsr	.mars_bg
	endif
; 		movem.l	(sp)+,d6-d7/a6
		rts

; ------------------------------------------------

.this_bg:
		btst	#7,map_flags(a6)
		beq	.no_bg
		bsr	.init_xy
		move.w	d0,d2
		move.w	d1,d3
		move.l	map_blk(a6),a5
		move.l	map_low(a6),a4
		move.l	map_hi(a6),a3
		moveq	#0,d6
		moveq	#0,d5
		moveq	#0,d4
		move.w	#((512)/16)-1,d7		; d7 - X cells | Y cells
		swap	d7
		move.w	#((256)/16)-1,d7
		move.w	map_vout(a6),d6
		move.w	d6,d5
		rol.w	#2,d6
		andi.w	#%11,d6
		swap	d6
		move.w	d5,d6
		andi.w	#$3FFF,d6
		or.w	#$4000,d6
		move.w	map_y(a6),d5			; Read Y
		subi.w	#$10,d5				; - 1 block
		andi.w	#-$10,d5
		lsl.w	#4,d5				; * $100
		and.w	#$F00,d5
		move.w	map_x(a6),d4
		subi.w	#$10,d4				; - 1 block
		andi.w	#-$10,d4
		lsr.w	#2,d4
		and.w	#$80-2,d4

	; a6 - Current BG buffer
	; a5 - Block-data BASE
	; a4 - LOW layout data
	; a3 - HI layout data
	; a2 - a4 current
	; a1 - a3 current
	; a0 - Block-data read

	; d7 - X loop        | Y loop
	; d6 - VDP 2nd write | VDP 1st write (TOP)
	; d5 - X loop curr   | Y pos out
	; d4 - temporal      | X pos out
	; d3 - Y inc
	; d2 - X inc
	; d1 - temporal      | X pos curr
	; d0 -
.y_loop:
		move.l	a4,a2		; a2 - LOW line
		move.l	a3,a1		; a1 - HI line
		move.w	map_height(a6),d1
		cmp.w	d1,d3
		blt.s	.y_wrap
		clr.w	d3
.y_wrap:
		moveq	#0,d0
		move.w	map_width(a6),d1
		move.w	d3,d0
		lsr.w	#4,d0		; /16 both
		lsr.w	#4,d1
		mulu.w	d1,d0
		add.l	d0,a2
		add.l	d0,a1
		moveq	#0,d0
		move.w	d2,d0
		swap	d2		; Backup X incr
		move.w	d0,d2		; temp copy of Xincr
		lsr.w	#4,d0
		add.l	d0,a2
		add.l	d0,a1
		swap	d7		; Show X loop
		move.w	d4,d1		; d1 - X pos current
		swap	d4		; Hide X pos out
		swap	d5		; Hide Y pos out
		move.w	d7,d5		; d5 - X loop current
.x_loop:
		moveq	#0,d0
		move.w	map_width(a6),d0
		cmp.w	d0,d2
		blt.s	.x_wrap
		move.l	d2,a0		; <-- no one will notice
		lsr.w	#4,d0
		sub.l	d0,a2
		move.l	a1,d2
		tst.l	d2
		beq.s	.no_xhi
		sub.l	d0,a1
.no_xhi:
		move.l	a0,d2
		clr.w	d2
.x_wrap:
		swap	d1
		clr.w	d1		; Clear HI bit
		moveq	#0,d0
		move.b	(a2),d0		; Read LOW block
		bne.s	.use_it		; If not zero: valid block
		move.l	a3,d0		; HI data is 0?
		tst.l	d0
		beq.s	.f_blank
		moveq	#0,d0
		move.b	(a1),d0		; Read HIGH block
		beq.s	.f_blank	; If zero: blank
		or.w	#$8000,d1	; Set VDP HI priority
		bra.s	.use_it
.f_blank:
		moveq	#0,d0
.use_it:
		bsr	.mk_block
		swap	d1
		addq.w	#4,d1
		andi.w	#$80-2,d1
		adda	#1,a2
		adda	#1,a1
		addi.w	#$10,d2
		dbf	d5,.x_loop
		swap	d2		; Show X incr
		swap	d4		; Show X pos out
		swap	d5		; Show Y pos out
		swap	d7
		addi.w	#$0100,d5
		andi.w	#$0F00,d5
		addi.w	#$10,d3
		dbf	d7,.y_loop
		rts

; ------------------------------------------------
; 13
; 24
.mk_block:
		move.l	a5,a0			; a0 - current block data
		lsl.w	#3,d0
		adda	d0,a0
		move.w	d6,d4
		swap	d6			; Show 2nd write
		swap	d5
		add.w	d5,d4
		swap	d5
		swap	d1
		add.w	d1,d4			; Top + Ypos + Xcurr
		swap	d1
		bsr.s	.do_2cell
		addq.w	#2,d4
		bsr.s	.do_2cell
		swap	d6
		rts
.do_2cell:
		move.w	d4,(vdp_ctrl).l
		move.w	d6,(vdp_ctrl).l
		move.w	(a0)+,d0
		beq.s	.null_0
		subq.w	#1,d0
; 		cmp.w	#SET_NullVram,d0
; 		beq.s	.null_0
		add.w	map_vram+2(a6),d0
		add.w	d1,d0
.null_0:
		move.w	d0,(vdp_data).l
		addi.w	#$80,d4			; NEXT Y LINE foward
		move.w	d4,(vdp_ctrl).l
		move.w	d6,(vdp_ctrl).l
		subi.w	#$80,d4			; Return Y line backward
		move.w	(a0)+,d0
		beq.s	.null_1
		subq.w	#1,d0
; 		cmp.w	#SET_NullVram,d0
; 		beq.s	.null_1
		add.w	map_vram+2(a6),d0
		add.w	d1,d0
.null_1:
		move.w	d0,(vdp_data).l
.no_bg:
		rts

; ------------------------------------------------
; Shared init

.init_xy:
		move.b	map_flags(a6),d0
		andi.w	#%11110000,d0
		move.b	d0,map_flags(a6)
		move.w	map_x(a6),d0		; X start
		move.w	map_y(a6),d1		; Y start
		move.b	d0,map_x_set(a6)
		move.b	d1,map_y_set(a6)
		and.b	#$0F,map_x_set(a6)
		and.b	#$0F,map_y_set(a6)
		move.w	d0,map_x_old(a6)
		move.w	d1,map_y_old(a6)
		subi.w	#$10,d0
		subi.w	#$10,d1
		move.w	map_width(a6),d2
		move.w	map_height(a6),d3
	; Reset internal counters
.x_left:	tst.w	d0
		bpl.s	.x_mid
		add.w	d2,d0
		bra.s	.x_left
.x_mid:		cmp.w	d2,d0
		blt.s	.x_ok
		sub.w	d2,d0
		bra.s	.x_mid
.x_ok:

.y_left:	tst.w	d1
		bpl.s	.y_mid
		add.w	d3,d1
		bra.s	.y_left
.y_mid:		cmp.w	d3,d1
		blt.s	.y_ok
		sub.w	d3,d1
		bra.s	.y_mid
.y_ok:
		move.w	d0,map_x_inc(a6)
		move.w	d1,map_y_inc(a6)
		andi.w	#-$10,d0
		andi.w	#-$10,d1
		rts

; ------------------------------------------------
; 32X drawall
; ------------------------------------------------

	if MARS|MARSCD
.mars_bg:
		btst	#7,map_flags(a6)
		beq	.no_mars
		bsr.s	.init_xy
		lea	(RAM_MdMars_ScrlBuff).w,a3
		move.l	map_vram(a6),mscrl_Vram(a3)
		move.l	map_blk(a6),a5
		move.l	map_low(a6),a4
		moveq	#0,d7
		moveq	#0,d6
		move.w	d1,d7
		move.w	d0,d6
		move.w	d2,d5
		lsr.w	#4,d5
		lsr.w	#4,d6		; x/16
		lsr.w	#4,d7
		mulu.w	d5,d7
		add.l	d6,d7
		add.l	d7,a4
		lea	(RAM_MdMars_ScrlData).w,a3
		moveq	#0,d6
		moveq	#0,d5
		move.w	map_y(a6),d6
		subi.w	#$10,d6
		move.w	d1,d3
		lsl.l	#2,d6
		andi.l	#$3C0,d6
		move.w	map_x(a6),d5
		subi.w	#$10,d5
		move.w	d0,d2
		lsr.w	#3,d5
		andi.w	#$03E,d5
		move.w	#((224+32)/16)-1,d7
.ym_loop:
		swap	d7
		move.l	d5,d4
		move.w	#((320+32)/16)-1,d7
		move.l	a4,a2
		move.w	d2,d1
.xm_loop:
		move.l	a3,a1
		add.l	d6,a1
		add.l	d4,a1
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	.zero
		subq.w	#1,d0
		add.w	d0,d0
		move.w	(a5,d0.w),d0
.zero:
		move.w	d0,(a1)
		addq.l	#2,d4
		andi.l	#$3E,d4
		adda	#1,a2
		add.w	#$10,d1
		cmp.w	map_width(a6),d1
		blt.s	.xm_low
		moveq	#0,d0
		move.w	d1,d0
		lsr.w	#4,d0		; /16
		sub.l	d0,a2
		clr.w	d1
.xm_low:
		dbf	d7,.xm_loop

		moveq	#0,d0
		move.w	map_width(a6),d0
		lsr.w	#4,d0
		add.l	d0,a4
		add.w	#$10,d3
		move.w	map_height(a6),d0
		cmp.w	d0,d3
		blt.s	.ym_wrap
		moveq	#0,d0
		move.w	map_height(a6),d0
		muls.w	map_width(a6),d0
		lsr.l	#8,d0		; both /16
		sub.l	d0,a3
		clr.w	d3
.ym_wrap:
		add.l	#(512/16)*2,d6
		andi.l	#$3C0,d6
		swap	d7
		dbf	d7,.ym_loop
.no_mars:
		rts
	endif

; --------------------------------------------------------
; MapScrl_DrawScrl
;
; Draws off-screen changes on the Genesis side,
; for 32X see MapScrl_Mars_DrawScrl
;
; For VBlank ONLY, call this AFTER System_Render in
; your screen's loop.
; --------------------------------------------------------

MapScrl_DrawScrl:
; 		movem.l	d6-d7/a6,-(sp)
		lea	(RAM_MapScrl).w,a6
		lea	(vdp_data),a5		; a5 - VDP
		bsr.s	.this_bg
		adda	#sizeof_mapscrl,a6

; ------------------------------------------------

.this_bg:
		move.b	map_flags(a6),d7
		btst	#7,d7
		beq	.no_bg
		move.w	map_x(a6),d0		; X start
		move.w	map_y(a6),d1		; Y start
		move.w	map_x_inc(a6),d2
		move.w	map_y_inc(a6),d3
		move.w	map_height(a6),d4
		bclr	#bitDrwU,d7
		beq.s	.no_u
; 		add.w	#16,d3			; LAZY PATCH
; 		cmp.w	d4,d3
; 		blt.s	.y_up
; 		sub.w	d4,d3
; .y_up:
; 		add.w	#16,d1
		bsr	.mk_row
		bra.s	.no_d
.no_u:
		bclr	#bitDrwD,d7
		beq.s	.no_d
		add.w	#224+16,d3
		cmp.w	d4,d3
		blt.s	.y_down
		sub.w	d4,d3
.y_down:
		add.w	#224+16,d1		; X add
		bsr	.mk_row
.no_d:
		move.w	map_x(a6),d0		; X start
		move.w	map_y(a6),d1		; Y start
		move.w	map_x_inc(a6),d2
		move.w	map_y_inc(a6),d3

		move.w	map_width(a6),d4
		bclr	#bitDrwL,d7
		beq.s	.no_l
		bsr.s	.mk_clmn
		bra.s	.no_r
.no_l:
		bclr	#bitDrwR,d7
		beq.s	.no_r
		add.w	#320+32,d2
		cmp.w	d4,d2
		blt.s	.x_left
		sub.w	d4,d2
.x_left:
		add.w	#320+32,d0			; VDP X add
		bsr.s	.mk_clmn
.no_r:
		move.b	d7,map_flags(a6)

.no_bg:
		rts

; ------------------------------------------------
; Make column
; d0 - X
; d1 - Y
; d2 - X increment
; d3 - Y increment
; ------------------------------------------------

.mk_clmn:
		swap	d7
		bsr	.get_coords
		bsr	.get_vdpcoords

	; d0 -    X curr | Current cell X/Y (1st)
	; d1 -    Y curr | VDP 1st write
	; d2 - Cell VRAM | VDP 2nd write
	; d3 -    Y wrap | Y add
	; d4 -         *****
	; d5 -         *****
	; d6 -         *****
	; d7 - lastflags | loop blocks
		swap	d0
		move.w	d4,d0
		swap	d0
		move.w	#$FFF,d3
		swap	d3
		move.w	#$100,d3
		move.w	#((224+32)/16)-1,d7
.y_blk:
		move.b	(a3),d6
		bne.s	.vld
		move.l	a2,d5
		tst.l	d5
		beq.s	.blnk
		move.b	(a2),d6
		bne.s	.prio
.blnk:
		moveq	#0,d4
		moveq	#0,d5
		bra.s	.frce
.prio:
		move.l	#$80008000,d4
		move.l	#$80008000,d5
		bra.s	.frm_hi
.vld:
		moveq	#0,d4
		moveq	#0,d5
.frm_hi:
		move.l	a4,a0
		and.w	#$FF,d6
		lsl.w	#3,d6
		adda	d6,a0
		moveq	#0,d6

		swap	d2
		move.w	(a0)+,d6
		beq.s	.top_0c
		subq.w	#1,d6
		add.w	d6,d4
		add.w	d2,d4
.top_0c:
		move.w	(a0)+,d6
		beq.s	.bot_0c
		subq.w	#1,d6
		add.w	d6,d5
		add.w	d2,d5
.bot_0c:
		swap	d4
		swap	d5
		move.w	(a0)+,d6
		beq.s	.top_1c
		subq.w	#1,d6
		add.w	d6,d4
		add.w	d2,d4
.top_1c:
		move.w	(a0)+,d6
		beq.s	.bot_1c
		subq.w	#1,d6
		add.w	d6,d5
		add.w	d2,d5
.bot_1c:
		swap	d2

.frce:
		move.w	d0,d6
		add.w	d1,d6
		or.w	#$4000,d6
		move.w	d6,4(a5)
		move.w	d2,4(a5)
		move.l	d4,(a5)
		add.w	#$80,d6
		move.w	d6,4(a5)
		move.w	d2,4(a5)
		move.l	d5,(a5)
		move.l	d3,d4		; Next Y block
		swap	d4
		add.w	d3,d0
		and.w	d4,d0
		move.w	map_width(a6),d6
		lsr.w	#4,d6
		adda	d6,a3
		move.l	a2,d4
		tst.l	d4
		beq.s	.no_clhi
		adda	d6,a2
.no_clhi:
		swap	d1
		add.w	#$10,d1
		cmp.w	map_height(a6),d1
		blt.s	.y_low
		moveq	#0,d5
		move.w	map_width(a6),d5
		mulu.w	d1,d5
		lsr.l	#8,d5
		sub.l	d5,a3
		move.l	a2,d6
		tst.l	d6
		beq.s	.yl_nohi
		sub.l	d5,a2
.yl_nohi:
		clr.w	d1
.y_low:
		swap	d1
		dbf	d7,.y_blk
		swap	d7
.mid_x:
		rts

; ------------------------------------------------
; Make row
; d0 - X
; d1 - Y
; d2 - X increment
; d3 - Y increment
; ------------------------------------------------

.mk_row:
		swap	d7
		bsr	.get_coords
		bsr	.get_vdpcoords
		swap	d1
		move.w	d5,d1
		swap	d1
		move.w	#$7F,d3
		swap	d3
		move.w	#4,d3

	; d0 -    X curr | Current cell X/Y (1st)
	; d1 -    Y curr | VDP 1st write
	; d2 - Cell VRAM | VDP 2nd write
	; d3 -    X wrap | X add
	; d4 -         *****
	; d5 -         *****
	; d6 - loopflags | *****
	; d7 - lastflags | loop blocks

		move.w	d0,d6
		and.w	#-$100,d6	; Merge d1
		add.w	d6,d1
		move.l	d3,d5
		swap	d5
		and.w	d5,d0
; 		move.w	#((512)/16)-1,d7
		move.w	#((320+48)/16)-1,d7
.x_blk:
		move.b	(a3),d6
		bne.s	.xvld
		move.l	a2,d5
		tst.l	d5
		beq.s	.xblnk
		move.b	(a2),d6
		bne.s	.xprio
.xblnk:
		moveq	#0,d4
		moveq	#0,d5
		bra.s	.xfrce
.xprio:
		move.l	#$80008000,d4
		move.l	#$80008000,d5
		bra.s	.x_fromh
.xvld:
		moveq	#0,d4
		moveq	#0,d5
.x_fromh:
		move.l	a4,a0
		and.w	#$FF,d6
		lsl.w	#3,d6
		adda	d6,a0
		moveq	#0,d6

		swap	d2
		move.w	(a0)+,d6
		beq.s	.top_0b
		subq.w	#1,d6
		add.w	d6,d4
		add.w	d2,d4
.top_0b:
		move.w	(a0)+,d6
		beq.s	.bot_0b
		subq.w	#1,d6
		add.w	d6,d5
		add.w	d2,d5
.bot_0b:
		swap	d4
		swap	d5
		move.w	(a0)+,d6
		beq.s	.top_1b
		subq.w	#1,d6
		add.w	d6,d4
		add.w	d2,d4
.top_1b:
		move.w	(a0)+,d6
		beq.s	.bot_1b
		subq.w	#1,d6
		add.w	d6,d5
		add.w	d2,d5
.bot_1b:
		swap	d2

.xfrce:
		move.w	d0,d6
		add.w	d1,d6
		or.w	#$4000,d6
		move.w	d6,4(a5)
		move.w	d2,4(a5)
		move.l	d4,(a5)
		add.w	#$80,d6
		move.w	d6,4(a5)
		move.w	d2,4(a5)
		move.l	d5,(a5)
		add.w	d3,d0
		swap	d3
		and.w	d3,d0
		swap	d3
	; X wrap
		swap	d0
		add.w	#$10,d0
		moveq	#0,d4
		move.w	map_width(a6),d4
		cmp.w	d4,d0
		blt.s	.x_low
		lsr.w	#4,d4		; /16
		sub.l	d4,a3
		move.l	a2,d6
		beq.s	.xl_nohi
		sub.l	d4,a2
.xl_nohi:
		clr.w	d0

.x_low:
		adda	#1,a3
		move.l	a2,d5
		beq.s	.x_new
		adda	#1,a2

.x_new:
		swap	d0
		dbf	d7,.x_blk
		swap	d7
.mid_y:
		rts

; ------------------------------------------------
; Input
; d0 - X position
; d1 - Y position
; d2 - X increment beam
; d3 - Y increment beam
;
; Out:
; d2 - VDP position

.get_coords:
		bsr	subMapScrl_GetPos
		move.l	map_blk(a6),a4
		move.l	map_low(a6),a3
		move.l	map_hi(a6),a2
		moveq	#0,d6
		moveq	#0,d5
		move.w	d3,d6
		lsr.w	#4,d6
		move.w	map_width(a6),d5
		lsr.w	#4,d5
		mulu.w	d5,d6
		move.w	d2,d5
		lsr.w	#4,d5
		add.l	d5,d6
		add.l	d6,a3
		move.l	a2,d5
		tst.l	d5
		beq.s	.no_hilyr
		add.l	d6,a2
.no_hilyr:
		rts

; ------------------------------------------------

.get_vdpcoords:
		moveq	#0,d2
		move.w	map_vram+2(a6),d2
		swap	d2
		lsr.w	#2,d1			; Y >> 2
		lsl.w	#6,d1			; Y * $40
		lsr.w	#2,d0			; X >> 2
		and.w	#$FFF,d1
		and.w	#$7C,d0
		add.w	d1,d0
		move.w	map_vout(a6),d1
		move.w	d1,d2
		and.w	#$3FFF,d1
		rol.w	#2,d2
		and.w	#%11,d2
		rts

; ------------------------------------------------

subMapScrl_GetPos:
		subi.w	#$10,d0
		subi.w	#$10,d1
		and.l	#-$10,d0		; block X/Y limit
		and.l	#-$10,d1
		and.l	#-$10,d2
		and.l	#-$10,d3
		swap	d0
		swap	d1
		move.w	d2,d0
		move.w	d3,d1
		swap	d0
		swap	d1
		rts

; --------------------------------------------------------
; MapScrl_Mars_DrawScrl
;
; Call this BEFORE System_Render in your screen's loop.
; --------------------------------------------------------

MapScrl_Mars_DrawScrl:
	if MARS|MARSCD
		lea	(RAM_MapScrl_Mars).w,a6
		move.b	map_flags(a6),d7
		btst	#7,d7
		beq	.nom_bg
		move.w	map_x(a6),d0		; X start
		move.w	map_y(a6),d1		; Y start
		move.w	map_x_inc(a6),d2
		move.w	map_y_inc(a6),d3
		move.w	map_height(a6),d4
		bclr	#bitDrwU,d7
		beq.s	.nom_u
		bsr	.mkmars_row
		bra.s	.nom_d
.nom_u:
		bclr	#bitDrwD,d7
		beq.s	.nom_d
		add.w	#224+16,d3
		cmp.w	d4,d3
		blt.s	.ym_down
		sub.w	d4,d3
.ym_down:
		add.w	#224+16,d1
		bsr	.mkmars_row

.nom_d:
		move.w	map_x(a6),d0		; X start
		move.w	map_y(a6),d1		; Y start
		move.w	map_x_inc(a6),d2
		move.w	map_y_inc(a6),d3
		move.w	map_width(a6),d4
		bclr	#bitDrwL,d7
		beq.s	.nom_l
		bsr	.mkmars_clmn
		bra.s	.nom_r
.nom_l:
		bclr	#bitDrwR,d7
		beq.s	.nom_r
		add.w	#320+16,d2
		cmp.w	d4,d2
		blt.s	.xm_left
		sub.w	d4,d2
.xm_left:
		add.w	#320+16,d0		; VDP X add
		bsr	.mkmars_clmn
.nom_r:
		move.b	d7,map_flags(a6)
.nom_bg:
	endif
		rts

; ------------------------------------------------
; Input
; d0 - X position
; d1 - Y position
; d2 - X increment beam
; d3 - Y increment beam
;
; Out:
; d2 - VDP position

	if MARS|MARSCD
.get_coords:
		bsr	subMapScrl_GetPos
		move.l	map_blk(a6),a4
		move.l	map_low(a6),a3
		moveq	#0,d6
		moveq	#0,d5
		move.w	d3,d6
		lsr.w	#4,d6
		move.w	map_width(a6),d5
		lsr.w	#4,d5
		mulu.w	d5,d6
		move.w	d2,d5
		lsr.w	#4,d5
		add.l	d5,d6
		add.l	d6,a3
		rts

; ------------------------------------------------

.mkmars_row:
		swap	d7
		bsr	.get_coords
		lea	(RAM_MdMars_ScrlData).w,a5
	; a5 - Dreq_ScrlData
	; d0 - X pos
	; d1 - Y pos
	; d2 - X layout incr
	; d3 - Y layour incr
		moveq	#0,d6
		move.w	d1,d6
		lsl.l	#2,d6
		andi.l	#$3C0,d6
		add.l	d6,a5		; out Y locate
		moveq	#0,d6
		move.w	d0,d6
		lsr.w	#3,d6
		andi.w	#$3E,d6		; out X variable
		move.w	map_width(a6),d4
		move.w	#((320+32)/16)-1,d7
		move.l	a3,a0
.nxt_vtblk:
		move.l	a5,a1
		add.l	d6,a1
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	.vzero
		subq.w	#1,d0
		add.w	d0,d0
		move.w	(a4,d0.w),d0
.vzero:
		move.w	d0,(a1)
		adda	#1,a0
		add.w	#$10,d2
		cmp.w	d4,d2
		blt.s	.x_wrap
		moveq	#0,d0
		move.w	map_width(a6),d0
		lsr.w	#4,d0
		sub.l	d0,a0
		clr.w	d2
.x_wrap:
		addq.l	#2,d6
		andi.l	#$3F,d6
		dbf	d7,.nxt_vtblk
		swap	d7
		rts

; ------------------------------------------------

.mkmars_clmn:
		swap	d7
		bsr	.get_coords
		lea	(RAM_MdMars_ScrlData).w,a5

	; a5 - Dreq_ScrlData
	; d0 - X pos
	; d1 - Y pos
	; d2 - X layout incr
	; d3 - Y layour incr
		moveq	#0,d6
		move.w	d0,d6
		lsr.w	#3,d6
		andi.w	#$3E,d6
		add.l	d6,a5		; out X locate
		moveq	#0,d6
		move.w	d1,d6
		lsl.l	#2,d6
		andi.l	#$3C0,d6	; out Y variable
		moveq	#0,d5
		move.l	map_low(a6),a2	; a2 - lazy wrap Y patch
		move.w	d2,d5
		lsr.w	#4,d5
		adda	d5,a2
		move.w	map_height(a6),d4
		move.w	map_width(a6),d2
		lsr.w	#4,d2
		move.w	d2,d5
		move.w	#((224+32)/16)-1,d7
		move.l	a3,a0
.nxt_cblk:
		move.l	a5,a1
		add.l	d6,a1
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	.zero
		subq.w	#1,d0
		add.w	d0,d0
		move.w	(a4,d0.w),d0
.zero:
		move.w	d0,(a1)
		adda	d2,a0
		add.w	#$10,d3
		cmp.w	d4,d3
		blt.s	.y_wrap
		clr.w	d3
		move.l	a2,a0
.y_wrap:
		add.l	#(512/16)*2,d6
		andi.l	#$3C0,d6
		dbf	d7,.nxt_cblk
		swap	d7
		rts
	endif

; --------------------------------------------------------
; MapScrl_Set
;
; Set new map data to a slot.
;
; Input:
; a0   | 16x16 block data
; a1   | LOW priority layout data
; a2   | HI priority layout data, set to 0
;        if not using it.
;        UNUSED on 32X/CD32X.
; a3   | COLLISION data, optional.
;        Set to 0 if not using it.
; d0.w | Map scroll slot: $00-$02
;        SLOT $02 is reserved for 32X.
; d1.? | VRAM Input (Graphics) location
;         VDP: d1.w
;        SVDP: d1.l
; d2.w | VRAM Output (Drawing) location
;         VDP: Plane's VRAM location
;        SVDP: UNUSED
; d3.l | FULL Width + FULL Height: $wwwwhhhhh
;        w - Width
;        h - Height
;
; Note:
; Call MapScrl_Pos with your Current X/Y positions
; (or reset) after this.
; --------------------------------------------------------

MapScrl_Set:
		movem.l	d7/a6,-(sp)
		lea	(RAM_MapScrl).w,a6
		move.w	d0,d7
		mulu.w	#sizeof_mapscrl,d7
		adda	d7,a6
		clr.w	map_x(a6)
		clr.w	map_y(a6)
		clr.w	map_x_inc(a6)
		clr.w	map_y_inc(a6)
		move.l	a0,map_blk(a6)
		move.l	a1,map_low(a6)
		move.l	a2,map_hi(a6)
		move.l	a3,map_col(a6)
		move.l	#MapSys_slopes,map_cmap(a6)	; *TEMPORARY*
		move.l	d1,d7
		cmpi.w	#$02,d0		; Slot $02?
		beq.s	.is_mars
		andi.l	#$FFFF,d7	; Limit VDP VRAM
.is_mars:
		move.l	d7,map_vram(a6)
		move.w	d2,map_vout(a6)
		move.l	d3,d7
		move.w	d7,map_height(a6)
		swap	d7
		move.w	d7,map_width(a6)
		bset	#7,map_flags(a6) ; Enable slot
.exit:
		movem.l	(sp)+,d7/a6
		rts

; --------------------------------------------------------
; MapScrl_Delete
;
; Disable Map for rendering
;
; Input:
; d0.w | Map scroll slot: $00-$02
; --------------------------------------------------------

MapScrl_Delete:
		movem.l	d7/a6,-(sp)
		lea	(RAM_MapScrl).w,a6
		move.w	d0,d7
		mulu.w	#sizeof_mapscrl,d7
		adda	d7,a6
		bclr	#7,map_flags(a6) ; Disable slot
.exit:
		movem.l	(sp)+,d7/a6
		rts

; --------------------------------------------------------
; MapScrl_Pos
;
; Sets the Map's X and Y positions, If the map is
; disabled it will get skipped.
;
; Input:
; d0.w | Map scroll slot: $00-$02
;        SLOT $02 is reserved for 32X.
; d1.w | X position
; d2.w | Y position
; --------------------------------------------------------

MapScrl_Pos:
		movem.l	d7/a6,-(sp)
		lea	(RAM_MapScrl).w,a6
		move.w	d0,d7
		mulu.w	#sizeof_mapscrl,d7
		adda	d7,a6
		btst	#7,map_flags(a6)
		beq.s	.no_bg
		move.w	d1,map_x(a6)
		move.w	d2,map_y(a6)
.no_bg:
		movem.l	(sp)+,d7/a6
		rts

; ----------------------------------------

; Slope data 16x16
MapSys_slopes:
		dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b 15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
		dc.b  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
		dc.b 15,15,14,14,13,13,12,12,11,11,10,10, 9, 9, 8, 8
		dc.b  7, 7, 6, 6, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1, 0, 0
		dc.b  0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7
		dc.b  8, 8, 9, 9,10,10,11,11,12,12,13,13,14,14,15,15
		align 2

; --------------------------------------------------------
; *** These routines require the MapScrl System ***
; --------------------------------------------------------

; --------------------------------------------------------
; object_MapCol_ChkDown, object_MapCol_ChkUp,
; object_MapCol_ChkRight, object_MapCol_ChkLeft
;
; Detects collision on the selected map slot on
; a specific direction.
; If collision is found by beq and bcs you need to
; call _MapCol_Set(dir) to properly apply the position
; changes to the object, for faster speeds call
; _MapCol_Set(dir)Snap
;
; WITHOUT snapping:
; 	bsr object_MapCol_Chk(dir)
;	bne.s .no_collision
;	bsr object_MapCol_Set(dir)
; .no_collision:
;
; WITH snapping:
; 	bsr object_MapCol_Chk(dir)
; 	bra.s .found_top
;	bcc.s .no_collision
; .found_top:
;	bsr object_MapCol_Set(dir)
; .no_collision:
;
; Input:
; a6   | This object
; d0.w | Map slot to check in RAM_MapScrl
;
; Returns:
; bne  | No collision found
; beq  | Found collision at the exact point
; bcs  | Found collision BEHOND the point,
;        for fast falling objects.
;
; * beq/bcs ONLY, don't use these *
; a5   | Map buffer we used, required for snapping
; d0.w | Last collision block number found
; d1.w | X or Y position snapped to the block
; d2.w | X or Y increment/decrement (on bcs)
;
; Notes:
; Call these only after your final X/Y are set, if
; any of these return as bne IGNORE the outputs.
; --------------------------------------------------------
; TODO OFFBOUNDS CHECK

; ----------------------------------------
; CENTER BOTTOM
;
; o--o--o
; |  |  |
; o--o--o
; |  |  |
; o--?--o
; ----------------------------------------

object_MapCol_ChkDown:
		movem.l	d3-d7/a3-a4,-(sp)
		bsr	objMapCol_GetColMap
		beq	.nothing
		bsr	objMapCol_GetX_Center
; 		beq	.nothing
	; --------------------------------------
		move.w	obj_y(a6),d4		; d4 | Y output to snap
		move.l	obj_size(a6),d7		; $UUDDLLRR
		swap	d7			; $UUDD
		andi.l	#$FF,d7			; $00DD
		beq.s	.no_size		; If zero, skip this
		move.w	d7,d0
		lsl.w	#3,d0			; d7 - Size*8 (cell)
		add.w	d0,d4			; d4 - Ypos + Dsize
.no_size:
	; --------------------------------------
	; OOB Y check
		tst.w	d4			; If Ypos < 0, return nothing
		bmi	.nothing
		move.w	d4,d1			; d1 | Y center snapped
		andi.w	#-$10,d1
	; --------------------------------------
		moveq	#0,d0			; d0 | Return block
		move.w	d4,d6
		asr.w	#4,d6
		move.w	map_width(a5),d5
		lsr.w	#4,d5			; d5 - Y row decrement
		muls.w	d5,d6			; d6 - Y row current
		moveq	#0,d2			; d2 | Y adjust
	; --------------------------------------
	; Check normal collision point
		move.l	a4,a3			; Read current row
		add.l	d6,a3
		move.b	(a3),d0			; Collision != 0?
		bne.s	.found_it
	; --------------------------------------
	; OPTIONAL snapping, for faster speeds
		move.w	#-$10,d4
		lsr.w	#1,d7			; Size/2
.next_y:
		sub.l	d5,d6
		bmi.s	.nothing
		move.l	a4,a3			; Read current row
		add.l	d6,a3
		move.b	(a3),d3			; Collision != 0?
		beq.s	.keep_chk
		move.b	d3,d0
		move.w	d4,d2
.keep_chk:
		subi.w	#$10,d4
		dbf	d7,.next_y
		tst.w	d0
		beq.s	.nothing
		tst.w	d2
		beq.s	.found_it
.found_ex:
		move	#%001,ccr		; Set BCS exit
		bra.s	.exit
.found_it:
		move	#%100,ccr		; Set BEQ exit
		bra.s	.exit
.nothing:
		moveq	#0,d0			; Return 0 block
		move	#%000,ccr		; Set BNE exit
.exit:
		movem.l	(sp)+,d3-d7/a3-a4
		rts

; ----------------------------------------
; CENTER TOP
;
; o--?--o
; |  |  |
; o--o--o
; |  |  |
; o--o--o
; ----------------------------------------

object_MapCol_ChkUp:
		movem.l	d3-d7/a3-a4,-(sp)
		bsr	objMapCol_GetColMap
		beq	.nothing
		bsr	objMapCol_GetX_Center
; 		beq	.nothing
	; --------------------------------------
		move.w	obj_y(a6),d4		; d4 | Y output to snap
; 		subq.w	#1,d4			; <-- UP ONLY
		move.l	obj_size(a6),d7		; $UUDDLLRR
		swap	d7			; $UUDD
		lsr.w	#8,d7			; <-- UP SIZE
		andi.l	#$FF,d7			; $00UU
		beq.s	.no_size		; If zero, skip this
		move.w	d7,d0
		lsl.w	#3,d0			; d7 - Size*8 (cell)
		sub.w	d0,d4			; d4 - Ypos - Usize
.no_size:
	; --------------------------------------
	; OOB Y check
; 		tst.w	d4			; If Ypos < 0, return nothing
; 		bmi	.nothing
		move.w	d4,d1			; d1 | Y center snapped
		andi.w	#-$10,d1
	; --------------------------------------
		moveq	#0,d0			; d0 | Return block
		move.w	d4,d6
		asr.w	#4,d6
		move.w	map_width(a5),d5
		lsr.w	#4,d5			; d5 - Y row decrement
		muls.w	d5,d6			; d6 - Y row current
		moveq	#0,d2			; d2 | Y adjust
	; --------------------------------------
	; Check normal collision point
		move.l	a4,a3			; Read current row
		add.l	d6,a3
		move.b	(a3),d3			; Collision != 0?
		bne.s	.found_it
	; --------------------------------------
	; OPTIONAL snapping, for faster speeds
		move.w	#$10,d4
		lsr.w	#1,d7			; Size/2
	; Size 00 works same as 01
.next_y:
		add.l	d5,d6
		bmi.s	.nothing
		move.l	a4,a3			; Read current row
		add.l	d6,a3
		move.b	(a3),d3			; Collision != 0?
		beq.s	.keep_chk
		move.b	d3,d0
		move.w	d4,d2
.keep_chk:
		addi.w	#$10,d4
		dbf	d7,.next_y
		tst.b	d0
		beq.s	.nothing
.found_ex:
		move	#%001,ccr		; Set BCS exit
		bra.s	.exit
.found_it:
		move.b	d3,d0
		move	#%100,ccr		; Set BEQ exit
		bra.s	.exit
.nothing:
		moveq	#0,d0			; Return 0 block
		move	#%000,ccr		; Set BNE exit
.exit:
		movem.l	(sp)+,d3-d7/a3-a4
		rts

; ; ----------------------------------------
; ; CENTER RIGHT
; ;
; ; o--o--o
; ; |  |  |
; ; o--o--?
; ; |  |  |
; ; o--o--o
; ; ----------------------------------------
;
; object_MapCol_ChkRight:
; 		movem.l	d3-d7/a3-a4,-(sp)
; 		bsr	objMapCol_GetColMap
; 		beq	.nothing
; 		bsr	objMapCol_GetY_Center
; 		beq	.nothing
; 	; --------------------------------------
; 		move.w	obj_x(a6),d4		; d4 | Y output to snap
; 		move.l	obj_size(a6),d7		; $UUDDLLRR
; 		swap	d7			; $UUDD
; 		andi.l	#$FF,d7			; $00DD
; 		beq.s	.no_size		; If zero, skip this
; 		move.w	d7,d0
; 		lsl.w	#3,d0			; d7 - Size*8 (cell)
; 		add.w	d0,d4			; d4 - Ypos + Dsize
; .no_size:
; 	; --------------------------------------
; 	; OOB Y check
; 		tst.w	d4			; If Ypos < 0, return nothing
; 		bmi	.nothing
; 		move.w	d4,d1			; d1 | Y center snapped
; 	; --------------------------------------
; 		moveq	#0,d0			; d0 | Return block
; 		move.w	d4,d6
; 		asr.w	#4,d6
; 		move.w	map_width(a5),d5
; 		lsr.w	#4,d5			; d5 - Y row decrement
; 		muls.w	d5,d6			; d6 - Y row current
; 		moveq	#0,d2			; d2 | Y adjust
; 	; --------------------------------------
; 	; Check normal collision point
; 		move.l	a4,a3			; Read current row
; 		add.l	d6,a3
; 		move.b	(a3),d0			; Collision != 0?
; 		bne.s	.found_it
; 	; --------------------------------------
; 	; OPTIONAL snapping, for faster speeds
; 		move.w	#-$10,d4
; 		lsr.w	#1,d7			; Size/2
; .next_y:
; 		sub.l	d5,d6
; 		bmi.s	.nothing
; 		move.l	a4,a3			; Read current row
; 		add.l	d6,a3
; 		move.b	(a3),d3			; Collision != 0?
; 		beq.s	.keep_chk
; 		move.b	d3,d0
; 		move.w	d4,d2
; .keep_chk:
; 		subi.w	#$10,d4
; 		dbf	d7,.next_y
; 		tst.w	d0
; 		beq.s	.nothing
; 		tst.w	d2
; 		beq.s	.found_it
; .found_ex:
; 		move	#%001,ccr		; Set BCS exit
; 		bra.s	.exit
; .found_it:
; 		move	#%100,ccr		; Set BEQ exit
; 		bra.s	.exit
; .nothing:
; 		moveq	#0,d0			; Return 0 block
; 		move	#%000,ccr		; Set BNE exit
; .exit:
; 		movem.l	(sp)+,d3-d7/a3-a4
; 		rts

; --------------------------------------
; Read collision map
;
; beq - Nothing/Not set
objMapCol_GetColMap:
		lea	(RAM_MapScrl).w,a5
		move.w	d0,d7
		mulu.w	#sizeof_mapscrl,d7
		adda	d7,a5
		moveq	#0,d7
		btst	#7,map_flags(a5)
		beq.s	.no_bg
		move.l	map_col(a5),a4
		move.l	a4,d7
.no_bg:
		tst.l	d7
		rts

; --------------------------------------
; Set X CENTER point
objMapCol_GetX_Center:
		moveq	#0,d5
		move.w	map_width(a5),d6
; 		subq.w	#1,d6
		move.w	obj_x(a6),d5
		bpl.s	.x_min
		clr.w	d5
.x_min:
		cmp.w	d6,d5
		blt.s	.x_max
		subq.w	#1,d6
		move.w	d6,d5
.x_max:

		asr.w	#4,d5		; /16
		add.l	d5,a4
		moveq	#0,d6
		moveq	#0,d5
		moveq	#0,d4
		moveq	#0,d3
		move	#%000,ccr
		rts
.get_out:
		move	#%100,ccr
		rts

; --------------------------------------
; Set X CENTER point
objMapCol_GetY_Center:
		moveq	#0,d6
		moveq	#0,d5
		move.w	map_height(a5),d6
		move.w	obj_y(a6),d5
		bmi.s	.get_out
		cmp.w	d6,d5
		bge.s	.get_out
		move.w	map_width(a5),d6
		lsr.w	#4,d6
		asr.w	#4,d5		; /16
		mulu.w	d6,d5
		add.l	d5,a4
		moveq	#0,d6
		moveq	#0,d5
		moveq	#0,d4
		moveq	#0,d3
		move	#%000,ccr
		rts
.get_out:
		move	#%100,ccr
		rts

; --------------------------------------------------------
; object_MapCol_SetDown, object_MapCol_SetUp,
; object_MapCol_SetRight, object_MapCol_SetLeft
;
; Forces snap to the object after calling any of the
; _MapCol_Chk(dir) routines
;
; Input:
; a6   | This object
; a5   | Map buffer
; d0.w | Collision block number (0 = no collision)
; d1.w | Y position to snap
; d2.w | Y increment (carry set only)
; --------------------------------------------------------

object_MapCol_SetDown:
		movem.l	d5-d7/a4,-(sp)
		move.w	d1,d5
		andi.w	#-$10,d5
		add.w	d2,d5
		move.l	obj_size(a6),d7
		swap	d7
		andi.w	#$00FF,d7
		lsl.w	#3,d7
		sub.w	d7,d5
		bra	objMapColS_SetY

; ----------------------------------------

object_MapCol_SetUp:
		movem.l	d5-d7/a4,-(sp)
		move.w	d1,d5
		andi.w	#-$10,d5
		addi.w	#$10,d5		; <-- TOP only
		add.w	d2,d5
		move.l	obj_size(a6),d7
		swap	d7
		andi.w	#$FF00,d7
		lsr.w	#8,d7
		lsl.w	#3,d7
		add.w	d7,d5
; 		bra.s	objMapColS_SetY

; --------------------------------------
objMapColS_SetY:
; 		move.w	obj_y(a6),d6
; 		movem.w	d5/d6,($FF0000).l
;
; 		move.w	d5,obj_y(a6)
; 		clr.w	obj_y_spd(a6)
; 		movem.l	(sp)+,d5-d7/a4
; 		rts
;
; ; --------------------------------------

		moveq	#0,d7
		move.l	map_cmap(a5),a4
		move.w	d0,d7
		lsl.w	#4,d7
		adda	d7,a4			; Locate block
		move.w	obj_x(a6),d7
		andi.w	#$0F,d7
		move.b	(a4,d7.w),d7
		andi.w	#$FF,d7
		add.w	d7,d5			; Add the pixels
		move.w	obj_y(a6),d6
; 		andi.w	#-$10,d6
; 		add.w	d7,d6
		movem.w	d5/d6,($FF0000).l
		cmp.w	d6,d5
		bcc.s	.exit			; If exact match only return set.
		move.w	d5,obj_y(a6)		; If higher > target, snap Y
; 		clr.w	obj_y_spd(a6)
.exit:
		movem.l	(sp)+,d5-d7/a4
.bad_spd:
		rts
