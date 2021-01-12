#!/bin/bash

. ./settings

# which emu is the default
DEFAULT=fbneo
SECONDARY=mame2003

# a few things to set beforehand
SCRIPTPATH=$(pwd)
# the location of the MAME 2003 fullset on the local host
MAME2k3ROMDIR=$GAMESDIR/mame2003/
# the location of the Final Burn Neo fullset on the local host
FBNEOROMDIR=$GAMESDIR/fbneo/
# the command that will be run ton establish what games are clones
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
# the complete list of games, it saves time and RAM to just create a flat file
$MAMEBIN -listfull | sort > ${SCRIPTPATH}/LISTFULL
# a temporary location to rezip the ROM file
TMPDIR=/tmp/
# where is the rezipper
REZIP=$(command -v zipify)

# Print things in beautiful colors
# This is the generic formatting function
# Colors are defined in specific functions below
print_color() {
  printf "%-10.9s%-10.9s\e[1;${4}m%-60s\e[0m\n" "$1" "$2" "$3"
}

print_red() {
  print_color "$1" "$2" "$3" "31"
}

print_green() {
  print_color "$1" "$2" "$3" "32"
}

print_yellow() {
  print_color "$1" "$2" "$3" "33"
}

print_blue() {
  print_color "$1" "$2" "$3" "34"
}

# The standard usage message when no argument is given
usage() {
  printf "Usage: $0 <MAME gamename>"
  exit 1
}

# Print out an error message when an error is encountered
die() {
  printf "ERROR: $1"
  exit 1
}

# Test if a game is present in the clone list
is_clone() {
  return $(echo ${CLONES} | grep -q -w ${1})
}

# Upload a game to the remote host
push_game() {
  # Otherwise we upload it to the appropriate folder
  print_green "$1" "$2" "$FULLNAME"
  if [ -f ${2}.7z ]; then
    # Unless STAGING=1 is set at runtime, then we're only doing a dry run
    if [ -n "${STAGING+1}" ]; then
      print_yellow "staging" "$2" "not pushing"
    else
      # copy to the temp location
      cp "${2}.7z" "$TMPDIR/"
      # rezip
      cd "$TMPDIR"
      ${REZIP} "${2}.7z" > /dev/null
      # Push the rom
      lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd ${VITA_ROMPATH}/${1} ; mput -c \"${2}.zip\""
    fi
  else
    # If the rom is not found, display a message but continue
    print_red "critical" "$2" "not found"
  fi
}

# find if we need to push an alternate game
push_alt_game() {
  case "$2" in
    simpsons)
      ALTROM="simpsons2p"
      ;;
    ssriders)
      ALTROM="ssridersubc"
      ;;
    tmnt)
      ALTROM="tmht2p"
      ;;
    tmnt2)
      ALTROM="tmnt22pu"
      ;;
    xmen)
      ALTROM="xmen2pu"
      ;;
    *)
      ALTROM="puckman"
      echo "No alternate found for $2"
      ;;
    esac
    # with Konami games we need to merge or use a merged set
    # this might not be necessary with future cases
    push_game "$1" ${ALTROM}
}

# handle specific cases
push_emu() {
  case "$2" in
    ${KONAMI})
      push_alt_game "$1" "$2"
      ;;
    ${BOOTLEG})
      print_yellow "bootleg" "$2" "${FULLNAME}"
      ;;
    ${CONVERSION})
      print_yellow "convert" "$2" "${FULLNAME}"
      ;;
    ${FISHING})
      print_yellow "fishing" "$2" "${FULLNAME}"
      ;;
    ${GUN})
      print_yellow "lightgun" "$2" "${FULLNAME}"
      ;;
    ${KOREA})
      print_yellow "korea" "$2" "${FULLNAME}"
      ;;
    ${MAHJONG})
      print_yellow "mahjong" "$2" "${FULLNAME}"
      ;;
    # ${MATURE})
    #   print_yellow "mature" "$2" "${FULLNAME}"
    #   ;;
    ${PURIKURA})
      print_yellow "purikura" "$2" "${FULLNAME}"
      ;;
    ${PROTOTYPE})
      print_yellow "prototype" "$2" "${FULLNAME}"
      ;;
    ${QUIZZES})
      print_yellow "quiz" "$2" "${FULLNAME}"
      ;;
    ${RACING})
      print_yellow "racing" "$2" "${FULLNAME}"
      ;;
    ${REJECTS})
      print_yellow "blacklist" "$2" "${FULLNAME}"
      ;;
    *)
      push_game "$1" "$2"
      ;;
  esac
}

# find out if game will run with MAME 2003 or Final Burn Neo
select_emu() {
  # default emulator is first
  if [ -f "${GAMESDIR}/${DEFAULT}/$1".7z ]
  then
    cd "${GAMESDIR}/${DEFAULT}/"
    push_emu "${DEFAULT}" "$1"
  elif [ -f "${GAMESDIR}/${SECONDARY}/$1".7z ]
  then
    cd "${GAMESDIR}/${SECONDARY}/"
    push_emu ${SECONDARY} "$1"
  else print_red "notfound" "$1" "skipping..."
  fi
}

# handle driver-specific cases
select_driver() {
  case "$2" in
    cps2)
      # CPS2 separate folder
      cd ${FBNEOROMDIR}
      push_emu cps2 "$1"
      ;;
    dec0)
      # issues with Final Burn, forcing MAME here
      cd ${MAME2k3ROMDIR}
      push_emu mame2003 "$1"
      ;;
    neogeo)
      # Neo Geo separate folder
      cd ${FBNEOROMDIR}
      push_emu neogeo "$1"
      ;;
    segas32)
      case "$1" in
        spidman)
          # a rare case of game renamed between MAME 2003 and modern MAME
          push_game mame2003 spidey
          ;;
        *)
          select_emu "$1"
          ;;
      esac
      ;;
    # blacklisted drivers or just cannot run on Vita
    namcos11|stv|jalmah|mahjong|royalmah|cps3|konamigx)
      print_red "denied" "$1" "driver not allowed"
      ;;
    *)
    select_emu "$1"
    ;;
  esac
}

# test argument presence
if [ $# -lt 1 ]
  then
    usage
fi

# main loop
while [ $# -ne 0 ]
do
  echo "Default emulator is $DEFAULT"
  # find which driver this is, using current version of MAME
  # we *really* don't want to parse XML files
  # this should be replaced by a flat file though
  DRIVER=$(${MAMEBIN} -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
  print_blue "Emulator" "Rom" "Driver: ${DRIVER}"
  # push games running on the same driver
  # this helps discovering lesser-known games that are probably of interest
  for GAME in $(${MAMEBIN} -listsource | grep -w $(echo ${DRIVER}.cpp) | awk '{print $1}')
  do
    # avoid clones, we only want originals
    if ! is_clone ${GAME}
    then
      # get the game's fullname from MAME
      FULLNAME=$(grep -w "${GAME}" ${SCRIPTPATH}/LISTFULL | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
      select_driver ${GAME} ${DRIVER}
    fi
  done
  shift
done

rm -f ${SCRIPTPATH}/LISTFULL
exit 0
