 rem *** A simple demo to demo switching between rotary style input devices
 rem *** Note that you can access the X for all rotating controllers with
 rem *** the same X variable. You also can use the regular joystick button
 rem *** checking.

 displaymode 320A
 set zoneheight 8

 rem *** The paddle range. Increasing this will increase CPU usage during 
 rem *** the visible screen.
 set paddlerange 160

 rem *** paddles are one of the controllers that are read during the visible
 rem *** screen, and will eat up CPU cycles. Reducing the range in half and
 rem *** scaling the paddle values x2 will cut CPU usage in half, at the
 rem *** loss of resolution.
 rem set paddlerange 80
 rem set paddlescalex2 on

 rem *** When used like a paddle, the driving control needs to complete
 rem *** ~3 rotations to cover the screen. This setting doubles the delta
 rem *** values used, to add a boost.
 set drivingboost on

 rem *** Eliminate Y axis checking. Potentially more responsive for X. 
 set mousexonly on

 changecontrol 0 paddle

 dim firetest=a
 dim device=b

 incgraphic atascii_full.png 320A 1 0
 incgraphic arrow.png 320A

 characterset atascii_full
 alphachars ASCII

 rem *** set the colors for palette 0 and 1
  P0C2=$fb
  P1C2=$0F

main
 clearscreen

 rem ** the mouse buttons are read just like two-button joystick buttons...
 firetest=0
 if joy0fire0 then firetest=$80
 if joy0fire1 then firetest=firetest|$40
 BACKGRND=firetest

 if switchselect then gosub changecontroller

 if device=0 then plotchars 'device: paddle' 1 16 0
 if device=1 then plotchars 'device: st mouse' 1 16 0
 if device=2 then plotchars 'device: amiga mouse' 1 16 0
 if device=3 then plotchars 'device: driving controller' 1 16 0

 plotvalue atascii_full 1 mousex0 2 0 0

 rem ** Draw the sprite, wait a frame, and loop...
 plotsprite arrow 0 mousex0 100
 drawscreen
 goto main

changecontroller
  clearscreen
  drawscreen
  if switchselect then goto changecontroller
  device=(device+1)&3
  if device=0 then changecontrol 0 paddle
  if device=1 then changecontrol 0 stmouse
  if device=2 then changecontrol 0 amigamouse
  if device=3 then changecontrol 0 driving
  return
