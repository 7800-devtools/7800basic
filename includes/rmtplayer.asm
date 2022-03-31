 ifconst RMT

rmtmodulestart

;*
;* Raster Music Tracker, RMT Atari routine version 1.20030223
;* (c) Radek Sterba, Raster/C.P.U., 2002 - 2003
;* http://raster.atari.org
;*
;* Some small changes to allow using this code with DASM cross assembler and
;* to compile for cartridge based systems, like the Atari 5200 or Atari 7800,
;* by Eckhard Stolberg ( http://home.arcor.de/estolberg/ ).
;*
;* Warnings:
;*
;* 1. RMT player routine needs 19 itself reserved bytes in zero page (no accessed
;*    from any other routines) as well as cca 1KB of memory before the "PLAYER"
;*    address for frequency tables and functionary variables. It's:
;*	  a) from PLAYER-$400 to PLAYER for stereo RMTplayer
;*    b) from PLAYER-$380 to PLAYER for mono RMTplayer
;*
;* note: This has been changed for 5200 & 7800 compatibility. Now PLAYER points
;*       to the start of the frequency tables. The player routines follows after
;*       that. The variables are now independent and can be located with
;*       PLAYER_VAR_RAM and PLAYER_ZP_RAM (see below): 
;*
;* 2. RMT player routine MUST (!!!) be compiled from the begin of the memory page.
;*    i.e. "PLAYER" address can be $..00 only!
;*
;* 3. Because of RMTplayer provides a lot of effects, it spent a lot of CPU time.
;*
;*
;* Define the following equates here or in your main code file.
;* Set the values according to the system you compile for.
;*

POKEY_BASE          equ     pokeyaddress
PLAYER_ZP_RAM       equ     songchannel1layer1lo ; player routine needs 19 bytes of zero page RAM
PLAYER_VAR_RAM      equ     RMTRAM ;variables in main RAM - 173 bytes mono - 337 stereo
ROM_BASED           equ     1      ;using a ROM based system - no self modifying code
STEREO8T            equ     0      ;0 => compile RMTplayer for mono 4 tracks
;                                  ;1 => compile RMTplayer for stereo 8 tracks

rmt_ispeed              equ     PLAYER_ZP_RAM+19
rmt_intcount            equ     PLAYER_ZP_RAM+20

;*

	IF  STEREO8T
TRACKS		equ 8
	ELSE
TRACKS		equ 4
	EIF

;*
;* RMT FEATures definitions
;* For optimizations of RMT player routine to concrete RMT modul only!
;* --------BEGIN--------
FEAT_COMMAND1		equ 1			;* cca 8 bytes
FEAT_COMMAND2		equ 1			;* cca 20 bytes (+save 1 address in zero page) and quicker whole RMT routine
FEAT_COMMAND3		equ 1			;* cca 12 bytes
FEAT_COMMAND4		equ 1			;* cca 15 bytes
FEAT_COMMAND5		equ 1			;* cca 67 bytes
FEAT_COMMAND6		equ 1			;* cca 15 bytes
;* COMMAND7 SETNOTE (i.e. command 7 with parameter != $80)
FEAT_COMMAND7SETNOTE		equ 1		;* cca 12 bytes
;* COMMAND7 VOLUMEONLY (i.e. command 7 with parameter == $80)
FEAT_COMMAND7VOLUMEONLY		equ 1		;* cca 74 bytes
;* PORTAMENTO
FEAT_PORTAMENTO		equ 1			;* cca 138 bytes and quicker whole RMT routine
;* FILTER
FEAT_FILTER			equ 1			;* cca 179 bytes and quicker whole RMT routine
FEAT_FILTERG0L		equ	1			;* (cca 38 bytes for each)
FEAT_FILTERG1L		equ	1
FEAT_FILTERG0R		equ	1
FEAT_FILTERG1R		equ	1
;* BASS16B (i.e. distortion value 6)
FEAT_BASS16			equ 1			;* cca 194 bytes +128bytes freq table and quicker whole RMT routine
FEAT_BASS16G1L		equ 1			;* (cca 47 bytes for each)
FEAT_BASS16G3L		equ 1
FEAT_BASS16G1R		equ 1
FEAT_BASS16G3R		equ 1
;* VOLUME ONLY for particular generators
FEAT_VOLUMEONLYG0L	equ 1			;* (cca 7 bytes for each)
FEAT_VOLUMEONLYG2L	equ 1
FEAT_VOLUMEONLYG3L	equ 1
FEAT_VOLUMEONLYG0R	equ 1
FEAT_VOLUMEONLYG2R	equ 1
FEAT_VOLUMEONLYG3R	equ 1
;* TABLE TYPE (i.e. TABLETYPE=1)
FEAT_TABLETYPE		equ 1			;* cca 53 bytes and quicker whole RMT routine
;* TABLE MODE (i.e. TABLEMODE=1)
FEAT_TABLEMODE		equ 1			;* cca 16 bytes and quicker whole RMT routine
;* AUDCTLMANUALSET (i.e. any MANUAL AUDCTL setting to nonzero value)
FEAT_AUDCTLMANUALSET	equ 1		;* cca 27 bytes and quicker whole RMT routine
;* --------END--------
;*
;*
;* RMT ZeroPage addresses

