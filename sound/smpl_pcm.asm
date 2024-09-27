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

	gSmplData PcmIns_Trumpet1,"sound/instr/smpl/trumpet1.wav",27625
	gSmplData PcmIns_BBoxHats,"sound/instr/smpl/hats_bbox.wav",0
	gSmplData PcmIns_Kick,"sound/instr/smpl/wegot_kick.wav",0
	gSmplData PcmIns_BBoxSnare,"sound/instr/smpl/snare_bbox.wav",0

; 	gSmplData PcmIns_trnthem_01,"sound/instr/smpl/trnthem/01.wav",12048
	gSmplData PcmIns_trnthem_02,"sound/instr/smpl/trnthem/02.wav",0
	gSmplData PcmIns_trnthem_03,"sound/instr/smpl/trnthem/03.wav",0
	gSmplData PcmIns_trnthem_04,"sound/instr/smpl/trnthem/04.wav",19996
	gSmplData PcmIns_trnthem_05,"sound/instr/smpl/trnthem/05.wav",0
	gSmplData PcmIns_trnthem_06,"sound/instr/smpl/trnthem/06.wav",0
	gSmplData PcmIns_trnthem_07,"sound/instr/smpl/trnthem/07.wav",2938
; 	gSmplData PcmIns_trnthem_08,"sound/instr/smpl/trnthem/08.wav",3875
; 	gSmplData PcmIns_trnthem_09,"sound/instr/smpl/trnthem/09.wav",4608
; 	gSmplData PcmIns_trnthem_10,"sound/instr/smpl/trnthem/10.wav",3033
; 	gSmplData PcmIns_trnthem_11,"sound/instr/smpl/trnthem/11.wav",0
; 	gSmplData PcmIns_trnthem_12,"sound/instr/smpl/trnthem/12.wav",0
; 	gSmplData PcmIns_trnthem_13,"sound/instr/smpl/trnthem/13.wav",0
; 	gSmplData PcmIns_trnthem_14,"sound/instr/smpl/trnthem/14.wav",3406
; 	gSmplData PcmIns_trnthem_15,"sound/instr/smpl/trnthem/15.wav",18276
; 	gSmplData PcmIns_trnthem_16,"sound/instr/smpl/trnthem/16.wav",13991
	gSmplData PcmIns_trnthem_20,"sound/instr/smpl/trnthem/20.wav",14309
; 	gSmplData PcmIns_trnthem_21,"sound/instr/smpl/trnthem/21.wav",24142
