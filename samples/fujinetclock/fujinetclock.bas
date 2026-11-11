 rem fujinetclock -- the time of day, from the adapter's clock (device $45),
 rem asked again once a second.
 rem
 rem   GET_ISO_LOCAL  $49 'I'  no parameters; 25 characters of local time
 rem   GET_ISO_UTC    $5A 'Z'  the same in UTC
 rem
 rem Needs: a FujiNet cartridge with WiFi and the time set (it asks NTP).
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 dim local = $2200
 dim utc = $2220
 dim ix = var0

 clearscreen
 plotchars 'CLOCK' 0 8 2
 plotchars 'LOCAL' 0 8 5
 plotchars local 0 40 5 25
 plotchars 'UTC' 0 8 7
 plotchars utc 0 40 7 25
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

refresh
 fn_dev = FN_CLOCK : fn_cmd = $49 : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 for ix = 0 to 24 : local[ix] = FN_REPLY[ix] : next

 fn_dev = FN_CLOCK : fn_cmd = $5A : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 for ix = 0 to 24 : utc[ix] = FN_REPLY[ix] : next

 rem a second of frames, then ask again
 for ix = 1 to 60 : drawscreen : next
 goto refresh

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 incbasic fujilib.bas
