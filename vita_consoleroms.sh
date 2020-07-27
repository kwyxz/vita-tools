#!/bin/bash

. ./settings

if [ $# -eq 0 ]; then
  echo "Error: no argument present. Please enter at least one rom folder name."
  exit 1
fi

check_revision () {
  BASENAME=$(basename "${2}" .sfc.7z)
  if [[ -f "${BASENAME} (Rev 3).sfc.7z" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev 3).sfc.7z"
  elif [[ -f "${BASENAME} (Rev 2).sfc.7z" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev 2).sfc.7z"
  elif [[ -f "${BASENAME} (Rev 1).sfc.7z" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev 1).sfc.7z"
  else
    push_to_vita "$1" "${2}"
  fi
}

push_to_vita () {
  HW=$(echo $1 | rev | cut -d '/' -f1 | rev)
  lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd ${VITA_ROMPATH}/${HW} ; mput -c \"$1/${2}\""
}

check_country () {
  GAMENAME=$(find . -name "$2 (*$3*)*" | grep -v BIOS | grep -v \(Unl | grep -v \([dD]emo | grep -v \(Hack | grep -v \(Beta | grep -v \(NP | grep -v \(Rev | head -n1)
  case "$GAMENAME" in
   '') # no rom file found for this country
      case "$3" in
      "USA") check_country "$1" "$2" "France" ;;
      "France") check_country "$1" "$2" "Europe" ;;
      "Europe") check_country "$1" "$2" "World" ;;
      "World") check_country "$1" "$2" "Japan" ;;
      esac ;;
   *) check_revision "$1" "$GAMENAME" ;;
  esac
}

extract_romname () {
  cd $1
  while read romname; do
    check_country "$1" "$romname" "USA"
  done < <(ls -1 | cut -d '(' -f 1 | sort | uniq) 
  cd ..
}


for folder in "$@"; do
  if [ -d "$folder" ]; then
    extract_romname "$folder"
  else
    echo "Error: folder $folder does not exist, skipping."
  fi
done

exit 0
