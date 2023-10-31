#!/bin/sh
# rebuild static libraries for adhoc platform

TARGETDIR="$PWD/../adhoc"

rm -fr "$TARGETDIR"
mkdir "$TARGETDIR" 2>/dev/null

#zlib.....................
rm -fr zlib-1.2.8
tar -xvzf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --static --prefix="$TARGETDIR"
make
make install
cd ..
rm -fr zlib-1.2.8

#libpng...................
rm -fr libpng-1.5.17
tar -xvzf libpng-1.5.17.tar.gz
cd libpng-1.5.17/
export LDFLAGS="-L$TARGETDIR/lib"
export CFLAGS="-I$TARGETDIR/include"
./configure --enable-static --disable-shared  --prefix="$TARGETDIR"
make
make install
cd ..
rm -fr libpng-1.5.17

#liblzsa.................
rm -fr lzsa
tar -xvzf lzsa-1.4.1.tar.gz
cd lzsa
make
ar -ros liblzsa.a obj/src/shrink_inmem.o obj/src/shrink_context.o obj/src/shrink_block_v1.o obj/src/shrink_block_v2.o obj/src/frame.o obj/src/matchfinder.o obj/src/libdivsufsort/lib/divsufsort.o obj/src/libdivsufsort/lib/divsufsort_utils.o obj/src/libdivsufsort/lib/sssort.o obj/src/libdivsufsort/lib/trsort.o
cp liblzsa.a "$TARGETDIR/lib"
cp includelib/* "$TARGETDIR/include"
# copy the binary out, in case someone needs it outside of 7800basic...
cp lzsa ../../../lzsa
cd ..
rm -fr lzsa
cat << EOF > ../../lzsa.LICENSE.txt
7800basic uses LZSA as its compression format.

The LZSA code is available under the Zlib license.
The match finder (matchfinder.c) is available under the CC0 license due to using portions of code from Eric Bigger's Wimlib in the suffix array-based matchfinder.

For more information, check out the LZSA github:

  https://github.com/emmanuel-marty/lzsa/

EOF
unix2dos ../../lzsa.LICENSE.txt
