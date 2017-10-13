#!/bin/bash

BASEFOLDER=./
VITA_IP=192.168.0.10
VITA_PORT=1337

if [ $# -lt 1 ]
then
  echo "Usage: $0 file(s).vpk" 
  exit 1
fi

if [ $1 == "clean" ]
then
  echo -n "Cleaning temporary directories ... "
  rm -rf *.dir
  echo "done."
  echo -n "Cleaning repacked files ... "
  rm -f repack*.vpk
  echo "done."
  exit 0
fi

while [ $# -ne 0 ]
do
  VPK=$(basename $1)
  if [ -f repack-$VPK ]; then echo Removing previous repacked $VPK ; rm repack-$VPK ; fi
  DIR=$VPK.dir
  if [ -d $DIR ]; then echo Removing previous temporary folder $DIR ; rm -rf $DIR ; fi

  case $VPK in
    desmume_libretro.vpk)
      HW=ds
      ;;
    fbalpha_libretro.vpk|mame2003_libretro.vpk)
      HW=arcade
      ;;
    gambatte_libretro.vpk)
      HW=gb
      ;;
    genesis_plus_gx_libretro.vpk)
      HW=sms
      ;;
    gpsp_libretro.vpk|vba_next_libretro.vpk)
      HW=gba
      ;;
    handy_libretro.vpk)
      HW=lynx
      ;;
    mednafen_ngp_libretro.vpk)
      HW=ngp
      ;;
    mednafen_pce_fast_libretro.vpk)
      HW=pce
      ;;
    mednafen_wswan_libretro.vpk)
      HW=wswan
      ;;
    nestopia_libretro.vpk)
      HW=nes
      ;;
    pcsx_rearmed_libretro.vpk)
      HW=ps1
      ;;
    picodrive_libretro.vpk)
      HW=md
      ;;
    snes9x2002_libretro.vpk|snes9x2005_libretro.vpk|snes9x2005_plus_libretro.vpk|snes9x2010_libretro.vpk)
      HW=snes
      ;;
    *)
      echo "$VPK: unsupported hardware"
      exit 1
      ;;
  esac

  mkdir $DIR
  echo -n "Unpacking VPK $1 ... "
  unzip -q -d $DIR $1
  echo done
  if [ -f $BASEFOLDER/$HW/icon0.png ] ; then cp $BASEFOLDER/$HW/icon0.png $DIR/sce_sys/ ; fi
  if [ -f $BASEFOLDER/$HW/bg.png ] ; then cp $BASEFOLDER/$HW/bg.png $DIR/sce_sys/livearea/contents/bg.png ; fi
  if [ -f $BASEFOLDER/$HW/startup.png ] ; then cp $BASEFOLDER/$HW/startup.png $DIR/sce_sys/livearea/contents/ ; fi
  if [ -f $BASEFOLDER/$HW/website.png ] ; then cp $BASEFOLDER/$HW/website.png $DIR/sce_sys/livearea/contents/ ; fi
  cd $DIR
  echo -n "Repacking new VPK ... "
  find . -type f -exec zip -9 -q ../repack-$VPK {} \;
  echo repack-$VPK
  cd ..
  rm -rf $DIR
  shift
  echo -n "Pushing to Vita ... "
  lftp -c "open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /ux0:/homebrew/vpk/ ; mput repack-$VPK" > /dev/null
  echo "done"
done
