; ===========================================================================
; -------------------------------------------------------------------
; GEMA/Nikona Sound Driver v1.0
; by GenesisFan64 2023-2024
;
; Features:
; - Support for SEGA CD's PCM channels:
;   | All 8 channels with streaming support
;   | for larger samples.
;
; - Support for 32X's PWM:
;   | 7 pseudo-channels in either MONO
;   | or STEREO.
;
; - WAVE playback at 16000hz (base) for
;   | all sample-based channels:
;   | DAC, PCM and PWM
;
; - DMA ROM protection for DAC
;   | This keeps the wave playback in a
;   | decent quality while doing any DMA
;   | task in the 68k side.
; - FM special mode with custom frequencies
; - Autodetection for the PSG's Tone3 mode
;
; * Notes:
; This driver uses the area $FFFF00-$FFFFFF
; The Z80 writes a flag directly to RAM for
; a workaround to bypass a data-reading
; hardware limitation. (see Sound_Update)
;
; CURRENTLY THIS CAN ONLY BE USED HERE IN NikonaSDK
; BECAUSE OF CROSS-REFERENCING LABELS BETWEEN THE
; Z80 and 68K.
; -------------------------------------------------------------------

; ------------------------------------------------------------
; MACROS
; ------------------------------------------------------------

; ----------------------------------------------------
; gSmplData - Include .WAV sample data, applies to
;             DAC, PCM* and PWM
;
;             * No need to convert data, Sub-CPU
;             converts the data manually.
;
; labl | 24-bit Pointer, depending of the
;        current CPU
; file | File path for the WAV sample file
; loop | Loop start point if sample loop is enabled
;        Set to 0 if not using loop.
; ----------------------------------------------------

gSmplData macro labl,file,loop
	if MARS|MARSCD		; <-- label align for 32X
		align 4
	endif
labl	label *
	dc.b ((labl_e-labl_s)&$FF),(((labl_e-labl_s)>>8)&$FF),(((labl_e-labl_s)>>16)&$FF)
	dc.b ((loop)&$FF),(((loop)>>8)&$FF),(((loop)>>16)&$FF)
labl_s:
	binclude file,$2C
labl_e:
	if MARS|MARSCD		; <-- label align for 32X
		align 4
	endif
	endm

; ----------------------------------------------------
; gemaList - Make a tracklist label
; ----------------------------------------------------

gemaList macro thislbl
	align 2
thislbl	label *
GLBL_GEMABASE := *
	endm

; ----------------------------------------------------
; gemaTrk - Sequence entry on Gema_MasterList
;
; enblt | Disable/Enable global beats on this Sequence
;         0 - Don't Use beats, 1 - Use beats
; ticks | Ticks (Default tempo: 150-NTSC 120-PAL)
;   loc | Direct location of the sequence data
; ----------------------------------------------------

gemaTrk macro enbltp,ticks,loc
	dc.l ((enbltp&$01)<<31)|((ticks&$7F)<<24)|(loc&$FFFFFF)
	endm

; ----------------------------------------------------
; gemaHead - Track pointers to their respective data
;
; blk_data  | Block data pointer
; patt_data | Pattern data pointer
; ins_list  | instrument list pointer
; num_chnls | Number of channels used in the track
;             If 0: Read ALL channels
;                   (NOT recommended, UNSTABLE)
; ----------------------------------------------------

gemaHead macro blk,pat,ins,num
	dc.w num
	dc.l blk
	dc.l pat
	dc.l ins
	endm

; ------------------------------------------------------------
; Instrument macros, instrument_num-1
; (ex. Instrument 1 is 0 here)
;
; NOTE: UNUSED instruments MUST use gInsNull or
; the Z80 gets unexpected results and probably crash.
; ------------------------------------------------------------

; ----------------------------------------------------
; gInsNull - Null instrument
; ----------------------------------------------------

gInsNull macro
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	endm

; ----------------------------------------------------
; gInsPsg - PSG tone
;
; pitch | Pitch/Octave
; alv   | Attack level
; atk   | Attack rate
; slv   | Sustain
; dky   | Decay rate (up)
; rrt   | Release rate (down)
; vib   | Set to 0, planned vibrato for later.
; ----------------------------------------------------

gInsPsg	macro pitch,alv,atk,slv,dky,rrt,vib
	dc.b $80,pitch,alv,atk
	dc.b slv,dky,rrt,vib
	endm

