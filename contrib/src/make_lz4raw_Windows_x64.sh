#!/bin/sh
# rebuild lz4raw for linux x86 64-bit

rm -fr lz4raw

export CC=x86_64-w64-mingw32-gcc
export CFLAGS=' -O2'

tar -xvzf "lz4raw.tgz"
cd lz4raw
make
cp programs/lz4.exe ../../../lz4raw.Windows.x64.exe
cd ..
rm -fr lz4raw
