#!/bin/sh
./make_dasm_Linux_x64.sh
./make_dasm_Linux_x86.sh
./make_dasm_OSX_x64.sh
./make_dasm_OSX_x86.sh
./make_dasm_Windows_x64.sh
./make_dasm_Windows_x86.sh
cp ../../dasm.Windows.x86.exe ../../dasm.exe
cat << EOF > ../../dasm.LICENSE.txt
Dasm is distributed here under the terms of the GNU GPL v2 License.

Please see the included LICENSE.txt file for the full GPL v2 license text.

The source code for this version of dasm is available via github at this
location:

   https://github.com/dasm-assembler/dasm
EOF
unix2dos ../../dasm.LICENSE.txt
