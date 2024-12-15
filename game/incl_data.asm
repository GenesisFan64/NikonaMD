; ===========================================================================
; ----------------------------------------------------------------
; DATA BANKS
;
; MACRO Usage:
;	data_bank LABEL_START
;	include "game/data/your_bank.asm"
;	dend_bank LABEL_END
;
; Load banks with:
; 	lea	bank_info(pc),a0
; 	bsr	System_SetDataBank
; 	; mode code
;
; bank_info:
; 	dc.l DATA_BANK0		; ROM label for Cartridge
; 	dc.b "BNK_MAIN.BIN",0	; ISO filename for CD
; 	align 2
;
; You MUST use the banks for compatibility on all systems
; even if the standard Genesis doesn't use require it.
; ----------------------------------------------------------------

	data_bank DATA_BANK0
	include "game/data/bank_main.asm"
	dend_bank DATA_BANK0_e

	data_bank DATA_BANK1
	include "game/data/stamps_0.asm"
	dend_bank DATA_BANK1_e
