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

SCRamRead:

SpriteXRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteYRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteXFractionRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteYFractionRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteMotionRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteActionRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteParamRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
SpriteHitPointsRead:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
Background:
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
          .byte ?, ?, ?, ?,  ?, ?, ?, ?
          .byte ?, ?, ?, ?,  ?, ?, ?, ?

          .if * > $1080
          .error "Ran out of SC RAM"
          .fi

WRITE = $80
