#!/bin/sh
# /data/fun/Atari/7800basic.0.1/contrib/lib/linux
# rebuild dasm for linux x86 32-bit

rm -fr dasm*

# determine DASMRELEASE and DASMSOURCE
. ./version_dasm.sh

export CC=x86_64-w64-mingw32-gcc
export CFLAGS=' -O2'

mkdir dasmtmp
TAR=$(basename "$DASMSOURCE")
cd dasmtmp
wget "$DASMSOURCE"
tar -xvzf "$TAR" && rm $TAR
cd *
make

cp src/dasm*exe ../../../../dasm.Windows.x64.exe
cd ../..
rm -fr dasm*
