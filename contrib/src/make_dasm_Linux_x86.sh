#!/bin/sh
# /data/fun/Atari/7800basic.0.1/contrib/lib/linux
# rebuild dasm for linux x86 32-bit

# determine DASMRELEASE and DASMSOURCE
. ./version_dasm.sh

export LDFLAGS=' -m32 -L/usr/lib32'
export CFLAGS=' -m32'

rm -fr dasm*
mkdir dasmtmp
TAR=$(basename "$DASMSOURCE")
cd dasmtmp
wget "$DASMSOURCE"
tar -xvzf "$TAR" && rm $TAR
cd *
make
cp src/dasm ../../../../dasm.Linux.x86
cd ../..
rm -fr dasm*
