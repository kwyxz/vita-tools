#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Error: no argument present. Please enter at least one rom folder name."
  exit 1
fi

check_country () {
  ROMFILE=$(find . -name "$1 (*$2*)*")
  case "$ROMFILE" in
   '') # no rom file found for this country
      case "$2" in
      "France") check_country "$1" "Europe" ;;
      "Europe") check_country "$1" "USA" ;;
#      "USA") check_country "$1" "Japan" ;;
      esac ;;
   *) find . -name "$1 (*$2*)*" ;;
  esac
}

extract_romname () {
  cd $1
  while read romname; do
    check_country "$romname" "France"
  done < <(ls -1 | cut -d '(' -f 1 | sort | uniq | grep -vi BIOS) 
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
