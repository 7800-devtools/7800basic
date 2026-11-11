 ; Provided under the CC0 license. See the included LICENSE.txt for details.

 ; a simple guard, than ensures the 7800basic code hasn't
 ; spilled into the encryption area...
 ifconst FUJINETSUPPORT
 ; the FujiNet claim lives at $FF70, so the 7800basic area ends there
 echo "   ",($FF70-*)d,"bytes left in the 7800basic reserved area."
 if (*>$FF6F)
        echo
        echo  "***************************"
        echo  "*** Abort: ROM Overflow ***"
        echo  "***************************"
	ERR  ; abort the assembly
 endif
 else
 echo "   ",($FF7E-*)d,"bytes left in the 7800basic reserved area."
 if (*>$FF7D)
        echo
        echo  "***************************"
        echo  "*** Abort: ROM Overflow ***"
        echo  "***************************"
	ERR  ; abort the assembly
 endif
 endif
