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
          lda #SoundChirp
          sta WRITE + NextSound
          lda #0
          sta WRITE + DoorWalkColumns
          sta WRITE + DoorWalkSummon
          lda SpriteX, x
          cmp # ( HBlankWidth + 160 ) / 2
          bge ShotRightDoor
ShotLeftDoor:
          lda #-1
          sta WRITE + DoorWalkDirection
          rts

ShotRightDoor:
          lda # 1
          sta WRITE + DoorWalkDirection
          rts

CannotOpenDoor:
          lda #SoundDrone
          sta WRITE + NextSound
          rts

          .bend
