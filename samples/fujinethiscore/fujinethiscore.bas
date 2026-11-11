 rem fujinethiscore -- a tiny catch game whose top-five table lives on the
 rem FujiNet's SD card, in an AppKey.
 rem
 rem   OPEN_APPKEY   $DC  payload: creator (lo, hi), app, key, mode, 0
 rem                       mode 0 = read, 1 = write
 rem   READ_APPKEY   $DD  reply: a u16 length, then the value ($0802 on)
 rem   WRITE_APPKEY  $DE  one u8 parameter (the length), then the value
 rem   CLOSE_APPKEY  $DB
 rem The table is 20 bytes: five entries of three initials and a score.
 rem It is read at start-up and written after a new entry, as the file
 rem /FujiNet/7800ff01.key on the SD card. Register a creator and app id
 rem for your own game in the AppKeys registry; this sample borrows creator
 rem $7800, app $FF, key 1.
 rem
 rem Play: left/right moves the catcher under the falling stars. Three
 rem misses end the game. If you place, up/down picks a letter and fire
 rem takes it.
 rem
 rem Needs: a FujiNet cartridge and an SD card. Without them the game still
 rem plays, and just doesn't remember its scores.
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 rem the value READ_APPKEY returns starts after its two-byte length
 dim FN_R_VALUE = $0802
 rem the table, and five printed rows of 16 characters
 dim tbl = $2300
 dim rows = $2200
 dim row0 = $2200
 dim row1 = $2210
 dim row2 = $2220
 dim row3 = $2230
 dim row4 = $2240
 dim ini = $2250
 dim digs = $2258
 dim missd = $225C
 rem the stars: four slots, x in character columns, y in rows (255 = none)
 dim itx = var10
 dim ity = var14
 dim plx = var20
 dim score = var21
 dim miss = var22
 dim gtick = var23
 dim idx = var24
 dim ent = var25
 dim dst = var26
 dim src = var27
 dim kay = var28
 dim tmp = var29
 dim tmp2 = var30
 dim lox = var31
 dim hix = var32
 dim tx = var33
 dim ty = var34
 dim pos = var35
 dim cur = var36
 dim held = var37
 dim saved = var38
 dim wait = var39
 dim tens = var40
 dim akmode = var41
 dim havefn = var42

 havefn = 0
 gosub fn_chk
 if fn_res = FN_OK then havefn = 1
 gosub defaults
 if havefn <> 0 then gosub loadtable

title
 gosub buildrows
 clearscreen
 plotchars 'STAR CATCH' 0 8 1
 plotchars 'TOP FIVE' 0 8 4
 plotchars row0 0 8 6 16
 plotchars row1 0 8 7 16
 plotchars row2 0 8 8 16
 plotchars row3 0 8 9 16
 plotchars row4 0 8 10 16
 plotchars 'FIRE TO PLAY' 0 8 14
 if havefn = 0 then plotchars 'NO FUJINET: SCORES NOT KEPT' 0 8 18
 if saved = 1 then plotchars 'SAVED TO THE SD CARD' 0 8 18
 if saved = 2 then plotchars 'COULD NOT SAVE THE TABLE' 0 8 18
 drawscreen
 if joy0fire then goto title_up
 goto title
title_up
 rem wait for the button to be let go, then play
 drawscreen
 if joy0fire then goto title_up

play
 plx = 18 : score = 0 : miss = 0 : gtick = 0 : saved = 0
 for idx = 0 to 3 : ity[idx] = 255 : next
gloop
 gtick = gtick + 1
 rem move the catcher every third frame
 tmp = gtick & 3
 if tmp <> 0 then goto nomove
 if joy0left && plx > 2 then plx = plx - 1
 if joy0right && plx < 34 then plx = plx + 1
nomove
 rem the stars fall a row every eighth frame; one is dropped every 48
 tmp = gtick & 7
 if tmp = 0 then gosub step
 tmp = gtick & 63
 if tmp = 0 then gosub drop
 if miss >= 3 then goto gameover
 if score >= 99 then goto gameover

 clearscreen
 gosub digits
 plotchars 'SCORE' 0 8 0
 plotchars digs 0 48 0 2
 plotchars 'MISSED' 0 88 0
 tmp = miss + 48
 missd[0] = tmp
 plotchars missd 0 124 0 1
 lox = plx - 1
 tx = lox * 4
 plotchars '[_]' 0 tx 22
 for idx = 0 to 3
   if ity[idx] = 255 then goto nostar
   tmp = itx[idx] * 4
   ty = ity[idx]
   plotchars '*' 0 tmp ty
nostar
 next
 drawscreen
 goto gloop

 rem digits -- score as two digits in digs[0..1]; digs[2] a blank
digits
 tens = score / 10
 tmp = tens * 10
 tmp2 = score - tmp
 tmp = tens + 48
 digs[0] = tmp
 tmp = tmp2 + 48
 digs[1] = tmp
 digs[2] = 32
 return

 rem drop -- start a star in a free slot, at a random column
drop
 for idx = 0 to 3
   if ity[idx] <> 255 then goto notfree
   tmp = rand
   tmp = tmp & 31
   tmp = tmp + 2
   itx[idx] = tmp
   ity[idx] = 2
   return
notfree
 next
 return

 rem step -- every star down a row; at the catcher's row it is caught or missed
step
 for idx = 0 to 3
   if ity[idx] = 255 then goto nofall
   tmp = ity[idx] + 1
   ity[idx] = tmp
   if tmp < 22 then goto nofall
   rem it reached the catcher's row: caught if within a column of the middle
   ity[idx] = 255
   lox = plx - 1
   hix = plx + 1
   if itx[idx] < lox then goto missed
   if itx[idx] > hix then goto missed
   score = score + 1
   goto nofall
