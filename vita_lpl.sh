#!/bin/bash

. ./settings

echo -n "Cleaning up local directory... "
rm -f *.lpl
echo "done."

echo -n "Cleaning up remote directory on Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$RETROPATH ; mrm -f playlists/*" > /dev/null
echo "done."

CONSOLELIST=$(lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH ; cls -1 " | tr -d $'\r' | sed -e 's/\/$//')

_mame ()
{
  MAMEGAME=$(basename $1 .zip)
  FULLNAME=$($MAMEBIN -listfull "$MAMEGAME" | grep -v Description | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
  if [[ ! -z "$FULLNAME" ]]; then
    echo -n .
  else
    echo "Game $1 was skipped!"
    SKIP=1
  fi
}

_getname ()
{
  case $3 in
    fbneo|neogeo|cps[12]|mame2003)
      _mame "$1"
      ;;
    *)
      if $(echo "$1" | grep -q "$2"); then
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        if $(echo "$GAME" | grep -q \.zip); then
          FULLNAME=$(basename "$GAME" "$2.zip")
        else
          FULLNAME=$(basename "$GAME" "$2")
        fi
      else
        echo "$1" has an unrecognized extension, skipping
        SKIP=1
      fi
      ;;
  esac
}

_init_lpl ()
{
  echo -e "{\n  \"version\": \"1.2\",\n  \"default_core_path\": \"$2\",\n  \"default_core_name\": \"$3\",\n  \"items\": [" > "$1"
}

_add_game_to_json ()
{
  echo -e "    {\n      \"path\": \"$1\",\n      \"label\": \"$2\",\n      \"core_path\": \"$3\",\n      \"core_name\": \"$4\",\n      \"crc32\": \"$5|crc\",\n      \"db_name\": \"$6\"\n    }," >> "$6"
}

_close_lpl ()
{
  echo -e "  ]\n}" >> "$1"
}

