# NikonaMD
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⡿⠿⠿⠿⣶⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀<br>
 ⠀⠀⠀⠀⠀⠀⢀⣠⣶⢟⣿⠟⠁⢰⢋⣽⡆⠈⠙⣿⡿⣶⣄⡀⠀⠀⠀⠀⠀⠀<br>
 ⠀⠀⠀⠀⣠⣴⠟⠋⢠⣾⠋⠀⣀⠘⠿⠿⠃⣀⠀⠈⣿⡄⠙⠻⣦⣄⠀⠀⠀⠀<br>
 ⠀⢀⣴⡿⠋⠁⠀⢀⣼⠏⠺⠛⠛⠻⠂⠐⠟⠛⠛⠗⠘⣷⡀⠀⠈⠙⢿⣦⡀⠀<br>
 ⣴⡟⢁⣀⣠⣤⡾⢿⡟⠀⠀⠀⠘⢷⠾⠷⡾⠃⠀⠀⠀⢻⡿⢷⣤⣄⣀⡈⢻⣦<br>
 ⠙⠛⠛⠋⠉⠁⠀⢸⡇⠀⠀⢠⣄⠀⠀⠀⠀⣠⡄⠀⠀⢸⡇⠀⠈⠉⠙⠛⠛⠋<br>
 ⠀⠀⠀⠀⠀⠀⠀⢸⡇⢾⣦⣀⣹⡧⠀⠀⢼⣏⣀⣴⡷⢸⡇⠀⠀⠀⠀⠀⠀⠀<br>
 ⠀⠀⠀⠀⠀⠀⠀⠸⣧⡀⠈⠛⠛⠁⠀⠀⠈⠛⠛⠁⢀⣼⠇⠀⠀⠀⠀⠀⠀⠀<br>
 ⠀⠀⠀⠀⠀⠀⠀⢀⣘⣿⣶⣤⣀⣀⣀⣀⣀⣀⣤⣶⣿⣃⠀⠀⠀⠀⠀⠀⠀⠀<br>
 ⠀⠀⠀⠀⠀⣠⡶⠟⠋⢉⣀⣽⠿⠉⠉⠉⠹⢿⣍⣈⠉⠛⠷⣦⡀⠀⠀⠀⠀⠀<br>
 ⠀⠀⠀⠀⢾⣯⣤⣴⡾⠟⠋⠁⠀⠀⠀⠀⠀⠀⠉⠛⠷⣶⣤⣬⣿⠀⠀⠀⠀⠀<br>

<br>
A codebase in pure assembly for developing on these SEGA systems: Genesis, Sega CD, Sega 32X, Sega CD32X and Sega Pico.<br>

## REQUIREMENTS

* AS Macro Assembler improved by Flamewing: https://github.com/flamewing/asl-releases/releases/ original AS will not work.<br>
* Python 3<br>

## HOW TO USE

* Extract the AS assembler to these locations depending of the system you are currently using:<br>
/tools/AS/win32<br>
/tools/AS/linux<br>
* Python 3 is required for a script to convert the .p file output into a working binary, there's also other scripts used to convert Graphics, Sprites, 3D models and Sound to their respective formats.

* All the user code goes to /game, DO NOT MODIFY ANYTHING AT /system as it will get modified with the latest changes and fixes

* To keep compatibilty all the game code is stored separately as "modes" and the data are stored as BANKS, for a normal game the code would be separated as for example: the title screen, the main level code, etc.

## Features

### Genesis

* Basic PRINT text to the screen, 8x8 and 8x16
* Multipurpose Object system for easily making your characters/enemies/misc.
* Sprites engine (VDP side)
* All Sound runs entirely on Z80
* SRAM Support
* Inputs: 3 button, 6 button and Mouse

### with Sega CD

* Basic ISO file loading to Word-RAM or Genesis RAM.
* CDDA Playback Play, Stop, Fading
* BRAM Saving/Loading
* PCM playback: All 8-channels with internal-streaming for larger samples *see GEMA Sound Driver
* ASIC Stamps --Currently UNFINISHED and unstable--

### with Sega 32X

* 256-color 2D scrolling layer with "Super" Sprites --Currently unstable and slow--
* 256-color 3D envoriment using model data and 3D-Sprites.
* PWM playback: Maximum 7-channels, supports Stereo samples *see GEMA Sound Driver

### Sega CD32X (CD+32X)

All the SCD and 32X features can be used at the same time although for the 32X there's very low memory for storing it's data, specially with the PWM samples.

### Sega Pico

* Support for the tablet, storyboard and changing pages.

(No sound it doesn't have a Z80, requires converting the Z80 driver to 68K)

## GEMA Sound Driver

This is a custom sound driver, tracker-based that supports all the sound channels: PSG, FM, FM3 special, FM6 DAC, Sega CD PCM and 32X PWM all at the same time, up to 25 channels can be used in a single track (although I haven't untested all at the same time)<br>
<br>
4 modlues can be played at the same time, BGM and SFX.<br>

## CURRENT ISSUES/NOTES

* This is NOT finished at all and NOT TESTED ON REAL HARDWARE as of this current code.
* No documentation as I keep changing things until I get everyhing organized.
* (SCD) Stamps run awfully slow
* (32X) 2D-mode will get slow if loading more than 3 o 4 "Super" Sprites because a single SH2 is not powerfull enough to draw everyhing, the other SH2 is required but there's not enough RAM for sharing tasks.
* (32X) 3D-mode might randomly freeze on hardware.
