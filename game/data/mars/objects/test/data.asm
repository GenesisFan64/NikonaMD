MarsObj_test:
		dc.w 166,92
		dc.l .vert-MarsObj_test,.face-MarsObj_test,.vrtx-MarsObj_test,.mtrl-MarsObj_test
.vert:		binclude "game/data/mars/objects/test/vert.bin"
.face:		binclude "game/data/mars/objects/test/face.bin"
.vrtx:		binclude "game/data/mars/objects/test/vrtx.bin"
.mtrl:		include "game/data/mars/objects/test/mtrl.asm"
		align 4