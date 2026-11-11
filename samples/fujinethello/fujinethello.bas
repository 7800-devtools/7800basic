 rem fujinethello -- the smallest FujiNet program: a screen, some text, and
 rem proof the cartridge is there. No transaction yet.
 rem
 rem   set fujinet on       stamps the FujiNet claim ("FUJI" at $FF70), so
 rem                        the cartridge gives the program its mailbox
 rem   incbasic fujinet.bas the mailbox names (from includes/)
 rem   fn_chk               looks for the cartridge's 'F','N' signature
 rem
 rem Needs: a FujiNet Atari 7800 cartridge (or the FujiNet MAME).
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 clearscreen
 plotchars 'FUJINET ATARI 7800' 0 8 2
 plotchars 'HELLO, WORLD' 0 8 4
 gosub fn_chk
 if fn_res <> FN_OK then goto nocart
 plotchars 'A FUJINET CARTRIDGE ANSWERS' 0 8 6
 rem MODE 3 = the cartridge started this program as an app
 if FN_MODE = 3 then plotchars 'RUNNING AS AN APP' 0 8 7
 goto main
nocart
 plotchars 'NO FUJINET CARTRIDGE' 0 8 6

main
 drawscreen
 goto main

 incbasic fujilib.bas
