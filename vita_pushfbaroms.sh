#!/bin/bash

VITA_IP=192.168.1.10
VITA_PORT=1337
MAME=/usr/local/games/mame/mame64
GAMESDIR=/mnt/space/Games/

if [ $# -lt 1 ]
  then
    echo "Usage: $0 <MAME driver>" 
    exit 1
fi

push_game () {
    echo -n "Pushing $2 to Vita in folder $1 ... "
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /ux0:/homebrew/roms/$1/ ; mput -c $2" > /dev/null
    echo "done"
}

while [ $# -ne 0 ]
do
  GAMES=$($MAME -listfull | awk '{print $1}' | sort | uniq)
  if ! echo $GAMES | grep -q -w $1  
  then
    $MAME -listfull $1
  else
    DRIVERNAME=$($MAME -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    echo -n "Driver for game $1 is $DRIVERNAME, retrieving all games for this driver... "
    DRIVERGAMES=$($MAME -listsource | grep -w "$DRIVERNAME" | awk '{print $1}')
    echo "done"

    while IFS= read -r GAME
    do
      CLONES=$($MAME -listclones | awk '{print $1}' | sort | uniq)
      if ! echo $CLONES | grep -q -w $GAME
      then
        if [ "$DRIVERNAME" = "neogeo" ] || [ "$DRIVERNAME" = "cps2" ]
        then
          cd $GAMESDIR/fba/
          push_game fba $GAME.zip
        elif [ -f $GAMESDIR/mame2003/$GAME.zip ]
        then
          cd $GAMESDIR/mame2003/
          push_game mame2003 $GAME.zip
        elif [ -f $GAMESDIR/fba/$GAME.zip ]
        then
          cd $GAMESDIR/fba/
          push_game fba $GAME.zip
        fi
      fi
      done <<< $DRIVERGAMES
  fi
  shift
done
