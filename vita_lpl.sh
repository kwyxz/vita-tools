#!/bin/bash

MAMEBIN=/usr/local/games/mame/mame64
VITA_IP=192.168.0.10
VITA_PORT=1337

echo -n "Cleaning up local directory... "
rm *.lpl
echo done

echo -n "Cleaning up remote directory on Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /ux0:/data/retroarch ; mrm playlists/*" > /dev/null
echo done

CONSOLELIST=$(lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /ux0:/homebrew/roms/ ; cls -1 " | tr -d $'\r' | sed -e 's/\/$//')

_mame ()
{
  MAMEGAME=$(basename $1 .zip)
  FULLNAME=$($MAMEBIN -listfull | grep ^"$MAMEGAME\ " | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
  if [[ ! -z "$FULLNAME" ]]; then
    echo -n .
  else
    PLAYLIST=""
  fi
}

_getname ()
{
  GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
  FULLNAME=$(basename "$GAME" "$2")
}

for CONSOLE in $CONSOLELIST
do
  echo Generating playlist for : $CONSOLE

  COMMAND="open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /ux0:/homebrew/roms/$CONSOLE/ ; cls -1 "
  GAMELIST=$(lftp -c "$COMMAND" | tr ' ' '_' | tr -d $'\r')
  FULLNAME=""

  for GAMENAME in $GAMELIST
  do
    case $CONSOLE in
      32x)
        EXTENSION=".32x"
        PLAYLIST="Sega - 32X.lpl"
        LIBRETRO="app0:/picodrive_libretro.self"
        LIBNAME="Picodrive"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      fba|neogeo|cps[1-2])
        PLAYLIST="FB Alpha - Arcade Games.lpl"
        LIBRETRO="app0:/fbalpha2012_libretro.self"
        LIBNAME="FB Alpha 2012"
        _mame "$GAMENAME"
        ;;
      gba)
        EXTENSION=".gba"
        PLAYLIST="Nintendo - Game Boy Advance.lpl"
        LIBRETRO="app0:/vba_next_libretro.self"
        LIBNAME="VBA Next"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      gb)
        EXTENSION=".gb"
        PLAYLIST="Nintendo - Game Boy.lpl"
        LIBRETRO="app0:/gambatte_libretro.self"
        LIBNAME="Gambatte"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      gbc)
        EXTENSION=".gbc"
        PLAYLIST="Nintendo - Game Boy Color.lpl"
        LIBRETRO="app0:/gambatte_libretro.self"
        LIBNAME="Gambatte"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      gg)
        EXTENSION=".gg"
        PLAYLIST="Sega - Game Gear.lpl"
        LIBRETRO="app0:/genesis_plus_gx_libretro.self"
        LIBNAME="Genesis Plus GX"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      md)
        EXTENSION=".gen"
        PLAYLIST="Sega - Mega Drive - Genesis.lpl"
        LIBRETRO="app0:/picodrive_libretro.self"
        LIBNAME="Picodrive"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      mame2000)
        PLAYLIST="MAME.lpl"
        LIBRETRO="app0:/mame2000_libretro.self"
        LIBNAME="MAME 2000"
        _mame "$GAMENAME"
        ;;
      megacd)
        EXTENSION=".cue"
        PLAYLIST="Sega - Mega-CD - Sega CD.lpl"
        LIBRETRO="app0:/picodrive_libretro.self"
        LIBNAME="Picodrive"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      lynx)
        EXTENSION=".lnx"
        PLAYLIST="Atari - Lynx.lpl"
        LIBRETRO="app0:/handy_libretro.self"
        LIBNAME="Handy"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      nes)
        EXTENSION=".nes"
        PLAYLIST="Nintendo - Nintendo Entertainment System.lpl"
        LIBRETRO="app0:/nestopia_libretro.self"
        LIBNAME="Nestopia"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      ngp)
        EXTENSION=".ngp"
        PLAYLIST="SNK - Neo Geo Pocket.lpl"
        LIBRETRO="app0:/mednafen_ngp_libretro.self"
        LIBNAME="Mednafen NeoPop"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      ngpc)
        EXTENSION=".ngc"
        PLAYLIST="SNK - Neo Geo Pocket Color.lpl"
        LIBRETRO="app0:/mednafen_ngp_libretro.self"
        LIBNAME="Mednafen NeoPop"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      pce)
        EXTENSION=".pce"
        PLAYLIST="NEC - PC Engine - TurboGrafx 16.lpl"
        LIBRETRO="app0:/mednafen_pce_fast_libretro.self"
        LIBNAME="Mednafen PCE Fast"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      sms)
        EXTENSION=".sms"
        PLAYLIST="Sega - Master System - Mark III.lpl"
        LIBRETRO="app0:/genesis_plus_gx_libretro.self"
        LIBNAME="Genesis Plus GX"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      snes)
        EXTENSION=".sfc"
        PLAYLIST="Nintendo - Super Nintendo Entertainment System.lpl"
        LIBRETRO="app0:/snes9x2002_libretro.self"
        LIBNAME="Snes9x 2002"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      ws)
        EXTENSION=".ws"
        PLAYLIST="Bandai - Wonderswan.lpl"
        LIBRETRO="app0:/mednafen_wswan_libretro.self"
        LIBNAME="Mednafen WonderSwan"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      wsc)
        EXTENSION=".wsc"
        PLAYLIST="Bandai - Wonderswan Color.lpl"
        LIBRETRO="app0:/mednafen_wswan_libretro.self"
        LIBNAME="Mednafen WonderSwan"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      *)
        PLAYLIST=""
        echo "Hardware $CONSOLE is not supported."
        ;;
    esac

  if [[ ! -z $PLAYLIST ]]
  then
    FULLPATH=$(echo ux0:/homebrew/roms/$CONSOLE/$GAMENAME | tr '_' ' ')
    CRC32="00000000"
    echo "$FULLPATH" >> "$PLAYLIST"
    echo "$FULLNAME" >> "$PLAYLIST"
    echo "$LIBRETRO" >> "$PLAYLIST"
    echo "$LIBNAME" >> "$PLAYLIST"
    echo "$CRC32|crc" >> "$PLAYLIST"
    echo "$PLAYLIST" >> "$PLAYLIST"
    echo -n .
  fi

  done
echo
done

echo -n "Uploading playlists to Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /ux0:/data/retroarch/playlists ; mput *.lpl" > /dev/null
echo "done"

exit 0
