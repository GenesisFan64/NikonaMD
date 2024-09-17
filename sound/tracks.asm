; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona DEFAULT sound-track data
;
; Soundtrack data can be stored on ROM, RAM* and Word-RAM**
;
;  * Requires calling Sound_Update manually to send the data
;    as a workaround for the Z80 bankswitch limitation.
; ** Make sure the Word-RAM permission is set to MAIN-CPU.
;
; This tracklist is stored on:
; ROM      on Genesis/32X($880000)
; WORD-RAM on SegaCD/CD32X
;
; This data will be unavilable if using SegaCD's stamps, relocate
; the entire data manually.
; -------------------------------------------------------------------

; ------------------------------------------------------------
; Setup:
; 	gemaList LABEL_TRACKLIST
; 	gemaTrk option,ticks,location
;	; more tracks here
;
; option: 0 - Don't use global subbeats
;         1 - Use global subbeats (SET externally)
; ticks:  Ticks number on a fixed tempo:
;         150 on NTSC or 125 on PAL
;         To change the tempo set "option" to 1,
;         and set your sub-beats externally.
;
; To change your "master list" use:
; 	move.l	#Gema_DefaultList,d0
; 	bsr	gemaSetMasterList
; This will be needed if using the SegaCD's Stamps.
;
; To use sub-beats:
; 	move.w	#beats_num,d0
; 	bsr	gemaSetBeats
; 	move.w  #slot_id,d0
; 	move.w	#sequence_id,d1
; 	move.w  #start_block,d2
;	bsr	gemaPlayTrack
; * This change will affect ALL tracks with the same
;   sub-beats flag enabled *
; ------------------------------------------------------------

		gemaList MainGemaSeqList
		gemaTrk 0,3,gtrk_Test
		gemaTrk 0,2,gtrk_Test2
		gemaTrk 0,3,gtrk_Gigalo
		gemaTrk 0,3,gtrk_Temple
		gemaTrk 0,3,gtrk_Brinstr

		gemaTrk 1,3,gtrk_wegot
		gemaTrk 1,5,gtrk_MOVEME
		gemaTrk 0,7,gtrk_MOVEME
		gemaTrk 0,7,gtrk_MOVEME

		gemaTrk 1,6,gtrk_sauron
; 		gemaTrk 1,5,gtrk_NadieMd
; 		gemaTrk 1,5,gtrk_NadieCd
; 		gemaTrk 1,5,gtrk_NadieMars

; ----------------------------------------------------

gtrk_Test:
		gemaHead .blk,.pat,.ins,10
.blk:		binclude "sound/tracks/chill_blk.bin"
.pat:		binclude "sound/tracks/chill_patt.bin"
.ins:
		gInsFm -12,FmIns_Vibraphone_1
		gInsDac -36,DacIns_Kick,0
		gInsDac +22,DacIns_Snare,0
		gInsFm -12,FmIns_Trumpet_1
		gInsFm -12,FmIns_Bass_Groove_1
		gInsPsgN 0,$00,$00,$00,$00,$40,0,%101
		gInsPsgN 0,$00,$00,$00,$00,$40,0,%100
		gInsNull
		gInsNull
		gInsPsgN 0,$10,$20,$00,$00,$40,0,%100
		gInsFm 0,FmIns_Trumpet_15
		gInsPsg 0,$20,$20,$00,$00,$01,0
		gInsNull

; ----------------------------------------------------

gtrk_Test2:
		gemaHead .blk,.pat,.ins,10
.blk:		binclude "sound/tracks/mirror_blk.bin"
.pat:		binclude "sound/tracks/mirror_patt.bin"
.ins:
		gInsDac +11,DacIns_Timpani,0
		gInsNull
		gInsNull
		gInsDac +22,DacIns_Snare,0
		gInsDac 0,DacIns_Kick,0
		gInsFm +12,FmIns_Hats_1;PsgN 0,$10,$20,$00,$00,$18,0,%100
		gInsFm +12,FmIns_Hats_1;gInsPsgN 0,$10,$20,$00,$00,$18,0,%100
		gInsDac +11,DacIns_Kick,0
		gInsFm -24,FmIns_Bass_Groove_1

		gInsFm -12,FmIns_Trumpet_1
		gInsNull
		gInsPsg 0,$20,$20,$00,$00,$01,0
		gInsFm -12,FmIns_Vibraphone_1
		gInsFm -12,FmIns_Flaute_1
		gInsNull
		gInsFm -24,FmIns_Trumpet_15
		gInsNull
		gInsNull
		gInsNull

		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull
		gInsNull

