;;; Meteoroid Source/Banks/Bank05/SpritesProvince0.s
;;; Copyright © 2021 Bruce-Robert Pocock

SpriteList:    .block

          .byte SpriteEquipment
          .byte EquipMorph
          .word $004c           ; x
          .byte $27             ; y
          .byte 0               ; art index
          .byte SpriteMoveIdle

          .byte SpriteEquipment
          .byte EquipHighJump
          .word $208d
          .byte $27
          .byte 0
          .byte SpriteMoveIdle

          .byte 0

          .bend