MEMLOC SET PLAYER_ZP_RAM
p_tis = MEMLOC
p_instrstable	        = MEMLOC
MEMLOC SET (MEMLOC+2)
p_trackslbstable        = MEMLOC
MEMLOC SET (MEMLOC+2)
p_trackshbstable        = MEMLOC
MEMLOC SET (MEMLOC+2)
p_song                  = MEMLOC
MEMLOC SET (MEMLOC+2)

_ns                     = MEMLOC
MEMLOC SET (MEMLOC+2)
_nr                     = MEMLOC
MEMLOC SET (MEMLOC+2)
_nt                     = MEMLOC
MEMLOC SET (MEMLOC+2)

rmtreg1                 = MEMLOC
MEMLOC SET (MEMLOC+1)
rmtreg2			= MEMLOC
MEMLOC SET (MEMLOC+1)
rmtreg3			= MEMLOC
MEMLOC SET (MEMLOC+1)
_tmp		        = MEMLOC
MEMLOC SET (MEMLOC+1)
	IF  FEAT_COMMAND2
frqaddcmd2		= MEMLOC
MEMLOC SET (MEMLOC+1)
	EIF

;*
;* Variables in main RAM used by player routine.
;* 337 bytes for stereo - 173 bytes for mono
;*

MEMLOC SET PLAYER_VAR_RAM
track_variables = MEMLOC

trackn_db                = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_hb                = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_idx               = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_pause             = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_note              = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_volume            = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_distor            = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_shiftfrq          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)

	IF  FEAT_PORTAMENTO
trackn_portafrqc         = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_portafrqa         = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_portaspeed        = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_portaspeeda       = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_portadepth        = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
	EIF

trackn_instrx2           = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_instrdb           = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_instrhb           = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_instridx          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_instrlen          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_instrlop          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_instrreachend     = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_volumeslidedepth  = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_volumeslidevalue  = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_volumemin         = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_effdelay          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_effvibratoa       = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_effvibratobeg     = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_effvibratoend     = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_effshift          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_tabletypespeed    = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)

	IF  FEAT_TABLEMODE
trackn_tablemode         = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
	EIF

trackn_tablenote         = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)

trackn_tablea            = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_tableend          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_tablelop          = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_tablespeeda       = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_command           = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)

	IF  FEAT_BASS16
trackn_outnote           = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
	EIF
	IF  FEAT_FILTER
trackn_filter            = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
	EIF

trackn_audf             = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
trackn_audc             = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)

	IF  FEAT_AUDCTLMANUALSET
trackn_audctl           = MEMLOC
MEMLOC SET (MEMLOC+TRACKS)
	EIF

v_audctl                = MEMLOC
MEMLOC SET (MEMLOC+1)
v_audctl2               = MEMLOC
MEMLOC SET (MEMLOC+1)
v_speed                 = MEMLOC
MEMLOC SET (MEMLOC+1)
v_aspeed                = MEMLOC
MEMLOC SET (MEMLOC+1)
v_bspeed                = MEMLOC
MEMLOC SET (MEMLOC+1)
v_instrspeed            = MEMLOC
MEMLOC SET (MEMLOC+1)
v_ainstrspeed           = MEMLOC
MEMLOC SET (MEMLOC+1)
v_maxtracklen           = MEMLOC
MEMLOC SET (MEMLOC+1)
v_abeat	                = MEMLOC
MEMLOC SET (MEMLOC+1)

track_endvariables      = MEMLOC

;*
;* Data tables used by player routine.
;*
		ALIGN	256
PLAYER = .

volumetab
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
	dc.b $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
	dc.b $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
	dc.b $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
	dc.b $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
	dc.b $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
	dc.b $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
	dc.b $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
	dc.b $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
	dc.b $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
	dc.b $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
	dc.b $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
	dc.b $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

