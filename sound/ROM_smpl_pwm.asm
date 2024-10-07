; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona PWM instruments on Cartridge ONLY
;
; - Samples located here CANNOT be used on CD32X
; - If the Genesis does DMA that requires the RV bit this
;   section will get protected ASAP before the DMA starts
;
; MACRO:
; gSmplData Label,"file_path",loop_start
; Set loop_start to 0 if not using it.
;
; BASE C-5 samplerate is 16000hz
; -------------------------------------------------------------------

	align 4
	;gSmplData Label,"file_path",loop_start
; -----------------------------------------------------------
	gSmplData PwmIns_Nadie,"sound/instr/smpl/nadie_st.wav",0
	gSmplData PwmIns_Piano,"sound/instr/smpl/piano_1.wav",0
	gSmplData PwmIns_PKick,"sound/instr/smpl/wegot_kick.wav",0
	gSmplData PwmIns_PTom,"sound/instr/smpl/sauron_tom.wav",0
