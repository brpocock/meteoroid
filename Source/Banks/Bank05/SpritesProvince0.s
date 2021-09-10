;;; Meteoroid Source/Banks/Bank05/SpritesProvince0.s
;;; Copyright © 2021 Bruce-Robert Pocock

SpriteList:    .block

          .byte SpriteEquipment
          .byte EquipMorph
          .word $004c           ; x
          .byte $27             ; y
          .byte 0               ; art index
          .byte SpriteMoveNone

          .byte SpriteEquipment
          .byte EquipHighJump
          .word $208d
          .byte $2b
          .byte 0
          .byte SpriteMoveNone

          .byte SpriteSavePoint
          .byte 1
          .word $1046
          .byte $13
          .byte 1
          .byte SpriteMoveNone

          .byte 0

          .bend
