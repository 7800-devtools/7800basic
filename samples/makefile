# The bB generic-Unix makefile. Should work with most unixy OSes.


all: adventurer/adventurer.bas.a78 banksets/banksets.bas.a78 atarivoxspeech/atarivoxspeech.bas.a78 banner/banner.bas.a78 boxcollision/boxcollision.bas.a78  doublebuffer/doublebuffer.bas.a78 helloworld/helloworld.bas.a78 pokey/pokey.bas.a78 snescontrollers/snescontrollers.bas.a78 rmtromdemo/rmtromdemo.bas.a78 rmtramdemo/rmtramdemo.bas.a78

test:
	./make_test.sh

adventurer/adventurer.bas.a78:
	cd adventurer ; 7800basic.sh adventurer.bas

banksets/banksets.bas.a78:
	cd banksets ; 7800basic.sh banksets.bas

atarivoxspeech/atarivoxspeech.bas.a78:
	cd atarivoxspeech ; 7800basic.sh atarivoxspeech.bas

banner/banner.bas.a78:
	cd banner ; 7800basic.sh banner.bas

boxcollision/boxcollision.bas.a78:
	cd boxcollision ; 7800basic.sh boxcollision.bas
	cd ..

doublebuffer/doublebuffer.bas.a78:
	cd doublebuffer ; 7800basic.sh doublebuffer.bas
	cd ..

helloworld/helloworld.bas.a78: 
	cd helloworld ; 7800basic.sh helloworld.bas
	cd ..

pokey/pokey.bas.a78: 
	cd pokey ; 7800basic.sh pokey.bas
	cd ..

snescontrollers/snescontrollers.bas.a78: 
	cd snescontrollers; 7800basic.sh snescontrollers.bas
	cd ..

rmtromdemo/rmtromdemo.bas.a78: 
	cd rmtromdemo; 7800basic.sh rmtromdemo.bas
	cd ..

rmtramdemo/rmtramdemo.bas.a78: 
	cd rmtramdemo; 7800basic.sh rmtramdemo.bas
	cd ..

clean:
	rm -fr */*.bas.* */*.list.txt */*.symbol.txt */banksetrom.asm */7800.asm */7800basic_variable_redefs.h */a78info.cfg */includes.7800 */cfg */banksetrom.bin
