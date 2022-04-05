#!/bin/sh
./make_lz4raw_Linux_x64.sh
./make_lz4raw_Linux_x86.sh
./make_lz4raw_OSX_x64.sh
./make_lz4raw_OSX_x86.sh
./make_lz4raw_Windows_x64.sh
./make_lz4raw_Windows_x86.sh
cp ../../lz4raw.Windows.x86.exe ../../lz4raw.exe
cat << EOF > ../../lz4raw.LICENSE.txt
lz4raw is distributed here under the terms of the GNU GPL v2 License.

Please see the included LICENSE.txt file for the full GPL v2 license text.
EOF
unix2dos ../../lz4raw.LICENSE.txt
