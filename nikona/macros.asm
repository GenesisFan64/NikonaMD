; ===========================================================================
; -------------------------------------------------------------------
; MACROS Section
;
; *** THIS MUST BE INCLUDED AT START OF THE CODE ***
; -------------------------------------------------------------------

MAX_WramBank	equ $3F800	; Maxium WRAM available to use + filler $120

; ====================================================================
; ------------------------------------------------------------
; AS Functions
; ------------------------------------------------------------

splitw		function l,r,(((l))<<16&$FFFF0000|((r))&$FFFF)		; Two WORDS stored in a single LONG: $11112222
cell_num	function a,(a<<5)					; Value in VDP cells
; pstr_mem	function a,b,((a|$80)<<24)|b&$FFFFFF			; PRINT memory: pstr_mem(type,mem_pos)
full_loc	function a,-(-a)&$FFFFFFFF
vdp_wrtl	function a,((a>>14)&3)|(((a&$3FFF)|$4000)<<16)

; ====================================================================
; ------------------------------------------------------------
; Macros
; ------------------------------------------------------------

; --------------------------------------------
; Memory reserve
;
; Example:
; 		memory RAM_Somewhere
; RAM_ThisLong	ds.l 1
; RAM_ThisWord	ds.w 1
; RAM_ThisByte	ds.b 1				; <-- careful with alignment
; 		endmemory 			; finish
; --------------------------------------------

memory		macro thisinput			; Reserve memory address
GLBL_LASTPC	:= *
		dephase
		phase thisinput
GLBL_LASTORG	:= *
		endm

; --------------------------------------------

endmemory	macro				; Then finish.
.here:		dephase
		ds.b -(.here-GLBL_LASTORG)
		phase GLBL_LASTPC
		endm

; --------------------------------------------
; Report memory usage
; --------------------------------------------

report		macro text,this,that
	if MOMPASS == 2
		if that == -1
			message text+": \{(this)&$FFFFFF}"
		else
			if this > that
				warning "RAN OUT OF "+text+" SPACE (\{(this)&$FFFFFF} of \{(that)&$FFFFFF})"
			else
				message text+" uses \{(this)&$FFFFFF} of \{(that)&$FFFFFF}"
			endif
		endif
	endif
		endm

; --------------------------------------------
; Same as report but only show on error
; --------------------------------------------

erreport	macro text,this,that
	if MOMPASS == 2
		if this > that
			error "RAN OUT OF "+text+" (\{(this)&$FFFFFF} of \{(that)&$FFFFFF})"
		endif
	endif
		endm

; --------------------------------------------
; ZERO Fill padding
; --------------------------------------------

rompad		macro target
.this_sz := target - *
		if .this_sz < 0
			error "Too much data at $\{target} ($\{(-.this_sz)} bytes)"
		else
			dc.b [.this_sz]0
		endif
	endm

; ====================================================================
; ------------------------------------------------------------
; Filesystem macros
;
; NOTE: A pre-generated ISO head is required
;       at $8000 until $B7FF
; ------------------------------------------------------------

; ------------------------------------------------------------
; FS setup
; ------------------------------------------------------------

fs_mkList	macro type,start,end
.fstrt:
		dc.b .fend-.fstrt				; Block size
		dc.b 0						; Zero
		dc.b (start>>11&$FF),(start>>19&$FF)		; Start sector, little endian
		dc.b (start>>27&$FF),(start>>35&$FF)
		dc.l start>>11					; Start sector, big endian
		dc.b ((end-start)&$FF),((end-start)>>8&$FF)	; Filesize, little endian
		dc.b ((end-start)>>16&$FF),((end-start)>>24&$FF)
		dc.l end-start					; Filesize, big endian
		dc.b (2025-1900)+1				; Year
		dc.b 0,0,0,0,0,0				; (filler)
		dc.b 2						; File flags
		dc.b 0,0
		dc.b 1,0					; Volume sequence number, little
		dc.b 0,1					; Volume sequence number, big
		dc.b 1,type
.fend:
		endm

; ------------------------------------------------------------
; FS File
; ------------------------------------------------------------

fs_file		macro filename,start,end
.fstrt:		dc.b .fend-.fstrt				; Block size
		dc.b 0						; zero
		dc.b (start>>11&$FF),(start>>19&$FF)		; Start sector, little
		dc.b (start>>27&$FF),(start>>35&$FF)
		dc.l start>>11					; Start sector, big
		dc.b ((end-start)&$FF),((end-start)>>8&$FF)	; Filesize, little
		dc.b ((end-start)>>16&$FF),((end-start)>>24&$FF)
		dc.l end-start					; Filesize, big
		dc.b (2025-1900)+1				; Year
		dc.b 0,0,0,0,0,0				; (filler)
		dc.b 0						; File flags
		dc.b 0,0
		dc.b 1,0					; Volume sequence number, little
		dc.b 0,1					; Volume sequence number, big
		dc.b .flend-.flen
