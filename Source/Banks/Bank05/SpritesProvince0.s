;;; Meteoroid Source/Banks/Bank05/SpritesProvince0.s
;;; Copyright © 2021 Bruce-Robert Pocock

SpriteList:    .block

;;; Row 0 Room 0
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

          .byte SpriteDoor
          .byte 1
          .word $3044
          .byte $22
          .byte 4
          .byte SpriteMoveNone

          .byte SpriteMonster
          .byte 1
          .word $20b7
          .byte $2b
          .byte 2
          .byte MoveWalk
          
          .byte 0
          
;;; Row 0 Room 1

          .byte 0

;;; Row 0 Room 2

          .byte 0

;;; Row 1 Room 0

          .byte 0

          .fill $80, 0
          

          .bend
