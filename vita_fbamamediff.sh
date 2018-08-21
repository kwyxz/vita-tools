#!/bin/bash

VITA_IP=192.168.1.10
VITA_PORT=1337
HOMEBREWPATH=ux0:/homebrew
ROMPATH=$HOMEBREWPATH/roms
GAMESDIR=/mnt/space/Games/

echo -n "Getting list of MAME games... "
MAMELIST=$(lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/mame2003 ; cls -1 " | tr -d $'\r' | sed -e 's/\/$//')
echo "done."

push_game () {
    echo -n "Pushing $1 for Final Burn Alpha to Vita ... "
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/fba/ ; mput -c $1" > /dev/null
    echo "done"
}

remove_game () {
    echo -n "Removing $1 from MAME on Vita ... "
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/mame2003/ ; rm $1" > /dev/null
    echo "done"
}

for GAME in $MAMELIST; do
  if [ -f "$GAMESDIR/fba/$GAME" ]; then
    cd $GAMESDIR/fba
    push_game $GAME
    remove_game $GAME
  fi
done
