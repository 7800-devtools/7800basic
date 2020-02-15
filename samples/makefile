# The bB generic-Unix makefile. Should work with most unixy OSes.


all: adventurer/adventurer.bas.a78 atarivoxspeech/atarivoxspeech.bas.a78 banner/banner.bas.a78 boxcollision/boxcollision.bas.a78  doublebuffer/doublebuffer.bas.a78 helloworld/helloworld.bas.a8

test:
	./make_test.sh

adventurer/adventurer.bas.a78:
	cd adventurer ; 7800basic.sh adventurer.bas

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

helloworld/helloworld.bas.a8: 
	cd helloworld ; 7800basic.sh helloworld.bas
	cd ..

clean:
	rm -fr */*.bas.* */7800.asm */7800basic_variable_redefs.h */a78info.cfg */includes.7800 */cfg
