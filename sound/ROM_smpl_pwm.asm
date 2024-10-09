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
; 	gSmplData PwmIns_Nadie,"sound/instr/smpl/inga_st.wav",0
	gSmplData PwmIns_Piano,"sound/instr/smpl/piano_1.wav",0
	gSmplData PwmIns_PKick,"sound/instr/smpl/wegot_kick.wav",0
	gSmplData PwmIns_PTom,"sound/instr/smpl/sauron_tom.wav",0

 	gSmplData PwmIns_sauron_01,"sound/instr/smpl/sauron/01.wav",0
 	gSmplData PwmIns_sauron_02,"sound/instr/smpl/sauron/02.wav",0
  	gSmplData PwmIns_sauron_03,"sound/instr/smpl/sauron/03.wav",0
  	gSmplData PwmIns_sauron_04,"sound/instr/smpl/sauron/04.wav",0
 	gSmplData PwmIns_sauron_05,"sound/instr/smpl/sauron/05.wav",13988
  	gSmplData PwmIns_sauron_06,"sound/instr/smpl/sauron/06.wav",0
 	gSmplData PwmIns_sauron_07,"sound/instr/smpl/sauron/07.wav",0
  	gSmplData PwmIns_sauron_08,"sound/instr/smpl/sauron/08.wav",0
 	gSmplData PwmIns_sauron_09,"sound/instr/smpl/sauron/09.wav",0
  	gSmplData PwmIns_sauron_10,"sound/instr/smpl/sauron/10.wav",0
 	gSmplData PwmIns_sauron_11,"sound/instr/smpl/sauron/11.wav",0
 	gSmplData PwmIns_sauron_12,"sound/instr/smpl/sauron/12.wav",0