.flen:		dc.b filename,";1"
.flend:		dc.b 0
.fend:
		endm

; ====================================================================
; ------------------------------------------------------------
; Nikona macros
; ------------------------------------------------------------

; --------------------------------------------
; Screen mode code
;
; code_bank START_LABEL,END_LABEL,CODE_PATH
; --------------------------------------------

code_bank macro lblstart,lblend,path
	if MCD|MARSCD
		align $800		; SCD/CD32X sector align
	elseif MARS
		phase $880000+*		; 32X ROM-area
		align 4
	endif
lblstart label *			; Register start label
	if MARS
		dephase			; 32X dephase
	endif
mctopscrn:
	if MARS|MCD|MARSCD
		phase RAM_UserCode	; Phase code to RAM area
	endif
mcscrn_s:
	include path;"game/screenX/code.asm"
mcscrn_e:
	if MARS
		dephase			; dephase RAM section
	elseif MCD|MARSCD
		dephase
		phase mctopscrn+(mcscrn_e-RAM_UserCode)	; Add the used bytes
		align $800
	endif
lblend label *
	erreport "SCREEN CODE: lblstart",mcscrn_e-mcscrn_s,MAX_UserCode
	endm

; --------------------------------------------
; Data bank START
; --------------------------------------------

data_bank macro startlbl
	if MCD|MARSCD
		align $800		; Sector alignment
	elseif MARS
		align 4			; 32X alignment
	endif
startlbl label *			; Register label
	if MCD|MARSCD			; Set PHASE
		phase sysmcd_wram
	elseif MARS
		phase $900000+(startlbl&$0FFFFF)
	endif
GLBL_MDATA_ST := *			; Save current pos globally
	endm

; --------------------------------------------
; Data bank END
; --------------------------------------------

dend_bank macro endlbl
GLBL_MDATA_RP := *-GLBL_MDATA_ST	; Get used size to report

	; Set 32X bank end
	if MARS
		if GLBL_MDATA_RP >= $900000+$100000
			error "32X: RAN OUT OF MEMORY FOR A SINGLE 1MB BANK"
		endif
		dephase			; Dephase $900000

	; Set MCD/CD32X data end
	elseif MCD|MARSCD
		dephase			; Dephase WRAM
mlastpos := *	; <-- CD/CD32X ONLY
mpadlbl	:= (mlastpos&$FFF800)+$800	; Fill sectors
		rompad mpadlbl
endlbl label *	; <-- CD/CD32X ONLY

		if GLBL_MDATA_RP > MAX_WramBank
			error "SCD/CD32X: DATA BANK IS TOO LARGE: $\{GLBL_MDATA_RP} of $\{MAX_WramBank}"
		endif
	endif
	endm

; --------------------------------------------
; SCD Stamp Start/End
; --------------------------------------------

mcdStampData	macro
		phase 0
		ds.b $80
		endm

mcdStampDEnd	macro
		align 2
.end:
		erreport "This SCD Stamp data",.end,$3F800
		dephase
		endm

; --------------------------------------------
; 32X graphics data Start/End
; --------------------------------------------

marsVramData	macro
		phase 0
		endm

marsVramDEnd	macro
		align 8
.end:
		erreport "This 32X graphics data",.end,$18000
		dephase
		endm

; --------------------------------------------
; Fill CD sectors
; --------------------------------------------

fillSectors macro num
	rept num
		align $800-1
		dc.b 0
	endm
	endm

; --------------------------------------------
; binclude VDP graphics
; --------------------------------------------

binclude_dma	macro lblstart,file
	; 32X: Temporally show ROM position
	if MARS
GLBL_LASTPHDMA	set *
	dephase
GLBL_PHASEDMA	set *
		endif

		align 2
lblstart	label *
		binclude file
		align 2
	; 32X: Return to last phase
	if MARS
GLBL_ENDPHDMA	set *-GLBL_PHASEDMA
		phase GLBL_LASTPHDMA+GLBL_ENDPHDMA
	endif
		endm

; --------------------------------------------
; binclude VDP graphics w/End label
; --------------------------------------------

binclude_dma_e	macro lblstart,lblend,file
	; 32X: Temporally show ROM position
	if MARS
GLBL_LASTPHDMA	set *
	dephase
GLBL_PHASEDMA	set *
		endif
		align 2
lblstart	label *
		binclude file
lblend		label *
		align 2
	; 32X: Return to last phase
	if MARS
GLBL_ENDPHDMA	set *-GLBL_PHASEDMA
		phase GLBL_LASTPHDMA+GLBL_ENDPHDMA
	endif
		endm

; ====================================================================
; ------------------------------------------------------------
; Nikona CODE macros
; ------------------------------------------------------------

; --------------------------------------------
; VDP color debug
; --------------------------------------------

vdp_showme	macro color
		move.l	#$C0000000,(vdp_ctrl).l
		move.w	#color,(vdp_data).l
		endm
