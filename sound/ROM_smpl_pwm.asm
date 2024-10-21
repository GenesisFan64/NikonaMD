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
; 	gSmplData PwmIns_Nadie,"sound/ins/smpl/inga_st.wav",0
	gSmplData PwmIns_Piano,"sound/ins/smpl/piano_1.wav",0
	gSmplData PwmIns_PKick,"sound/ins/smpl/wegot_kick.wav",0
	gSmplData PwmIns_PTom,"sound/ins/smpl/sauron_tom.wav",0

	gSmplData PwmIns_sxbeats,"sound/ins/smpl/sxbeats.wav",0
	gSmplData PwmIns_sxbeats2,"sound/ins/smpl/sxbeats2.wav",0
	gSmplData PwmIns_drumsetA,"sound/ins/smpl/drumsetA.wav",0

 	gSmplData PwmIns_sauron_01,"sound/ins/smpl/sauron/01.wav",0
 	gSmplData PwmIns_sauron_02,"sound/ins/smpl/sauron/02.wav",0
  	gSmplData PwmIns_sauron_03,"sound/ins/smpl/sauron/03.wav",0
  	gSmplData PwmIns_sauron_04,"sound/ins/smpl/sauron/04.wav",0
 	gSmplData PwmIns_sauron_05,"sound/ins/smpl/sauron/05.wav",13988
  	gSmplData PwmIns_sauron_06,"sound/ins/smpl/sauron/06.wav",0
 	gSmplData PwmIns_sauron_07,"sound/ins/smpl/sauron/07.wav",0
  	gSmplData PwmIns_sauron_08,"sound/ins/smpl/sauron/08.wav",0
 	gSmplData PwmIns_sauron_09,"sound/ins/smpl/sauron/09.wav",0
  	gSmplData PwmIns_sauron_10,"sound/ins/smpl/sauron/10.wav",0
 	gSmplData PwmIns_sauron_11,"sound/ins/smpl/sauron/11.wav",0
 	gSmplData PwmIns_sauron_12,"sound/ins/smpl/sauron/12.wav",0
