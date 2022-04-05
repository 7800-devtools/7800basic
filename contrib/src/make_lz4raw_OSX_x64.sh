#!/bin/sh
# rebuild lz4raw for linux x86 64-bit

rm -fr lz4raw

export PATH=/usr/i686-apple-darwin10/bin:$PATH
export CC=i686-apple-darwin10-gcc
export LD=$CC
export CFLAGS=' -m64 -arch i386 '
export LDFLAGS='-m64 -L/usr/i686-apple-darwin10/lib -arch i386'
#export LDIR=./lib

tar -xvzf "lz4raw.tgz"
cd lz4raw
make
cd programs
make
cd ..
cp programs/lz4 ../../../lz4raw.OSX.x64
cd ..
rm -fr lz4raw 
