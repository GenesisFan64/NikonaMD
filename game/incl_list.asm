; ============================================================
; --------------------------------------------------------
; SCREEN CODE jump list sorted by ID (RAM_ScreenMode)
;
; - CODE banks are at: incl_code.asm
; - For SCD/CD32X:
;   Include the Start+End labels and ISO filename
;   at iso_files.asm
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
; CD/CD32X ONLY: Bank filenames at any order
;
; If you forget to reference the label it will crash
; the entire SCD system.
;
; - Include the Start+End labels and ISO filename
;   at iso_files.asm
; --------------------------------------------------------

disc_banklist:
		dc.l DATA_BANK0		; Start Label
		dc.b "BNK_MAIN.BIN"	; ISO filename
		dc.l -1			; END-OF-LIST
