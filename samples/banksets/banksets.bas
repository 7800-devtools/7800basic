 	
  rem *** This is the "adventurer" sample, converted to banksets
  rem *** There were only 3 changes required to use banksets.
  rem *** 
  rem ***   1 - add "set banksets on" near the top of the source
  rem ***   2 - add "bset_" to the name of the alphadata that displays the word "demo"
  rem ***   3 - add "bset_" to the name of the alphadata that defines the screen tiles.
  rem *** 

  set doublewide on
  set tv ntsc
  set banksets on

  dim xpos=a
  dim ypos=b
  dim frame=c
  dim herodir=d
  dim moving=e
  dim heroframe=f
 
  displaymode 160A

  xpos=40

  rem ** setup Palette 1
  P1C1=$12
  P1C2=$F6
  P1C3=$Fc

  rem ** setup Palette 2
  P2C1=$62
  P2C2=$86
  P2C3=$ac

  incgraphic gfx/tileset_blanks.png 160A 3 0 1 2
  incgraphic gfx/tileset_rocks.png 
  incgraphic gfx/scoredigits_8_wide.png
  incgraphic gfx/alphabet_8_wide.png 160A 0 2 1 3 

  incgraphic gfx/herodown1.png
  incgraphic gfx/herodown2.png
  incgraphic gfx/heroleft1.png
  incgraphic gfx/heroleft2.png
  incgraphic gfx/heroup1.png
  incgraphic gfx/heroup2.png
  incgraphic gfx/heroright1.png
  incgraphic gfx/heroright2.png

  P0C1=heroright2_color1
  P0C2=heroright2_color2
  P0C3=heroright2_color3

  rem ** activate the graphics area with our tiles...
  characterset tileset_blanks

  clearscreen

  rem ** put the background down and save the screen before the main loop. 
  rem ** this way we don't setup the background over and over again.

  plotmap bset_screen1map 1 0 0 20 12
  plotchars bset_demotext 2 64 3 4
  savescreen

  drawscreen

mainloop

    z=$11
    frame=(frame+1)&31
    if frame=0 then score0=score0+1:score1=score1+z

    BACKGRND=$00
    if joy0fire1 then BACKGRND=$38
    if joy0fire0 then BACKGRND=$a8

    rem ** move our hero in only the cardinal directions...
    moving=moving+1
    if joy0down  then ypos=ypos+1:herodir=0:goto doneherowalk
    if joy0up    then ypos=ypos-1:herodir=2:goto doneherowalk
    if joy0left  then xpos=xpos-1:herodir=1:goto doneherowalk
    if joy0right then xpos=xpos+1:herodir=3:goto doneherowalk
    moving=moving-1 : rem we didn't move
doneherowalk

    restorescreen

    rem ** calculate which animation frame to display, based on direction and
    rem ** the walking counter...

    heroframe=(herodir*2)+((moving/16)&1)
    plotsprite herodown1 0 xpos ypos heroframe

    plotvalue scoredigits_8_wide 2 score0 6 56 11
    plotvalue scoredigits_8_wide 2 score1 6 56 10

    drawscreen

    goto mainloop

 alphadata bset_demotext alphabet_8_wide
 'demo'
end

 alphachars ' abcdefghijklmnopqrstuvwxyz' 

 alphadata bset_screen1map tileset_blanks
 'hifgfg        fgfghi'
 'hi                hi'
 'hi                hi'
 'fg                fg'
 '                    '
 '                    '
 '                    '
 '                    '
 'hi                hi'
 'hi                hi'
 'hi              dehi'
 'fgfgfg        fgfgfg'
end
