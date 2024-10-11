; ===========================================================================
; ----------------------------------------------------------------
; BANK data
; ----------------------------------------------------------------

		binclude_dma	ASCII_FONT,"game/data/md/tilesets/font_8/art.bin"
		binclude_dma	ASCII_FONT_W,"game/data/md/tilesets/font_16/art.bin"
		binclude_dma	Art_BlkPuzzl,"game/data/md/tilesets/stepblk/art.bin"

		binclude_dma_e	Art_TESTBG,Art_TESTBG_e,"game/data/md/maps/test/art.bin"

		binclude_dma	Art_Haruna,"game/data/md/sprites/haruna/art.bin"
		binclude_dma_e	Art_Sisi,Art_Sisi_e,"game/data/md/sprites/sisi/art.bin"

		binclude_dma	Art_FairyDodo,"game/data/md/sprites/dodo/art.bin"
		binclude_dma	Art_FairyMimi,"game/data/md/sprites/mimi/art.bin"
		binclude_dma	Art_FairyFifi,"game/data/md/sprites/fifi/art.bin"

; ----------------------------------------------------------------
; Everything else...
; ----------------------------------------------------------------

Pal_BlkPuzzl:	binclude "game/data/md/tilesets/stepblk/pal.bin"
		align 2

Pal_Haruna:	binclude "game/data/md/sprites/haruna/pal.bin"
		align 2
Map_Haruna:	binclude "game/data/md/sprites/haruna/map.bin"
		align 2
Plc_Haruna:	binclude "game/data/md/sprites/haruna/plc.bin"
		align 2

Pal_Sisi:	binclude "game/data/md/sprites/sisi/pal.bin"
		align 2
Map_Sisi:	binclude "game/data/md/sprites/sisi/map.bin"
		align 2

Pal_TESTBG:	binclude "game/data/md/maps/test/pal.bin"
		align 2
Map_TESTBG:	binclude "game/data/md/maps/test/map.bin"
		align 2
Pal_TESTBG2:	binclude "game/data/md/maps/test2/pal.bin"
		align 2
Map_TESTBG2:	binclude "game/data/md/maps/test2/map.bin"
		align 2


objPal_Dodo:	binclude "game/data/md/sprites/dodo/pal.bin"
		align 2
objMap_Dodo:	binclude "game/data/md/sprites/dodo/map.bin"
		align 2
objMap_Mimi:	binclude "game/data/md/sprites/mimi/map.bin"
		align 2
objMap_Fifi:	binclude "game/data/md/sprites/fifi/map.bin"
		align 2
