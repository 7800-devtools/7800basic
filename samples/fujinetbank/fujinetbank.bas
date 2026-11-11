 rem fujinetbank -- FujiNet from a banked program. With romsize
 rem 128k the ROM is eight 16K banks, SuperGame's way: the last, bank 8,
 rem sits at $C000 for good, and the others take turns at $8000. Banks 2
 rem and 3 each make a real transaction from their own code; the mailbox
 rem subroutines live in bank 8, where every bank can reach them.
 set romsize 128k
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 dim ssid1 = $2200
 dim ssid2 = $2220
 dim ssid3 = $2240
 dim ix = var0

 for ix = 0 to 95 : ssid1[ix] = 32 : next
 clearscreen
 plotchars 'FUJINET 7800BASIC BANKED APP' 0 8 2
 plotchars 'BANK 1' 0 8 5
 plotchars ssid1 0 40 5 20
 plotchars 'BANK 2' 0 8 7
 plotchars ssid2 0 40 7 20
 plotchars 'BANK 3' 0 8 9
 plotchars ssid3 0 40 9 20
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 gosub acfg
 if fn_res <> FN_OK then goto failed
 for ix = 0 to 19 : ssid1[ix] = FN_REPLY[ix] : next
 gosub fetch2 bank2
 if fn_res <> FN_OK then goto failed
 gosub fetch3 bank3
 if fn_res <> FN_OK then goto failed
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 bank 2
fetch2
 gosub acfg
 if fn_res <> FN_OK then return otherbank
 for ix = 0 to 19 : ssid2[ix] = FN_REPLY[ix] : next
 return otherbank

 bank 3
fetch3
 gosub acfg
 if fn_res <> FN_OK then return otherbank
 for ix = 0 to 19 : ssid3[ix] = FN_REPLY[ix] : next
 return otherbank

 bank 8
 rem the font lives here too: MARIA reads it every line, and a font in
 rem bank 1 would turn to garbage while bank 2 or 3 is switched in
 incgraphic fujifont.png 320A

 rem acfg -- one GET_ADAPTERCONFIG_EXTENDED, from whichever bank calls
acfg
 fn_dev = FN_FUJI : fn_cmd = $C4 : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 return

 incbasic fujilib.bas