; ----------------------------------------------------
; gInsPsg - PSG noise
;
; pitch | Pitch/Octave
;         If using Tone3: set to 47 for a full noise
; alv   | Attack level
; atk   | Attack rate
; slv   | Sustain
; dky   | Decay rate (up)
; rrt   | Release rate (down)
; vib   | Set to 0, planned vibrato for later.
; mode  | Noise mode: %tmm
;        t - Bass(0)|Noise(1)
;        m - Clock(0)|Clock/2(1)|Clock/4(2)|Tone3(3)
;        Using Tone3 will disable PSG Channel 3.
;
; Note:
; Tone3 WILL silence PSG3 as it steals the
; frequency from it, chip limitation.
; ----------------------------------------------------

gInsPsgN macro pitch,alv,atk,slv,dky,rrt,vib,mode
	dc.b $90|mode,pitch,alv,atk
	dc.b slv,dky,rrt,vib
	endm

; ----------------------------------------------------
; gInsFm - FM Normal instrument/patch
;
; pitch | Pitch/Octave
; fmins | 24-bit pointer to FM patch data
; ----------------------------------------------------

gInsFm macro pitch,fmins
	dc.b $A0,pitch,((fmins>>16)&$FF),((fmins>>8)&$FF)
	dc.b fmins&$FF,$00,$00,$00
	endm

; ----------------------------------------------------
; gInsFm - FM3 Special instrument/patch
;
; pitch | UNUSED, set to 0
; fmins | 24-bit pointer to FM patch data
; ----------------------------------------------------

gInsFm3	macro pitch,fmins
	dc.b $B0,pitch,((fmins>>16)&$FF),((fmins>>8)&$FF)
	dc.b fmins&$FF,$00,$00,$00
	endm

; ----------------------------------------------------
; gInsDac - DAC instrument
;
; pitch | Pitch/Octave
; start | 24-bit pointer to DAC sample
; flags | Flags: %0000000l
;         l - Use loop enable: No(0) or Yes(1)
; ----------------------------------------------------

gInsDac	macro pitch,start,flags
	dc.b $C0|flags,pitch,((start>>16)&$FF),((start>>8)&$FF)
	dc.b start&$FF,0,0,0
	endm

; ----------------------------------------------------
; gInsPcm - Sega CD PCM Sample
;
; pitch | Pitch/Octave
; start | 24-bit pointer to DAC sample
; flags | Flags: %0000000l
;         l - Use loop enable: No(0) or Yes(1)
; ----------------------------------------------------

gInsPcm	macro pitch,start,flags
 if MCD|MARSCD
	dc.b $D0|flags,pitch,((start>>16)&$FF),((start>>8)&$FF)
	dc.b start&$FF,0,0,0
 else
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
 endif
	endm

; ----------------------------------------------------
; gInsPwm - Sega 32X PWM Sample
;
; pitch | Pitch/Octave
; start | 24-bit pointer to DAC sample
; flags | Flags: %000000sl
;         l - Use loop enable: No(0) or Yes(1)
;         s - Sample data is in Stereo
; ----------------------------------------------------

gInsPwm	macro pitch,start,flags
 if MARS|MARSCD
	dc.b $E0|flags,pitch,((start>>24)&$FF),((start>>16)&$FF)
	dc.b ((start>>8)&$FF),start&$FF,0,0
 else
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
 endif
	endm

; ====================================================================
; --------------------------------------------------------
; Variables
; --------------------------------------------------------

; z80_cpu	equ $A00000		; Z80 CPU area, size: $2000
; z80_bus 	equ $A11100		; only read bit 0 (bit 8 as WORD)
; z80_reset	equ $A11200		; WRITE only: $0000 reset/$0100 cancel

; Z80-area points:
zDrvFifo	equ commZfifo		; FIFO command storage
zDrvFWrt	equ commZWrite		; FIFO command index
zDrvRomBlk	equ commZRomBlk		; ROM block flag
zDrvMarsBlk	equ marsBlock		; Flag to disable 32X's PWM
zDrvMcdBlk	equ mcdBlock		; Flag to disable SegaCD's PCM
zDrvRamSrc	equ cdRamSrcB		; RAM-read source+dest pointers
zDrvRamLen	equ cdRamLen		; RAM-read length and flag

; ====================================================================
; --------------------------------------------------------
; Labels
; --------------------------------------------------------

RAM_ZCdFlag_D	equ RAM_SoundBuff	; transferRom flag (ALSO for Z80)

; ====================================================================
; --------------------------------------------------------
; Initialize Sound
; --------------------------------------------------------

