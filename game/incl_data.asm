; ====================================================================
; ----------------------------------------------------------------
; DATA Section
; ----------------------------------------------------------------

; ------------------------------------------------------------
; Usage:
;	data_bank LABEL_START
;	include "game/data/your_bank.asm"
;	dend_bank LABEL_END
;
; CD/CD32X ONLY:
; Go to incl_list.asm add an entry in disc_banklist:
; 	dc.l DATA_BANK			; Label
; 	dc.b "BNK_EXMP.BIN"		; ISO filename
;
; And add the labels and ISO filename at iso_files.asm
;
; * This is ONLY required for CD/CD32X, if you forget to
; include it it will crash the entire system.
;
; During your screen code load banks with:
; 	move.l	#DATA_BANK,d0
; 	bsr	System_SetDataBank
;
; You MUST use the banks for compatibility to all systems
; even if the standard Genesis doesn't require it.
; DO note that on SCD and CD32X the DATA banks are stored
; on DISC so loading banks will be SLOW.
; ------------------------------------------------------------

	data_bank DATA_BANK0
	include "game/data/bank_main.asm"
	dend_bank DATA_BANK0_e
