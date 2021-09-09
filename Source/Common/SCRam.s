;;; Meteoroid Source/Common/SCRam.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;;
;;; Mapped as $1000 (read) and $1080 (write)

          * = $f080
          .offs -$f000

SCRAM:

DeltaX:
          .byte ?
DeltaY:
          .byte ?
JumpMomentum:
          .byte ?

PlayerXFraction:
          .byte ?
PlayerYFraction:
          .byte ?

PlayerMissileX:
          .byte ?
PlayerMissileY:
          .byte ?
;;; High bits of sprite position and sprite facing bit
;;; High bits are in upper nybble
;;; Facing (REFP1) bit is $08
SpriteXH:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
PlayerX:
          .byte ?
SpriteX:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
PlayerY:
          .byte ?
SpriteY:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
MovementStyle:
          .byte ?
SpriteMotion:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteIndex:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteAction:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteHP:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?

MonsterMissileX:
          .byte ?, ?, ?, ?
MonsterMissileY:
          .byte ?, ?, ?, ?
          
MapFlags:
          .byte ?

SaveSCRam:

ProgressFlags:
          .byte ?, ?, ?, ?, ?, ?, ?, ?

;;; It's an Atari game, of course we have a score.
Score:
          .byte ?, ?, ?

;;;  Where was the player last known to be safe?
BlessedX:
          .byte ?
BlessedY:
          .byte ?

          EndSaveSCRam = * - 1
          SaveSCRamLength = EndSaveSCRam - SaveSCRam + 1
          
;;; Temporarily used when switching rooms
NextMap:
          .byte ?

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
;;; String Buffer for text displays of composed text
StringBuffer:
          .byte ?, ?, ?, ?, ?, ?
          

;;; 
;;; SpeakJet

;;; What part of a sentence has been sent to the AtariVox/SpeakJet?
SpeechSegment:
          .byte ?


SpeakJetCooldown:
          .byte ?
;;; 
;;; EEPROM

;;; The active game slot, 0-2 (1-3)
SaveGameSlot:
          .byte ?
;;; 
;;; Music and Sound FX

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
;;; Scratchpad for Game Play mode
            * = Scratchpad

;;; How many non-player sprites are in the level now?
;;; These virtual sprites are multiplexed onto Player Graphic 1
SpriteCount:
          .byte ?

;;; Which non-player sprite should be drawn on this frame?
SpriteFlicker:
          .byte ?

MissileCount:
          .byte ?
          
MissileFlicker:
          .byte ?

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

SpriteMoving:
          .byte ?

SpriteDeltaX:
          .byte ?

SpriteDeltaY:
          .byte ?

;;; 

LastActivity:
          .byte ?

;;; 

;;; Are we scrolling between rooms, and if so, in which direction?
DoorWalkDirection:
          .byte ?

;;; If we are scrolling in a new room, how many columns remain?
DoorWalkColumns:
          .byte ?

;;; If we have just completed the door walk, are we loading the sprite data?
DoorWalkSummon:
          .byte ?

;;; 
          .warn "SC-RAM is used up to ", * - 1, " leaving ", ($f100 - *), " bytes free"
          
          .if * > $f100
          .error "Ran out of SC RAM, overran by ", * - $f100, " bytes"
          .fi

          WRITE = -$80

;;; 
          
          * = $1000
          .offs -$1000

          ;; Duplicate strings in both read and write sections are there
	;; so  that Stella  will  correctly  detect this  as  as EFSC  or
	;; F4SC image.

          ;; URL is there for PlusCart.
          .enc "Unicode"
RAMWrite:
          .text "https://star-hope.org/games/Meteoroid/meteoroid.plx", 0
          .text "Meteoroid, © 2021 Bruce-Robert Pocock.", 0
          .if DEMO
          .text "F4SC"
          .else
          .text "EFSC"
          .fi
          .align $80, 0
RAMRead:
          .text "https://star-hope.org/games/Meteoroid/meteoroid.plx", 0
          .text "Meteoroid, © 2021 Bruce-Robert Pocock.", 0
          .if DEMO
          .text "F4SC"
          .else
          .text "EFSC"
          .fi
          .align $80, 0

          .enc "none"

          * = $f100
          .offs -$f000
