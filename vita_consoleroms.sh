#!/bin/bash

. ./settings

ZIPEXT=".zip"

if [ $# -eq 0 ]; then
  echo "Error: no argument present. Please enter at least one rom folder name."
  exit 1
fi

check_revision () {
  BASENAME=$(basename "${2}" ${ZIPEXT})
  ROMEXT="${BASENAME##*.}"
  if [[ -f "${BASENAME} (Rev 3).${ROMEXT}${ZIPEXT}" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev 3).${ROMEXT}${ZIPEXT}"
  elif [[ -f "${BASENAME} (Rev B).${ROMEXT}${ZIPEXT}" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev B).${ROMEXT}${ZIPEXT}"
  elif [[ -f "${BASENAME} (Rev 2).${ROMEXT}${ZIPEXT}" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev 2).${ROMEXT}${ZIPEXT}"
  elif [[ -f "${BASENAME} (Rev A).${ROMEXT}${ZIPEXT}" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev A).${ROMEXT}${ZIPEXT}"
  elif [[ -f "${BASENAME} (Rev 1).${ROMEXT}${ZIPEXT}" ]]; then
    push_to_vita "$1" "${BASENAME} (Rev 1).${ROMEXT}${ZIPEXT}"
  else
    push_to_vita "$1" "${2}"
  fi
}

push_to_vita () {
  HW=$(echo $1 | rev | cut -d '/' -f1 | rev)
  if [ "$HW" != "n64" ]; then
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd ${VITA_ROMPATH}/${HW} ; mput -c \"$1/${2}\""
  else
    lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd ${N64_ROMPATH}/ ; mput -c \"$1/${2}\""
  fi
}

check_country () {
  GAMENAME=$(find . -name "$2 (*$3*)*" | grep -v BIOS | grep -v \(Unl | grep -v \([dD]emo | grep -v \(Hack | grep -v \(Program | grep -v \(Beta | grep -v \(NP | grep -v \(Alt | head -n1)
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
