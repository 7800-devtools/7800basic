 rem fujinet.bas -- the FujiNet cartridge's mailbox, named for 7800basic.
 rem
 rem Use it with:   set fujinet on        (stamps the claim at $FF70)
 rem                incbasic fujinet.bas  (these names; at the top)
 rem                incbasic fujilib.bas  (the subroutines; after the main
 rem                                       loop, where nothing falls into it)
 rem
 rem In BASIC a register's name is its address: FN_CMD = $C4 is one store,
 rem STA $0D01. Use the FN_ names only on the left of a plain assignment or
 rem the right of a comparison, never in arithmetic: FN_TX = FN_TX + 1 would
 rem read the page back and write it twice, and the cartridge counts both.
 rem
 rem The library needs: alphachars ASCII with a 256-glyph font, var86-var99
 rem and $27FE-$27FF for itself. Never let MARIA read $0600-$0FFF: copy any
 rem reply text into console RAM ($2200-$27FD) before you plotchars it.

 rem cells the cartridge paints: read them
 dim FN_REPLY = $0800
 dim FN_ACKSEQ = $0C00
 dim FN_STATUS = $0C01
 dim FN_ERR = $0C02
 dim FN_REPLYCMD = $0C03
 dim FN_RXLEN = $0C04
 dim FN_RXLENHI = $0C05
 dim FN_BOOTSTATE = $0C06
 dim FN_BOOTPCT = $0C07
 dim FN_BOOTERR = $0C08
 dim FN_MAGIC0 = $0C09
 dim FN_MAGIC1 = $0C0A
 dim FN_MODE = $0C12
 dim FN_INPTLOCK = $0C1D

 rem registers it watches: write them, one store each
 dim FN_DEVICE = $0D00
 dim FN_CMD = $0D01
 dim FN_NPARAM = $0D02
 dim FN_DATA_RST = $0D05
 dim FN_SEQ = $0D10
 dim FN_BOOTLOCK = $0D11
 dim FN_TX = $0F00

 rem the library's own variables
 dim fn_dev = var90
 dim fn_cmd = var91
 dim fn_npr = var92
 dim fn_val = var93
 dim fn_valhi = var94
 dim fn_res = var95
 dim fn_seq = var96
 dim fn_tick = var97
 dim fn_tmo = var98
 dim fn_i = var99
 rem the network helpers' answers (fn_status) -- var86-var89
 dim fn_avail = var86
 dim fn_availhi = var87
 dim fn_conn = var88
 dim fn_nerr = var89
 dim fn_hexbuf = $27FE

 rem devices, and the commands the samples use
 const FN_FUJI = $70
 const FN_NET = $71
 const FN_CLOCK = $45
 const FN_OK = 0
 const FN_ENOCART = $FD
 const FN_ENAK = $EE
 const FN_EWAIT = $FF
 const FN_BOOT_READY = 2
 const FN_BOOT_FAILED = $80
 const FN_NET_OPEN = $4F
 const FN_NET_CLOSE = $43
 const FN_NET_READ = $52
 const FN_NET_WRITE = $57
 const FN_NET_STATUS = $53
 const FN_NET_PARSE = $50
 const FN_NET_QUERY = $51
 const FN_NET_SETPARSER = $FC
 rem OPEN modes
 const FN_M_GET = 4
 const FN_M_PUT = 8
 const FN_M_GETH = 12
 const FN_M_POST = 13
