
  rem ** 69 sprites with background and double-buffered display. This routine 
  rem ** and 7800basic can handle more, but Maria runs out of DMA time when 
  rem ** too many of the sprites drift into the same zone. As it stands, this 
  rem ** demo intentionally spreads the sprites out vertically, to help Maria
  rem ** out. Think of this demo as an upper-bound for regular sprite 
  rem ** plotting.
  rem **
  rem ** This demo uses some inline assembly for the text scroller.

  rem ** Make the rom a 128k cart with ram, because we want extra RAM
  set romsize 128kRAM
  set 7800header 'name Sixty-Nine Sprites... Nice!'

  set pokeysupport $450
  set trackersupport rmt

  set zoneheight 16
  set screenheight 208

  rem ** setup some cart ram as display list memory
  set dlmemory $4000 $67ff
  dim RMTRAM=$6800

  rem ** memory that holds our scrolling text, so we can update it
  rem ** one character at a time.
  dim scrollerram=$6900
  dim scrollerram2=$6900+20

  characterset atascii
  alphachars ASCII

  dim frame=a
  dim tempplayerx=b
  dim tempplayery=c
  dim tempplayercolor=d
  dim tempplayerdx=e
  dim tempplayerdy=f
  dim tempanim=g

  dim textpointlo=h
  dim textpointhi=i

  dim textfinescroll=j
  dim texttock=k

  rem ** variable arrays for holding sprite info
  dim playerx=$2200
  dim playery=$2300
  dim playerdx=$2400
  dim playerdy=$2500

  rem ** include graphics
  incgraphic gfx/atascii.png 320A
  rem incgraphic gfx/ball.png
  incgraphic gfx/ring1.png
  incgraphic gfx/ring2.png
  incgraphic gfx/ring3.png
  incgraphic gfx/ring4.png
  goto rundemo
  incrmtfile enigmapt2.rmta
  bank 8
  dmahole 0 noflow
rundemo
  incbanner gfx/golum.png

  BACKGRND=$00

  rem ** initialize the position of a bunch of sprites
  x=10: y=8
  for z=0 to 100
    playerx[z]=x
    playery[z]=y
    rem y=y+34
    rem y=y+23
    y=y+17
    x=rand
    if y>191 then y=y-191
    if x>149 then x=x-149
    playerdx[z]=(rand&2)-1
    playerdy[z]=(rand&2)-1
  next

  rem ** draw the screen background
  clearscreen
  drawscreen

  doublebuffer on

  alphadata scrollertext atascii
  ' ***  Welcome to the 7800basic 69 Sprite Demo, '
  'featuring music by Radek "Raster" Sterba  ***  '
  '        '
  '"One precious, two precious, three... so many preciousssses '
  'everywhere!!!", Gollum shouted, staring at the screen in disbelief!   '
  '"Howsits doing that?!?" he said, brow furrowed. Reaching out, he grabbed '
  'the 7800 console, yanking it from it's cables, clutching it to his chest. '
  'And without another sound, Gollum sank into the depths of the dark misty '
  'woods.  ***  '
  '        '
  'Listen. It's calling. The 7800 is whispering in your ear, reaching inside '
  'you, and burrowing deep down into your soul. Won't you answer your '
  'precioussss?'
  '                                              '
  '@'
end
  memcpy scrollerram scrollertext 512
  asm
  lda #<scrollertext
  sta textpointlo
  lda #>scrollertext
  sta textpointhi
end

  memset scrollerram 32 42
  plotchars scrollerram  5 0  0 20
  plotchars scrollerram2 5 80 0 21

  plotbanner golum 4 0 16

  rem ** it's important buffering is active before the savescreen.
  rem ** otherwise savescreen won't copy the saved screen into both buffers.
  savescreen

  drawscreen

  rem ** ring colors
  P0C1=$A2: P0C2=$A9: P0C3=$Ae ; blue
  P1C1=$06: P1C2=$0c: P1C3=$0f ; white
  P2C1=$22: P2C2=$26: P2C3=$2c ; gold
  P3C1=$42: P3C2=$44: P3C3=$49 ; red

  rem ** golum
  P4C1=$c4: P4C2=$f8: P4C3=$0A

  rem ** start the music!
  playrmt enigmapt2

