; ===========================================================================
; ----------------------------------------------------------------
; BANK data
; ----------------------------------------------------------------

PalMars_Test:
		binclude "game/data/mars/maps/test/pal.bin"
		align 2
MapMars_Test:
		binclude "game/data/mars/maps/test/map.bin"
		align 2
PalMars_STest:
PalMars_Haruna:
		binclude "game/data/mars/textures/haruna_pal.bin"
		align 2
PalMars_Sisi:
		binclude "game/data/mars/sprites/sisi/pal.bin"
		align 8

; ----------------------------------------------------

PalMars_Test2:
		binclude "game/data/mars/objects/test/mtrl/test_pal.bin"
		binclude "game/data/mars/textures/doremi/pal.bin"	; FILLER
		align 2

; ===========================================================
; ----------------------------------------------------
; 32X GRAPHICS BANKS
; ----------------------------------------------------

		mars_VramStart ArtMars_Test2D		; Graphics/Texture pack START
; ----------------------------------------------------
ArtMars_TestArt:
		binclude "game/data/mars/maps/test/art.bin"
		align 8
ArtMars_Sisi:
		binclude "game/data/mars/sprites/sisi/art.bin"
		align 8
Textr_Haruna:
		binclude "game/data/mars/textures/haruna_art.bin"
		align 8
; ----------------------------------------------------
		mars_VramEnd ArtMars_Test2D_e		; Graphics/Texture pack END

