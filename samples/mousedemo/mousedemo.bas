
 rem *** a simple mouse pointer demo

 displaymode 320A

 set zoneheight 8

 changecontrol 0 stmouse

 dim firetest=a

 incgraphic atascii_full.png 320A 1 0
 incgraphic arrow.png 320A

 characterset atascii_full

 rem *** set the colors for palette 0 and 1
  P0C2=$fb
  P1C2=$0F

 mousex0=40
 mousey0=50

main
 clearscreen

 rem ** the mouse buttons are read just like two-button joystick buttons...
 firetest=0
 if joy0fire0 then firetest=$80
 if joy0fire1 then firetest=firetest|$40
 BACKGRND=firetest

 plotvalue atascii_full 1 mousex0 8 40 19

 rem ** Draw the sprite, wait a frame, and loop...
 plotsprite arrow 0 mousex0 mousey0
 drawscreen
 goto main

