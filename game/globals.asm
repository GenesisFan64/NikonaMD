; ====================================================================
; ----------------------------------------------------------------
; USER GLOBAL settings and variables at RAM_Global
;
; Maximum size: $1000
; ----------------------------------------------------------------

; ------------------------------------------------------------
; Your Score, Lives, Level number, etc. go here.
; These will remain after changing screens, for temporal
; buffers use RAM_ScrnBuff (Max. $1000, MAX_ScrnBuff)
;
; You can use any name you want but be careful with any
; conflicting names used by the Nikona code
; "equ" es permanent, "set" is rewritable during build
;
; Example variables:
;
; example_value		equ $1234
; example_bool		equ True
; example_string	equ "NIKONA"
;
; Example RAM labels:
;
; RAM_YourName		ds.X N ; X: size b, w, l
;                              ; N: number of items
;                              ;
; RAM_Glbl_ExL		ds.l 8 ; Reserve 8 LONGS ($20 bytes)
; RAM_Glbl_ExW		ds.w 5 ; Reserve 5 WORDS ($0A bytes)
; RAM_Glbl_ExB		ds.b 6 ; Reserve 6 BYTES
;
; Be careful with the aligment or you will get an
; ADDRESS ERROR on real hardware
; ------------------------------------------------------------

RAM_Glbl_Example_L	ds.l 1		; 1 long (4 bytes)
RAM_Glbl_Example_W	ds.w 1		; 1 word (2 bytes)
RAM_Glbl_Example_B	ds.b 1		; 1 byte
