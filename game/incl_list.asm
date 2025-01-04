; ============================================================
; --------------------------------------------------------
; SCREEN CODE jump-list sorted by ID (RAM_ScreenMode)
;
; - Screen CODE list: incl_code.asm
; - DATA Bank list: incl_data.asm
;
; ** For SCD/CD32X:
;    Go to iso_files.asm, include the label and
;    filename.
; --------------------------------------------------------

.screen_list:
		dc.l Md_Screen00	; ROM label
		dc.b "SCREEN00.BIN"	; ISO Filename
		dc.l Md_Screen00
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen00
		dc.b "SCREEN00.BIN"
		dc.l Md_Screen07
		dc.b "SCREEN07.BIN"
		dc.l -1			; END-OF-LIST

; ============================================================
; --------------------------------------------------------
; SCD/CD32X ONLY:
; Bank label redirects to ISO filename
; --------------------------------------------------------

disc_banklist:
		dc.l DATA_BANK0		; Label
		dc.b "BNK_MAIN.BIN"	; ISO filename
		dc.l -1			; END-OF-LIST
