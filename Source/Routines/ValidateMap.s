;;; Meteoroid Source/Routines/ValidateMap.s
;;; Copyright © 2021 Bruce-Robert Pocock

ValidateMap:        .block
          lda GameMode
          cmp #ModePlayNewRoomDoor
          bne DonePlacing
PlacePlayerUnderDoor:
          ldx SpriteCount
          beq DonePlacing

          ldx #0
CheckNextSpriteForDoor:
          lda SpriteAction, x
          cmp #SpriteDoor
          beq +
          and #$07
          cmp #SpriteProvinceDoor
          bne NotADoor
+
          lda SpriteX, x
          sta WRITE + PlayerX
          sta WRITE + BlessedX

          lda SpriteY, x
          clc
          adc #12
          sta PlayerY
          sta BlessedY

          gne DonePlacing

NotADoor:
          inx
          cmp SpriteCount
          bne CheckNextSpriteForDoor
DonePlacing:
;;; 
CheckForRandomSpawns:
          ldx SpriteCount
          beq Bye
          dex
CheckSpriteSpawn:
          lda SpriteX, x
          bne NextMayBeRandom

RandomX:
          jsr Random
          cmp #ScreenLeftEdge
          blt RandomX
          cmp #ScreenRightEdge
          bge RandomX
          sta WRITE + SpriteX, x

RandomY:
          jsr Random
          and #$3f
          sta WRITE + SpriteY, x

NextMayBeRandom:
          dex
          bpl CheckSpriteSpawn
;;; 
Bye:
          rts
          .bend
