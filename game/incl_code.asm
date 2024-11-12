; ============================================================
; --------------------------------------------------------
; CODE BANKS section
;
; Usage:
; screen_code START_LABEL,END_LABEL,CODE_PATH
;
; NOTES:
; - Screen order is at game/screens.asm
; - DATA banks are loaded separately inside the
;   screen's code
; --------------------------------------------------------

	screen_code Md_Screen00,Md_Screen00_e,"game/code/main.asm"
; 	screen_code Md_Screen01,Md_Screen01_e,"game/code/screen_1.asm"
; 	screen_code Md_Screen02,Md_Screen02_e,"game/code/screen_2.asm"
; 	screen_code Md_Screen03,Md_Screen03_e,"game/code/screen_3.asm"
; 	screen_code Md_Screen04,Md_Screen04_e,"game/code/screen_4.asm"
	screen_code Md_Screen07,Md_Screen07_e,"game/code/sound_test.asm"
