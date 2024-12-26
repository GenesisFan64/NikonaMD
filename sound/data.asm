; ===========================================================================
; -------------------------------------------------------------------
; Main sound data
; -------------------------------------------------------------------

MainGemaSeqList:
	gemaTrk 1,3,gtrk_Test0
	gemaTrk 0,6,gtrk_Test0	; $0F
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,3,gtrk_Test0
	gemaTrk 1,3,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0	; $08
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 1,6,gtrk_Test0
	gemaTrk 0,6,gtrk_Test0	; $0F

; ----------------------------------------------------
gtrk_Test0:
	gemaHead .blk,.pat,.ins,10
.blk:	binclude "sound/seq/axe_blk.bin"
.pat:	binclude "sound/seq/axe_patt.bin"
.ins:
	gInsFm 0,FmIns_Vibraphone_1
	gInsFm 0,FmIns_Organ_drawbar
	gInsFm -12,FmIns_Bass_Groove_1
	gInsFm +12,FmIns_bass_italo
	gInsDac 0,DacIns_conga,0
	gInsDac 0,DacIns_conga_low,0
	gInsDac -12,DacIns_clap,0
	gInsFm 0,FmIns_Flaute_1
	gInsFm 0,FmIns_Hats_1
	gInsDac +24,DacIns_Kick_Strong,0
	gInsDac +12,DacIns_Snare,0
	gInsNull
	gInsPsg 0,$00,$00,$00,$00,$02,$00
	gInsNull
	gInsNull
	gInsNull
	gInsNull
	gInsNull
	gInsNull

; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona FM instruments
; -------------------------------------------------------------------

; -----------------------------------------------------------
; Normal FM Instruments
; -----------------------------------------------------------

FmIns_Bass_big_81:
		binclude "sound/ins/fm/bin/bass_big_82.bin"
FmIns_Bass_big_110:
		binclude "sound/ins/fm/bin/bass_big_110.bin"
FmIns_Bass_big_114:
		binclude "sound/ins/fm/bin/bass_big_114.bin"
FmIns_Bass_big_122:
		binclude "sound/ins/fm/bin/bass_big_122.bin"
FmIns_Bass_cave_47:
		binclude "sound/ins/fm/bin/bass_cave_47.bin"
FmIns_Bass_club_108:
		binclude "sound/ins/fm/bin/bass_club_108.bin"
FmIns_Bass_foot_75:
		binclude "sound/ins/fm/bin/bass_foot_75.bin"
FmIns_Bass_gem_26:
		binclude "sound/ins/fm/bin/bass_gem_26.bin"
FmIns_Bass_groove_119:
		binclude "sound/ins/fm/bin/bass_groove_119.bin"
FmIns_Bass_heavy_107:
		binclude "sound/ins/fm/bin/bass_heavy_107.bin"
FmIns_Bass_heavy_118:
		binclude "sound/ins/fm/bin/bass_heavy_118.bin"
FmIns_Bass_loud_117:
		binclude "sound/ins/fm/bin/bass_loud_117.bin"
FmIns_bass_low_46:
		binclude "sound/ins/fm/bin/bass_low_46.bin"
FmIns_Bass_Groove_1:
		binclude "sound/ins/fm/bin/bass_groove_1.bin"
FmIns_bass_low_81:
		binclude "sound/ins/fm/bin/bass_low_81.bin"
FmIns_bass_low_103:
		binclude "sound/ins/fm/bin/bass_low_103.bin"
FmIns_bass_low_106:
		binclude "sound/ins/fm/bin/bass_low_106.bin"
FmIns_bass_low_126:
		binclude "sound/ins/fm/bin/bass_low_126.bin"
FmIns_bass_mid_19:
		binclude "sound/ins/fm/bin/bass_mid_19.bin"
FmIns_bass_mid_80:
		binclude "sound/ins/fm/bin/bass_mid_80.bin"
FmIns_bass_mid_111:
		binclude "sound/ins/fm/bin/bass_mid_111.bin"
