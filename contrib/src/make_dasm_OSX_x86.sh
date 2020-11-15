#!/bin/sh
# /data/fun/Atari/7800basic.0.1/contrib/lib/linux
# rebuild dasm for OS X x86 32-bit

# determine DASMRELEASE and DASMSOURCE
. ./version_dasm.sh

export PATH=/usr/i686-apple-darwin10/bin:$PATH
export CC=i686-apple-darwin10-gcc
export LD=$CC
export CFLAGS=' -m32 -arch i386 '
export LDFLAGS='-m32 -L/usr/i686-apple-darwin10/lib -arch i386'

rm -fr dasm*
mkdir dasmtmp
TAR=$(basename "$DASMSOURCE")
cd dasmtmp
wget "$DASMSOURCE"
tar -xvzf "$TAR" && rm $TAR
cd *

make
cp src/dasm ../../../../dasm.Darwin.x86
cd ../..
rm -fr dasm*