gemaInit:
		ori.w	#$0700,sr
	if PICO
		; PICO driver init...
	else
		move.w	#$0100,(z80_bus).l		; Get Z80 bus
		move.w	#$0100,(z80_reset).l		; Z80 reset
.wait:
		btst	#0,(z80_bus).l
		bne.s	.wait
		lea	(z80_cpu).l,a1			; a1 - Z80 CPU area
		move.l	a1,a0
		move.w	#$1FFF,d1
		moveq	#0,d0
.cleanup:
		move.b	d0,(a0)+
		dbf	d1,.cleanup
		lea	(Z80_CODE).l,a0			; a0 - Z80 code (on $880000)
		move.w	#(Z80_CODE_END-Z80_CODE)-1,d0	; d0 - Size
.copy:
		move.b	(a0)+,(a1)+
		dbf	d0,.copy
		move.w	#0,(z80_reset).l		; Reset
		clr.b	(RAM_ZCdFlag_D).w		; Reset Z80 transferRom flag
		move.b	(sys_io).l,d0			; Write PAL mode flag from here
		btst	#6,d0
		beq.s	.not_pal
		move.b	#1,(z80_cpu+palMode).l
.not_pal:
		nop
		nop
		move.w	#$100,(z80_reset).l
		move.w	#0,(z80_bus).l			; Start Z80
	endif

; ====================================================================
; ----------------------------------------------------------------
; gemaReset
;
; Reset sound to default sequence list
; ----------------------------------------------------------------

gemaReset:
		lea	(MainGemaSeqList),a0
		bsr	gemaSetMasterList
		moveq	#6-1,d7				; Make sure it finishes.
		dbf	d7,*
		rts

; ====================================================================
; ----------------------------------------------------------------
; gemaUpdate
;
; Call this during DISPLAY ONLY and during your VBlank wait
; (already called by System_Render)
;
; RAM-to-Z80 transferRom workaround:
; This checks if the Z80 wants to read from RAM (as it can't
; see it), The 68k CPU manually writes the RAM bytes from
; here to the Z80's RAM
; THIS IS REQUIRED if you want to play your the tracks
; (and instruments) in case you use the ASIC-Stamp scaling/
; rotation.
;
; SCD/CD32X:
; - DAC samples are safe to read from WORD-RAM, but NOT
;   when Stamps are being used, use PCM samples instead.
; - Be careful when loading new data with gemaSetMasterList to
;   WORD-RAM, make sure MAIN-CPU has the permission set for
;   reading from there
;
; Sega Pico:
; - TODO The entire Sound Driver will be here, translated from
;   Z80 to 68k.
; ----------------------------------------------------------------

gemaUpdate:
	if PICO
		rts		; entire Sound driver for Pico goes here
	else
	; ------------------------------------------------
	; If transferRom wants to read from 68k RAM
		tst.b	(RAM_ZCdFlag_D).w		; Z80 WROTE the flag?
		beq.s	.no_task
		clr.b	(RAM_ZCdFlag_D).w		; Clear here
		movem.l	a4-a6/d5-d7,-(sp)
		moveq	#0,d7
		bsr	sndLockZ80
		move.b	(z80_cpu+zDrvRamLen).l,d7	; Size != 0?
		beq.s	.no_size
		subq.w	#1,d7
		lea	(z80_cpu+(zDrvRamSrc+1)),a6
		lea	(z80_cpu),a5
		move.b	-(a6),d6			; d6 - Source
		swap	d6
		move.b	-(a6),d6
		lsl.w	#8,d6
		move.b	-(a6),d6
		moveq	#0,d5
		move.b	-(a6),d5			; d5 - Dest
		lsl.w	#8,d5
		move.b	-(a6),d5
		add.l	d5,a5
		move.l	d6,a4
.copy_bytes:
		move.b	(a4)+,(a5)+
		dbf	d7,.copy_bytes
		move.b	#0,(z80_cpu+zDrvRamLen).l	; Clear LEN, breaks Z80 loop
.no_size:
		bsr	sndUnlockZ80
		movem.l	(sp)+,a4-a6/d5-d7
.no_task:
	endif
		rts

; ====================================================================
; ------------------------------------------------
; sndLockZ80
;
; Locks Z80, unlocks bus.
; ------------------------------------------------

sndLockZ80:
	if PICO=0
		move.w	#$0100,(z80_bus).l
.wait:
		btst	#0,(z80_bus).l
		bne.s	.wait
	endif
		rts

