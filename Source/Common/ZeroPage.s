;;; Meteoroid Source/Common/ZeroPage.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;;
;;; ZZZZZ EEEEE RRRR   OOO     PPPP    A    GGGG EEEEE
;;;    Z  E     R   R O   O    P   P  A A  G     E
;;;   Z   EEE   RRRR  O   O    PPPP  AAAAA G GGG EEE
;;;  Z    E     R   R O   O    P     A   A G   G E
;;; ZZZZZ EEEEE R   R  OOO     P     A   A  GGGG EEEEE
;;;
;;;

          * = $80
ZeroPage:
;;; 
;;; General-purpose short-term variable
;;;
;;; Use this as a temp var only within a block (non-reentrant)
Temp:
          .byte ?

Pointer:
          .word ?
;;; 
;;; Main "Traffic Cop" Switching
;;;

;;; The overall game mode.
;;; Used to select which "kernel" is in use.
GameMode:
          .byte ?

Pause:
          .byte ?
;;; 
;;; Game play/progress indicators -- global

;;; This data is saved to the first block of the save game file.
;;; It must never be more than 64 bytes (not that there's a great risk of that)
;;; In fact, it must be less than ( 64 - 4 × ProvincesCount )
;;; Currently ProvincesCount = 2 so it must be < 56 bytes

GlobalGameData:

;;; What map is the player currently on?
CurrentMap:
          .byte ?

;;; Global Timer (updated in VSYNC)
;;; This timer resets to zero when an alarm is set,
;;; but the Frame counter is used for some animation purposes.
;;; (The number of frames does in fact vary with 60Hz/50Hz locales)
ClockFourHours:
          .byte ?
ClockMinutes:
          .byte ?
ClockSeconds:
          .byte ?
ClockFrame:
          .byte ?

;;; It's an Atari game, of course we have a score.
Score:
          .byte ?, ?, ?

;;;  Where was the player last known to be safe?
BlessedX:
          .byte ?
BlessedY:
          .byte ?

CurrentHP:
          .byte ?
CurrentTanks:
          .byte ?
MaxTanks:
          .byte ?

MovementStyle:
          .byte ?

Equipment:
          .byte ?

CurrentProvince:
          .byte ?

CountdownSeconds:
          .byte ?
CountdownFrames:
          .byte ?

ScrollLeft:
          .byte ?

EndGlobalGameData:

          GlobalGameDataLength = EndGlobalGameData - GlobalGameData + 1
          
          .if GlobalGameDataLength > ($40 - 5 - 8)
          .error "Global data exceeds ", ($40 - 5 - 8), " bytes (length is ", GlobalGameDataLength, " bytes)"
          .fi
;;; 

;;; Temporarily used when switching rooms
NextMap:
          .byte ?
;;; An alarm can be set for various in-game special events.
;;; This happens in real time.
AlarmSeconds:
          .byte ?
AlarmFrames:
          .byte ?

;;; String Buffer for text displays of composed text,
;;; e.g.  monster names.
StringBuffer:
          .byte ?, ?, ?, ?, ?, ?
          
DebounceSWCHA:
          .byte ?
DebounceSWCHB:
          .byte ?
DebounceButtons:
          .byte ?
NewSWCHA:
          .byte ?
NewSWCHB:
          .byte ?
NewButtons:
          .byte ?
DeltaX:
          .byte ?
DeltaY:
          .byte ?
PlayerX:
          .byte ?
PlayerY:
          .byte ?
PlayerXFraction:
          .byte ?
PlayerYFraction:
          .byte ?

;;; 
;;; Variables used in drawing

;;; Line counter for various sorts of "kernels"
LineCounter:
          .byte ?

;;; Run length counter used by map screens
RunLength:
          .byte ?

PixelPointers:
pp0l:     .byte ?
pp0h:     .byte ?
pp1l:     .byte ?
pp1h:     .byte ?
pp2l:     .byte ?
pp2h:     .byte ?
pp3l:     .byte ?
pp3h:     .byte ?
pp4l:     .byte ?
pp4h:     .byte ?
pp5l:     .byte ?
pp5h:     .byte ?
          
;;; 
;;; SpeakJet

;;; What part of a sentence has been sent to the AtariVox/SpeakJet?
SpeechSegment:
          .byte ?

;;; Pointer to the next phoneme to be spoken, or $0000
;;; When commanding new speech, set to utterance ID with $00 high byte
CurrentUtterance:
          .word ?

SpeakJetCooldown:
          .byte ?
;;; 
;;; EEPROM

;;; The active game slot, 0-2 (1-3)
SaveGameSlot:
          .byte ?
;;; 
;;; Music and Sound FX

;;; Pointer to the next note of music to be played
CurrentMusic:
          .word ?

;;; Timer until the current music note is done
NoteTimer:
          .byte ?

;;; Timer until the current sound effects note is done
SFXNoteTimer:
          .byte ?

;;; When the current sound finishes, play this one next
;;; (index into list of sounds)
NextSound:
          .byte ?

;;; Pointer to the "note" of the sound being played
CurrentSound:
          .word ?


;;; Random number generator workspace
Rand:
          .word ?
;;; 
;;; Transient work space for one game mode
;;;
;;; The scratchpad pages are "overlaid," each game mode uses them differently.
;;; Upon entering a game mode, some care must be taken to re-initialize this
;;; area of memory appropriately.

            Scratchpad = *
;;; 
;;; Attract mode flags

;;; Attract mode flag for whether the speech associated with a certain mode
;;; has been started yet. (It's delayed on the title to avoid a conflict
;;; with the title screen jingle or the AtariVox start-up sound)

AttractHasSpoken:
          .byte ?

AttractTitleScroll:
          .byte ?

AttractTitleReveal:
          .byte ?
          
;;; The Story mode has several "panels" to be shown

AttractStoryPanel:
          .byte ?
AttractStoryProgress:
          .byte ?
;;; 
;;; Start Game phase

          * = Scratchpad

;;; 
;;; Scratchpad for Game Play mode
            * = Scratchpad

;;; How many non-player sprites are on screen now?
;;; These virtual sprites are multiplexed onto Player Graphic 1
;;;
;;; pp0 is pointer to player graphics.
;;; pp1-pp4 are pointers to the other sprites, if any.
SpriteCount:
          .byte ?

;;; Which non-player sprite should be drawn on this frame?
SpriteFlicker:
          .byte ?


;;; Counters for drawing P0 and P1 on this frame
P0LineCounter:
          .byte ?
P1LineCounter:
          .byte ?
M0LineCounter:
          .byte ?
M1LineCounter:
          .byte ?
BallLineCounter:
          .byte ?

MapPointer:
          .word ?

MapSpritePointer:
          .word ?

;;; 
;;; Verify that we don't run over

          LastRAM = * - 1
          
          ;; There must be at least $10 stack space (to be fairly safe)
          .if LastRAM >= $f0
          .error "Zero page ran right into stack space at ", LastRAM
          .fi

          .if LastRAM >= $ff
          .error "Zero page overcommitted entirely at ", LastRAM
          .fi

          .if LastRAM >= $e0
          .warn "End of zero-page variables at ", LastRAM, " leaves ", $100 - LastRAM, " bytes for stack"
          .fi