missed
   miss = miss + 1
nofall
 next
 return

gameover
 clearscreen
 gosub digits
 plotchars 'GAME OVER' 0 8 6
 plotchars 'SCORE' 0 8 8
 plotchars digs 0 48 8 2
 drawscreen
 wait = 0
go_pause
 drawscreen
 wait = wait + 1
 if wait < 90 then goto go_pause
 rem does it place? it must beat the fifth score
 tmp = tbl[19]
 if score <= tmp then goto title
 gosub initials
 gosub insert
 if havefn <> 0 then gosub savetable
 goto title

 rem initials -- up/down change the letter, fire takes it
initials
 for idx = 0 to 2 : ini[idx] = 65 : next
 cur = 0 : held = 1
in_loop
 clearscreen
 plotchars 'NEW HIGH SCORE' 0 8 4
 plotchars 'ENTER YOUR INITIALS' 0 8 6
 plotchars ini 0 8 9 3
 tmp = cur * 4
 tmp = tmp + 8
 plotchars '^' 0 tmp 10
 drawscreen
 if joy0up || joy0down then goto in_move
 if joy0fire then goto in_move
 held = 0
 goto in_loop
in_move
 if held <> 0 then goto in_loop
 held = 1
 tmp = ini[cur]
 if joy0up then tmp = tmp + 1
 if joy0down then tmp = tmp - 1
 if tmp > 90 then tmp = 65
 if tmp < 65 then tmp = 90
 ini[cur] = tmp
 if joy0fire then cur = cur + 1
 if cur < 3 then goto in_loop
 return

 rem insert -- put score and ini into the table, below any higher scores
insert
 pos = 0
ins_find
 tmp = pos * 4
 tmp = tmp + 3
 tmp2 = tbl[tmp]
 if score > tmp2 then goto ins_found
 pos = pos + 1
 if pos < 5 then goto ins_find
 return
ins_found
 rem entries 3 down to pos each move down one place
 ent = 3
ins_shift
 if ent < pos then goto ins_put
 src = ent * 4
 dst = src + 4
 for kay = 0 to 3
   tmp = src + kay
   tmp2 = dst + kay
   tbl[tmp2] = tbl[tmp]
 next
 if ent = 0 then goto ins_put
 ent = ent - 1
 goto ins_shift
ins_put
 dst = pos * 4
 for kay = 0 to 2
   tbl[dst] = ini[kay]
   dst = dst + 1
 next
 tbl[dst] = score
 return

 rem defaults -- the table a fresh SD card starts with
defaults
 for idx = 0 to 4
   dst = idx * 4
   tbl[dst] = 70
   dst = dst + 1
   tbl[dst] = 85
   dst = dst + 1
   tbl[dst] = 74
   dst = dst + 1
   tmp = 5 - idx
   tmp = tmp * 2
   tbl[dst] = tmp
 next
 return

 rem buildrows -- the five table rows as text: "1 FUJ 10"
buildrows
 for ent = 0 to 4
   dst = ent * 16
   tmp = ent + 49
   rows[dst] = tmp
   dst = dst + 2
   src = ent * 4
   for kay = 0 to 2
     tmp = src + kay
     rows[dst] = tbl[tmp]
     dst = dst + 1
   next
   dst = dst + 1
   tmp = src + 3
   tmp2 = tbl[tmp]
   tens = tmp2 / 10
   tmp = tens * 10
   tmp2 = tmp2 - tmp
   tmp = tens + 48
   rows[dst] = tmp
   dst = dst + 1
   tmp = tmp2 + 48
   rows[dst] = tmp
   dst = dst + 1
   rem blank out the rest of the row
   tmp = ent * 16
   tmp = tmp + 16
   if dst >= tmp then goto row_done
   rows[dst] = 32
row_done
 next
 return

 rem akopen -- OPEN_APPKEY for our key, mode in akmode
akopen
 fn_dev = FN_FUJI : fn_cmd = $DC : fn_npr = 0
 gosub fn_beg
 FN_TX = $00
 FN_TX = $78
 FN_TX = $FF
 FN_TX = 1
 FN_TX = akmode
 FN_TX = 0
 gosub fn_go
 return

 rem akclose -- CLOSE_APPKEY
akclose
 fn_dev = FN_FUJI : fn_cmd = $DB : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 return

 rem loadtable -- read the 20 bytes if the key exists and is the right size
loadtable
 akmode = 0
 gosub akopen
 if fn_res <> FN_OK then return
 fn_dev = FN_FUJI : fn_cmd = $DD : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 if fn_res <> FN_OK then goto lt_close
 if FN_REPLY[0] <> 20 then goto lt_close
 for idx = 0 to 19 : tbl[idx] = FN_R_VALUE[idx] : next
lt_close
 gosub akclose
 return

 rem savetable -- write the 20 bytes; saved = 1 if it worked, 2 if not
savetable
 saved = 2
 akmode = 1
 gosub akopen
 if fn_res <> FN_OK then return
 fn_dev = FN_FUJI : fn_cmd = $DE : fn_npr = 1
 gosub fn_beg
 fn_val = 20 : gosub fn_pb
 for idx = 0 to 19 : FN_TX = tbl[idx] : next
 gosub fn_go
 if fn_res = FN_OK then saved = 1
 gosub akclose
 return

 incbasic fujilib.bas
