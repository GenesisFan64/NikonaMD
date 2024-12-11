; ===========================================================================
; ----------------------------------------------------------------
; DATA BANKS
;
; MACRO Usage:
;	data_dset LABEL_START
;	; your data
;	data_dend LABEL_END
;
; - For including VDP graphics:
;	binclude_dma   LABEL_START,filepath		; Single label
;	binclude_dma_e LABEL_START,LABEL_END,filepath	; Start and End labels
;
; - For the SVDP graphics:
; 	mars_VramStart Label_test			; Set the Start label
; example_0:
; 	include "your_svdp_graphics.bin"
; 	align 4						; ** Don't forget to align by 4 at the end
; example_1:
; 	include "more_svdp.bin"
;	align 4
;	mars_VramEnd Label_end				; Set the End label
; ----------------------------------------------------------------

; ============================================================
; --------------------------------------------------------
; MAIN bank
; --------------------------------------------------------

	data_dset DATA_BANK0
		include "sound/data.asm"		; GEMA sound data
		include "game/data/bank_main.asm"
	data_dend DATA_BANK0_e
