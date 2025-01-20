; ===========================================================================
; ----------------------------------------------------------------
; Genesis/Pico 68000 RAM section (SCD: "MAIN-CPU")
;
; Used RAM areas:
; $FFF700-$FFFC00 | Used by Boot ROM *
; $FFFC00-$FFFD00 | Boot ROM's stack area a7
; $FFFD00-$FFFDB3 | RESERVED for the Sega CD Vector jumps
; $FFFDB4-$FFFFFF | Used by Boot ROM *
;
; * Free on Cartridge
; ----------------------------------------------------------------

; ====================================================================
; ----------------------------------------------------------------
; 68000 RAM SIZES (MAIN-CPU in SegaCD/CD32X)
; ----------------------------------------------------------------

MAX_Globals		equ $1000	; USER Global variables
MAX_ScrnBuff		equ $2000	; Current Screen's buffer
MAX_SysCode		equ $3000	; SCD/32X/CD32X: Nikona lib
MAX_UserCode		equ $7800	; SCD/32X/CD32X: Current SCREEN's CODE+small DATA

; ====================================================================

SET_RAMLIMIT		equ $00FFFC00

; ===========================================================================
; ----------------------------------------------------------------
; MAIN USER RAM
; ----------------------------------------------------------------

			memory $FFFF0000
		if MCD|MARS|MARSCD
RAM_SystemCode		ds.b MAX_SysCode
RAM_UserCode		ds.b MAX_UserCode
sizeof_thisram		ds.l 0
		endif
.end:
			endmemory

		if MCD|MARS|MARSCD
			memory sizeof_thisram
		else
			memory $FFFFB000	; Genesis/Pico ONLY
		endif
RAM_ScrnBuff		ds.b MAX_ScrnBuff
RAM_MdGlobal		ds.b MAX_Globals

; ----------------------------------------
; * FIRST PASS LABELS *
	if MOMPASS=1
	if MCD|MARS|MARSCD
RAM_MdMisc		ds.l 0
	endif
RAM_MdVideo		ds.l 0
RAM_MdSystem		ds.l 0
sizeof_MdRam		ds.l 0
	else
; ----------------------------------------
; * AUTOMATIC SIZES *
	if MCD|MARS|MARSCD
RAM_MdMisc		ds.b sizeof_mdmisc-RAM_MdMisc
	endif
RAM_MdVideo		ds.b sizeof_mdvid-RAM_MdVideo	; $FF8000
RAM_MdSystem		ds.b sizeof_mdsys-RAM_MdSystem	;
sizeof_MdRam		ds.l 0
	endif
; ------------------------------------------------
			endmemory
		if (sizeof_MdRam&$FF0000 == 0) | (sizeof_MdRam&$FFFFFF>(SET_RAMLIMIT))
			error "RAN OUT OF GENESIS/MAIN RAM FOR THIS SYSTEM"
		endif

; --------------------------------------------------------
; SCD and 32X special section
; --------------------------------------------------------

	if MCD|MARS|MARSCD
			memory RAM_MdMisc
; ----------------------------------------
; * FIRST PASS LABELS *
	if MOMPASS=1
RAM_MdMcd_Stamps	ds.l 0
RAM_MdMcd_StampSett	ds.l 0
RAM_MdMars_CommBuff	ds.l 0
RAM_MdMars_PalFd	ds.l 0
RAM_MdMars_MPalFdList	ds.l 0
sizeof_mdmisc		ds.l 0
	else
; ----------------------------------------
; * AUTOMATIC SIZES *
	if MCD|MARSCD
RAM_MdMcd_Stamps	ds.b $20*MAX_MCDSTAMPS		; SCD Stamps
RAM_MdMcd_StampSett	ds.b mdstmp_len			; SCD Stamp dot-screen control
	endif
	if MARS|MARSCD
RAM_MdMars_IndxPalFd	ds.w 1				; ''
RAM_MdMars_PalFd	ds.w 256			; Target 32X palette for FadeIn/Out
RAM_MdMars_MPalFdList	ds.b palfd_len*MAX_PALFDREQ	; '' same but for 32X
RAM_MdMars_CommBuff	ds.b Dreq_len			; 32X DREQ-RAM size
	endif
sizeof_mdmisc		ds.l 0
; ----------------------------------------
	endif
			endmemory
	endif

; --------------------------------------------------------
; Fixed areas
; --------------------------------------------------------

RAM_Stack		equ RAM_MegaCd		; <-- Goes backwards
RAM_MegaCd		equ $FFFFFD00		; SCD's vector jumps
RAM_SoundBuff		equ $FFFFFF00
