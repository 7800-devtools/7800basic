 rem fujinetadapter -- First Contact in 7800basic: the adapter's network
 rem settings on the screen.
 rem
 rem   GET_ADAPTERCONFIG_EXTENDED  $C4  device $70, no parameters; the reply is 240 bytes:
 rem       ssid 0, hostname 33, firmware 125, IP as text 140, MAC as text 204
 rem   GET_WIFISTATUS              $FA  one byte: 3 = connected, 6 = not
 rem
 rem Needs: a FujiNet cartridge. (In fujinet-pc the "WiFi" is a dummy.)
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 rem the reply's fields, by offset from $0800
 dim FN_R_HOST = $0821
 dim FN_R_FW = $087D
 dim FN_R_IP = $088C
 dim FN_R_MAC = $08CC
 rem console RAM for the strings, where MARIA can read them
 dim ssid = $2200
 dim ipaddr = $2220
 dim fwver = $2230
 dim hostn = $2240
 dim macad = $2260
 dim ix = var0

 clearscreen
 plotchars 'FUJINET 7800BASIC FIRST CONTACT' 0 8 1
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 fn_dev = FN_FUJI : fn_cmd = $C4 : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 for ix = 0 to 31 : ssid[ix] = FN_REPLY[ix] : next
 for ix = 0 to 15 : ipaddr[ix] = FN_R_IP[ix] : next
 for ix = 0 to 14 : fwver[ix] = FN_R_FW[ix] : next
 for ix = 0 to 15 : hostn[ix] = FN_R_HOST[ix] : next
 for ix = 0 to 16 : macad[ix] = FN_R_MAC[ix] : next

 rem GET_WIFISTATUS: one byte, 3 when the adapter is connected
 fn_dev = FN_FUJI : fn_cmd = $FA : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 if FN_REPLY[0] = 3 then goto wifi_up
 plotchars 'NOT CONNECTED' 0 40 14
 goto wifi_done
wifi_up
 plotchars 'CONNECTED' 0 40 14
wifi_done
 plotchars 'WIFI' 0 8 14
 plotchars 'HOST' 0 8 10
 plotchars hostn 0 40 10 16
 plotchars 'MAC' 0 8 12
 plotchars macad 0 40 12 17
 plotchars 'SSID' 0 8 4
 plotchars ssid 0 40 4 24
 plotchars 'IP' 0 8 6
 plotchars ipaddr 0 40 6 16
 plotchars 'FW' 0 8 8
 plotchars fwver 0 40 8 15
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 incbasic fujilib.bas