; 		gInsFm -24,FmIns_Test_00
; 		gInsFm -24,FmIns_Test_01
; 		gInsFm -24,FmIns_Test_02
; 		gInsFm -24,FmIns_Test_03
; 		gInsFm -24,FmIns_Test_04
; 		gInsFm -24,FmIns_Test_05
; 		gInsFm -24,FmIns_Test_06

; 		gInsPsg 0,$00,$00,$00,$00,$04,0
; 		gInsPsgN 0,$00,$00,$00,$00,$04,0,%111
; 		gInsFm 0,FmIns_Trumpet_1
; 		gInsFm3 0,FmIns_Sp_OpenHat
; 		gInsDac 0,DacIns_TEST,0
; 		gInsPcm 0,PcmIns_TEST,0
; 		gInsPwm 0,PwmIns_TEST,%10

; ----------------------------------------------------

gtrk_Gigalo:
		gemaHead .blk,.pat,.ins,4
.blk:		binclude "sound/tracks/gigalo_blk.bin"
.pat:		binclude "sound/tracks/gigalo_patt.bin"
.ins:
		gInsPsg 0,$00,$00,$00,$00,$09,0
		gInsPsgN 0,$00,$00,$00,$00,$09,0,%100
		gInsPsgN 0,$00,$00,$00,$00,$09,0,%101
		gInsPsgN 0,$00,$00,$00,$00,$09,0,%110

; ----------------------------------------------------

gtrk_Temple:
		gemaHead .blk,.pat,.ins,4
.blk:		binclude "sound/tracks/temple_blk.bin"
.pat:		binclude "sound/tracks/temple_patt.bin"
.ins:
		gInsPsg 0,$00,$00,$00,$00,$04,0
		gInsPsg 0,$00,$00,$00,$00,$04,0
		gInsPsgN 0,$00,$00,$00,$00,$18,0,%101

; ----------------------------------------------------

gtrk_Brinstr:
		gemaHead .blk,.pat,.ins,4
.blk:		binclude "sound/tracks/brinstr_blk.bin"
.pat:		binclude "sound/tracks/brinstr_patt.bin"
.ins:
		gInsPsg 0,$00,$00,$00,$00,$02,0
		gInsPsgN -12,$00,$00,$00,$00,$01,0,%011

; ----------------------------------------------------

gtrk_wegot:
		gemaHead .blk,.pat,.ins,8
.blk:		binclude "sound/tracks/wegot_blk.bin"
		align 2
.pat:		binclude "sound/tracks/wegot_patt.bin"
		align 2
.ins:
		gInsFm 0,FmIns_PSynth_plus
		gInsFm 0,FmIns_Bass_groove_2
		gInsDac 0,DacIns_wegot_kick,0
		gInsFm 0,FmIns_Bass_club
		gInsFm3 0,FmIns_Sp_OpenHat
		gInsPsg 0,$20,$40,$10,$01,$04,0
		gInsDac 0,DacIns_wegot_crash,0
		gInsPsgN 0,$00,$00,$00,$00,$10,0,%100
		gInsNull
		gInsNull

; ----------------------------------------------------

gtrk_MOVEME:
		gemaHead .blk,.pat,.ins,11
.blk:
		binclude "sound/tracks/moveme_blk.bin"
		align 2
.pat:
		binclude "sound/tracks/moveme_patt.bin"
		align 2
.ins:
		gInsPcm 0,PcmIns_MoveMe_Hit,%10
		gInsFm 0,FmIns_Bass_Duck
		gInsPcm 0,PcmIns_MoveMe_Brass,%11
		gInsFm 0,FmIns_ClosedHat
		gInsPsgN 0,$00,$00,$00,$00,$04,0,%110
		gInsFm -12,FmIns_HBeat_tom
		gInsPcm 0,PcmIns_Snare_moveme,%10
		gInsPcm 0,PcmIns_Kick,%10
		gInsFm -12,FmIns_Trumpet_carnival
		gInsPsg 0,$20,$20,$10,$01,$08,0
		gInsFm3 0,FmIns_Sp_OpenHat
		gInsPsg +12,$20,$10,$10,$0C,$0C,0
		gInsPsg 0,$00,$00,$00,$00,$06,0

; ----------------------------------------------------

gtrk_sauron:
		gemaHead .blk,.pat,.ins,5
.blk:
		binclude "sound/tracks/sauron_blk.bin"
		align 2
.pat:
		binclude "sound/tracks/sauron_patt.bin"
		align 2
