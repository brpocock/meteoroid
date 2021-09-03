;;; Meteoroid Source/Common/SCRam.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;;
;;; Mapped as $1000 (read) and $1080 (write)

          * = $1080
          .offs -$1000

SCRAM:

SpriteX:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteY:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteMotion:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteIndex:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteAction:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteHP:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?

PlayerMissileX:
          .byte ?
PlayerMissileY:
          .byte ?

MonsterMissileX:
          .byte ?, ?, ?, ?
MonsterMissileY:
          .byte ?, ?, ?, ?
          
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

CurrentDrawRow:
          .byte ?

MapFlags:
          .byte ?

ProgressFlags:
          .byte ?, ?, ?, ?, ?, ?, ?, ?

          .warn "SC-RAM is used up to ", * - 1, " leaving ", ($1100 - *), " bytes free"
          
          .if * > $1100
          .error "Ran out of SC RAM, overran by ", * - $1100, " bytes"
          .fi

          WRITE = -$80

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