frqtab
;	ERT [<frqtab]!=0	;* frqtab must begin at the memory page bound! (i.e. $..00 address)
frqtabbass1
	dc.b $BF,$B6,$AA,$A1,$98,$8F,$89,$80,$F2,$E6,$DA,$CE,$BF,$B6,$AA,$A1
	dc.b $98,$8F,$89,$80,$7A,$71,$6B,$65,$5F,$5C,$56,$50,$4D,$47,$44,$3E
	dc.b $3C,$38,$35,$32,$2F,$2D,$2A,$28,$25,$23,$21,$1F,$1D,$1C,$1A,$18
	dc.b $17,$16,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07
frqtabbass2
	dc.b $FF,$F1,$E4,$D8,$CA,$C0,$B5,$AB,$A2,$99,$8E,$87,$7F,$79,$73,$70
	dc.b $66,$61,$5A,$55,$52,$4B,$48,$43,$3F,$3C,$39,$37,$33,$30,$2D,$2A
	dc.b $28,$25,$24,$21,$1F,$1E,$1C,$1B,$19,$17,$16,$15,$13,$12,$11,$10
	dc.b $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00
frqtabpure
	dc.b $F3,$E6,$D9,$CC,$C1,$B5,$AD,$A2,$99,$90,$88,$80,$79,$72,$6C,$66
	dc.b $60,$5B,$55,$51,$4C,$48,$44,$40,$3C,$39,$35,$32,$2F,$2D,$2A,$28
	dc.b $25,$23,$21,$1F,$1D,$1C,$1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F
	dc.b $0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00,$00
	IF  FEAT_BASS16
frqtabbasshi
	dc.b $0D,$0D,$0C,$0B,$0B,$0A,$0A,$09,$08,$08,$07,$07,$07,$06,$06,$05
	dc.b $05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02
	dc.b $02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	EIF

	IF  FEAT_BASS16
frqtabbasslo
	dc.b $F2,$33,$96,$E2,$38,$8C,$00,$6A,$E8,$6A,$EF,$80,$08,$AE,$46,$E6
	dc.b $95,$41,$F6,$B0,$6E,$30,$F6,$BB,$84,$52,$22,$F4,$C8,$A0,$7A,$55
	dc.b $34,$14,$F5,$D8,$BD,$A4,$8D,$77,$60,$4E,$38,$27,$15,$06,$F7,$E8
	dc.b $DB,$CF,$C3,$B8,$AC,$A2,$9A,$90,$88,$7F,$78,$70,$6A,$64,$5E,$00
	EIF
	
	IF	ROM_BASED
rts_tab	dc.w	cmd0-1,cmd1-1,cmd2-1,cmd3-1,cmd4-1,cmd5-1,cmd6-1,cmd7-1
	EIF
INSTRPAR	equ 12
tabbeganddistor
 dc.b frqtabpure-frqtab,$00
 dc.b frqtabpure-frqtab,$20
 dc.b frqtabpure-frqtab,$40
 dc.b frqtabbass1-frqtab,$c0
 dc.b frqtabpure-frqtab,$80
 dc.b frqtabpure-frqtab,$a0
 dc.b frqtabbass1-frqtab,$c0
 dc.b frqtabbass2-frqtab,$c0
vibtabbeg dc.b 0,vib1-vib0,vib2-vib0,vib3-vib0,vibx-vib0
vib0	dc.b 0
vib1	dc.b 1,-1,-1,1
vib2	dc.b 1,0,-1,-1,0,1
vib3	dc.b 1,1,0,-1,-1,-1,-1,0,1,1
vibx
emptytrack
	dc.b 62,0

;*
;* Set of RMT main vectors:
;*
RASTERMUSICTRACKER
	jmp rmt_init
	jmp rmt_play
	jmp rmt_p3
	jmp rmt_silence
	jmp SetPokey
rmt_init
	stx _ns
	sty _ns+1
	pha
	IF  track_endvariables-track_variables>255
	ldy #0
	tya
rmtri0	sta track_variables,y
	sta track_endvariables-$100,y
	iny
	bne rmtri0
	ELSE
	ldy #track_endvariables-track_variables
	lda #0
rmtri0	sta track_variables-1,y
	dey
	bne rmtri0
	EIF
	ldy #4
	lda (_ns),y
	sta v_maxtracklen
	iny
	lda (_ns),y
	sta v_speed
	iny
	lda (_ns),y
	sta v_instrspeed
	sta v_ainstrspeed
	ldy #8
rmtri1	lda (_ns),y
	sta p_tis-8,y
	iny
	cpy #8+8
	bne rmtri1
	pla
	pha
	IF  STEREO8T
	asl 
	asl 
	asl 
	clc
	adc p_song
	sta p_song
	pla
	and #$e0
	asl 
	rol 
	rol 
	rol 
	ELSE
	asl 
	asl 
	clc
	adc p_song
	sta p_song
	pla
	and #$c0
	asl 
	rol 
	rol 
	EIF
	adc p_song+1
	sta p_song+1
	jsr GetSongLine
	jsr GetTrackLine
	jsr InitOfNewSetInstrumentsOnly
	jsr rmt_silence
	lda v_instrspeed
	rts
