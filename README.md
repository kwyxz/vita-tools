These are the tools I use to manage RetroArch on my Vita.

# fba_scrape

So far I have never been able to get exactly what I wanted from the Final Burn Alpha scraper in RetroArch so I decided to script these things. The result is dirty but it does the job for me. It is SOLELY based on filenames, so make sure your zip files are properly named. Then maybe it will also work for you.

Before running the script you will need to configure a few things: 
- the location of the DAT file for Final Burn Alpha (should be provided with your RetroArch installation, default value should be ok)
- the location of the MAME binary you want to use to extract the full names (can vary from FB, used only as backup if the name is not present in the DAT)
- the location of your Libretro cores (default value should be ok)

This script takes a path as an argument and will look for the zip filename in the retroarch DAT file. By default the DAT only handles files compatible with FB Alpha 2012. To be able to run games compatible with the most recent version of FB Alpha, use the --new option before the path.

EXAMPLES

To generate a list of games compatible with FBA2012, not using MAME
./fba_scrape.sh /path/to/games

To generate a list of games compatible with FBA, using MAME if configured
./fba_scrape.sh --new /path/to/games

TODO

- ability to separate games (Neo-Geo, CPS1/2, ...)
- driver autodetection to sort games out and create playlists accordingly

# vita_lpl

This script will probably be usable by me only for a while because it contains a bunch of settings that are very specific but it could evolve into something usable by many, who knows!
If you're interested in trying, there are a few variables to play with on top of the script

The FTP client required is lftp

You'll need a "homebrew" folder in /ux0 and in that folder, a "roms" folder
Within the "roms" folder, subfolders named after the hardware

Supported list of subfolders is the following:

- 32x - Sega 32x
- arcade - for Final Burn supported arcade hardware
- cps1 - Capcom Play System 1
- cps2 - Capcom Play System 2
- ds - Nintendo DS
- neogeo - SNK Neo Geo AES / MVS
- gb - Nintendo Game Boy
- gbc - Nintendo Game Boy Color
- gba - Nintendo Game Boy Advance
- gg - Sega Game Gear
- md - Sega Mega Drive / Genesis
- megacd - Sega CD / Mega CD
- lynx - Atari Lynx
- nes - Nintendo NES
- ngp - SNK Neo Geo Pocket
- ngpc - SNK Neo Geo Pocket Color
- pce - NEC PC Engine / TurboGraphx 16
- sms - Sega Mark III / Master System
- snes - Nintendo Super Famicom / Super Nintendo
- ws - Bandai Wonderswan
- wsc - Bandai Wonderswan Color

If you're adding Arcade games, you'll need Mame for name scrapping
Other hardware rom name scrapping is WIP

# vita_repack

Quick and dirty tool to repack RetroArch VPKs with more personalized icons and livearea backgrounds

# vita_pushfbaroms

Takes one or several MAME rom names as arguments then pushes every game using the same driver to the appropriate folder - MAME2003 when possible for high score saving, FBA otherwise.

# vita_romupload.sh

Takes one or several folder names (make sure your folders are named appropriately (see lpl section above about folder naming) then selects the most appropriate version of a ROM to push:

- US first
- French second (since I am french, but you can replace this with your own language or comment out in the script)
- Europe third
- World fourth
- Japan if nothing else exists (so many RPGs on the SNES...)

It then pushes the games to the respective folders on the Vita
The folders must exist on the Vita otherwise the FTP command will fail
