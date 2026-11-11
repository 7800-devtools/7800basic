 rem fujilib.bas -- the FujiNet mailbox subroutines for 7800basic.
 rem incbasic it after the main loop, where it is never fallen into, and
 rem call each with gosub. See fujinet.bas for the names and the rules.
 rem
 rem A transaction is: set fn_dev, fn_cmd, fn_npr; gosub fn_beg; append the
 rem parameters (fn_pb one byte, fn_pw two) and then the payload bytes with
 rem FN_TX = byte; gosub fn_go; read FN_REPLY[] (FN_RXLEN bytes) when
 rem fn_res = FN_OK.

 rem fn_chk -- fn_res = 0 if a FujiNet cartridge answers, else FN_ENOCART.
fn_chk
 fn_res = FN_ENOCART
 if FN_MAGIC0 <> $46 then return
 if FN_MAGIC1 <> $4E then return
 fn_res = FN_OK
 return

 rem fn_beg -- begin the transaction in fn_dev, fn_cmd, fn_npr. The TX
 rem stream is rewound last, so parameters can follow at once. Sets the
 rem timeout to 3 (about 13 seconds); raise fn_tmo after this for a slow
 rem command.
fn_beg
 FN_DEVICE = fn_dev
 FN_CMD = fn_cmd
 FN_NPARAM = fn_npr
 FN_DATA_RST = 0
 fn_tmo = 3
 return

 rem fn_pb -- append a one-byte parameter, fn_val.
fn_pb
 FN_TX = 1
 FN_TX = fn_val
 return

 rem fn_pw -- append a two-byte parameter, fn_val low and fn_valhi high.
fn_pw
 FN_TX = 2
 FN_TX = fn_val
 FN_TX = fn_valhi
 return

 rem fn_pad -- append NULs from byte fn_i until fn_i wraps: after a path
 rem of fn_i bytes, this makes it exactly 256.
fn_pad
 FN_TX = 0
 fn_i = fn_i + 1
 if fn_i <> 0 then goto fn_pad
 return

 rem fn_go -- launch it and wait, drawing the screen meanwhile. fn_res is
 rem 0 (FN_OK), the cartridge's error, FN_ENAK if the server said no, or
 rem FN_EWAIT if nothing came back in fn_tmo x 256 frames. The next
 rem sequence number is always the cartridge's ACKSEQ + 1, never a counter
 rem of ours: 0 is reserved, so 255 wraps to 1.
fn_go
 fn_seq = FN_ACKSEQ + 1
 if fn_seq = 0 then fn_seq = 1
 FN_SEQ = fn_seq
 fn_tick = 0
fn_go_wait
 if FN_ACKSEQ = fn_seq then goto fn_go_done
 drawscreen
 fn_tick = fn_tick + 1
 if fn_tick <> 0 then goto fn_go_wait
 fn_tmo = fn_tmo - 1
 if fn_tmo <> 0 then goto fn_go_wait
 fn_res = FN_EWAIT
 return
fn_go_done
 fn_res = FN_ERR
 if fn_res <> FN_OK then return
 if FN_REPLYCMD <> $06 then fn_res = FN_ENAK
 return

 rem fn_nopen -- begin an N: OPEN: fn_val is the mode (FN_M_GET ...) and
 rem fn_valhi the translation (0 none, 1 CR, 2 LF, 3 CRLF). Then append the
 rem devicespec bytes with FN_TX = byte, set fn_tmo = 22, and gosub fn_go.
fn_nopen
 fn_dev = FN_NET
 fn_cmd = FN_NET_OPEN
 fn_npr = 2
 gosub fn_beg
 gosub fn_pb
 fn_val = fn_valhi
 gosub fn_pb
 return

 rem fn_status -- N: STATUS. fn_avail/fn_availhi = bytes waiting, fn_conn
 rem the connected flag, fn_nerr the network error (1 = OK, 136 = EOF).
 rem Check fn_res first.
fn_status
 fn_dev = FN_NET
 fn_cmd = FN_NET_STATUS
 fn_npr = 2
 gosub fn_beg
 fn_val = 0
 gosub fn_pb
 gosub fn_pb
 fn_tmo = 22
 gosub fn_go
 if fn_res <> FN_OK then return
 fn_avail = FN_REPLY[0]
 fn_availhi = FN_REPLY[1]
 fn_conn = FN_REPLY[2]
 fn_nerr = FN_REPLY[3]
 return

 rem fn_read -- N: READ fn_val bytes (at most 1024; fn_valhi the high
 rem byte). The data is at FN_REPLY[], its length in FN_RXLEN.
fn_read
 fn_dev = FN_NET
 fn_cmd = FN_NET_READ
 fn_npr = 1
 gosub fn_beg
 gosub fn_pw
 fn_tmo = 22
 gosub fn_go
 return

 rem fn_close -- N: CLOSE.
fn_close
 fn_dev = FN_NET
 fn_cmd = FN_NET_CLOSE
 fn_npr = 0
 gosub fn_beg
 gosub fn_go
 return

 rem fn_hex -- fn_val as two hex digits in fn_hexbuf, for plotchars. Needs
 rem alphachars ASCII.
fn_hex
 fn_i = fn_val / 16
 fn_hexbuf[0] = fn_hexdigits[fn_i]
 fn_i = fn_val & 15
 fn_hexbuf[1] = fn_hexdigits[fn_i]
 return

 data fn_hexdigits
 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70
end
