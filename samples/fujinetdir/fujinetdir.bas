 rem fujinetdir -- the FujiNet's host slots, and a directory on a host.
 rem
 rem   READ_HOST_SLOTS   $F4  no parameters; 8 slots of 32 bytes (a name each)
 rem   MOUNT_HOST        $F9  one byte: the host slot
 rem   OPEN_DIRECTORY    $F7  one byte (host slot), then the path padded to 256
 rem   READ_DIR_ENTRY    $F6  two bytes (longest name, flags); a $7F,$7F entry ends it
 rem   CLOSE_DIRECTORY   $F5
 rem The names go into a 32 x 8 map in console RAM.
 rem
 rem Needs: a FujiNet cartridge, with host slot 1 holding an SD card (the
 rem default) and a folder /a7800book/ on it. Edit path for another folder.
 set fujinet on
 incbasic fujinet.bas

 displaymode 320A
 set zoneheight 8
 incgraphic fujifont.png 320A
 characterset fujifont
 alphachars ASCII
 BACKGRND = $00
 P0C2 = $0F

 const HOSTSL = 0
 const NAMELN = 30
 const NAMELAST = 29
 dim names = $2200
 dim hosts = $2300
 dim pos = var0
 dim ix = var1

 for ix = 0 to 255 : names[ix] = 32 : next
 clearscreen
 plotchars 'DIRECTORY OF SD:/A7800BOOK/' 0 8 2
 plotmap names 0 8 4 32 8
 gosub fn_chk
 if fn_res <> FN_OK then goto failed

 rem READ_HOST_SLOTS: the first slot's name, from the 256-byte reply
 fn_dev = FN_FUJI : fn_cmd = $F4 : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 for ix = 0 to 31 : hosts[ix] = FN_REPLY[ix] : next
 plotchars 'HOST SLOT 1' 0 8 14
 plotchars hosts 0 56 14 32

 rem MOUNT_HOST: one parameter, the host slot
 fn_dev = FN_FUJI : fn_cmd = $F9 : fn_npr = 1
 gosub fn_beg
 fn_val = HOSTSL : gosub fn_pb
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem OPEN_DIRECTORY: the host slot, then exactly 256 bytes of path
 fn_dev = FN_FUJI : fn_cmd = $F7 : fn_npr = 1
 gosub fn_beg
 fn_val = HOSTSL : gosub fn_pb
 fn_i = 0
open_path
 FN_TX = path[fn_i]
 fn_i = fn_i + 1
 if fn_i < path_length then goto open_path
 gosub fn_pad
 gosub fn_go
 if fn_res <> FN_OK then goto failed

 rem READ_DIR_ENTRY: the longest name wanted, and the flags
 pos = 0
entry
 fn_dev = FN_FUJI : fn_cmd = $F6 : fn_npr = 2
 gosub fn_beg
 fn_val = NAMELN : gosub fn_pb
 fn_val = 0 : gosub fn_pb
 gosub fn_go
 if fn_res <> FN_OK then goto failed
 if FN_REPLY[0] <> $7F then goto entry_show
 if FN_REPLY[1] = $7F then goto close
entry_show
 for ix = 0 to NAMELAST
   if FN_REPLY[ix] = 0 then goto entry_next
   names[pos] = FN_REPLY[ix]
   pos = pos + 1
 next
entry_next
 pos = pos & $E0
 pos = pos + 32
 if pos <> 0 then goto entry

 rem CLOSE_DIRECTORY: no parameters
close
 fn_dev = FN_FUJI : fn_cmd = $F5 : fn_npr = 0
 gosub fn_beg
 gosub fn_go
 goto main

failed
 fn_val = fn_res
 gosub fn_hex
 plotchars 'FAILED: E' 0 8 22
 plotchars fn_hexbuf 0 44 22 2

main
 drawscreen
 goto main

 alphadata path fujifont
 '/a7800book/'
end

 incbasic fujilib.bas
