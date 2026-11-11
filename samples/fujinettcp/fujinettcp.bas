 rem fujinettcp -- a TCP client: send a line, show what comes back.
 rem
 rem   OPEN    $4F  mode 12 (read/write), translation 0, devicespec N:TCP://host:port/
 rem   WRITE   $57  one u16 parameter (the length), then the bytes (317 at most)
 rem   STATUS  $53  bytes waiting, connected flag, error (136 = the peer hung up)
 rem   READ    $52  one u16 parameter, the count
 rem   CLOSE   $43
 rem
 rem Joystick: left/right choose one of three canned lines, fire sends it.
 rem What the server sends back scrolls up the screen.
 rem
 rem Needs: a FujiNet cartridge on WiFi and an echo server on your network,
 rem for example   ncat -l -k 6502 --exec /bin/cat
 rem Edit the host in tcpurl to your computer's address.
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 rem eight rows of 32 characters for the replies, one row for the choice
 dim scr = $2200
 dim scr1 = $2220
 dim lastrow = $22E0
 dim choice = $2300
 dim idx = var0
 dim pos = var1
 dim msgnum = var2
 dim tick = var3
 dim held = var4
 dim cnt = var5
 dim src = var6
 dim chr = var7
 dim col = var8
 dim sent = var9
 dim gone = var10
 dim pressed = var11

 for idx = 0 to 255 : scr[idx] = 32 : next
 for idx = 0 to 31 : choice[idx] = 32 : next
 clearscreen
 plotchars 'TCP CLIENT' 0 8 1
 plotchars 'LEFT/RIGHT: PICK   FIRE: SEND' 0 8 3
 plotchars choice 0 8 5 32
 plotmap scr 0 8 7 32 8
 plotchars 'STATUS' 0 8 20
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 rem OPEN: mode 12 (read/write), translation 0, then the devicespec
 fn_val = FN_M_GETH : fn_valhi = 0
 gosub fn_nopen
 idx = 0
open_tcp
 FN_TX = tcpurl[idx]
 idx = idx + 1
 if idx < tcpurl_length then goto open_tcp
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 plotchars 'CONNECTED' 0 44 20

 msgnum = 0 : tick = 0 : held = 0 : pos = 0 : sent = 0 : gone = 0
 gosub showchoice

main
 gosub plotscreen
 drawscreen
 rem edge-triggered input
 pressed = 0
 if joy0left then pressed = 1
 if joy0right then pressed = 1
 if joy0fire then pressed = 1
 if pressed <> 0 then goto isdown
 held = 0
 goto polltick
isdown
 if held <> 0 then goto polltick
 held = 1
 if joy0left && msgnum > 0 then msgnum = msgnum - 1
 if joy0right && msgnum < 2 then msgnum = msgnum + 1
 if joy0fire then gosub sendmsg
 gosub showchoice
polltick
 if gone <> 0 then goto main
 tick = tick + 1
 if tick < 20 then goto main
 tick = 0
 gosub fn_status
 if fn_res <> FN_OK then goto failed
 if fn_nerr = 136 then goto hungup
 if fn_avail = 0 then goto main
 gosub getreply
 if fn_res <> FN_OK then goto failed
 goto main

hungup
 gone = 1
 plotchars 'SERVER CLOSED     ' 0 44 20
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 gone = 1
 plotchars 'FAILED: E' 0 44 20
 plotchars fn_hexbuf 0 80 20 2
 goto main

 rem plotscreen -- the display list is rebuilt every frame
plotscreen
 clearscreen
 plotchars 'TCP CLIENT' 0 8 1
 plotchars 'LEFT/RIGHT: PICK   FIRE: SEND' 0 8 3
 plotchars choice 0 8 5 32
 plotmap scr 0 8 7 32 8
 plotchars 'STATUS' 0 8 20
 if gone = 0 then plotchars 'CONNECTED' 0 44 20
 return

 rem showchoice -- the chosen line, with its number
showchoice
 for idx = 0 to 31 : choice[idx] = 32 : next
 chr = msgnum + 49
 choice[0] = chr
 choice[1] = 58
 idx = 0
 if msgnum = 0 then goto sc0
 if msgnum = 1 then goto sc1
sc2
 chr = msg2[idx]
 if idx >= msg2_length then return
 col = idx + 3
 choice[col] = chr
 idx = idx + 1
 goto sc2
sc1
 chr = msg1[idx]
 if idx >= msg1_length then return
 col = idx + 3
 choice[col] = chr
 idx = idx + 1
 goto sc1
sc0
 chr = msg0[idx]
 if idx >= msg0_length then return
 col = idx + 3
 choice[col] = chr
 idx = idx + 1
 goto sc0

 rem sendmsg -- WRITE the chosen line and a line feed
sendmsg
 fn_dev = FN_NET : fn_cmd = FN_NET_WRITE : fn_npr = 1
 gosub fn_beg
 if msgnum = 0 then fn_val = msg0_length
 if msgnum = 1 then fn_val = msg1_length
 if msgnum = 2 then fn_val = msg2_length
 fn_val = fn_val + 1
 fn_valhi = 0
 gosub fn_pw
 idx = 0
 if msgnum = 0 then goto sm0
 if msgnum = 1 then goto sm1
sm2
 FN_TX = msg2[idx]
 idx = idx + 1
 if idx < msg2_length then goto sm2
 goto smend
sm1
 FN_TX = msg1[idx]
 idx = idx + 1
 if idx < msg1_length then goto sm1
 goto smend
sm0
 FN_TX = msg0[idx]
 idx = idx + 1
 if idx < msg0_length then goto sm0
smend
 FN_TX = 10
 fn_tmo = 6
 gosub fn_go
 return

 rem getreply -- READ what is waiting and add it to the text, a line at a time
getreply
 fn_val = fn_avail : fn_valhi = 0
 if fn_availhi <> 0 then fn_val = 255
 gosub fn_read
 if fn_res <> FN_OK then return
 cnt = FN_RXLEN
 src = 0
gr_loop
 if src >= cnt then return
 chr = FN_REPLY[src]
 src = src + 1
 if chr = 13 then goto gr_loop
 if chr = 10 then goto gr_newline
 col = pos & 31
 if col = 31 then goto gr_loop
 scr[pos] = chr
 pos = pos + 1
 goto gr_loop
gr_newline
 pos = pos & $E0
 if pos = $E0 then goto gr_scroll
 pos = pos + 32
 goto gr_loop
gr_scroll
 rem the last row is full: move every row up one and blank the last
 memcpy scr scr1 224
 memset lastrow 32 32
 goto gr_loop

 alphadata tcpurl fujifont
 'N:TCP://192.168.1.100:6502/'
end
 alphadata msg0 fujifont
 'HELLO FROM THE ATARI 7800'
end
 alphadata msg1 fujifont
 'FUJINET SAYS HI'
end
 alphadata msg2 fujifont
 'THE QUICK BROWN FOX'
end

 incbasic fujilib.bas
