; ===========================================================================
; ----------------------------------------------------------------
; 68K DATA BANKS
;
; Size limits:
;  $40000 for SegaCD's Word-RAM **compatible to all**
;  $80000 for Sega-Mapper(SSF2) bank
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
;
; 	mars_VramStart Label_test			; Start label
; example_0:
; 	include "your_svdp_graphics.bin"
; 	align 4						; Don't forget align by 4
; example_1:
; 	include "more_svdp.bin"
;	align 4
;	mars_VramEnd Label_end				; End label
; ----------------------------------------------------------------

; --------------------------------------------------------
; EXAMPLE INCLUDE
; --------------------------------------------------------
; 	data_dset DATA_BANKEXMPL
; 	; ------------------------------------------------
; 		include "your_data.asm"		; GEMA: Track data
; 		include "etc_stuff.asm"
; 	; ------------------------------------------------
; 	data_dend DATA_BANKEXMPL_e

; ============================================================
; --------------------------------------------------------
; MAIN bank
; --------------------------------------------------------

	data_dset DATA_BANK0
	; ------------------------------------------------
		include "sound/tracks.asm"		; GEMA: Track data
		include "sound/instr.asm"		; GEMA: FM instruments
		include "sound/smpl_dac.asm"		; GEMA: DAC samples
		include "game/data/bank_main.asm"
	; ------------------------------------------------
	data_dend DATA_BANK0_e

; ============================================================
; --------------------------------------------------------
; 32X stuff only
; --------------------------------------------------------

	data_dset DATA_BANK1
	; ------------------------------------------------
		include "game/data/bank_mars.asm"
	; ------------------------------------------------
	data_dend DATA_BANK1_e

; ============================================================
; --------------------------------------------------------
; STAMP BANK test
; --------------------------------------------------------

	data_dset DATA_BNKSTAMP
	; ------------------------------------------------
		include "game/data/stamps_0.asm"
	; ------------------------------------------------
	data_dend DATA_BNKSTAMP_e
