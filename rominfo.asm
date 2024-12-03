; ====================================================================
; ----------------------------------------------------------------
; ROM/DISC Info
;
; DO NOT CHANGE THE SIZE OF THE STRINGS
; ----------------------------------------------------------------

; --------------------------------------------------------
; System tags
;
; First 4 letters MUST contain "SEGA" or " SEGA"
; if not this will NOT boot on hardware.
; --------------------------------------------------------

HTAG_SYS_MD	equ "SEGA GENESIS    "
HTAG_SYS_MCD	equ "SEGA GENESIS    "	; Same as cartridge
HTAG_SYS_MARS	equ "SEGA 32X        "
HTAG_SYS_MARSCD	equ "SEGA GENESIS    "	; Same as cartridge
HTAG_SYS_PICO	equ "SEGA PICO       "

; --------------------------------------------------------
; SCD/CD32X ONLY
;
; Volume and System(SDK/Engine) name
;
; Note:
; Leave HTAG_SYSNAME as is if you haven't modified
; any of the Nikona SDK files (/system folder)
; --------------------------------------------------------

HTAG_DISCID	equ "NIKONACD   "	; SCD Disc Volume name
HTAG_DISCID_M	equ "NIKONACD32X"	; CD32X Disc Volume name
HTAG_SYSNAME	equ "NIKONA-SDK "
HTAG_CDVER	equ $0100|$02		; $0100|Version: $00-$FF

; --------------------------------------------------------
; Release date
;
; "(C)name year.month"
; --------------------------------------------------------

HTAG_DATEINFO	equ "(C)GF64 2024.???"

; --------------------------------------------------------
; "Domestic" Name, Your game's name in your language
; --------------------------------------------------------

HTAG_NDM_MD	equ "Nikona MD                                       "
HTAG_NDM_MCD	equ "Nikona MCD                                      "
HTAG_NDM_MARS	equ "Nikona SUPER32X                                 "
HTAG_NDM_MARSCD	equ "Nikona CD32X                                    "
HTAG_NDM_PICO	equ "Nikona PICO                                     "

; --------------------------------------------------------
; "Overseas" Name, Your game's name in English
; --------------------------------------------------------

HTAG_NOV_MD	equ "Nikona GENESIS                                  "
HTAG_NOV_MCD	equ "Nikona SCD                                      "
HTAG_NOV_MARS	equ "Nikona 32X                                      "
HTAG_NOV_MARSCD	equ "Nikona CD32X                                    "
HTAG_NOV_PICO	equ "Nikona PICO                                     "

; --------------------------------------------------------
; Serial number
;
; "id anything-vv"
;
; id:
; GM - Game
; AI - Educative
;
; anything:
; Your own serial format, there's no standard for this.
;
; vv:
; Version number: 00 to 99
; --------------------------------------------------------

HTAG_SERIAL	equ "GM HOMEBREW-02"

; --------------------------------------------------------
; Regions supported
; --------------------------------------------------------

HTAG_REGIONS	equ "F               "

; --------------------------------------------------------
; Save data settings
;
; Only UPPERCASE and _ are allowed.
; --------------------------------------------------------

SET_SRAMSIZE	equ $100		; SRAM/BRAM filesize, must be "blocks" of $40 bytes ($20 w/Protection)
HTAG_CDSAVE	equ "NIKONACD___"	; SCD internal save name
HTAG_MARSCDSAV	equ "NIKONACD32X"	; CD32X internal save name
