; ===========================================================================
; ----------------------------------------------------------------
; NULL SCREEN CODE
;
; Unused/filler that jumps back to Screen 0
; DO NOT USE LABELS HERE
; ----------------------------------------------------------------

		bsr	Mode_Init
		move.w	#0,(RAM_ScreenMode).w
		rts
