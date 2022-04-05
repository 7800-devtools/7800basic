#!/bin/sh
# rebuild lz4raw for linux x86 64-bit

export PATH=/usr/x86_64-w64-mingw32/bin:$PATH
export CC=i686-w64-mingw32-gcc

rm -fr lz4raw

export CFLAGS=' -m32'
export LDFLAGS=' -m32 -L/usr/lib32'

tar -xvzf "lz4raw.tgz"
cd lz4raw
make
cp programs/lz4.exe ../../../lz4raw.Windows.x86.exe
cd ..
rm -fr lz4raw
