; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona PCM instruments for Sega CD and CD32X
;
; Stored on DISC and loaded to Sub-CPU on boot
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
; 	gSmplData PcmIns_test_L,"sound/instr/smpl/test_l.wav",0
; 	gSmplData PcmIns_test_R,"sound/instr/smpl/test_r.wav",0
	gSmplData PcmIns_TEST,"sound/instr/smpl/test_m.wav",0

	gSmplData PcmIns_Nadie_L,"sound/instr/smpl/nadie_l.wav",0
	gSmplData PcmIns_Nadie_R,"sound/instr/smpl/nadie_r.wav",0
	gSmplData PcmIns_Piano,"sound/instr/smpl/piano_1.wav",0
	gSmplData PcmIns_PKick,"sound/instr/smpl/wegot_kick.wav",0
	gSmplData PcmIns_PTom,"sound/instr/smpl/sauron_tom.wav",0

	gSmplData PcmIns_MoveMe_Hit,"sound/instr/smpl/moveme_hit.wav",0
	gSmplData PcmIns_MoveMe_Brass,"sound/instr/smpl/brass_moveme_m.wav",6478
	gSmplData PcmIns_Snare_moveme,"sound/instr/smpl/snare_moveme.wav",0
	gSmplData PcmIns_Kick,"sound/instr/smpl/kick_moveme.wav",0

	gSmplData PcmIns_Sauron_01,"sound/instr/smpl/sauron/01.wav",0
	gSmplData PcmIns_Sauron_02,"sound/instr/smpl/sauron/02.wav",0
	gSmplData PcmIns_Sauron_03,"sound/instr/smpl/sauron/03.wav",0
	gSmplData PcmIns_Sauron_04,"sound/instr/smpl/sauron/04.wav",0
	gSmplData PcmIns_Sauron_05,"sound/instr/smpl/sauron/05.wav",13988
	gSmplData PcmIns_Sauron_06,"sound/instr/smpl/sauron/06.wav",0
	gSmplData PcmIns_Sauron_07,"sound/instr/smpl/sauron/07.wav",0
	gSmplData PcmIns_Sauron_08,"sound/instr/smpl/sauron/08.wav",0
	gSmplData PcmIns_Sauron_09,"sound/instr/smpl/sauron/09.wav",0
	gSmplData PcmIns_Sauron_10,"sound/instr/smpl/sauron/10.wav",0
	gSmplData PcmIns_Sauron_11,"sound/instr/smpl/sauron/11.wav",0
	gSmplData PcmIns_Sauron_12,"sound/instr/smpl/sauron/12.wav",0

