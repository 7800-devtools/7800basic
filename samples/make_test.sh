#!/bin/sh
echo "7800basic build test, using $(which 7800basic.sh)"
echo "    [$(7800basic.sh -v)]"
make all >/dev/null 2>&1
for FILE in $(cat sizes.ref | awk '{print $1}') ; do
        RECORDEDSIZE=$(grep "$FILE" sizes.ref | awk '{print $2}')
        REALSIZE=$(du -sb "$FILE"/"$FILE".bas.a78 2>/dev/null | awk '{print $1}')
        if [ "$RECORDEDSIZE" = "$REALSIZE" ] ; then
                echo "    "PASS: $FILE
        else
                echo "    "FAIL: $FILE
        fi
done
make clean >/dev/null 2>&1

