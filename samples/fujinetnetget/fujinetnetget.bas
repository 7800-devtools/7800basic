 rem fujinetnetget -- fetch a URL through the N: device and show the text.
 rem
 rem   OPEN    $4F  mode 12 (HTTP GET), translation 0, then the devicespec
 rem   STATUS  $53  two bytes; the reply is bytes waiting, connected, error
 rem   READ    $52  one u16 parameter, the count (224 at most here)
 rem   CLOSE   $43
 rem The text goes into a 32 x 7 map in console RAM a line at a time: LF
 rem ends a row, CR is skipped.
 rem
 rem Needs: a FujiNet cartridge on WiFi. Edit url for any plain-text page.
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 dim scr = $2200
 dim avail = var0
 dim prev = var1
 dim tries = var2
 dim src = var3
 dim pos = var4
 dim ch = var5
 dim ix = var6

 rem the map starts blank: 224 spaces
 for ix = 0 to 223 : scr[ix] = 32 : next
 clearscreen
 plotchars 'NETGET' 0 8 2
 plotmap scr 0 8 4 32 7
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 rem OPEN: the mode (12, HTTP GET) and the translation (0, none) as
 rem one-byte parameters, then the devicespec as the payload
 fn_dev = FN_NET : fn_cmd = $4F : fn_npr = 2
 gosub fn_beg
 fn_val = 12 : gosub fn_pb
 fn_val = 0 : gosub fn_pb
 ix = 0
open_url
 FN_TX = url[ix]
 ix = ix + 1
 if ix < url_length then goto open_url
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem STATUS until two readings agree and are not zero
 prev = $FF : tries = 0
status
 fn_dev = FN_NET : fn_cmd = $53 : fn_npr = 2
 gosub fn_beg
 fn_val = 0 : gosub fn_pb : gosub fn_pb
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 avail = FN_REPLY[0]
 if FN_REPLY[1] <> 0 then avail = 224
 if avail > 224 then avail = 224
 if avail <> prev then goto status_again
 if avail <> 0 then goto read
status_again
 prev = avail
 tries = tries + 1
 if tries = 30 then fn_res = FN_EWAIT : goto failed
 drawscreen : drawscreen : drawscreen
 goto status

 rem READ: ONE two-byte parameter, the count
read
 fn_dev = FN_NET : fn_cmd = $52 : fn_npr = 1
 gosub fn_beg
 fn_val = avail : fn_valhi = 0 : gosub fn_pw
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem into the map, a row per line
 src = 0 : pos = 0
show
 if src = FN_RXLEN then goto close
 ch = FN_REPLY[src]
 src = src + 1
 if ch = 13 then goto show
 if ch <> 10 then goto show_char
 pos = pos & $E0
 pos = pos + 32
 if pos = 224 then goto close
 goto show
show_char
 ix = pos & 31
 if ix = 31 then goto show
 scr[pos] = ch
 pos = pos + 1
 goto show

 rem CLOSE: no parameters
close
 fn_dev = FN_NET : fn_cmd = $43 : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 plotchars 'CLOSED' 0 8 22
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 alphadata url fujifont
 'N:http://worldtimeapi.org/api/timezone/Etc/UTC.txt'
end

 incbasic fujilib.bas
