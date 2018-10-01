#!/bin/bash

. ./settings

if [ $# -lt 1 ]
  then
    echo "Usage: $0 <MAME driver>" 
    exit 1
fi

push_game () {
    echo -n "Pushing $2 to Vita in folder $1 ... "
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/$1/ ; mput -c $2" > /dev/null
    echo "done"
}

while [ $# -ne 0 ]
do
  GAMES=$($MAMEBIN -listfull | awk '{print $1}' | sort | uniq)
  if ! echo $GAMES | grep -q -w $1  
  then
    $MAMEBIN -listfull $1
  else
    DRIVERNAME=$($MAMEBIN -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    echo -n "Driver for game $1 is $DRIVERNAME, retrieving all games for this driver... "
    DRIVERGAMES=$($MAMEBIN -listsource | grep -w "$DRIVERNAME" | awk '{print $1}')
    echo "done"

    while IFS= read -r GAME
    do
      CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
      if ! echo $CLONES | grep -q -w $GAME
      then
        if [ "$DRIVERNAME" = "neogeo" ] || [ "$DRIVERNAME" = "cps2" ] || [ "$DRIVERNAME" = "cps3" ]
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
