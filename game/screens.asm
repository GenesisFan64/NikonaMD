; ============================================================
; --------------------------------------------------------
; SCREEN CODE jump-list sorted by ID (RAM_ScreenMode)
;
; Format:
; 		dc.l Md_Screen00	; ROM label
; 		dc.b "SCREEN00.BIN"	; CD Filename
;
; - Screen CODE list: incl_code.asm
; - DATA Bank list: incl_data.asm
;
; ** For SCD/CD32X:
;    Also go to iso_files.asm, include the label and
;    filename.
; --------------------------------------------------------
		dc.l Md_Screen00	; ROM label/CD tag
		dc.b "SCREEN00.BIN"	; CD Filename
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00	; ****
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen07	; Sound tester
		dc.b "SCREEN07.BIN"
