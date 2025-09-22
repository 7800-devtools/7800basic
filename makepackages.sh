#!/bin/sh
# makepackages.sh
#   apply the release.dat contents to the release text in various sources
#   and documents, and then generate the individual release packages.

RELEASE=$(cat release.dat)
ERELEASE=$(cat release.dat | sed 's/ /_/g')
YEAR=$(date +%Y)

dos2unix 7800bas.c >/dev/null 2>&1
cat 7800bas.c | sed 's/BASIC_VERSION_INFO .*/BASIC_VERSION_INFO "7800basic v'"$RELEASE"'"/g' > 7800bas.c.new
mv 7800bas.c.new 7800bas.c
unix2dos 7800bas.c >/dev/null 2>&1

find . -name .\*.swp -exec rm '{}' \;

make dist

rm -fr packages
mkdir -p packages/7800basic 2>/dev/null

rm -f samples/*/*.a78 samples/*/*.bin samples/*/*bas.asm samples/*/*.txt samples/*/*.cfg samples/*/*.h samples/*/includes.7800
rm -fr samples/*/cfg samples/*/nvram

#populate architecture neutral stuff into the dist directory
cp -R includes packages/7800basic/
cp -R samples packages/7800basic/
rm packages/7800basic/samples/sizes.ref packages/7800basic/samples/makefile
rm packages/7800basic/samples/make_test.sh
cp *.TXT *.txt packages/7800basic/
cp docs/7800basic*pdf packages/7800basic/

OS=wasm
dos2unix packages/7800basic/*.txt
cp install_ux.sh packages/7800basic/
cp install_win.bat packages/7800basic/
cp 7800basic.sh packages/7800basic/
cp 7800bas.bat packages/7800basic/
cp *.wasm packages/7800basic/
for FILE in *.wasm ; do
  BASE=$(echo $FILE | cut -d. -f1)
  # gotta skip 7800basic.sh because it isn't a wrapper
  echo $BASE | grep 7800bas >/dev/null && continue
  if [ -r "$BASE.sh" ] ; then
      cp $BASE.sh packages/7800basic/$BASE 
  fi
  if [ -r "$BASE.bat" ] ; then
      cp $BASE.bat packages/7800basic/
  fi
done
  
rm packages/7800basic/makefile.xcmp.wasm
(cd packages ; tar --numeric-owner -cvzf 7800basic-$ERELEASE-$OS.tar.gz 7800basic)
(cd packages ; zip -r 7800basic-$ERELEASE-$OS.zip 7800basic)
rm -fr packages/7800basic
