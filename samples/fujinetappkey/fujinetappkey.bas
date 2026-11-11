 rem fujinetappkey -- read the shared FujiNet username, then write a key of
 rem our own and read it back. Creator 1, app 1, key 0 is the player's
 rem name; ours is creator $7800, app $FF, key 0. OPEN_APPKEY takes ONE
 rem six-byte struct as its payload: creator (low, high), app, key, mode,
 rem and a reserved zero.
 rem
 rem   OPEN_APPKEY $DC   READ_APPKEY $DD   WRITE_APPKEY $DE   CLOSE_APPKEY $DB
 rem
 rem Needs: a FujiNet cartridge with an SD card; the keys are files in /FujiNet.
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 rem READ_APPKEY's value starts after its two-byte length
 dim FN_R_VALUE = $0802
 dim line1 = $2200
 dim line2 = $2220
 dim akcrelo = var0
 dim akcrehi = var1
 dim akapp = var2
 dim akmode = var3
 dim ix = var4
 dim len = var5
 dim last = var6

 for ix = 0 to 63 : line1[ix] = 32 : next
 clearscreen
 plotchars 'APPKEYS' 0 8 2
 plotchars 'USERNAME: KEY 1:1:0' 0 8 5
 plotchars line1 0 16 6 30
 plotchars 'OURS: KEY $7800:$FF:0' 0 8 9
 plotchars line2 0 16 10 30
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 akcrelo = 1 : akcrehi = 0 : akapp = 1 : akmode = 0
 gosub akopen
 if fn_res <> FN_OK then goto failed
 gosub akread
 if fn_res <> FN_OK then goto failed
 len = FN_REPLY[0]
 if len > 30 then len = 30
 if len = 0 then goto ours
 last = len - 1
 for ix = 0 to last : line1[ix] = FN_R_VALUE[ix] : next
 gosub akclose

ours
 akcrelo = $00 : akcrehi = $78 : akapp = $FF : akmode = 1
 gosub akopen
 if fn_res <> FN_OK then goto failed
 rem WRITE_APPKEY: one parameter, the length, then the bytes
 fn_dev = FN_FUJI : fn_cmd = $DE : fn_npr = 1
 gosub fn_beg
 fn_val = value_length : gosub fn_pb
 last = value_length - 1
 for ix = 0 to last : FN_TX = value[ix] : next
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 gosub akclose
 akmode = 0
 gosub akopen
 if fn_res <> FN_OK then goto failed
 gosub akread
 if fn_res <> FN_OK then goto failed
 last = FN_REPLY[0] - 1
 for ix = 0 to last : line2[ix] = FN_R_VALUE[ix] : next
 gosub akclose
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 rem akopen -- OPEN_APPKEY: no parameters, the struct as the payload
akopen
 fn_dev = FN_FUJI : fn_cmd = $DC : fn_npr = 0
 gosub fn_beg
 FN_TX = akcrelo
 FN_TX = akcrehi
 FN_TX = akapp
 FN_TX = 0
 FN_TX = akmode
 FN_TX = 0
 gosub fn_go
 return

 rem akclose -- CLOSE_APPKEY: no parameters, no payload
akclose
 fn_dev = FN_FUJI : fn_cmd = $DB : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 return

 rem akread -- READ_APPKEY: the reply is the length (2 bytes), then the value
akread
 fn_dev = FN_FUJI : fn_cmd = $DD : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 return

 alphadata value fujifont
 'HELLO 7800'
end

 incbasic fujilib.bas
