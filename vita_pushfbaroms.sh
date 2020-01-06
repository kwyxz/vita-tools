#!/bin/bash

. ./settings

MAME2k3ROMDIR=$GAMESDIR/mame2003/
FBAROMDIR=$GAMESDIR/fbneo/

if [ $# -lt 1 ]
  then
    echo "Usage: $0 <MAME driver>" 
    exit 1
fi

push_game () {
    GAMENAME=$(basename $2 .zip)
    FULLNAME=$($MAMEBIN -listfull "$GAMENAME" | grep -v "Description" | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
    printf "%-10s%-10s%-60s\n" "$1" "$GAMENAME" "$FULLNAME"
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/$1/ ; mput -c $2" > /dev/null
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
        case "$DRIVERNAME" in
          cps2|neogeo)
            cd $FBAROMDIR/
            push_game $DRIVERNAME $GAME.zip
            ;;
          dec0)
            cd $MAME2k3ROMDIR/
            push_game mame2003 $GAME.zip
            ;;
          *)
            if [ -f $FBAROMDIR/$GAME.zip ]
            then
              cd $FBAROMDIR/
              case $GAME in
                simpsons)
                  push_game fbneo simpsons.zip
                  push_game fbneo simpsons2p.zip
                  ;;
                ssriders)
                  push_game fbneo ssriders.zip
                  push_game fbneo ssridersubc.zip
                  ;;
                tmnt)
                  push_game fbneo tmnt.zip
                  push_game fbneo tmht2p.zip
                  ;;
                tmnt2)
                  push_game fbneo tmnt2.zip
                  push_game fbneo tmnt22pu.zip
                  ;;
                xmen)
                  push_game fbneo xmen.zip
                  push_game fbneo xmen2pu.zip
                  ;;
                *)
                  push_game fbneo $GAME.zip
                  ;;
              esac
            elif [ -f $MAME2k3ROMDIR/$GAME.zip ]
            then
              cd $MAME2k3ROMDIR/
              push_game mame2003 $GAME.zip
            fi
            ;;
        esac
      fi
      done <<< $DRIVERGAMES
  fi
  shift
done
