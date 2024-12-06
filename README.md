# NikonaMD
A code-base in pure assembly for developing on these SEGA systems: Genesis, Sega CD, Sega 32X, Sega CD32X and Sega Pico.<br>

## REQUIREMENTS

* AS Macro Assembler improved by Flamewing: https://github.com/flamewing/asl-releases/releases/ ORIGINAL AS WILL NOT WORK.<br>
* Python 3, already included on most Linux distros<br>

## HOW TO USE

### Setting up the assembler

* Pick your version: linux ("ubuntu") or win32
* Go to `/src/tools`<br>
* Make the folder `AS` and extract the contents<br>
* Build with `build.sh` (Linux) or `build.bat` (Win32)

## Features

### Genesis

* Basic PRINT text functions, text sizes 8x8 and 8x16
* Multipurpose Object system for easily making your characters/enemies/misc.
* Sprites engine (VDP side)
* Z80 sound driver
* SRAM Support
* Inputs: 3 button, 6 button and Mouse

### with Sega CD

* Basic ISO file loading
* CDDA Playback: Play, Stop, Volume fading
* BRAM Saving/Loading
* PCM playback: All 8 channels with data-streaming for larger samples *see GEMA Sound Driver
* Scaling and Rotation "Stamps" **unstable**

### with Sega 32X

* 256-color 2D smooth-scrolling layer with "Super" Sprites --Single SH2 currently--
* 256-color 3D envoriment using model data and 3D-Sprites.
* PWM playback: Maximum 7 channels with both Mono and Stereo samples *see GEMA Sound Driver

### Sega CD32X (CD+32X)

All the SCD and 32X features can be used at the same time although for the 32X there's very low memory for storing it's data, specially with the PWM samples.

### Sega Pico

* Support for the tablet, storyboard and page flipping.

(No sound as it doesn't have a Z80, requires converting the Z80 driver to 68K)

## GEMA Sound Driver

This is a custom sound driver, tracker-based that supports all the sound channels: PSG, FM, FM3 special, FM6 DAC, Sega CD PCM and 32X PWM all at the same time, you can check the progress here: https://github.com/GenesisFan64/GEMA-drv <br>
<br>

## NOTES

* All the user code goes to `/game`, DO NOT MODIFY `/system` as it will get updated with the latest changes and fixes
* To keep compatibilty to all systems CODE and DATA are separated: game code is stored as "screen modes" (ex. Title, Level...) and the DATA is stored as "banks" and loaded manually depending of the system (Picking a ROM location or loading data from Disc)

## CURRENT ISSUES

* No documentation as I keep changing things.
* (SCD) Stamps support is unstable/unfinished
* (32X) 2D-mode might break on hardware if placing too many Super-Sprites

## PLANNED

* Support for the Sega Mapper "SSF2" (Genesis and 32X only)
* Convert the entire Z80 driver to 68K for Pico