; ------------------------------------------------
; sndUnlockZ80
;
; Unlocks Z80, locks bus.
; ------------------------------------------------

sndUnlockZ80:
	if PICO=0
		move.w	#0,(z80_bus).l
	endif
		rts

; ------------------------------------------------
; 68K-to-Z80 sound request enter/exit routines
;
; d6 - commFifo index
; ------------------------------------------------

sndReq_Enter:
		ori.w	#$0700,sr			; Disable interrupts
	if PICO=0
		move.w	#$0100,(z80_bus).l		; Request Z80 Stop
	endif
		suba	#4,sp				; Extra jump return
		movem.l	d6-d7/a5-a6,-(sp)		; Save these regs to the stack
		adda	#(4*4)+4,sp			; Go back to the RTS jump
		lea	(z80_cpu+zDrvFWrt).l,a5		; a5 - commZWrite
		lea	(z80_cpu+zDrvFifo).l,a6		; a6 - fifo command list
.wait:
	if PICO=0
		btst	#0,(z80_bus).l			; Wait for Z80
		bne.s	.wait
	endif
		move.b	(a5),d6				; d6 - index fifo position
		ext.w	d6				; extend to 16 bits
		rts
; JUMP ONLY
sndReq_Exit:
	if PICO=0
		move.w	#0,(z80_bus).l
	endif
		suba	#8+(4*4),sp
		movem.l	(sp)+,d6-d7/a5-a6		; And pop those back
		adda	#8,sp
		andi.w	#$F8FF,sr			; Enable interrupts
		rts

; ------------------------------------------------
; Send request id and arguments
;
; Input:
; d7 - byte to write
; d6 - index pointer
; a5 - commZWrite, update index
; a6 - commZfifo command list
;
; *** CALL sndReq_Enter FIRST ***
; ------------------------------------------------

sndReq_scmd:
		move.b	#-1,(a6,d6.w)			; write command-start flag
		addq.b	#1,d6				; next fifo pos
		andi.b	#MAX_ZCMND-1,d6			; * Z80 label *
		bra.s	sndReq_sbyte
sndReq_slong:
		bsr	sndReq_sbyte
		ror.l	#8,d7
sndReq_saddr:	; 24-bit address
		bsr	sndReq_sbyte
		ror.l	#8,d7
sndReq_sword:
		bsr	sndReq_sbyte
		ror.l	#8,d7
sndReq_sbyte:
		move.b	d7,(a6,d6.w)			; write byte
		addq.b	#1,d6				; next fifo pos
		andi.b	#MAX_ZCMND-1,d6			; * Z80 label *
		move.b	d6,(a5)				; update commZWrite
		rts

; --------------------------------------------------------
; gemaDmaPause
;
; Call this BEFORE doing any DMA transfer
;
; 32X: Set RV bit manually AFTER calling this.
; --------------------------------------------------------

gemaDmaPause:
	if PICO
		rts
	else
		move.l	d7,-(sp)
		bsr	sndLockZ80
		move.b	#1,(z80_cpu+zDrvRomBlk).l	; Block flag for Z80
		bsr	sndUnlockZ80
		move.w	#96,d7				; Small delay
		dbf	d7,*
		move.l	(sp)+,d7
		rts
	endif

; --------------------------------------------------------
; gemaDmaResume
;
; Call this AFTER finishing DMA transfer
;
; 32X: Clear the RV bit manually AFTER calling this.
; --------------------------------------------------------

gemaDmaResume:
	if PICO
		rts
	else
		move.l	d7,-(sp)
		bsr	sndLockZ80
		move.b	#0,(z80_cpu+zDrvRomBlk).l	; Unblock flag for Z80
		bsr	sndUnlockZ80
		move.w	#96,d7				; Small delay
		dbf	d7,*
		move.l	(sp)+,d7
		rts
	endif

; ====================================================================
; --------------------------------------------------------
; Subroutines
;
; USER Sound calls are here
; --------------------------------------------------------

; --------------------------------------------------------
; gemaTest
;
; For TESTING only.
; --------------------------------------------------------

