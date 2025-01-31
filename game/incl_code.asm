; ====================================================================
; ----------------------------------------------------------------
; CODE Section
; ----------------------------------------------------------------

; ------------------------------------------------------------
; Usage:
; 	code_bank START_LABEL,END_LABEL,CODE_PATH
;
; Go to incl_list.asm add an entry in .screen_list:
; 	dc.l START_LABEL		; Label
; 	dc.b "SCR_EXMP.BIN"		; ISO filename
; * IN ORDER by ID *
;
; CD/CD32X:
; Labels and ISO filename at iso_files.asm
; ------------------------------------------------------------

	code_bank Md_Screen00,Md_Screen00_e,"game/code/main.asm"
	code_bank Md_Screen07,Md_Screen07_e,"game/code/sound_test.asm"
