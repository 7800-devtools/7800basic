#!/bin/sh
# rebuild lz4raw for linux x86 64-bit

rm -fr lz4raw

export LDFLAGS=' -m32 -L/usr/lib32'
export CFLAGS=' -m32'

tar -xvzf "lz4raw.tgz"
cd lz4raw
make
cp lz4raw ../../../lz4raw.Linux.x86
cd ..
rm -fr lz4raw
