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
Temp:
          .byte ?

Pointer:
          .word ?
;;; 

Background:
BackgroundPF0:
          .byte ?, ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?, ?
BackgroundPF1L:
          .byte ?, ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?, ?
BackgroundPF2L:
          .byte ?, ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?, ?
BackgroundPF2R:
          .byte ?, ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?, ?
BackgroundPF1R:
          .byte ?, ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?, ?

;;; 
;;; Game play/progress indicators -- global

;;; This data is saved to the first block of the save game file.
;;; It must never be more than 64 bytes (not that there's a great risk of that)

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

CurrentHP:
          .byte ?
CurrentTanks:
          .byte ?
MaxTanks:
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

          EndGlobalGameData = * - 1
          
          GlobalGameDataLength = EndGlobalGameData - GlobalGameData + 1
;;; 

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

;;; An alarm can be set for various in-game special events.
;;; This happens in real time.
AlarmSeconds:
          .byte ?
AlarmFrames:
          .byte ?

;;; 

LineCounter:
          .byte ?
;;; 
;;; Variables used in drawing

MapPointer:
          .word ?

MapSpritePointer:
          .word ?

PixelPointers:
pp0l:     .byte ?               ; 0
pp0h:     .byte ?               ; 1
pp1l:     .byte ?               ; 2
pp1h:     .byte ?               ; 3
pp2l:     .byte ?               ; 4
pp2h:     .byte ?               ; 5
pp3l:     .byte ?               ; 6
pp3h:     .byte ?               ; 7
pp4l:     .byte ?               ; 8
pp4h:     .byte ?               ; 9
pp5l:     .byte ?               ; 10
pp5h:     .byte ?               ; 11

;;; Pointer to the next note of music to be played
CurrentMusic:
          .word ?

;;; Pointer to the "note" of the sound being played
CurrentSound:
          .word ?

;;; Pointer to the next phoneme to be spoken, or $0000
;;; When commanding new speech, set to utterance ID with $00 high byte
CurrentUtterance:
          .word ?

;;; Random number generator workspace
Rand:
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
