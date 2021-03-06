#!/bin/bash

. ./settings

echo -n "Cleaning up local directory... "
rm -f *.lpl
echo "done."

echo -n "Cleaning up remote directory on Vita... "
lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$RETROPATH ; mrm -f playlists/*" > /dev/null
echo "done."

CONSOLELIST=$(lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$VITA_ROMPATH ; cls -1 " | tr -d $'\r' | sed -e 's/\/$//')

_mame ()
{
  MAMEGAME=$(basename $1 .zip)
  FULLNAME=$($MAMEBIN -listfull "$MAMEGAME" | grep -v Description | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/' | sed 's/) (/, /g')
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
      case "$1" in
        simpsons.zip|ssriders.zip|tmnt.zip|tmnt2.zip|xmen.zip)
          SKIP=1
          ;;
        simpsons2p.zip|simpsn2p.zip)
          _mame simpsons.zip
          ;;
        ssriderusbc.zip|ssrdrubc.zip)
          _mame ssriders.zip
          ;;
        tmht2p.zip)
          _mame tmnt.zip
          ;;
        tmnt22pu.zip|tmnt22p.zip)
          _mame tmnt2.zip
          ;;
        xmen2pu.zip|xmen2p.zip)
          _mame xmen.zip
          ;;
        *)
          _mame "$1"
          ;;
      esac
      ;;
    sms)
      if $(echo "$1" | grep -q .sms); then
        EXTENSION=".sms"
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        FULLNAME=$(basename "$GAME" "$EXTENSION")
      elif $(echo "$1" | grep -q .sc); then
        EXTENSION=".sc"
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        FULLNAME=$(basename "$GAME" "$EXTENSION")
      elif $(echo "$1" | grep -q .sg); then
        EXTENSION=".sg"
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        FULLNAME=$(basename "$GAME" "$EXTENSION")
      else
        echo
        echo -n -e "\033[0;31m$1\033[0m" has an unrecognized extension, skipping
        SKIP=1
      fi
      ;;
    gg)
      if $(echo "$1" | grep -q .sms); then
        EXTENSION=".sms"
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        FULLNAME=$(basename "$GAME" "$EXTENSION")
      elif $(echo "$1" | grep -q .gg); then
        EXTENSION=".gg"
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        FULLNAME=$(basename "$GAME" "$EXTENSION")
      else
        echo
        echo -n -e "\033[0;31m$1\033[0m" has an unrecognized extension, skipping
        SKIP=1
      fi
      ;;
    *)
      if $(echo "$1" | grep -q "$2"); then
        GAME=$(echo "$1" | tr '_' ' ' | sed -e "s/\[\!\]//")
        if $(echo "$GAME" | grep -q \.zip); then
          FULLNAME=$(basename "$GAME" "$2.zip")
        elif $(echo "$GAME" | grep -q \.7z); then
          FULLNAME=$(basename "$GAME" "$2.7z")
        else
          FULLNAME=$(basename "$GAME" "$2")
        fi
      else
        echo
        echo -n -e "\033[0;31m$1\033[0m" has an unrecognized extension, skipping
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
  sed -i '$ s/,//' "$1"
  echo -e "  ]\n}" >> "$1"
}

for CONSOLE in $CONSOLELIST
do
  echo Generating playlist for : $CONSOLE

  COMMAND="open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$VITA_ROMPATH/$CONSOLE/ ; cls -1 "
  GAMELIST=$(lftp -c "$COMMAND" | tr ' ' '_' | tr -d $'\r')
  FULLNAME=""

  case $CONSOLE in
    cps2)
      PLAYLIST="Capcom - CP System II.lpl"
      LIBRETRO="app0:/fbneo_libretro.self"
      LIBNAME="FBNeo"
      ;;
    fbneo)
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
      LIBRETRO="app0:/sms_plus_gx_libretro.self"
      LIBNAME="SMS Plus GX"
      ;;
    md)
      EXTENSION=".md"
      PLAYLIST="Sega - Mega Drive - Genesis.lpl"
      LIBRETRO="app0:/genesis_plus_gx_libretro.self"
      LIBNAME="Genesis Plus GX"
      ;;
    mame2003)
      PLAYLIST="MAME.lpl"
      LIBRETRO="app0:/mame2003_plus_libretro.self"
      LIBNAME="MAME 2003 Plus"
      ;;
    megacd)
      EXTENSION=".chd"
      PLAYLIST="Sega - Mega-CD - Sega CD.lpl"
      LIBRETRO="app0:/genesis_plus_gx_libretro.self"
      LIBNAME="Genesis Plus GX"
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
      EXTENSION=".chd"
      PLAYLIST="SNK - Neo Geo CD.lpl"
      LIBRETRO="app0:/neocd_libretro.self"
      LIBNAME="NeoCD"
      ;;
    neogeo)
      PLAYLIST="SNK - Neo Geo.lpl"
      LIBRETRO="app0:/fbneo_libretro.self"
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
      LIBRETRO="app0:/mednafen_pce_libretro.self"
      LIBNAME="Mednafen PCE"
      ;;
    pcecd)
      EXTENSION=".chd"
      PLAYLIST="NEC - PC Engine CD - TurboGrafx-CD.lpl"
      LIBRETRO="app0:/mednafen_pce_libretro.self"
      LIBNAME="Mednafen PCE"
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
    sgx)
      EXTENSION=".pce"
      PLAYLIST="NEC - PC Engine SuperGrafx.lpl"
      LIBRETRO="app0:/mednafen_supergrafx_libretro.self"
      LIBNAME="Mednafen SuperGrafx"
      ;;
    sms)
      EXTENSION=".sms"
      PLAYLIST="Sega - Master System - Mark III.lpl"
      LIBRETRO="app0:/sms_plus_gx_libretro.self"
      LIBNAME="SMS Plus GX"
      ;;
    snes)
      EXTENSION=".sfc"
      PLAYLIST="Nintendo - Super Nintendo Entertainment System.lpl"
      LIBRETRO="app0:/snes9x2005_plus_libretro.self"
      LIBNAME="Snes9x 2005 Plus"
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
      continue
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
        FULLPATH=$(echo $VITA_ROMPATH/$CONSOLE/$GAMENAME | tr '_' ' ')
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