rmt_silence
	IF  STEREO8T
	lda #0
	sta POKEY_BASE+$08
	sta POKEY_BASE_S+$08
	ldy #3
	sty POKEY_BASE+$0f
	sty POKEY_BASE_S+$0f
	ldy #8
rmtsi1	sta POKEY_BASE+$00,y
	sta POKEY_BASE_S+$00,y
	dey
	bpl rmtsi1
	ELSE
	lda #0
	sta POKEY_BASE+$08
	ldy #3
	sty POKEY_BASE+$0f
	ldy #8
rmtsi1	sta POKEY_BASE+$00,y
	dey
	bpl rmtsi1
	EIF
	rts
GetSongLine
	ldx #0
	stx v_abeat
rmtnn0
	ldx #0
rmtnn1	txa
	tay
	lda (p_song),y
	cmp #$fe
	bcs rmtnn2
	tay
	lda (p_trackslbstable),y
	sta trackn_db,x
	lda (p_trackshbstable),y
rmtnn1a sta trackn_hb,x
	lda #0
	sta trackn_idx,x
	lda #1
	sta trackn_pause,x
	lda #$80
	sta trackn_instrx2,x
	inx
	cpx #TRACKS
	bne rmtnn1
	lda p_song
	clc
	adc #TRACKS
	sta p_song
	bcc rmtnn1b
	inc p_song+1
rmtnn1b
	rts
rmtnn2
	beq rmtnn3
rmtnn2a lda #<emptytrack
	sta trackn_db,x
	lda #>emptytrack
	jmp rmtnn1a
rmtnn3
	ldy #2
	lda (p_song),y
	tax
	iny
	lda (p_song),y
	sta p_song+1
	stx p_song
	jmp rmtnn0
GetTrackLine
rmtoo0
rmtoo0a
	lda v_speed
	sta v_bspeed
	ldx #0
rmtoo1
	lda trackn_pause,x
	beq rmtoo1x
	dec trackn_pause,x
	bne rmtoo1x
	inc trackn_pause,x
rmtoo1b
	lda trackn_db,x
	sta _ns
	lda trackn_hb,x
	sta _ns+1
rmtoo1i
	ldy trackn_idx,x
	lda (_ns),y
	sta rmtreg1
	iny
	lda (_ns),y
	sta rmtreg2
	iny
	tya
	sta trackn_idx,x
	lda rmtreg1
	and #$3f
	cmp #61
	beq rmtoo1a
	bcs rmtoo2
	sta trackn_note,x
	IF  FEAT_BASS16
	sta trackn_outnote,x
	EIF
	lda rmtreg2
	lsr 
	and #$3f*2
	sta trackn_instrx2,x
rmtoo1a lda rmtreg2
	lsr 
	ror rmtreg1
	lsr 
	ror rmtreg1
	lda rmtreg1
	and #$f0
	sta trackn_volume,x
rmtoo1x
	inx
	cpx #TRACKS
	bne rmtoo1
	lda v_bspeed
	sta v_speed
	sta v_aspeed
	rts
rmtoo2
	cmp #63
	beq rmtoo63
	lda rmtreg1
	and #$c0
	beq rmtoo62_b
	asl 
	rol 
	rol 
	sta trackn_pause,x
	dec trackn_idx,x
	jmp rmtoo1x
rmtoo62_b
	lda rmtreg2
	sta trackn_pause,x
	jmp rmtoo1x
rmtoo63
	lda rmtreg1
	bmi rmtoo63_1X
	lda rmtreg2
	sta v_bspeed
	jmp rmtoo1i
rmtoo63_1X
	cmp #255
	beq rmtoo63_11
	lda rmtreg2
	sta trackn_idx,x
	jmp rmtoo1i
rmtoo63_11
	jsr GetSongLine
	jmp rmtoo0
InitOfNewSetInstrumentsOnly
	ldx #0
p2x1 ldy trackn_instrx2,x
	bmi p2x2
	jsr SetUpInstrumentY2
	lda #$80
	sta trackn_instrx2,x
p2x2
	inx
	cpx #TRACKS
	bne p2x1
	rts
rmt_play
rmt_p0
	jsr SetPokey
rmt_p1
	dec v_ainstrspeed
	beq rmtp1a
	jmp rmt_p3
rmtp1a
	lda v_instrspeed
	sta v_ainstrspeed
rmt_p2
	dec v_aspeed
	bne rmt_p3
	inc v_abeat
	lda v_abeat
	cmp v_maxtracklen
	bne rmtp2o2
	jsr GetSongLine
rmtp2o2
	jsr GetTrackLine
	jmp rmt_p2X
go_ppnext jmp ppnext
rmt_p2X
	jsr InitOfNewSetInstrumentsOnly
rmt_p3
	lda #>frqtab
	sta _nr+1
	ldx #0
rmtpp1
	lda trackn_instrhb,x
	beq go_ppnext
	sta _ns+1
	lda trackn_instrdb,x
	sta _ns
	ldy trackn_instridx,x
	lda (_ns),y
	sta rmtreg1
	iny
	lda (_ns),y
	sta rmtreg2
	iny
	lda (_ns),y
	sta rmtreg3
	iny
	tya
	cmp trackn_instrlen,x
	bcc rmtpp2
	beq rmtpp2
	lda #$80
	sta trackn_instrreachend,x
rmtpp1b
	lda trackn_instrlop,x
rmtpp2	sta trackn_instridx,x
	lda rmtreg1
	IF  STEREO8T
	cpx #4
	bcc rmtpp2s
	lsr 
	lsr 
	lsr 
	lsr 
rmtpp2s
	EIF
	and #$0f
	ora trackn_volume,x
	tay
	lda volumetab,y
	pha
	lda rmtreg2
	and #$0e
	tay
	lda tabbeganddistor,y
	sta _nr
	pla
	ora tabbeganddistor+1,y
	sta trackn_audc,x
	jmp InstrumentsEffects
returnfromInstrumentsEffects
	IF  FEAT_COMMAND2
	lda #0
	sta frqaddcmd2
	EIF
	lda rmtreg2
	sta trackn_command,x
	and #$70
	lsr 
	lsr 
	IF	ROM_BASED
	lsr
	tay
	lda	rts_tab+1,y
	pha
	lda	rts_tab,y
	pha
	rts
	ELSE
	sta jmx+1
jmx	bcc *
	jmp cmd0
	nop
	jmp cmd1
	nop
	jmp cmd2
	nop
	jmp cmd3
	nop
	jmp cmd4
	nop
	jmp cmd5
	nop
	jmp cmd6
	nop
	jmp cmd7
	EIF
cmd0
	lda trackn_note,x
	clc
	adc rmtreg3
cmd0a
	IF  FEAT_TABLETYPE
	ldy trackn_tabletypespeed,x
	bmi cmd0b
	EIF
	clc
	adc trackn_tablenote,x
	cmp #61
	bcc cmd0a1
	lda #0
	sta trackn_audc,x
	lda #63
cmd0a1
	IF  FEAT_BASS16
	sta trackn_outnote,x
	EIF
	tay
	lda (_nr),y
	clc
	adc trackn_shiftfrq,x
	IF  FEAT_COMMAND2
	clc
	adc frqaddcmd2
	EIF
	sta trackn_audf,x
	jmp rmtpp9
	IF  FEAT_TABLETYPE
cmd0b
	cmp #61
	bcc cmd0b1
	lda #0
	sta trackn_audc,x
	lda #63
cmd0b1
	tay
	lda trackn_shiftfrq,x
	clc
	adc trackn_tablenote,x
	clc
	adc (_nr),y
	IF  FEAT_COMMAND2
	clc
	adc frqaddcmd2
	EIF
	sta trackn_audf,x
	jmp rmtpp9
	EIF
cmd1
	IF  FEAT_COMMAND1
	lda rmtreg3
	sta trackn_audf,x
	jmp rmtpp9
	EIF
cmd2
	IF  FEAT_COMMAND2
	lda rmtreg3
	sta frqaddcmd2
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd3
	IF  FEAT_COMMAND3
	lda trackn_note,x
	clc
	adc rmtreg3
	sta trackn_note,x
	jmp cmd0a
	EIF
cmd4
	IF  FEAT_COMMAND4
	lda trackn_shiftfrq,x
	clc
	adc rmtreg3
	sta trackn_shiftfrq,x
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd5
	IF  FEAT_COMMAND5&&FEAT_PORTAMENTO
	IF  FEAT_TABLETYPE
	lda trackn_tabletypespeed,x
	bpl cmd5a1
	ldy trackn_note,x
	lda (_nr),y
	clc
	adc trackn_tablenote,x
	jmp cmd5ax
	EIF
cmd5a1
	lda trackn_note,x
	clc
	adc trackn_tablenote,x
	cmp #61
	bcc cmd5a2
	lda #63
cmd5a2
	tay
	lda (_nr),y
cmd5ax
	sta trackn_portafrqc,x
	ldy rmtreg3
	bne cmd5a
	sta trackn_portafrqa,x
cmd5a
	tya
	lsr 
	lsr 
	lsr 
	lsr 
	sta trackn_portaspeed,x
	sta trackn_portaspeeda,x
	lda rmtreg3
	and #$0f
	sta trackn_portadepth,x
	lda trackn_note,x
	jmp cmd0a
	ELSE
	IF	FEAT_COMMAND5
	jmp rmtpp9
	EIF
	EIF
cmd6
	IF  FEAT_COMMAND6&&FEAT_FILTER
	lda rmtreg3
	clc
	adc trackn_filter,x
	sta trackn_filter,x
	lda trackn_note,x
	jmp cmd0a
	ELSE
	IF	FEAT_COMMAND6
	jmp rmtpp9
	EIF
	EIF
cmd7
	IF  FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	IF  FEAT_COMMAND7SETNOTE
	lda rmtreg3
	IF  FEAT_COMMAND7VOLUMEONLY
	cmp #$80
	beq cmd7a
	EIF
	sta trackn_note,x
	jmp cmd0a
	EIF
	IF  FEAT_COMMAND7VOLUMEONLY
cmd7a
	lda trackn_audc,x
	ora #$f0
	sta trackn_audc,x
	lda trackn_note,x
	jmp cmd0a
	EIF
	EIF
rmtpp9
	IF  FEAT_PORTAMENTO
	lda trackn_portaspeeda,x
	beq rmtpp10
	sec
	sbc #1
	sta trackn_portaspeeda,x
	bne rmtpp10
	lda trackn_portaspeed,x
	sta trackn_portaspeeda,x
	lda trackn_portafrqa,x
	cmp trackn_portafrqc,x
	beq rmtpp10
	bcs pps1
	adc trackn_portadepth,x
	bcs pps8
	cmp trackn_portafrqc,x
	bcs pps8
	jmp pps9
pps1
	sbc trackn_portadepth,x
	bcc pps8
	cmp trackn_portafrqc,x
	bcs pps9
pps8
	lda trackn_portafrqc,x
pps9
	sta trackn_portafrqa,x
rmtpp10
	lda rmtreg2
	and #$01
	beq rmtpp11
	lda trackn_portafrqa,x
	clc
	adc trackn_shiftfrq,x
	sta trackn_audf,x
rmtpp11
	EIF
ppnext
	inx
	cpx #TRACKS
	beq rmt_p4
	jmp rmtpp1
rmt_p4
	IF  FEAT_AUDCTLMANUALSET
	ldx #3
	lda #0
qq0	ora trackn_audctl,x
	dex
	bpl qq0
	sta v_audctl
qq1
	ldx v_audctl
	ELSE
	ldx #0
	stx v_audctl
	EIF
	IF  FEAT_FILTER
	IF  FEAT_FILTERG0L
	lda trackn_command+0
	bpl qq2
	lda trackn_audc+0
	and #$0f
	beq qq2
	lda trackn_audf+0
	clc
	adc trackn_filter+0
	sta trackn_audf+2
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq1a
	EIF
	lda #0
	sta trackn_audc+2
qq1a
	txa
	ora #4
	tax
	EIF
qq2
	IF  FEAT_FILTERG1L
	lda trackn_command+1
	bpl qq3
	lda trackn_audc+1
	and #$0f
	beq qq3
	lda trackn_audf+1
	clc
	adc trackn_filter+1
	sta trackn_audf+3
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3L
	lda trackn_audc+3
	and #$10
	bne qq2a
	EIF
	lda #0
	sta trackn_audc+3
qq2a
	txa
	ora #2
	tax
	EIF
qq3
	IF  FEAT_FILTERG0L||FEAT_FILTERG1L
	cpx v_audctl
	bne qq5
	EIF
	EIF
	IF  FEAT_BASS16
	IF  FEAT_BASS16G1L
	lda trackn_command+1
	and #$0e
	cmp #6
	bne qq4
	lda trackn_audc+1
	and #$0f
	beq qq4
	ldy trackn_outnote+1
	lda frqtabbasslo,y
	sta trackn_audf+0
	lda frqtabbasshi,y
	sta trackn_audf+1
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0L
	lda trackn_audc+0
	and #$10
	bne qq3a
	EIF
	lda #0
	sta trackn_audc+0
qq3a
	txa
	ora #$50
	tax
	EIF
qq4
	IF  FEAT_BASS16G3L
	lda trackn_command+3
	and #$0e
	cmp #6
	bne qq5
	lda trackn_audc+3
	and #$0f
	beq qq5
	ldy trackn_outnote+3
	lda frqtabbasslo,y
	sta trackn_audf+2
	lda frqtabbasshi,y
	sta trackn_audf+3
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq4a
	EIF
	lda #0
	sta trackn_audc+2
qq4a
	txa
	ora #$28
	tax
	EIF
	EIF
qq5
	stx v_audctl
	IF  STEREO8T
	IF  FEAT_AUDCTLMANUALSET
	ldx #3
	lda #0
qs0	ora trackn_audctl+4,x
	dex
	bpl qs0
	sta v_audctl2
qs1
	ldx v_audctl2
	ELSE
	ldx #0
	stx v_audctl2
	EIF
	IF  FEAT_FILTER
	IF  FEAT_FILTERG0R
	lda trackn_command+0+4
	bpl qs2
	lda trackn_audc+0+4
	and #$0f
	beq qs2
	lda trackn_audf+0+4
	clc
	adc trackn_filter+0+4
	sta trackn_audf+2+4
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
	lda trackn_audc+2+4
	and #$10
	bne qs1a
	EIF
	lda #0
	sta trackn_audc+2+4
qs1a
	txa
	ora #4
	tax
	EIF
qs2
	IF  FEAT_FILTERG1R
	lda trackn_command+1+4
	bpl qs3
	lda trackn_audc+1+4
	and #$0f
	beq qs3
	lda trackn_audf+1+4
	clc
	adc trackn_filter+1+4
	sta trackn_audf+3+4
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3R
	lda trackn_audc+3+4
	and #$10
	bne qs2a
	EIF
	lda #0
	sta trackn_audc+3+4
qs2a
	txa
	ora #2
	tax
	EIF
qs3
	IF  FEAT_FILTERG0R||FEAT_FILTERG1R
	cpx v_audctl2
	bne qs5
	EIF
	EIF
	IF  FEAT_BASS16
	IF  FEAT_BASS16G1R
	lda trackn_command+1+4
	and #$0e
	cmp #6
	bne qs4
	lda trackn_audc+1+4
	and #$0f
	beq qs4
	ldy trackn_outnote+1+4
	lda frqtabbasslo,y
	sta trackn_audf+0+4
	lda frqtabbasshi,y
	sta trackn_audf+1+4
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0R
	lda trackn_audc+0+4
	and #$10
	bne qs3a
	EIF
	lda #0
	sta trackn_audc+0+4
qs3a
	txa
	ora #$50
	tax
	EIF
qs4
	IF  FEAT_BASS16G3R
	lda trackn_command+3+4
	and #$0e
	cmp #6
	bne qs5
	lda trackn_audc+3+4
	and #$0f
	beq qs5
	ldy trackn_outnote+3+4
	lda frqtabbasslo,y
	sta trackn_audf+2+4
	lda frqtabbasshi,y
	sta trackn_audf+3+4
	IF  FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
	lda trackn_audc+2+4
	and #$10
	bne qs4a
	EIF
	lda #0
	sta trackn_audc+2+4
qs4a
	txa
	ora #$28
	tax
	EIF
	EIF
qs5
	stx v_audctl2
	EIF
rmt_p5
	lda v_ainstrspeed
	rts
SetPokey
	IF  STEREO8T
	ldy v_audctl2
	lda trackn_audf+0+4
	ldx trackn_audf+0
	sta POKEY_BASE_S+$00
	stx POKEY_BASE+$00
	lda trackn_audc+0+4
	ldx trackn_audc+0
	sta POKEY_BASE_S+$01
	stx POKEY_BASE+$01
	lda trackn_audf+1+4
	ldx trackn_audf+1
	sta POKEY_BASE_S+$02
	stx POKEY_BASE+$02
	lda trackn_audc+1+4
	ldx trackn_audc+1
	sta POKEY_BASE_S+$03
	stx POKEY_BASE+$03
	lda trackn_audf+2+4
	ldx trackn_audf+2
	sta POKEY_BASE_S+$04
	stx POKEY_BASE+$04
	lda trackn_audc+2+4
	ldx trackn_audc+2
	sta POKEY_BASE_S+$05
	stx POKEY_BASE+$05
	lda trackn_audf+3+4
	ldx trackn_audf+3
	sta POKEY_BASE_S+$06
	stx POKEY_BASE+$06
	lda trackn_audc+3+4
	ldx trackn_audc+3
	sta POKEY_BASE_S+$07
	stx POKEY_BASE+$07
	lda v_audctl
	sty POKEY_BASE_S+$08
	sta POKEY_BASE+$08
	ELSE
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta POKEY_BASE+$00
	stx POKEY_BASE+$01
	lda trackn_audf+1
	ldx trackn_audc+1
	sta POKEY_BASE+$00+2
	stx POKEY_BASE+$01+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta POKEY_BASE+$00+4
	stx POKEY_BASE+$01+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta POKEY_BASE+$00+6
	stx POKEY_BASE+$01+6
	sty POKEY_BASE+$08
	EIF
	rts
