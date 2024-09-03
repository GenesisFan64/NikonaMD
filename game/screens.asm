; ============================================================
; --------------------------------------------------------
; SCREEN CODE jump-list sorted by ID (RAM_ScreenMode)
;
; - Screen CODE includes: incl_code.asm
;
; - DATA Bank includes: incl_data.asm
;
; ** For CD/CD32X **
;    Add your ISO file entries for both
;    CODE and DATA in iso_files.asm
; --------------------------------------------------------

; Entry:
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen01	; ****
		dc.b "SCREEN01.BIN"
		dc.l Md_Screen02	; ****
		dc.b "SCREEN02.BIN"
		dc.l Md_Screen03	; ****
		dc.b "SCREEN03.BIN"
		dc.l Md_Screen04	; ****
		dc.b "SCREEN04.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen07	; ****
		dc.b "SCREEN07.BIN"
