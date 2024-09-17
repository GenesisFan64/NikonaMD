; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona FM instruments "patches"
;
; PSG, PCM and PWM's are stored separately.
; -------------------------------------------------------------------

; ----------------------------------------------------
; INTRUMENT/PATCH FORMAT:
; dc.b $30,$34,$38,$3C	; Your FM registers following this order
; dc.b $40,$44,$48,$4C	; **
; dc.b $50,$54,$58,$5C	; **
; dc.b $60,$64,$68,$6C	; **
; dc.b $70,$74,$78,$7C	; **
; dc.b $80,$84,$88,$8C	; **
; dc.b $90,$94,$98,$9C	; **
; dc.b $B0,$B4,$22,$28	; **
; dc.w OP1,OP2,OP3,OP4	; OPTIONAL: Manual FM3 frequencies
;
; Notes:
; SSG-EG CAN be used, but can get problematic on non-genuine systems.
;
; $B4 - AMS/PMS: %00aa0ppp
; a | AMS
; p | PMS
; Keep panning bits 0, set the panning manually in your track.
;
; $22 - LFO: %0000evvv
; e | Enable
; v | Value
; This is a global setting, this will affect ALL sound.
;
; $28 - KEYS: %oooo0000
; o | Operators 4-1
;
; For making your own FM patches:
; Run FM_EDITOR.bin on an emulator and
; save your patch as a savestate, include your
; instrument like this:
; binclude "sound/instr/fm/organ2.gsx",$2478,SIZE
;
; SIZE:
; Normal FM ins:  $20
; Special FM ins: $28
; ----------------------------------------------------

; FM3 Special
FmIns_Sp_OpenHat:
		binclude "sound/instr/fm/gsx/fm3_openhat.gsx",$2478,$28
FmIns_Sp_ClosedHat:
		binclude "sound/instr/fm/gsx/fm3_closedhat.gsx",$2478,$28
FmIns_Sp_Cowbell:
		binclude "sound/instr/fm/gsx/fm3_cowbell.gsx",$2478,$28

; ----------------------------------------------------

FmIns_Drums_Kick1:
		binclude "sound/instr/fm/gsx/drum_kick_gem.gsx",$2478,$20
FmIns_Piano_Aqua:
		binclude "sound/instr/fm/gsx/piano_aqua.gsx",$2478,$20
FmIns_HBeat_tom:
		binclude "sound/instr/fm/gsx/nadia_tom.gsx",$2478,$20
FmIns_Trumpet_1:
		binclude "sound/instr/fm/gsx/trumpet_1.gsx",$2478,$20

; ----------------------------------------------------

FmIns_Bass_duck:
		binclude "sound/instr/fm/gsx/bass_duck.gsx",$2478,$20
FmIns_ClosedHat:
		binclude "sound/instr/fm/gsx/hats_closed.gsx",$2478,$20
FmIns_Trumpet_carnival:
		binclude "sound/instr/fm/gsx/OLD_trumpet_carnivl.gsx",$2478,$20


; ====================================================================

FmIns_Bass_club:
		binclude "sound/instr/fm/gsx/OLD_bass_club.gsx",$2478,$20
FmIns_Bass_groove_2:
		binclude "sound/instr/fm/gsx/bass_groove_2.gsx",$2478,$20
FmIns_PSynth_plus:
		binclude "sound/instr/fm/gsx/psynth_plus.gsx",$2478,$20

; ----------------------------------------------------
; NEW

FmIns_Organ_drawbar:
		binclude "sound/instr/fm/organ_drawbar.bin"
FmIns_Flaute_1:
		binclude "sound/instr/fm/flaute_1.bin"
FmIns_Vibraphone_1:
		binclude "sound/instr/fm/vibraphone_1.bin"
FmIns_Bass_low81:
		binclude "sound/instr/fm/bass_low_46.bin"
FmIns_Trumpet_15:
		binclude "sound/instr/fm/trumpet_27.bin"
FmIns_Bass_Groove_1:
		binclude "sound/instr/fm/bass_low_78.bin"
FmIns_Hats_1:
		binclude "sound/instr/fm/hats_96.bin"

; ----------------------------------------------------

; FmIns_Test_00:	binclude "sound/instr/fm/trombone_12.bin"
; FmIns_Test_01:	binclude "sound/instr/fm/trombone_27.bin"
; FmIns_Test_02:	binclude "sound/instr/fm/trombone_51.bin"
; FmIns_Test_03:	binclude "sound/instr/fm/trombone_58.bin"
; FmIns_Test_04:	binclude "sound/instr/fm/trumpet_15.bin"
; FmIns_Test_05:	binclude "sound/instr/fm/trumpet_16.bin"
; FmIns_Test_06:	binclude "sound/instr/fm/trumpet_57.bin"
