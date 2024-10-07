MarsObj_test_2:
		dc.w 80,42
		dc.l .vert-MarsObj_test_2,.face-MarsObj_test_2,.vrtx-MarsObj_test_2,.mtrl-MarsObj_test_2
.vert:		binclude "game/data/mars/objects/test_2/vert.bin"
.face:		binclude "game/data/mars/objects/test_2/face.bin"
.vrtx:		binclude "game/data/mars/objects/test_2/vrtx.bin"
.mtrl:		include "game/data/mars/objects/test_2/mtrl.asm"
		align 4