main

  asm
  ; This bit of assembly code is a hack. The song wasn't designed to
  ; repeat, so we observe some memory that gets set to $10 at the end
  ; of the song. This isn't universal... some day I'll put in the 
  ; effort to see if there's a universal way to detect a non-repeating
  ; song being complete.
  ldx #3
checktrackmarker  
  lda $680C,x
  cmp #$10
  bne .skipresetsong
  dex
  bpl checktrackmarker
end
  playrmt enigmapt2
skipresetsong

  tempanim=(framecounter/4)&3

 rem ** Without double-buffering, the 7800 works best if we split up the
 rem ** game logic from the plot commands. This isn't needed when double 
 rem ** buffering is used.

 restorescreen

 for z=0 to 69
     rem ** update each sprite position variable...
     tempplayerx=playerx[z]+playerdx[z]
     tempplayery=playery[z]+playerdy[z]
     if tempplayerx<1 then playerdx[z]=1:goto skipx 
     if tempplayerx>149 then playerdx[z]=-1
skipx
     if tempplayery<8 then playerdy[z]=1:goto skipy
     if tempplayery>193 then playerdy[z]=-1
skipy
     playerx[z]=tempplayerx
     playery[z]=tempplayery

     q=z&3
     tempanim=(tempanim+1)&3 ; un-sync all of the ring animations
     plotsprite ring1 q tempplayerx tempplayery tempanim
 next

 doublebuffer flip
 goto main

  rem ** 320A mode at the top of the screen for text, and color it line-by-line
topscreenroutine
  displaymode 320A
  WSYNC=0
  P5C2=$45
  WSYNC=0
  P5C2=$46
  WSYNC=0
  P5C2=$47
  WSYNC=0
  P5C2=$48
  WSYNC=0
  P5C2=$48
  WSYNC=0
  P5C2=$47
  WSYNC=0
  P5C2=$46
  WSYNC=0
  P5C2=$45
  WSYNC=0
  WSYNC=0
  displaymode 160A
  asm

  ; slow down the text scroller by 50%
  inc texttock
  lda texttock
  and #1
  bne skipscroller 

  ; The text scroller moves the text pixel by pixel.
  ; More specifically, 3 out of 4 frames its just moving the X coordinate of
  ; the character objects 1 pixel to the left. (fine scroll)
  ; On the 4th frame it moves the X coordinate of the character objects back to
  ; the starting position on the right, and advances the text buffer by 1 
  ' character. (coarse scroll)

  inc textfinescroll
  lda textfinescroll
  and #3
  sta textfinescroll
  tay
  lda offset2,y      ; get the X coordinate value for the first char object
  sta ZONE0ADDRESS+9 ; and store it the object's X coordinate byte.
  sta ZONE0ADDRESS+9+DOUBLEBUFFEROFFSET ; (in both screen buffers)
  lda offset1,y      ; get the X coordinate value for the second char object
  sta ZONE0ADDRESS+4 ; and store it the object's X coordinate byte.
  sta ZONE0ADDRESS+4+DOUBLEBUFFEROFFSET ; (in both screen buffers)
  bne skipscroller
readnextchar
  inc textpointlo
  bne skiptextpointhiinc
  inc textpointhi
skiptextpointhiinc
  ldy #0
  lda (textpointlo),y
  cmp #64 ; '@' is the end-of-text marker
  bne skipscrollerreset
scrollerreset
  lda #<scrollertext
  sta textpointlo
  lda #>scrollertext
  sta textpointhi
  lda (textpointlo),y
skipscrollerreset
  sta scrollerram+41 ; update the last character in the buffer
  ldx #0
shiftcharactersloop
  lda scrollerram+1,x
  sta scrollerram,x
  inx
  cpx #41
  bne shiftcharactersloop
skipscroller
end
  return

 asm
offset1
  .byte 0,255,254,253
offset2
  .byte 80,79,78,77
end
