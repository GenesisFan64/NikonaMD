; ===========================================================================
; ----------------------------------------------------------------
; DATA BANKS
;
; MACRO Usage:
;	data_bank LABEL_START
;	include "game/data/your_bank.asm"
;	dend_bank LABEL_END
;
; In your screen code load banks with:
; 	lea	bank_info(pc),a0
; 	bsr	System_SetDataBank
; 	; mode code
;
; ; the data:
; bank_info:
; 	dc.l DATA_BANK0		; ROM label for Cartridge, used on CD as a temporal
; 	dc.b "BNK_MAIN.BIN",0	; ISO filename for CD (Unused on Cartridge)
; 	align 2
;
; You MUST use the banks for compatibility on all systems
; even if the standard Genesis doesn't use require it.
; ----------------------------------------------------------------

	data_bank DATA_BANK0
	include "game/data/bank_main.asm"
	dend_bank DATA_BANK0_e
