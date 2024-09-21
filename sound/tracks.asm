; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona Track data
; -------------------------------------------------------------------

MainGemaSeqList:
		gemaTrk 0,2,gtrk_Test
; ----------------------------------------------------
gtrk_Test:
		gemaHead .blk,.pat,.ins,10
.blk:		binclude "sound/tracks/mirror_blk.bin"
.pat:		binclude "sound/tracks/mirror_patt.bin"
.ins:
		gInsDac +11,DacIns_Timpani,0
		gInsNull
		gInsNull
		gInsDac +22,DacIns_Snare,0
		gInsDac 0,DacIns_Kick,0
		gInsFm +12,FmIns_Hats_1
		gInsFm +12,FmIns_Hats_1
		gInsDac +11,DacIns_Kick,0
		gInsFm -24,FmIns_Bass_Groove_1
		gInsFm -12,FmIns_Trumpet_1
		gInsDac +11,DacIns_Kick,0
		gInsPsg 0,$20,$20,$00,$00,$04,0
		gInsFm -12,FmIns_Vibraphone_1
		gInsFm -12,FmIns_Flaute_1
		gInsFm +12,FmIns_Hats_1
		gInsFm -36,FmIns_Brass_7
		gInsFm -12,FmIns_Bell_mid36

; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona FM instruments
; -------------------------------------------------------------------

; -----------------------------------------------------------
; Normal FM Instruments
; -----------------------------------------------------------

FmIns_Bass_big_81:
		binclude "sound/instr/fm/bin/bass_big_82.bin"
FmIns_Bass_big_110:
		binclude "sound/instr/fm/bin/bass_big_110.bin"
FmIns_Bass_big_114:
		binclude "sound/instr/fm/bin/bass_big_114.bin"
FmIns_Bass_big_122:
		binclude "sound/instr/fm/bin/bass_big_122.bin"
FmIns_Bass_cave_47:
		binclude "sound/instr/fm/bin/bass_cave_47.bin"
FmIns_Bass_club_108:
		binclude "sound/instr/fm/bin/bass_club_108.bin"
FmIns_Bass_foot_75:
		binclude "sound/instr/fm/bin/bass_foot_75.bin"
FmIns_Bass_gem_26:
		binclude "sound/instr/fm/bin/bass_gem_26.bin"
FmIns_Bass_groove_119:
		binclude "sound/instr/fm/bin/bass_groove_119.bin"
FmIns_Bass_heavy_107:
		binclude "sound/instr/fm/bin/bass_heavy_107.bin"
FmIns_Bass_heavy_118:
		binclude "sound/instr/fm/bin/bass_heavy_118.bin"
FmIns_Bass_loud_117:
		binclude "sound/instr/fm/bin/bass_loud_117.bin"
FmIns_bass_low_46:
		binclude "sound/instr/fm/bin/bass_low_46.bin"
FmIns_Bass_Groove_1:
		binclude "sound/instr/fm/bin/bass_groove_1.bin"
FmIns_bass_low_81:
		binclude "sound/instr/fm/bin/bass_low_81.bin"
FmIns_bass_low_103:
		binclude "sound/instr/fm/bin/bass_low_103.bin"
FmIns_bass_low_106:
		binclude "sound/instr/fm/bin/bass_low_106.bin"
FmIns_bass_low_126:
		binclude "sound/instr/fm/bin/bass_low_126.bin"
FmIns_bass_mid_19:
		binclude "sound/instr/fm/bin/bass_mid_19.bin"
FmIns_bass_mid_80:
		binclude "sound/instr/fm/bin/bass_mid_80.bin"
FmIns_bass_mid_111:
		binclude "sound/instr/fm/bin/bass_mid_111.bin"
FmIns_bass_power_123:
		binclude "sound/instr/fm/bin/bass_power_123.bin"
FmIns_bass_silent_53:
		binclude "sound/instr/fm/bin/bass_silent_53.bin"
FmIns_bass_slap_10:
		binclude "sound/instr/fm/bin/bass_slap_10.bin"
FmIns_bass_slap_105:
		binclude "sound/instr/fm/bin/bass_slap_105.bin"
FmIns_bass_synth_60:
		binclude "sound/instr/fm/bin/bass_synth_60.bin"
FmIns_bass_synth_61:
		binclude "sound/instr/fm/bin/bass_synth_61.bin"
FmIns_bass_synth_72:
		binclude "sound/instr/fm/bin/bass_synth_72.bin"
FmIns_bass_synth_73:
		binclude "sound/instr/fm/bin/bass_synth_73.bin"
FmIns_bass_vlow_74:
		binclude "sound/instr/fm/bin/bass_vlow_74.bin"

FmIns_Organ_drawbar:
		binclude "sound/instr/fm/bin/organ_drawbar.bin"
