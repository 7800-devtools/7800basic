#!/bin/sh
# rebuild lz4raw for linux x86 64-bit

rm -fr lz4raw

export PATH=/usr/i686-apple-darwin10/bin:$PATH
export CC=i686-apple-darwin10-gcc
export LD=$CC
export CFLAGS=' -m32 -arch i386 '
export LDFLAGS='-m32 -L/usr/i686-apple-darwin10/lib -arch i386'

tar -xvzf "lz4raw.tgz"
cd lz4raw
make
cd programs
make
cd ..
cp programs/lz4 ../../../lz4raw.OSX.x86
cd ..
rm -fr lz4raw 
