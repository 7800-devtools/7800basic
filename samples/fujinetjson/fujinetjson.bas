 rem fujinetjson -- fetch a JSON document and show three of its values.
 rem
 rem The N: device fetches the page, parses it, and answers queries by path:
 rem   OPEN        $4F  mode 12 (HTTP GET), translation 0, then the devicespec
 rem   SET_PARSER  $FC  two bytes: any, then 1 = JSON
 rem   PARSE       $50  no parameters -- the adapter fetches and parses here
 rem   QUERY       $51  payload: the path, such as /timezone
 rem   STATUS      $53  how many bytes of the answer are waiting
 rem   READ        $52  one u16 parameter, the count; the value comes back as text
 rem   CLOSE       $43
 rem Read a query's whole answer before the next QUERY, or the next one
 rem comes back empty.
 rem
 rem Needs: a FujiNet cartridge on WiFi. Edit url, path0, path1 and path2 for
 rem any other JSON document; the three rows show whatever those paths hold.
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 rem the three answers, 32 bytes each, in console RAM where MARIA can read
 dim rows = $2200
 dim row0 = $2200
 dim row1 = $2220
 dim row2 = $2240
 dim lofs = var0
 dim idx = var1
 dim dst = var2
 dim cnt = var3
 dim tries = var4

 for idx = 0 to 95 : rows[idx] = 32 : next
 clearscreen
 plotchars 'JSON QUERY' 0 8 1
 plotchars 'TIMEZONE' 0 8 4
 plotchars row0 0 16 5 24
 plotchars 'ABBREVIATION' 0 8 7
 plotchars row1 0 16 8 24
 plotchars 'DAY OF THE YEAR' 0 8 10
 plotchars row2 0 16 11 24
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 rem OPEN: mode 12 (GET) and translation 0 as parameters, then the url
 fn_val = FN_M_GETH : fn_valhi = 0
 gosub fn_nopen
 idx = 0
open_url
 FN_TX = url[idx]
 idx = idx + 1
 if idx < url_length then goto open_url
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem SET_PARSER: the second byte picks the parser, 1 = JSON
 fn_dev = FN_NET : fn_cmd = FN_NET_SETPARSER : fn_npr = 2
 gosub fn_beg
 fn_val = 0 : gosub fn_pb
 fn_val = 1 : gosub fn_pb
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem PARSE: the fetch happens here, so allow it time
 fn_cmd = FN_NET_PARSE : fn_npr = 0
 gosub fn_beg
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem three queries, each answered in full before the next
 lofs = 0
 fn_cmd = FN_NET_QUERY : fn_npr = 0
 gosub fn_beg
 idx = 0
ask0
 FN_TX = path0[idx]
 idx = idx + 1
 if idx < path0_length then goto ask0
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 gosub getvalue
 if fn_res <> FN_OK then goto failed

 lofs = 32
 fn_cmd = FN_NET_QUERY : fn_npr = 0
 gosub fn_beg
 idx = 0
ask1
 FN_TX = path1[idx]
 idx = idx + 1
 if idx < path1_length then goto ask1
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 gosub getvalue
 if fn_res <> FN_OK then goto failed

 lofs = 64
 fn_cmd = FN_NET_QUERY : fn_npr = 0
 gosub fn_beg
 idx = 0
ask2
 FN_TX = path2[idx]
 idx = idx + 1
 if idx < path2_length then goto ask2
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 gosub getvalue
 if fn_res <> FN_OK then goto failed

 gosub fn_close
 plotchars 'DONE' 0 8 20
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 rem getvalue -- STATUS until the answer is waiting, READ all of it, and
 rem keep its first 24 bytes in the row at lofs.
getvalue
 tries = 0
gv_poll
 gosub fn_status
 if fn_res <> FN_OK then return
 if fn_avail <> 0 then goto gv_read
 tries = tries + 1
 if tries = 30 then fn_res = FN_EWAIT : return
 drawscreen : drawscreen : drawscreen
 goto gv_poll
gv_read
 fn_val = fn_avail : fn_valhi = 0
 if fn_availhi <> 0 then fn_val = 255
 gosub fn_read
 if fn_res <> FN_OK then return
 cnt = FN_RXLEN
 if cnt > 24 then cnt = 24
 idx = 0
gv_copy
 if idx >= cnt then return
 dst = lofs + idx
 rows[dst] = FN_REPLY[idx]
 idx = idx + 1
 goto gv_copy

 rem the document and the three paths: edit these
 alphadata url fujifont
 'N:https://worldtimeapi.org/api/timezone/Etc/UTC'
end
 alphadata path0 fujifont
 '/timezone'
end
 alphadata path1 fujifont
 '/abbreviation'
end
 alphadata path2 fujifont
 '/day_of_year'
end

 incbasic fujilib.bas
