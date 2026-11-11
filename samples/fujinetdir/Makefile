export PROJECT=fujinetdir
export PROJECTDIR=`pwd`
export COMPILER=7800basic.sh

main: 	${PROJECT}.bas.bin

${PROJECT}.bas.bin: ${PROJECT}.bas
	${COMPILER} ${PROJECT}.bas -O

clean:
	/bin/rm -f ${PROJECT}.bas.bin ${PROJECT}.bas.asm ${PROJECT}.bas.a78 ${PROJECT}.bas.list.txt ${PROJECT}.bas.symbol.txt ${PROJECT}.bas.pre
	/bin/rm -fr cfg a78info.cfg includes.7800 7800.asm 7800gfx.asm 7800basic_variable_redefs.h 

# needs the FujiNet cartridge model in MAME (fujinet-firmware, pico/atari-7800)
# and a FujiNet or fujinet-pc answering bus-over-IP on FUJINET_TCP
run:
	FUJINET_TCP=127.0.0.1:9995 a7800 a7800 -cartslot fujinet -cart ${PROJECT}.bas.a78
