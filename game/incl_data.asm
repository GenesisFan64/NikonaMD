; ===========================================================================
; ----------------------------------------------------------------
; DATA BANKS
;
; MACRO Usage:
;	data_bank LABEL_START
;	include "game/data/your_bank.asm"
;	dend_bank LABEL_END
;
; Then in incl_list.asm add an entry like this, this is only
; required for SCD and CD32X:
; 	dc.l DATA_BANK			; Label
; 	dc.b "BNK_MAIN.BIN"		; ISO filename
;
; In your screen code load banks with:
; 	move.l	#DATA_BANK,d0
; 	bsr	System_SetDataBank
;
; You MUST use the banks for compatibility to all systems
; even if the standard Genesis doesn't require it.
; DO note that on SCD and CD32X the DATA banks are stored
; on DISC, so loading will be take a lot.
; ----------------------------------------------------------------

	data_bank DATA_BANK0
	include "game/data/bank_main.asm"
	dend_bank DATA_BANK0_e
