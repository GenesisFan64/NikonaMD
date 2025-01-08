; ============================================================
; ----------------------------------------------------
; SCD/CD32X ONLY:
;
; Labels and ISO filenames for the CODE and DATA banks
;
; The labels are the same ones your set on
; incl_code.asm and incl_data.asm
; ----------------------------------------------------

	;fs_file "ISO_FILE.BIN",Label_Start,Lable_End
	fs_file "SCREEN00.BIN",Md_Screen00,Md_Screen00_e
	fs_file "SCREEN07.BIN",Md_Screen07,Md_Screen07_e
	fs_file "BNK_MAIN.BIN",DATA_BANK0,DATA_BANK0_e
