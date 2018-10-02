These are the tools I use to manage RetroArch on my Vita.

# settings

The first thing to do is to configure the settings file accordingly.

VITA_IP is the IP address of your Vita
VITA_PORT should be left as 1337 by default as it is the port of the FTP server in VitaShell

Now you want to configure the remote paths, aka the location of things on your Vita. 
I created a folder called "homebrew" in the ux0: directory but you can change it to anything you like. 
The most important is the ROMPATH which is the location where you are going to store all your roms on the Vita. For me it is in ux0:/homebrew/roms
Then, the RETROPATH is the location of RetroArch's data files, which by default is ux0:/data/retroarch (I do not recommend changing this one)

Next, the location of your roms in GAMESDIR. My roms on the vita are split between architectures, with specific subfolders names. The subfolders are named as such:

- 32x - Sega 32x
- fba - for Final Burn supported arcade hardware
- cps1 - Capcom Play System 1
- cps2 - Capcom Play System 2
- ds - Nintendo DS
- neogeo - SNK Neo Geo AES / MVS
- gb - Nintendo Game Boy
- gbc - Nintendo Game Boy Color
- gba - Nintendo Game Boy Advance
- gg - Sega Game Gear
- mame - for MAME supported arcade hardware
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

And finally, for Arcade game name scraping, MAMEBIN is the location of your MAME binary. If you don't have any arcade game, you can disregard this setting.

Every single one of these scripts requires the "lftp" FTP client to be installed.

# vita_romupload.sh

Takes one or several folder names then selects the most appropriate version of a ROM to push:

- US first
- French second (since I am french, but you can replace this with your own language or comment out in the script)
- Europe third
- World fourth
- Japan if nothing else exists (so many RPGs on the SNES...)

It then pushes the games to their respective folders on the Vita.
The folders must exist on the Vita otherwise the FTP command will fail.
For easy playlist generation, I recommend using the folder names described above.

# vita_pushfbaroms.sh

This script will take a game name as an argument (following the MAME naming scheme) and will push every game running the same driver to the Vita. This is convenient for quickly pushing every CPS-1, Neo Geo, or Sega System 16 game at once. The script will prefer Final Burn whenever the game is supported for performance reasons. 

Additional settings to be configured: the location of your MAME2003 and FBA roms. By default, they are in fba/ and mame2003/ of your $GAMESDIR directory configured in the "settings" file. You can use other versions of MAME though MAME2003 is recommended for performance.

# vita_lpl.sh

This script is the only one that requires the folders on the Vita to follow the naming scheme described above, and it might change in a future release. For now, it generates playlists using the file names for console games and the MAME binary for arcade games. As such, the names of your ROM files are very important. Once the playlists are generated, they will appear in RetroArch, allowing you to start the games directly. If you wish to change the emulator used for each hardware you can do so on the LIBRETRO lines in the script.
