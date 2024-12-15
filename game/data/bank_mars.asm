; ===========================================================================
; ----------------------------------------------------------------
; BANK data
;
; Special macros:
;
; - VDP graphics:
;	binclude_dma   LABEL_START,"filename"		; For single label
;	binclude_dma_e LABEL_START,LABEL_END,"filename"	; Start and End labels
;
; - 32X SVDP graphics:
; 	mars_VramStart Label_test			; Set the Start label
; example_0:
; 	include "your_svdp_graphics.bin"
; 	align 4						; ** Don't forget to align by 4 at the end **
; example_1:
; 	include "more_svdp.bin"
;	align 4
;	mars_VramEnd Label_end				; Set the End label
; ----------------------------------------------------------------

MarsGfxBank0:
		marsVramData
	; ------------------------------------------------
; 		dc.b "32X GRAPHICS GO HERE"
		dc.b 0
	; ------------------------------------------------
		marsVramDEnd
marsVramData0_e:
