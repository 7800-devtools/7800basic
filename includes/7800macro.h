 ; Provided under the CC0 license. See the included LICENSE.txt for details.

; 7800MACRO.H

;-------------------------------------------------------
; BOXCOLLISIONCHECK
; author: Mike Saarna
;
; A general bounding box collision check. compares 2 rectangles of differing size
; and shape for overlap. Carry is set for collision detected, clear for none.
; 
; Usage: BOXCOLLISIONCHECK x1var,y1var,w1var,h1var,x2var,y2var,w2var,h2var
;

 MAC BOXCOLLISIONCHECK
.boxx1    SET {1}
.boxy1    SET {2}
.boxw1    SET {3}
.boxh1    SET {4}
.boxx2    SET {5}
.boxy2    SET {6}
.boxw2    SET {7}
.boxh2    SET {8}

.DoXCollisionCheck
     lda .boxx1 ;3
     cmp .boxx2 ;2
     bcs .X1isbiggerthanX2 ;2/3
.X2isbiggerthanX1
     adc #.boxw1 ;2
     cmp .boxx2 ;3
     bcs .DoYCollisionCheck ;3/2
     bcc .noboxcollision ;3
.X1isbiggerthanX2
     clc ;2
     sbc #.boxw2 ;2
     cmp .boxx2 ;3
     bcs .noboxcollision ;3/2
.DoYCollisionCheck
     lda .boxy1 ;3
     cmp .boxy2 ;3
     bcs .Y1isbiggerthanY2 ;3/2
.Y2isbiggerthanY1
     adc #.boxh1 ;2
     cmp .boxy2 ;3
     jmp .checkdone ;6 
.Y1isbiggerthanY2
     clc ;2
     sbc #.boxh2 ;2
     cmp .boxy2 ;3
     bcs .noboxcollision ;3/2
.boxcollision
     sec ;2
     .byte $24 ; hardcoded "BIT [clc opcode]", used to skip over the following clc
.noboxcollision
     clc ;2
.checkdone

 ENDM

; QBOXCOLLISIONCHECK
; author: unknown
;
; A general bounding box collision check. compares 2 rectangles of differing size
; and shape for overlap. Carry is CLEAR for collision detected, SET for none.
; 
; Usage: QBOXCOLLISIONCHECK x1var,y1var,w1var,h1var,x2var,y2var,w2var,h2var
;
 MAC QBOXCOLLISIONCHECK
.boxx1    SET {1}
.boxy1    SET {2}
.boxw1    SET {3}
.boxh1    SET {4}
.boxx2    SET {5}
.boxy2    SET {6}
.boxw2    SET {7}
.boxh2    SET {8}

	lda .boxx2
	clc
	adc #.boxw2
	sbc .boxx1
	cmp #.boxw1+.boxw2-1
	bcs .qboxcollisiondone
	;if we're here, carry is clear
 	lda .boxy2
	adc #.boxh2
	sbc .boxy1
	cmp #.boxh1+.boxh2-1
.qboxcollisiondone
	rol ; temp for testing - invert carry...
	eor #1
	ror
 ENDM


 MAC MEDIAN3

	; A median filter (for smoothing paddle jitter)
	;   this macro takes the current paddle value, compares it to historic
	;   values, and replaces the current paddle value with the median.
	; 
	; called as:  MEDIAN3 STORAGE CURRENT
	;    where STORAGE points to 3 consecutive bytes of memory. The first 2
	;        must be dedicated to this MEDIAN filter. The last 1 is a temp.
	;    where CURRENT is memory holding the new value you wish to compare to
	;        the previous values, and update with the median value.
	;
	; returns: CURRENT (modified to contain median value)
	;
	; author: Mike Saarna (aka RevEng)

.MedianBytes    SET {1}
.NewValue       SET {2}

	lda #0
	ldy .NewValue
	sty .MedianBytes+2 ; put the new value in the most "recent" slot

	; build an index from relative size comparisons between our 3 values.
	cpy .MedianBytes
	rol
	cpy .MedianBytes+1
	rol
	ldy .MedianBytes
	cpy .MedianBytes+1
	rol
	tay

	ldx MedianOrderLUT,y ; convert the size-comparison index to an index to the median value
	lda .MedianBytes,x
	sta .NewValue ; we replace the new value memory with the median value

	; then shift values from "newer" bytes to "older" bytes, leaving the 
	; newest byte (.MedianBytes+2) empty for next time.
	lda .MedianBytes+1 
	sta .MedianBytes
	lda .MedianBytes+2
	sta .MedianBytes+1
 ifnconst MedianOrderLUT
	jmp MedianOrderLUTend
MedianOrderLUT ; converts our "comparison index" to an index to the median value
	.byte 0 ; 0  B2 < B0 < B1
	.byte 1 ; 1  B2 < B1 < B0
	.byte 2 ; 2   impossible 
	.byte 2 ; 3  B1 < B2 < B0
	.byte 2 ; 4  B0 < B2 < B1
	.byte 2 ; 5   impossible 
	.byte 1 ; 6  B0 < B1 < B2
	.byte 0 ; 7  B1 < B0 < B2
MedianOrderLUTend
 endif
   ENDM

 MAC PLOTSPRITE

	; A macro version of the plotsprite command. 
	; This trades off rom space for speed.
	; It also doesn't check if the visible screen is displayed or not.
	; It has no training wheels. It is all rusty sharp edges.

.GFXLabel   SET {1} ; constant
.Palette    SET {2} ; constant/variable MACARG2CONST
.SpriteX    SET {3} ; constant/variable MACARG3CONST
.SpriteY    SET {4} ; constant/variable MACARG4CONST
.ByteOffset SET {5} ; constant/variable MACARG5CONST

 if MACARG4CONST = 0
	lda .SpriteY
 else
	lda #.SpriteY
 endif

        lsr
        lsr
        asr #%11111110 ; ensure carry is clear
   if WZONEHEIGHT = 16
        asr #%11111110 ; ensure carry is clear
   endif
 
	tax

        cpx #WZONECOUNT
	bcs .PLOTSPRITEnext
	; carry is clear
	
        ifconst VSCROLL
		ldy Xx3,x
		lda DLLMEM+11,y
        else  ; !VSCROLL
		lda DLPOINTL,x ; Get pointer to DL that this sprite starts in
        endif
	ifconst DOUBLEBUFFER
		adc doublebufferdloffset
	endif ; DOUBLEBUFFER
	sta dlpnt
	ifconst VSCROLL
		lda DLLMEM+10,y
	else  ; !VSCROLL
		lda DLPOINTH,x
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc #0
	endif ; DOUBLEBUFFER
	sta dlpnt+1
	
 	ldy dlend,x ; find the next new object position in this zone

 ifconst .ByteOffset

 if MACARG5CONST = 1
	lda #.ByteOffset 
 else
	lda .ByteOffset 
 endif
	ifconst DOUBLEBUFFER
 	if {1}_width = 1
        	clc
 	endif
 	endif
 if {1}_width = 2
        asl
 endif
 if {1}_width = 3
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 4
        asl
        asl
 endif
 if {1}_width = 5
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 6
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 7
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 8
        asl
        asl
        asl
 endif
 if {1}_width = 9
        asl
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 10
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 11
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 12
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 endif
 if {1}_width = 13
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 
 endif
 if {1}_width = 14
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 15
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 16
        asl
        asl
        asl
        asl
 endif
	adc #<.GFXLabel ; carry is clear via previous asl or asr
 else
	lda #<.GFXLabel ; carry is clear via previous asl or asr
 endif ; .ByteOffset
        sta (dlpnt),y ; #1 - low byte object address

	iny

	lda #({1}_mode | %01000000)
	sta (dlpnt),y ; #2 - graphics mode , indirect

	iny

 if MACARG4CONST = 0
	lda .SpriteY
 else
	lda #.SpriteY
 endif
	and #(WZONEHEIGHT - 1)
	cmp #1 ; clear carry if our sprite is just in this zone
	ora #>.GFXLabel
	sta (dlpnt),y ; #3 - hi byte object address

	iny

 if MACARG2CONST = 1
	lda #({1}_width_twoscompliment | (.Palette * 32))
 else
	lda #({1}_width_twoscompliment)
	ora .Palette
 endif
	sta (dlpnt),y ; #4 - palette|width

	iny

 if MACARG3CONST = 1
	lda #.SpriteX
 else
	lda .SpriteX
 endif
	sta (dlpnt),y ; #5 - x object position

        iny
        sty dlend,x

    ifconst ALWAYSTERMINATE
         iny
         lda #0
         sta (dlpnt),y
     endif

	bcc .PLOTSPRITEend

.PLOTSPRITEnext
	inx ; next zone

        cpx #WZONECOUNT
	bcs .PLOTSPRITEend 
	; carry is clear

	ifconst VSCROLL
		ldy Xx3,x
		lda DLLMEM+11,y
	else  ; !VSCROLL
		lda DLPOINTL,x ;Get pointer to DL that this sprite starts in
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc doublebufferdloffset
	endif ; DOUBLEBUFFER
	sta dlpnt
	ifconst VSCROLL
		lda DLLMEM+10,y
	else  ; !VSCROLL
		lda DLPOINTH,x
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc #0
	endif ; DOUBLEBUFFER
	sta dlpnt+1
	
 	ldy dlend,x ; find the next new object position in this zone

 ifconst .ByteOffset

 if MACARG5CONST = 1
	lda #.ByteOffset 
 else
	lda .ByteOffset 
 endif
 if {1}_width = 1
        clc
 endif
 if {1}_width = 2
        asl ; carry clear
 endif
 if {1}_width = 3
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 4
        asl ; carry clear
        asl
 endif
 if {1}_width = 5
        asl ; carry clear
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 6
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 7
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 8
        asl ; carry clear
        asl
        asl
 endif
 if {1}_width = 9
        asl ; carry clear
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 10
        asl ; carry clear
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 11
        asl ; carry clear
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 12
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 endif
 if {1}_width = 13
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 14
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 15
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 16
        asl
        asl
        asl
        asl
 endif
	adc #<.GFXLabel
 else
	lda #<.GFXLabel
 endif ; .ByteOffset

        sta (dlpnt),y ; #1 - low byte object address

	iny

	lda #({1}_mode | %01000000)
	sta (dlpnt),y ; #2 - graphics mode , indirect

	iny

 if MACARG4CONST = 0
	lda .SpriteY
 else
	lda #.SpriteY
 endif
	and #(WZONEHEIGHT - 1)
	ora #>(.GFXLabel - (WZONEHEIGHT * 256)) ; start in the dma hole
	sta (dlpnt),y ; #3 - hi byte object address

	iny

 if MACARG2CONST = 1
	lda #({1}_width_twoscompliment | (.Palette * 32))
 else
	lda #({1}_width_twoscompliment)
	ora .Palette
 endif
	sta (dlpnt),y ; #4 - palette|width

	iny

 if MACARG3CONST = 1
	lda #.SpriteX
 else
	lda .SpriteX
 endif
	sta (dlpnt),y ; #5 - x object position

	iny
	sty dlend,x

    ifconst ALWAYSTERMINATE
         iny
         lda #0
         sta (dlpnt),y
     endif

.PLOTSPRITEend
 ENDM

 MAC PLOTSPRITE4

	; A macro version of plotsprite. (with 4 byte objects)
	; This trades off rom space for speed.
	; It also doesn't check if the visible screen is displayed or not.
	; It has no training wheels. It is all rusty sharp edges.

.GFXLabel   SET {1}
.Palette    SET {2} ; constant
.SpriteX    SET {3} ; variable
.SpriteY    SET {4} ; variable
.ByteOffset SET {5} ; variable 

 if MACARG4CONST = 0
	lda .SpriteY
 else
	lda #.SpriteY
 endif
        lsr
        lsr
        asr #%11111110 ; ensure carry is clear
   if WZONEHEIGHT = 16
        asr #%11111110 ; ensure carry is clear
   endif
 
	tax

        cpx #WZONECOUNT
	bcs .PLOTSPRITEnext
	; carry is clear
	ifconst VSCROLL
		ldy Xx3,x
		lda DLLMEM+11,y
	else  ; !VSCROLL
		lda DLPOINTL,x ;Get pointer to DL that this sprite starts in
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc doublebufferdloffset
	endif ; DOUBLEBUFFER
	sta dlpnt
	ifconst VSCROLL
		lda DLLMEM+10,y
	else  ; !VSCROLL
		lda DLPOINTH,x
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc #0
	endif ; DOUBLEBUFFER
	sta dlpnt+1
	
 	ldy dlend,x ; find the next new object position in this zone

 ifconst .ByteOffset

 if MACARG5CONST = 1
	lda #.ByteOffset 
 else
	lda .ByteOffset 
 endif
	ifconst DOUBLEBUFFER
 	if {1}_width = 1
       		clc
 	endif
 	endif
 if {1}_width = 2
        asl
 endif
 if {1}_width = 3
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 4
        asl
        asl
 endif
 if {1}_width = 5
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 6
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif

        asl
 endif
 if {1}_width = 7
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 8
        asl
        asl
        asl
 endif
 if {1}_width = 9
        asl
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 10
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 11
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 12
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 endif
 if {1}_width = 13
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 14
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 15
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 16
        asl
        asl
        asl
        asl
 endif
	adc #<.GFXLabel ; carry is clear via previous asl or asr
 else
	lda #<.GFXLabel ; carry is clear via previous asl or asr
 endif ; .ByteOffset
        sta (dlpnt),y ; #1 - low byte object address

	iny

 if MACARG2CONST = 1
	lda #({1}_width_twoscompliment | (.Palette * 32))
 else
	lda #({1}_width_twoscompliment)
	ora .Palette
 endif
	sta (dlpnt),y ; #2 - palette|width

	iny
 if MACARG4CONST = 0
	lda .SpriteY
 else
	lda #.SpriteY
 endif
	and #(WZONEHEIGHT - 1)
	cmp #1 ; clear carry if our sprite is just in this zone
	ora #>.GFXLabel
	sta (dlpnt),y ; #3 - hi byte object address

	iny
 if MACARG3CONST = 1
	lda #.SpriteX
 else
	lda .SpriteX
 endif
	sta (dlpnt),y ; #4 - x object position

        iny
        sty dlend,x

    ifconst ALWAYSTERMINATE
         iny
         lda #0
         sta (dlpnt),y
     endif

	bcc .PLOTSPRITEend

.PLOTSPRITEnext
	inx ; next zone

        cpx #WZONECOUNT
	bcs .PLOTSPRITEend 
	; carry is clear
	ifconst VSCROLL
		ldy Xx3,x
		lda DLLMEM+11,y
	else  ; !VSCROLL
		lda DLPOINTL,x ;Get pointer to DL that this sprite starts in
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc doublebufferdloffset
	endif ; DOUBLEBUFFER
	sta dlpnt
	ifconst VSCROLL
		lda DLLMEM+10,y
	else  ; !VSCROLL
		lda DLPOINTH,x
	endif ; !VSCROLL
	ifconst DOUBLEBUFFER
		adc #0
	endif ; DOUBLEBUFFER
	sta dlpnt+1
	
 	ldy dlend,x ; find the next new object position in this zone

 ifconst .ByteOffset

 if MACARG5CONST = 1
	lda #.ByteOffset 
 else
	lda .ByteOffset 
 endif
 if {1}_width = 1
        clc
 endif
 if {1}_width = 2
        asl ; carry clear
 endif
 if {1}_width = 3
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 4
        asl ; carry clear
        asl
 endif
 if {1}_width = 5
        asl ; carry clear
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 6
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 
        asl
 endif
 if {1}_width = 7
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 8
        asl ; carry clear
        asl
        asl
 endif
 if {1}_width = 9
        asl ; carry clear
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 10
        asl ; carry clear
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 11
        asl ; carry clear
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 12
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 endif
 if {1}_width = 13
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 14
        asl ; carry clear
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 endif
 if {1}_width = 15
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
        asl
 if MACARG5CONST = 1
	adc #.ByteOffset 
 else
	adc .ByteOffset 
 endif
 endif
 if {1}_width = 16
        asl
        asl
        asl
        asl
 endif
	adc #<.GFXLabel
 else
	lda #<.GFXLabel
 endif ; .ByteOffset
        sta (dlpnt),y ; #1 - low byte object address

	iny
 if MACARG2CONST = 1
	lda #({1}_width_twoscompliment | (.Palette * 32))
 else
	lda #({1}_width_twoscompliment)
	ora .Palette
 endif

	sta (dlpnt),y ; #2 - palette|width

	iny
 if MACARG4CONST = 0
	lda .SpriteY
 else
	lda #.SpriteY
 endif
	and #(WZONEHEIGHT - 1)
	ora #>(.GFXLabel - (WZONEHEIGHT * 256)) ; start in the dma hole
	sta (dlpnt),y ; #3 - hi byte object address

	iny
 if MACARG3CONST = 1
	lda #.SpriteX
 else
	lda .SpriteX
 endif
	sta (dlpnt),y ; #4 - x object position

	iny
	sty dlend,x

    ifconst ALWAYSTERMINATE
         iny
         lda #0
         sta (dlpnt),y
     endif

.PLOTSPRITEend
 ENDM

 MAC SCROLLSETUP

        ; If vertical scrolling is enabled...
        ;   * Fills the DLs with hidden masking sprites.
	; Adds blank sprites to the DLs to fill the screen.
	; If horizontal scrolling is enabled...
	;   * Adds another blank DL off-screen

	; {1} - constant - the first dl of the scrolling area
	; {2} - symbol   - blank tile label

	; *** clear the saved dl ending for scrolling zones...
	ldx #{1}
	lda #0
.scrollcleardls	
	sta dlend,x
	inx
	cpx #WZONECOUNT
	bne .scrollcleardls

 ifconst VSCROLL
	; *** adjust the ending for our mask dl to allow for mask objects...
	dex
	lda #(maskscrollspriteend-maskscrollsprite)
	sta dlend,x

	; *** Add 4x dma masking objects to last zone...
	ldx #(maskscrollspriteend-maskscrollsprite-1)
.scrollpopulateloop1
	lda maskscrollsprite,x
	sta LASTZONEADDRESS+0,x
	ifconst DOUBLEBUFFER
		sta LASTZONEADDRESS+0+DOUBLEBUFFEROFFSET,x
	endif ; DOUBLEBUFFER
	dex
	bpl .scrollpopulateloop1
	inx ; x=0
	stx finescrolly
 endif ; VSCROLL

	; *** Add blank sprite-tile objects to the scrolling zones...
PLOTSP4 = 1 ; ensure we use 4 byte sprites

	; convert byte width of the sprit to coordinate width...
 if {2}_mode = 0  ; ### 160A, 320A, 320D
.scrollXWIDTH SET ({2}_width * 4) ; 4x 160-mode pixels per byte
 else             ; ### 160B, 320B, 320C
.scrollXWIDTH SET ({2}_width * 2) ; 2x 160-mode pixels per byte
 endif

        ; figure out how many sprites we need to fill a screen width...
.scrollSPRITECOuNT SET ((160+.scrollXWIDTH-1)/.scrollXWIDTH)
 ifconst HSCROLL
.scrollSPRITECOuNT SET (.scrollSPRITECOuNT+1) 
 endif ; HSCROLL

	; setup plotsprite4 parameters...
	lda #<{2}
	sta temp1
	lda #>{2}
	sta temp2
	lda #{2}_width_twoscompliment
	sta temp3 ; width

	lda #{1}
	asl
	asl
	asl
 if WZONEHEIGHT
	asl
 endif
	sta temp5 ; Y
.scrollpopulateloop2
	lda #0
	sta temp4 ; X
.scrollpopulateloop3
	jsr skipplotsprite4wait
	lda temp4 ; X
	clc
	adc #.scrollXWIDTH
	sta temp4 ; X
	cmp #(.scrollSPRITECOuNT*.scrollXWIDTH)
	bne .scrollpopulateloop3
	lda temp5 ; Y
	clc
	adc #WZONEHEIGHT
	sta temp5 ; Y
	cmp #((WZONECOUNT*WZONEHEIGHT)+WZONEHEIGHT)
	bne .scrollpopulateloop2
 ENDM ; SCROLLSETUP

 MAC SIZEOF

	; echoes the size difference between the current address and the
	; a label that was passed as an argument. This is a quick way to
	; determine the size of a structure.

.NAME SETSTR {1}
        echo " The Size of",.NAME,"is:",[* - {1}]d,[* - {2}]d,"bytes."
  ENDM

