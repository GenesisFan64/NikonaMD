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


; 	gSmplData PcmIns_Sauron_01,"sound/instr/smpl/sauron/01.wav",0
; 	gSmplData PcmIns_Sauron_02,"sound/instr/smpl/sauron/02.wav",0
; 	gSmplData PcmIns_Sauron_03,"sound/instr/smpl/sauron/03.wav",0
; 	gSmplData PcmIns_Sauron_04,"sound/instr/smpl/sauron/04.wav",0
; 	gSmplData PcmIns_Sauron_05,"sound/instr/smpl/sauron/05.wav",13988
; 	gSmplData PcmIns_Sauron_06,"sound/instr/smpl/sauron/06.wav",0
; 	gSmplData PcmIns_Sauron_07,"sound/instr/smpl/sauron/07.wav",0
; 	gSmplData PcmIns_Sauron_08,"sound/instr/smpl/sauron/08.wav",0
; 	gSmplData PcmIns_Sauron_09,"sound/instr/smpl/sauron/09.wav",0
; 	gSmplData PcmIns_Sauron_10,"sound/instr/smpl/sauron/10.wav",0
; 	gSmplData PcmIns_Sauron_11,"sound/instr/smpl/sauron/11.wav",0
; 	gSmplData PcmIns_Sauron_12,"sound/instr/smpl/sauron/12.wav",0

