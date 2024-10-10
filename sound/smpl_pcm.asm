; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona PCM instruments for SCD's PCM soundchip
;
; Stored on DISC and loaded to Sub-CPU on boot
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
	gSmplData PcmIns_sxbeats,"sound/instr/smpl/sxbeats.wav",0
	gSmplData PcmIns_sxbeats2,"sound/instr/smpl/sxbeats2.wav",0
	gSmplData PcmIns_drumsetA,"sound/instr/smpl/drumsetA.wav",0

	gSmplData PcmIns_Trumpet1,"sound/instr/smpl/trumpet1.wav",27625
	gSmplData PcmIns_BBoxHats,"sound/instr/smpl/hats_bbox.wav",0
	gSmplData PcmIns_Kick,"sound/instr/smpl/wegot_kick.wav",0
	gSmplData PcmIns_BBoxSnare,"sound/instr/smpl/snare_bbox.wav",0

 	gSmplData PcmIns_sauron_01,"sound/instr/smpl/sauron/01.wav",0
 	gSmplData PcmIns_sauron_02,"sound/instr/smpl/sauron/02.wav",0
  	gSmplData PcmIns_sauron_03,"sound/instr/smpl/sauron/03.wav",0
  	gSmplData PcmIns_sauron_04,"sound/instr/smpl/sauron/04.wav",0
 	gSmplData PcmIns_sauron_05,"sound/instr/smpl/sauron/05.wav",13988
  	gSmplData PcmIns_sauron_06,"sound/instr/smpl/sauron/06.wav",0
 	gSmplData PcmIns_sauron_07,"sound/instr/smpl/sauron/07.wav",0
  	gSmplData PcmIns_sauron_08,"sound/instr/smpl/sauron/08.wav",0
 	gSmplData PcmIns_sauron_09,"sound/instr/smpl/sauron/09.wav",0
  	gSmplData PcmIns_sauron_10,"sound/instr/smpl/sauron/10.wav",0
 	gSmplData PcmIns_sauron_11,"sound/instr/smpl/sauron/11.wav",0
 	gSmplData PcmIns_sauron_12,"sound/instr/smpl/sauron/12.wav",0

	gSmplData PcmIns_trnthem_02,"sound/instr/smpl/trnthem/02.wav",0
	gSmplData PcmIns_trnthem_03,"sound/instr/smpl/trnthem/03.wav",0
	gSmplData PcmIns_trnthem_04,"sound/instr/smpl/trnthem/04.wav",19996
	gSmplData PcmIns_trnthem_05,"sound/instr/smpl/trnthem/05.wav",0
	gSmplData PcmIns_trnthem_06,"sound/instr/smpl/trnthem/06.wav",0
	gSmplData PcmIns_trnthem_07,"sound/instr/smpl/trnthem/07.wav",2938
	gSmplData PcmIns_trnthem_10,"sound/instr/smpl/trnthem/10.wav",3033
	gSmplData PcmIns_trnthem_20,"sound/instr/smpl/trnthem/20.wav",14309
