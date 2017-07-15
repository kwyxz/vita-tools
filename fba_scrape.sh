#!/bin/bash

######################### CONFIGURATION OPTIONS #######################

# enter the location of your Final Burn Alpha DAT file
DATFILE="$HOME/.config/retroarch/database/FB Alpha - Arcade Games.dat"

# enter the location of your MAME binary (if no MAME binary leave empty)
MAMEBIN=/usr/local/games/mame/mame64

# enter the location of your Libretro cores
RETROCORES=/usr/local/lib/libretro/

########################## END OF CONFIGURATION #######################

_mame ()
{
  MAMEGAME=$(basename $1 .zip)
  FULLNAME=$("$MAMEBIN" -listfull | grep ^"$MAMEGAME\ " | cut -d '"' -f 2 \
  # no need for this now, handled by Retroarch directly
  # | tr '&' '_' | tr '*' '_' | tr '/' '_' | tr ':' '_' | tr '`' '_' | tr '<' '_' | tr '>' '_' | tr '?' '_' | tr '\\' '_' | tr '|' '_'
            )
}

if [ $# -lt 1 ] || ( ( [ $# -lt 2 ] ) && ( [ $1 == "--new" ] || [ $1 == "-n" ] ) )
  then
    echo "Usage: $0 [ -n, --new ] rompath/"
    exit 1
fi

if [ $1 == "--new" ] || [ $1 == "-n" ]
then
  NEW=1
  LIBRETRO="$RETROCORES"/fbalpha_libretro.so
  LIBNAME="FB Alpha"
  PLAYLIST="FB Alpha - Arcade Games.lpl"
  shift
else
  NEW=0
  LIBRETRO="$RETROCORES"/fbalpha2012_libretro.so
  LIBNAME="FB Alpha 2012"
  PLAYLIST="FB Alpha 2012 - Arcade Games.lpl"
fi

if [[ ! -d $1 ]]
then
  echo "Error: path $1 does not exist."
  exit 1
else
  if [[ -f "$PLAYLIST" ]]
  then
    echo -n "Cleaning up local directory... "
    rm -f "$PLAYLIST"
    echo done
  fi

  echo "Generating playlist $PLAYLIST"

  for ZIPFILE in $1/*
  do
    FULLNAME=$(grep -B 3 \"$(basename $ZIPFILE) "$DATFILE" | head -n1 | cut -d '"' -f 2)
  
    CRC32="$(crc32 $ZIPFILE)"
  
    if [[ -z "$FULLNAME" ]]
    then
      if [[ $NEW -ne 0 ]] && [[ ! -z "$MAMEBIN" ]]
      then
        _mame "$ZIPFILE"
      fi
    fi
    
    if [[ ! -z "$FULLNAME" ]]
    then
      echo -n "."
      echo "$ZIPFILE" >> "$PLAYLIST"
      echo "$FULLNAME" >> "$PLAYLIST"
      echo "$LIBRETRO" >> "$PLAYLIST"
      echo "$LIBNAME" >> "$PLAYLIST"
      echo "$CRC32|crc" >> "$PLAYLIST"
      echo "$PLAYLIST" >> "$PLAYLIST"
    else
      if [[ $NEW -eq 1 ]]
      then
        echo;echo "Skipping $ZIPFILE : not in the DAT nor in MAME"
      else
        echo;echo "Skipping $ZIPFILE : not found in FBA 2012 DAT file (try with --new)"
      fi
    fi
  
  done
  
  echo " done"
fi