FmIns_Flaute_1:
		binclude "sound/instr/fm/bin/flaute_1.bin"
FmIns_Vibraphone_1:
		binclude "sound/instr/fm/bin/vibraphone_1.bin"
FmIns_Vibraphone_2:
		binclude "sound/instr/fm/bin/vibraphone_2.bin"
FmIns_Xylophone:
		binclude "sound/instr/fm/bin/xylophone2_43.bin"

FmIns_Bass_low81:
		binclude "sound/instr/fm/bin/bass_low_46.bin"
FmIns_Trumpet_15:
		binclude "sound/instr/fm/bin/trumpet_27.bin"

FmIns_Hats_1:
		binclude "sound/instr/fm/bin/hats_96.bin"

FmIns_Bell_mid36:
		binclude "sound/instr/fm/bin/bell_mid_36.bin"

; -----------------------------------------------------------
; Special FM3 Instruments
; -----------------------------------------------------------

FmSpIns_clack_1:
		binclude "sound/instr/fm/bin/fm3_clack_1.bin"
FmSpIns_cowbell_h:
		binclude "sound/instr/fm/bin/fm3_cowbell_h.bin"
FmSpIns_cowbell_l:
		binclude "sound/instr/fm/bin/fm3_cowbell_l.bin"
FmSpIns_hats_hq:
		binclude "sound/instr/fm/bin/fm3_hats_hq.bin"
FmSpIns_sfx_alien:
		binclude "sound/instr/fm/bin/fm3_sfx_alien.bin"
FmSpIns_sfx_knckbuzz:
		binclude "sound/instr/fm/bin/fm3_sfx_knckbuzz.bin"
FmSpIns_sfx_knock_h:
		binclude "sound/instr/fm/bin/fm3_sfx_knock_h.bin"
FmSpIns_sfx_knock_l:
		binclude "sound/instr/fm/bin/fm3_sfx_knock_l.bin"
FmSpIns_sfx_laser:
		binclude "sound/instr/fm/bin/fm3_sfx_laser.bin"

; ====================================================================

; FM3 Special
FmIns_Sp_OpenHat:
		binclude "sound/instr/fm/gsx/fm3_openhat.gsx",$2478,$28
FmIns_Sp_ClosedHat:
		binclude "sound/instr/fm/gsx/fm3_closedhat.gsx",$2478,$28
FmIns_Sp_Cowbell:
		binclude "sound/instr/fm/gsx/fm3_cowbell.gsx",$2478,$28
FmIns_Drums_Kick1:
		binclude "sound/instr/fm/gsx/drum_kick_gem.gsx",$2478,$20
FmIns_Piano_Aqua:
		binclude "sound/instr/fm/gsx/piano_aqua.gsx",$2478,$20
FmIns_HBeat_tom:
		binclude "sound/instr/fm/gsx/nadia_tom.gsx",$2478,$20
FmIns_Trumpet_1:
		binclude "sound/instr/fm/gsx/trumpet_1.gsx",$2478,$20
FmIns_Bass_duck:
		binclude "sound/instr/fm/gsx/bass_duck.gsx",$2478,$20
FmIns_ClosedHat:
		binclude "sound/instr/fm/gsx/hats_closed.gsx",$2478,$20
FmIns_Trumpet_carnival:
		binclude "sound/instr/fm/gsx/OLD_trumpet_carnivl.gsx",$2478,$20
FmIns_Bass_club:
		binclude "sound/instr/fm/gsx/OLD_bass_club.gsx",$2478,$20
FmIns_Bass_groove_2:
		binclude "sound/instr/fm/gsx/bass_groove_2.gsx",$2478,$20
FmIns_PSynth_plus:
		binclude "sound/instr/fm/gsx/psynth_plus.gsx",$2478,$20

FmIns_Brass_7:
		binclude "sound/instr/fm/gsx/brass_7.gsx",$2478,$20

; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona DAC samples
;
; 16000hz base
; -------------------------------------------------------------------

		gSmplData DacIns_Arena_01,"sound/instr/smpl/arena_01.wav",0
		gSmplData DacIns_Arena_02,"sound/instr/smpl/arena_02.wav",0
		gSmplData DacIns_Arena_03,"sound/instr/smpl/arena_03.wav",0
		gSmplData DacIns_Kick,"sound/instr/smpl/kick.wav",0
		gSmplData DacIns_Snare,"sound/instr/smpl/snare.wav",0
		gSmplData DacIns_Timpani,"sound/instr/smpl/timpani.wav",0
		gSmplData DacIns_wegot_kick,"sound/instr/smpl/wegot_kick.wav",0
		gSmplData DacIns_wegot_crash,"sound/instr/smpl/wegot_crash.wav",0