for CONSOLE in $CONSOLELIST
do
  echo Generating playlist for : $CONSOLE

  COMMAND="open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/$CONSOLE/ ; cls -1 "
  GAMELIST=$(lftp -c "$COMMAND" | tr ' ' '_' | tr -d $'\r')
  FULLNAME=""

  case $CONSOLE in
    cps2)
      PLAYLIST="Arcade (FB Alpha 2012 CPS-2).lpl"
      LIBRETRO="app0:/fbalpha2012_cps2_libretro.self"
      LIBNAME="FB Alpha 2012 CPS-2"
      ;;
    fbneo|neogeo)
      PLAYLIST="FBNeo - Arcade Games.lpl"
      LIBRETRO="app0:/fbneo_libretro.self"
      LIBNAME="FBNeo"
      ;;
    fds)
      EXTENSION=".fds"
      PLAYLIST="Nintendo - Family Computer Disk System.lpl"
      LIBRETRO="app0:/nestopia_libretro.self"
      LIBNAME="Nestopia"
      ;;
    gba)
      EXTENSION=".gba"
      PLAYLIST="Nintendo - Game Boy Advance.lpl"
      LIBRETRO="app0:/gpsp_libretro.self"
      LIBNAME="gpSP"
      ;;
    gb)
      EXTENSION=".gb"
      PLAYLIST="Nintendo - Game Boy.lpl"
      LIBRETRO="app0:/gambatte_libretro.self"
      LIBNAME="Gambatte"
      ;;
    gbc)
      EXTENSION=".gbc"
      PLAYLIST="Nintendo - Game Boy Color.lpl"
      LIBRETRO="app0:/gambatte_libretro.self"
      LIBNAME="Gambatte"
      ;;
    gg)
      EXTENSION=".gg"
      PLAYLIST="Sega - Game Gear.lpl"
      LIBRETRO="app0:/genesis_plus_gx_libretro.self"
      LIBNAME="Genesis Plus GX"
      ;;
    md)
      EXTENSION=".md"
      PLAYLIST="Sega - Mega Drive - Genesis.lpl"
      LIBRETRO="app0:/genesis_plus_gx_libretro.self"
      LIBNAME="Genesis Plus GX"
      ;;
    mame2003)
      EXTENSION=".zip"
      PLAYLIST="MAME.lpl"
      LIBRETRO="app0:/mame2003_libretro.self"
      LIBNAME="MAME 2003"
      ;;
    megacd)
      EXTENSION=".cue"
      PLAYLIST="Sega - Mega-CD - Sega CD.lpl"
      LIBRETRO="app0:/picodrive_libretro.self"
      LIBNAME="Picodrive"
      ;;
    lynx)
      EXTENSION=".lnx"
      PLAYLIST="Atari - Lynx.lpl"
      LIBRETRO="app0:/handy_libretro.self"
      LIBNAME="Handy"
      ;;
    nes)
      EXTENSION=".nes"
      PLAYLIST="Nintendo - Nintendo Entertainment System.lpl"
      LIBRETRO="app0:/nestopia_libretro.self"
      LIBNAME="Nestopia"
      ;;
    neocd)
      EXTENSION=".cue"
      PLAYLIST="SNK - Neo Geo CD.lpl"
      LIBRETRO="app0:fbneo_libretro.self"
      LIBNAME="FBNeo"
      ;;
    ngp)
      EXTENSION=".ngp"
      PLAYLIST="SNK - Neo Geo Pocket.lpl"
      LIBRETRO="app0:/mednafen_ngp_libretro.self"
      LIBNAME="Mednafen NeoPop"
      ;;
    ngpc)
      EXTENSION=".ngc"
      PLAYLIST="SNK - Neo Geo Pocket Color.lpl"
      LIBRETRO="app0:/mednafen_ngp_libretro.self"
      LIBNAME="Mednafen NeoPop"
      ;;
    pce)
      EXTENSION=".pce"
      PLAYLIST="NEC - PC Engine - TurboGrafx 16.lpl"
      LIBRETRO="app0:/mednafen_pce_fast_libretro.self"
      LIBNAME="Mednafen PCE Fast"
      ;;
    pcecd)
      EXTENSION=".cue"
      PLAYLIST="NEC - PC Engine CD - TurboGrafx-CD.lpl"
      LIBRETRO="app0:/mednafen_pce_fast_libretro.self"
      LIBNAME="Mednafen PCE Fast"
      ;;
    ps1)
      EXTENSION=".cue"
      PLAYLIST="Sony - PlayStation.lpl"
      LIBRETRO="app0:/pcsx_rearmed_libretro.self"
      LIBNAME="PCSX ReArmed"
      ;;
    sg1000)
      EXTENSION=".sg"
      PLAYLIST="Sega - SG-1000.lpl"
      LIBRETRO="app0:/genesis_plus_gx_libretro.self"
      LIBNAME="Genesis Plus GX"
      ;;
    sms)
      EXTENSION=".sms"
      PLAYLIST="Sega - Master System - Mark III.lpl"
      LIBRETRO="app0:/genesis_plus_gx_libretro.self"
      LIBNAME="Genesis Plus GX"
      ;;
    snes)
      EXTENSION=".sfc"
      PLAYLIST="Nintendo - Super Nintendo Entertainment System.lpl"
      LIBRETRO="app0:/snes9x2005_libretro.self"
      LIBNAME="Snes9x 2005"
      ;;
    ws)
      EXTENSION=".ws"
      PLAYLIST="Bandai - Wonderswan.lpl"
      LIBRETRO="app0:/mednafen_wswan_libretro.self"
      LIBNAME="Mednafen WonderSwan"
      ;;
    wsc)
      EXTENSION=".wsc"
      PLAYLIST="Bandai - Wonderswan Color.lpl"
      LIBRETRO="app0:/mednafen_wswan_libretro.self"
      LIBNAME="Mednafen WonderSwan"
      ;;
    *)
      PLAYLIST=""
      echo "Hardware $CONSOLE is not supported."
      ;;
  esac

  _init_lpl "$PLAYLIST" "$LIBRETRO" "$LIBNAME"

  for GAMENAME in $GAMELIST
  do
    SKIP=0

    _getname "$GAMENAME" "$EXTENSION" "$CONSOLE"

    if [[ ! -z "$PLAYLIST" ]]
    then
      if [[ $SKIP -eq 0 ]]
      then
        FULLPATH=$(echo $ROMPATH/$CONSOLE/$GAMENAME | tr '_' ' ')
        CRC32="00000000"
        _add_game_to_json "$FULLPATH" "$FULLNAME" "$LIBRETRO" "$LIBNAME" "$CRC32" "$PLAYLIST"
        echo -n .
      fi
    fi

  done

  _close_lpl "$PLAYLIST"
  echo

done

echo -n "Uploading playlists to Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$RETROPATH/playlists ; mput *.lpl" > /dev/null
echo "done"

exit 0