.ins:
		gInsPcm -12,PcmIns_Sauron_01,0
		gInsPcm -12,PcmIns_Sauron_02,0
		gInsPcm -12,PcmIns_Sauron_03,0
		gInsPcm -12,PcmIns_Sauron_04,0
		gInsPcm -12,PcmIns_Sauron_05,1
		gInsPcm -12,PcmIns_Sauron_06,0
		gInsPcm -12,PcmIns_Sauron_07,0
		gInsPcm -12,PcmIns_Sauron_08,0
		gInsPcm -12,PcmIns_Sauron_09,0
		gInsPcm -12,PcmIns_Sauron_10,0
		gInsPcm -12,PcmIns_Sauron_11,0
		gInsPcm -12,PcmIns_Sauron_12,0

; ; ----------------------------------------------------
;
; gtrk_NadieMars:
; 		gemaHead .blk,.pat,.ins,11
; .blk:
; 		binclude "sound/tracks/nadie_blk.bin"
; .pat:
; 		binclude "sound/tracks/nadie_patt.bin"
; .ins:
; 	if MARS
; 		gInsPwm 0,PwmIns_Nadie,%10	 ; <-- %10 stereo, no loop
; 		gInsFm -36,FmIns_Piano_Aqua
; 		gInsFm -12,FmIns_HBeat_tom
; 		gInsPwm -5,PwmIns_PKick,%00
; 		gInsPsg 0,$30,$20,$00,$02,$04,0
; 		gInsFm 0,FmIns_Trumpet_1
; 		gInsPwm 0,PwmIns_Piano,%00
; 		gInsPwm -12,PwmIns_PTom,%00
; 		gInsNull
; 	else
; 		gInsNull;gInsPwm 0,PwmIns_Nadie,%10
; 		gInsNull;gInsFm -36,FmIns_Piano_Aqua
; 		gInsNull;gInsFm -12,FmIns_HBeat_tom
; 		gInsNull;gInsPwm -12,PwmIns_PKick,%00
; 		gInsNull;gInsPsg 0,$40,$60,$10,$08,$0A,0
; 		gInsNull;gInsFm 0,FmIns_Trumpet_1
; 		gInsNull;gInsPwm 0,PwmIns_Piano,%00
; 		gInsNull;gInsPwm -12,PwmIns_PTom,%00
; 		gInsNull
; 	endif
;
; ; ----------------------------------------------------
;
; gtrk_NadieCd:
; 		gemaHead .blk,.pat,.ins,11
; .blk:
; 		binclude "sound/tracks/nadie_cd_blk.bin"
; .pat:
; 		binclude "sound/tracks/nadie_cd_patt.bin"
; .ins:
; 	if MCD|MARSCD
; 		gInsPcm 0,PcmIns_Nadie_L,0
; 		gInsFm -36,FmIns_Piano_Aqua
; 		gInsFm -12,FmIns_HBeat_tom
; 		gInsPcm -5,PcmIns_PKick,%00
; 		gInsPsg 0,$30,$20,$00,$02,$04,0
; 		gInsFm 0,FmIns_Trumpet_1
; 		gInsPcm 0,PcmIns_Piano,%00
; 		gInsPcm -12,PcmIns_PTom,%00
; 		gInsNull
; 		gInsPcm 0,PcmIns_Nadie_R,0
; 	else
; 		gInsNull;gInsPwm 0,PwmIns_Nadie,%10
; 		gInsNull;gInsFm -36,FmIns_Piano_Aqua
; 		gInsNull;gInsFm -12,FmIns_HBeat_tom
; 		gInsNull;gInsPwm -12,PwmIns_PKick,%00
; 		gInsNull;gInsPsg 0,$40,$60,$10,$08,$0A,0
; 		gInsNull;gInsFm 0,FmIns_Trumpet_1
; 		gInsNull;gInsPwm 0,PwmIns_Piano,%00
; 		gInsNull;gInsPwm -12,PwmIns_PTom,%00
; 		gInsNull
; 	endif
;
; ; ----------------------------------------------------
;
; gtrk_NadieMd:
; 		gemaHead .blk,.pat,.ins,7
; .blk:
; 		binclude "sound/tracks/nadie_md_blk.bin"
; .pat:
; 		binclude "sound/tracks/nadie_md_patt.bin"
; .ins:
; 		gInsDac 0,DacIns_Nadie,0
; 		gInsFm -36,FmIns_Piano_Aqua
; 		gInsFm -12,FmIns_HBeat_tom
; 		gInsFm -36,FmIns_Drums_Kick1
; 		gInsPsg 0,$30,$20,$00,$02,$04,0
; 		gInsFm 0,FmIns_Trumpet_1
; 		gInsNull
; 		gInsNull
; 		gInsNull
