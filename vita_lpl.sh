#!/bin/bash

MAMEBIN=/usr/local/games/mame/mame64
VITA_IP=192.168.1.10
VITA_PORT=1337
HOMEBREWPATH=ux0:/homebrew
ROMPATH=$HOMEBREWPATH/roms
RETROPATH=ux0:/data/retroarch

echo -n "Cleaning up local directory... "
rm *.lpl
echo done

echo -n "Cleaning up remote directory on Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$RETROPATH ; mrm playlists/*" > /dev/null
echo done

CONSOLELIST=$(lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH ; cls -1 " | tr -d $'\r' | sed -e 's/\/$//')

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
  if $(echo "$1" | grep -q "$2")
  then
    GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
    if $(echo "$GAME" | grep -q \.zip)
    then
      FULLNAME=$(basename "$GAME" "$2.zip")
    else
      FULLNAME=$(basename "$GAME" "$2")
    fi
  else
    echo "$1" has an unrecognized extension, skipping
    SKIP=1
  fi
}

for CONSOLE in $CONSOLELIST
do
  echo Generating playlist for : $CONSOLE

  COMMAND="open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/$CONSOLE/ ; cls -1 "
  GAMELIST=$(lftp -c "$COMMAND" | tr ' ' '_' | tr -d $'\r')
  FULLNAME=""

  for GAMENAME in $GAMELIST
  do
  SKIP=0
    case $CONSOLE in
      fba|neogeo|cps[1-2])
        PLAYLIST="FB Alpha - Arcade Games.lpl"
        LIBRETRO="app0:/fbalpha_libretro.self"
        LIBNAME="FB Alpha"
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
        EXTENSION=".md"
        PLAYLIST="Sega - Mega Drive - Genesis.lpl"
        LIBRETRO="app0:/genesis_plus_gx_libretro.self"
        LIBNAME="Genesis Plus GX"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      mame2003)
        PLAYLIST="MAME.lpl"
        LIBRETRO="app0:/mame2003_libretro.self"
        LIBNAME="MAME 2003"
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
      pcecd)
        EXTENSION=".cue"
        PLAYLIST="NEC - PC Engine CD - TurboGrafx-CD.lpl"
        LIBRETRO="app0:/mednafen_pce_fast_libretro.self"
        LIBNAME="Mednafen PCE Fast"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      ps1)
        EXTENSION=".cue"
        PLAYLIST="Sony - PlayStation.lpl"
        LIBRETRO="app0:/pcsx_rearmed_libretro.self"
        LIBNAME="PCSX ReArmed"
        _getname "$GAMENAME" "$EXTENSION"
        ;;
      sg1000)
        EXTENSION=".sg"
        PLAYLIST="Sega - SG-1000.lpl"
        LIBRETRO="app0:/genesis_plus_gx_libretro.self"
        LIBNAME="Genesis Plus GX"
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
        LIBRETRO="app0:/snes9x2005_libretro.self"
        LIBNAME="Snes9x 2005"
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
    if [[ $SKIP -eq 0 ]]
    then
      FULLPATH=$(echo $ROMPATH/$CONSOLE/$GAMENAME | tr '_' ' ')
      CRC32="00000000"
      echo "$FULLPATH" >> "$PLAYLIST"
      echo "$FULLNAME" >> "$PLAYLIST"
      echo "$LIBRETRO" >> "$PLAYLIST"
      echo "$LIBNAME" >> "$PLAYLIST"
      echo "$CRC32|crc" >> "$PLAYLIST"
      echo "$PLAYLIST" >> "$PLAYLIST"
      echo -n .
    fi
  fi

  done
echo
done

echo -n "Uploading playlists to Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$RETROPATH/playlists ; mput *.lpl" > /dev/null
echo "done"

exit 0