SetUpInstrumentY2
	lda (p_instrstable),y
	sta trackn_instrdb,x
	sta _nt
	iny
	lda (p_instrstable),y
	sta trackn_instrhb,x
	sta _nt+1
	ldy #0
	lda (_nt),y
	sta trackn_tableend,x
	clc
	adc #1
	sta trackn_instridx,x
	iny
	lda (_nt),y
	sta trackn_tablelop,x
	iny
	lda (_nt),y
	sta trackn_instrlen,x
	iny
	lda (_nt),y
	sta trackn_instrlop,x
	iny
	lda (_nt),y
	sta trackn_tabletypespeed,x
	IF  FEAT_TABLETYPE||FEAT_TABLEMODE
	and #$3f
	EIF
	sta trackn_tablespeeda,x
	IF  FEAT_TABLEMODE
	lda (_nt),y
	and #$40
	sta trackn_tablemode,x
	EIF
	iny
	IF  FEAT_AUDCTLMANUALSET
	lda (_nt),y
	sta trackn_audctl,x
	EIF
	iny
	lda (_nt),y
	sta trackn_volumeslidedepth,x
	iny
	lda (_nt),y
	sta trackn_volumemin,x
	iny
	lda (_nt),y
	sta trackn_effdelay,x
	iny
	lda (_nt),y
	tay
	lda vibtabbeg,y
	sta trackn_effvibratoa,x
	sta trackn_effvibratobeg,x
	lda vibtabbeg+1,y
	sta trackn_effvibratoend,x
	ldy #10
	lda (_nt),y
	sta trackn_effshift,x
	lda #128
	sta trackn_volumeslidevalue,x
	lda #0
	sta trackn_instrreachend,x
	sta trackn_shiftfrq,x
	lda #INSTRPAR
	sta trackn_tablea,x
	tay
	lda (_nt),y
	sta trackn_tablenote,x
	IF  FEAT_FILTER
	lda #1
	sta trackn_filter,x
	EIF
	rts
InstrumentsEffects
	lda trackn_effdelay,x
	beq ei2
	tay
	dey
	bne ei1
	lda trackn_shiftfrq,x
	clc
	adc trackn_effshift,x
	clc
	ldy trackn_effvibratoa,x
	adc vib0,y
	sta trackn_shiftfrq,x
	iny
	tya
	cmp trackn_effvibratoend,x
	bne ei1a
	lda trackn_effvibratobeg,x
ei1a
	sta trackn_effvibratoa,x
	jmp ei2
ei1
	tya
	sta trackn_effdelay,x
ei2
	lda trackn_tableend,x
	cmp #INSTRPAR
	beq ei3
	lda trackn_tablespeeda,x
	bpl ei2f
ei2c
	lda trackn_tablea,x
	clc
	adc #1
	cmp trackn_tableend,x
	bcc ei2a
	beq ei2a
	lda trackn_tablelop,x
ei2a
	sta trackn_tablea,x
	lda trackn_instrdb,x
	sta _nt
	lda trackn_instrhb,x
	sta _nt+1
	ldy trackn_tablea,x
	lda (_nt),y
	IF  FEAT_TABLEMODE
	ldy trackn_tablemode,x
	beq ei2e
	clc
	adc trackn_tablenote,x
ei2e
	EIF
	sta trackn_tablenote,x
	lda trackn_tabletypespeed,x
	IF  FEAT_TABLETYPE||FEAT_TABLEMODE
	and #$3f
	EIF
ei2f
	sec
	sbc #1
	sta trackn_tablespeeda,x
ei3
	lda trackn_instrreachend,x
	bpl ei4
	lda trackn_volume,x
	beq ei4
	cmp trackn_volumemin,x
	beq ei4
	bcc ei4
	tay
	lda trackn_volumeslidevalue,x
	clc
	adc trackn_volumeslidedepth,x
	sta trackn_volumeslidevalue,x
	bcc ei4
	tya
	sbc #16
	sta trackn_volume,x
ei4
	jmp returnfromInstrumentsEffects

rmtmoduleend
 echo "  (rmtplayer module is using ",[(rmtmoduleend-rmtmodulestart)]d," bytes)"

 endif ; RMT
