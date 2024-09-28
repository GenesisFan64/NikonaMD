; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona PWM instruments located at SDRAM
;
; *** VERY LIMITED STORAGE ***
; If you are using CD32X consider using PCM samples instead.
;
; MACRO:
; gSmplData Label,"file_path",loop_start
;
; Set loop_start to 0 if not using it.
;
; BASE C-5 samplerate is 16000hz
; -------------------------------------------------------------------

	align 4
	;gSmplData Label,"file_path",loop_start
; -----------------------------------------------------------
; 	gSmplData PwmIns_TEST,"sound/instr/smpl/test_st.wav",0

	gSmplData PwmIns_trnthem_01,"sound/instr/smpl/trnthem/01.wav",12048
	gSmplData PwmIns_trnthem_10,"sound/instr/smpl/trnthem/10.wav",3033
	gSmplData PwmIns_trnthem_11,"sound/instr/smpl/trnthem/11.wav",0
	gSmplData PwmIns_trnthem_12,"sound/instr/smpl/trnthem/12.wav",0
