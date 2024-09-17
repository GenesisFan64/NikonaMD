; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona DAC samples
;
; This is located on the Genesis area and can be
; stored in ROM, and WORD-RAM.
; * RAM IS possible with help of Sound_Update but it's
;   not a good idea as samples are too long to fit. *
;
; SCD/CD32X:
; - Stored on WORD-RAM
;   CANNOT be used if Stamps are active/rendering, use
;   PCM instead.
;
; 32X Cartridge:
; - Always stored on the $880000(fixed) area.
; - $900000(banked) is possible but requires the BANK to
;   stay as-is.
;
; MACRO:
; gSmplData Label,"file_path",loop_start
;
; Set loop_start to 0 if not using it.
;
; BASE C-5 samplerate is 16000hz
; -------------------------------------------------------------------

; 	align $100
	;gSmplData Label,"file_path",loop_start
; -----------------------------------------------------------
	gSmplData DacIns_Nadie,"sound/instr/smpl/nadie.wav",0

	gSmplData DacIns_Kick,"sound/instr/smpl/kick.wav",0
	gSmplData DacIns_Snare,"sound/instr/smpl/snare.wav",0
	gSmplData DacIns_Timpani,"sound/instr/smpl/timpani.wav",0
	gSmplData DacIns_wegot_kick,"sound/instr/smpl/wegot_kick.wav",0
	gSmplData DacIns_wegot_crash,"sound/instr/smpl/wegot_crash.wav",0
