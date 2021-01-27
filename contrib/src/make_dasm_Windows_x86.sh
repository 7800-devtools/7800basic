#!/bin/sh
# /data/fun/Atari/7800basic.0.1/contrib/lib/linux
# rebuild dasm for linux x86 32-bit

rm -fr dasm*

# determine DASMRELEASE and DASMSOURCE
. ./version_dasm.sh

export PATH=/usr/x86_64-w64-mingw32/bin:$PATH
export CC=i686-w64-mingw32-gcc

export CFLAGS=' -m32'
export LDFLAGS=' -m32 -L/usr/lib32'


mkdir dasmtmp
TAR=$(basename "$DASMSOURCE")
cd dasmtmp
wget "$DASMSOURCE"
tar -xvzf "$TAR" && rm $TAR
cd *
make

cp src/dasm ../../../../dasm.Windows.x86.exe
cd ../..
rm -fr dasm*
