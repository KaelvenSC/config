#!/bin/bash

echo "https://gofile.io/d/X3BaAy"
read LINK

ID=$(echo $LINK | awk -F/ '{print $NF}')

DATA=$(curl -s https://api.gofile.io/contents/$ID)

echo "Daftar file:"
echo "$DATA" | grep -o '"name":"[^"]*"' | cut -d':' -f2 | tr -d '"' | nl

echo "Pilih range file (contoh 1-5):"
read RANGE

START=$(echo $RANGE | cut -d- -f1)
END=$(echo $RANGE | cut -d- -f2)

LINKS=$(echo "$DATA" | grep -o '"link":"[^"]*"' | cut -d':' -f2- | tr -d '"')

COUNT=1
for URL in $LINKS
do
if [ $COUNT -ge $START ] && [ $COUNT -le $END ]; then
echo "Downloading $COUNT..."
wget $URL
fi
COUNT=$((COUNT+1))
done