FmIns_bass_power_123:
		binclude "sound/ins/fm/bin/bass_power_123.bin"
FmIns_bass_silent_53:
		binclude "sound/ins/fm/bin/bass_silent_53.bin"
FmIns_bass_slap_10:
		binclude "sound/ins/fm/bin/bass_slap_10.bin"
FmIns_bass_slap_105:
		binclude "sound/ins/fm/bin/bass_slap_105.bin"
FmIns_bass_synth_60:
		binclude "sound/ins/fm/bin/bass_synth_60.bin"
FmIns_bass_synth_61:
		binclude "sound/ins/fm/bin/bass_synth_61.bin"
FmIns_bass_synth_72:
		binclude "sound/ins/fm/bin/bass_synth_72.bin"
FmIns_bass_synth_73:
		binclude "sound/ins/fm/bin/bass_synth_73.bin"
FmIns_bass_vlow_74:
		binclude "sound/ins/fm/bin/bass_vlow_74.bin"
FmIns_Organ_drawbar:
		binclude "sound/ins/fm/bin/organ_drawbar.bin"
FmIns_Flaute_1:
		binclude "sound/ins/fm/bin/flaute_1.bin"
FmIns_Flaute_2:
		binclude "sound/ins/fm/bin/flaute_2.bin"
FmIns_Vibraphone_1:
		binclude "sound/ins/fm/bin/vibraphone_1.bin"
FmIns_Vibraphone_2:
		binclude "sound/ins/fm/bin/vibraphone_2.bin"
FmIns_Xylophone:
		binclude "sound/ins/fm/bin/xylophone2_43.bin"
FmIns_Bass_low81:
		binclude "sound/ins/fm/bin/bass_low_46.bin"
FmIns_Trumpet_low:
		binclude "sound/ins/fm/bin/trumpet_low.bin"
FmIns_Trumpet_genie:
		binclude "sound/ins/fm/bin/trumpet_genie.bin"
FmIns_Trumpet_bus:
		binclude "sound/ins/fm/bin/trumpet_bus.bin"
FmIns_Hats_1:
		binclude "sound/ins/fm/bin/hats_96.bin"
FmIns_Bell_mid36:
		binclude "sound/ins/fm/bin/bell_mid_36.bin"
FmIns_Bell_62:
		binclude "sound/ins/fm/bin/bell_62.bin"
FmIns_Bell_93:
		binclude "sound/ins/fm/bin/bell_93.bin"
FmIns_Bell_low13:
		binclude "sound/ins/fm/bin/bell_low_13.bin"

FmIns_Drum_Kick:
		binclude "sound/ins/fm/bin/kick_low.bin"
FmIns_Tick:
		binclude "sound/ins/fm/bin/tick_44.bin"

; -----------------------------------------------------------
; Special FM3 Instruments
; -----------------------------------------------------------

FmSpIns_clack_1:
		binclude "sound/ins/fm/bin/fm3_clack_1.bin"
FmSpIns_cowbell_h:
		binclude "sound/ins/fm/bin/fm3_cowbell_h.bin"
FmSpIns_cowbell_l:
		binclude "sound/ins/fm/bin/fm3_cowbell_l.bin"
FmSpIns_hats_hq:
		binclude "sound/ins/fm/bin/fm3_hats_hq.bin"
FmSpIns_sfx_alien:
		binclude "sound/ins/fm/bin/fm3_sfx_alien.bin"
FmSpIns_sfx_knckbuzz:
		binclude "sound/ins/fm/bin/fm3_sfx_knckbuzz.bin"
FmSpIns_sfx_knock_h:
		binclude "sound/ins/fm/bin/fm3_sfx_knock_h.bin"
FmSpIns_sfx_knock_l:
		binclude "sound/ins/fm/bin/fm3_sfx_knock_l.bin"
FmSpIns_sfx_laser:
		binclude "sound/ins/fm/bin/fm3_sfx_laser.bin"

; -----------------------------------------------------------
; FM sound effects
; -----------------------------------------------------------