gemaTest:
		bsr	sndReq_Enter
		move.w	#$00,d7		; Command $00
		bsr	sndReq_scmd
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaSetMasterList
;
; Sets the Master tracklist location, data can be stored
; on ROM, RAM* and Word-RAM*
;
; Input:
; a0 | 68k pointer
;
; Notes:
; - STOP ALL TRACKS WITH gemaStopAll BEFORE
;   CALLING THIS.
;
; * RAM data (SCD/CD32X when using Stamps):
;   Requires calling Sound_Update manually as a
;   workaround for the Z80's limitation of not being
;   able to read from RAM
;   (BUT it can WRITE into as normal)
; * Word-RAM (SCD/CD32X):
;   Make sure the Word-RAM permission is set to MAIN-CPU.
;
; MUST USE THE MACROS TO PROPERLY SETUP THE TRACK LIST:
; 	gemaList Tracklist_Pointer
; 	gemaTrk 0,2,gtrk_Test
; 	; other tracks go here
; --------------------------------------------------------

gemaSetMasterList:
		bsr	sndReq_Enter
		move.w	#$01,d7		; Command $01
		bsr	sndReq_scmd
		move.l	a0,d7
		bsr	sndReq_slong
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaPlaySeq
;
; Play a sequence with arguments
;
; Input:
; d0.b | Playback slot number
;        If -1: Auto-search free slot
; d1.b | Sequence number
; d2.b | Starting block
; --------------------------------------------------------

gemaPlaySeq:
		bsr	sndReq_Enter
		move.w	#$02,d7		; Command $02
		bsr	sndReq_scmd
		move.b	d1,d7		; d1.b Seq number
		bsr	sndReq_sbyte
		move.b	d2,d7		; d2.b Block <--
		bsr	sndReq_sbyte
		move.b	d0,d7		; d0.b Slot
		bsr	sndReq_sbyte
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaStopSeq
;
; Stops tracks with the same sequence number
;
; Input:
; d0.b | Playback slot number
;        If -1: Stop all slots
; d1.b | Sequence number to search for
;        If -1: Stop tracks with any sequence
; --------------------------------------------------------

gemaStopSeq:
		bsr	sndReq_Enter
		move.w	#$03,d7		; Command $03
		bsr	sndReq_scmd
		move.b	d1,d7		; d0.b Seq number
		bsr	sndReq_sbyte
		move.b	d0,d7		; d1.b Slot
		bsr	sndReq_sbyte
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaStopAll
;
; Stops ALL tracks, quick version of gemaStopTrack.
; --------------------------------------------------------

gemaStopAll:
		bsr	sndReq_Enter
		move.w	#$03,d7		; Command $03
		bsr	sndReq_scmd
		moveq	#-1,d7		; d0.b Seq number
		bsr	sndReq_sbyte
		moveq	#-1,d7		; d1.b Slot
		bsr	sndReq_sbyte
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaFadeSeq
;
; Set Master volume to a track slot.
;
; Input:
; d0.b | Playback slot number
;        If -1: Apply to all slots
; d1.b | Target volume
;
; Notes:
; - DO NOT MIX THIS WITH gemaSetTrackVol
; - In v1.0 this only works during new notes on playback.
; --------------------------------------------------------

gemaFadeSeq:
		bsr	sndReq_Enter
		move.w	#$05,d7		; Command $05
		bsr	sndReq_scmd
		move.b	d1,d7		; d0.b Target volume
		bsr	sndReq_sbyte
		move.b	d0,d7		; d1.b Slot
		bsr	sndReq_sbyte
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaSetSeqVol
;
; Set Master volume to a Seq slot.
;
; Input:
; d0.b | Playback slot number
;        If -1: Set to all slots
; d1.b | Master volume:
;        $00-max $40-min
;
; Notes:
; - DO NOT MIX THIS WITH gemaFadeSeq
; - In v1.0 this only works on (re)start
;   or during new notes on playback.
; --------------------------------------------------------

gemaSetSeqVol:
		bsr	sndReq_Enter
		move.w	#$06,d7		; Command $06
		bsr	sndReq_scmd
		move.b	d1,d7		; d1.b Volume data <--
		bsr	sndReq_sbyte
		move.b	d0,d7		; d0.b Slot
		bsr	sndReq_sbyte
		bra 	sndReq_Exit

; --------------------------------------------------------
; gemaSetBeats
;
; Sets global sub-beats, affects ALL tracks.
;
; Input:
; d0.w | sub-beats
;
; Note:
; This gets auto-converted if Z80 is in PAL-speed
; mode.
; --------------------------------------------------------

; Ex. sub-beats 215 is tempo 125 on NTSC speed

gemaSetBeats:
		bsr	sndReq_Enter
		move.w	#$07,d7		; Command $07
		bsr	sndReq_scmd
		move.w	d0,d7
		bsr	sndReq_sword
		bra 	sndReq_Exit
