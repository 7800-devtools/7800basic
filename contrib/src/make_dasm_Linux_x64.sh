#!/bin/sh
# rebuild dasm for linux x86 64-bit

rm -fr dasm*

# determine DASMRELEASE and DASMSOURCE
. ./version_dasm.sh

export LDFLAGS=' -m64 '
export CFLAGS=' -m64'

mkdir dasmtmp
TAR=$(basename "$DASMSOURCE")
cd dasmtmp
wget "$DASMSOURCE"
tar -xvzf "$TAR" && rm "$TAR"
cd *
make
cp src/dasm ../../../../dasm.Linux.x64
cd ../..
rm -fr dasm*