FmIns_sfx_punch:
		binclude "sound/ins/fm/bin/sfx_punch.bin"
FmIns_sfx_explode:
		binclude "sound/ins/fm/bin/sfx_explode.bin"
FmIns_sfx_slash:
		binclude "sound/ins/fm/bin/sfx_slash.bin"
FmIns_sfx_alien1:
		binclude "sound/ins/fm/bin/sfx_alien_83.bin"
FmIns_sfx_alien2:
		binclude "sound/ins/fm/bin/sfx_alien_84.bin"

; ====================================================================

; FM3 Special
FmIns_Sp_OpenHat:
		binclude "sound/ins/fm/gsx/fm3_openhat.gsx",$2478,$28
FmIns_Sp_ClosedHat:
		binclude "sound/ins/fm/gsx/fm3_closedhat.gsx",$2478,$28
FmIns_Sp_Cowbell:
		binclude "sound/ins/fm/gsx/fm3_cowbell.gsx",$2478,$28
FmIns_Drums_Kick1:
		binclude "sound/ins/fm/gsx/drum_kick_gem.gsx",$2478,$20
FmIns_Piano_Aqua:
		binclude "sound/ins/fm/gsx/piano_aqua.gsx",$2478,$20
FmIns_HBeat_tom:
		binclude "sound/ins/fm/gsx/nadia_tom.gsx",$2478,$20
FmIns_Trumpet_1:
		binclude "sound/ins/fm/gsx/trumpet_1.gsx",$2478,$20
FmIns_Bass_duck:
		binclude "sound/ins/fm/gsx/bass_duck.gsx",$2478,$20
FmIns_ClosedHat:
		binclude "sound/ins/fm/gsx/hats_closed.gsx",$2478,$20
FmIns_Trumpet_carnival:
		binclude "sound/ins/fm/gsx/OLD_trumpet_carnivl.gsx",$2478,$20
FmIns_Bass_club:
		binclude "sound/ins/fm/gsx/OLD_bass_club.gsx",$2478,$20
FmIns_Bass_groove_2:
		binclude "sound/ins/fm/gsx/bass_groove_2.gsx",$2478,$20
FmIns_PSynth_plus:
		binclude "sound/ins/fm/gsx/psynth_plus.gsx",$2478,$20
FmIns_Brass_7:
		binclude "sound/ins/fm/gsx/brass_7.gsx",$2478,$20

FmIns_sfx_punch_2:
		binclude "sound/ins/fm/gsx/fmsfx_punch.gsx",$2478,$20
FmIns_sfx_smash:
		binclude "sound/ins/fm/gsx/fmsfx_smash.gsx",$2478,$20

FmIns_bass_italo:
		binclude "sound/ins/fm/gsx/bass_italo.gsx",$2478,$20
FmIns_Guitar_bball:
		binclude "sound/ins/fm/gsx/guitar_bball.gsx",$2478,$20

; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona DAC samples
;
; 16000hz base
; -------------------------------------------------------------------

		align $800
		;gSmplData Label,"file_path",loop_start
		gSmplData DacIns_clap,"sound/ins/smpl/clap.wav",0
		gSmplData DacIns_conga,"sound/ins/smpl/conga.wav",0
		gSmplData DacIns_conga_low,"sound/ins/smpl/conga_low.wav",0
		gSmplData DacIns_Kick_Strong,"sound/ins/smpl/kick_strong.wav",0
		gSmplData DacIns_Snare,"sound/ins/smpl/snare.wav",0
; 		gSmplData DacIns_Kick_2,"sound/ins/smpl/kick_2.wav",0
; 		gSmplData DacIns_Snare_2,"sound/ins/smpl/snare_2.wav",0
; 		gSmplData DacIns_Timpani,"sound/ins/smpl/timpani.wav",0
; 		gSmplData DacIns_wegot_kick,"sound/ins/smpl/wegot_kick.wav",0
; 		gSmplData DacIns_wegot_crash,"sound/ins/smpl/wegot_crash.wav",0
