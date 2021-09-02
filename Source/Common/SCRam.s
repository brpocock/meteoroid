;;; Meteoroid Source/Common/SCRam.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;;
;;; Mapped as $1000 (read) and $1080 (write)

          * = $1000

          .enc "Unicode"
RAMRead:
          .fill $80, "Meteoroid, © 2021 Bruce-Robert Pocock. EFSC."
RAMWrite:
          .fill $80, "Meteoroid, © 2021 Bruce-Robert Pocock. EFSC."

          .enc "none"

          
          * = $1000

SCRAM:

SpriteX:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteY:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteXFraction:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteYFraction:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteMotion:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteIndex:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteAction:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteParam:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteHitPoints:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
Background:
          .byte ?, ?, ?, ?, ?,  ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?,  ?, ?, ?, ?, ?
          .byte ?, ?, ?, ?, ?,  ?, ?, ?, ?, ?

MapFlags:
          .byte ?

ScrollLeft:
          .byte ?
          
BumpCooldown:
          .byte ?

          .warn "SC-RAM is used up to ", * - 1, " leaving ", ($1080 - *), " bytes free"
          
          .if * > $1080
          .error "Ran out of SC RAM"
          .fi

WRITE = $80
