;;; Meteoroid Source/Routines/CheckSpriteCollision.s
;;; Copyright © 2021 Bruce-Robert Pocock

CheckSpriteCollision:         .block
          bit CXM0P
          bmi GotShot
          rts

GotShot:
          ldx SpriteFlicker
          lda SpriteAction, x
          cmp #SpriteMonster
          beq ShotMonster
          cmp #SpriteDoor
          beq ShotDoor
          rts

ShotMonster:
          lda #$ff
          sta WRITE + PlayerMissileY

          lda SpriteHP, x
          sec
          sbc # 1
          sta WRITE + SpriteHP, x
          beq KilledMonster
          lda #SoundBump
          sta WRITE + NextSound
          rts

KilledMonster:
          lda #SoundDeleted
          sta WRITE + NextSound
          rts

ShotDoor:
          lda SpriteHP, x
          cmp # 1
          bne CannotOpenDoor
ShotOpensDoor:
          lda SpriteY, x
          lsr a
          lsr a
          sec
          sbc # 2
          sta WRITE + DoorYPosition
          lda #SoundChirp
          sta WRITE + NextSound
          lda # 0
          sta WRITE + DoorColumns
          sta WRITE + SpriteHP, x
          lda #DoorScrollToEnd
          sta WRITE + DoorMode
          lda SpriteX, x
          cmp # ( HBlankWidth + 160 ) / 2
          blt ShotRightDoor
ShotLeftDoor:
          lda #-1
          sta WRITE + DoorDirection
          rts

ShotRightDoor:
          lda # 1
          sta WRITE + DoorDirection
          rts

CannotOpenDoor:
          lda #SoundDrone
          sta WRITE + NextSound
          rts

          .bend
