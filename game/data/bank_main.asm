; ===========================================================================
; ----------------------------------------------------------------
; BANK data
; ----------------------------------------------------------------

		binclude_dma	ASCII_FONT,"game/data/md/tilesets/font_8/art.bin"
		binclude_dma	ASCII_FONT_W,"game/data/md/tilesets/font_16/art.bin"
		binclude_dma	Art_FairyDodo,"game/data/md/sprites/dodo/art.bin"
		binclude_dma	Art_FairyMimi,"game/data/md/sprites/mimi/art.bin"
		binclude_dma	Art_FairyFifi,"game/data/md/sprites/fifi/art.bin"
		binclude_dma	ART_TESTBG,"game/data/md/maps/test/art.bin"

; ----------------------------------------------------------------

PAL_TESTBG:	binclude "game/data/md/maps/test/pal.bin"
		align 2
MAP_TESTBG:	binclude "game/data/md/maps/test/map.bin"
		align 2

objPal_Dodo:	binclude "game/data/md/sprites/dodo/pal.bin"
		align 2
objMap_Dodo:	binclude "game/data/md/sprites/dodo/map.bin"
		align 2
objMap_Mimi:	binclude "game/data/md/sprites/mimi/map.bin"
		align 2
objMap_Fifi:	binclude "game/data/md/sprites/fifi/map.bin"
		align 2
