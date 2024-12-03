; ===========================================================================
; ----------------------------------------------------------------
; 68K DATA BANKS
;
; Size limitations:
;  $40000 for SegaCD's Word-RAM
;  $80000 for Sega-Mapper(SSF2) bank *not tested*
; $100000 for 32X Cartridge
; All 4MB for Genesis/Pico
;
; SCD/CD32:
; Add your BANK entries and filenames on iso_files.asm
;
; MACRO Usage:
;	data_dset LABEL_START
;	; your data
;	data_dend LABEL_END
; ----------------------------------------------------------------
; - For including VDP graphics:
;	binclude_dma LABEL_START,filepath		; Single label
;	binclude_dma_e LABEL_START,LABEL_END,filepath	; Start and End labels
;
; - For the SVDP graphics:
; 	mars_VramStart Label_test			; Start label
; example_0:
; 	include "your_svdp_graphics.bin"
; 	align 4						; Don't forget align by 4
; example_1:
; 	include "more_svdp.bin"
;	align 4
;	mars_VramEnd Label_end				; End label
; ----------------------------------------------------------------

; ============================================================
; --------------------------------------------------------
; MAIN bank
; --------------------------------------------------------

	data_dset DATA_BANK0
		include "sound/data.asm"		; GEMA sound data
		include "game/data/bank_main.asm"
	data_dend DATA_BANK0_e
