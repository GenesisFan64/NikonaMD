; ====================================================================
; ----------------------------------------------------------------
; Save file struct
;
; Make sure SET_ENBLSAVE is enabled on rominfo.asm
; ----------------------------------------------------------------

RAM_Save_TAG		ds.b 4		; ** DO NOT REMOVE **
RAM_Save_Counter	ds.l 1		; Temporal counter
