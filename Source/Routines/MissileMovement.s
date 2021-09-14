;;; Meteoroid Source/Routines/MissileMovement.s
;;; Copyright © 2021 Bruce-Robert Pocock

MissileMovement:    .block

          ldx # 4
Loop:
          lda PlayerMissileY, x
          eor #$ff
          beq Next

          lda BitMask, x
          bit MissileDeltaX
          bne UpdateMissileLeft
UpdateMissileRight:
          lda PlayerMissileX, x
          clc
          adc # 2
          sta WRITE + PlayerMissileX, x
          cmp # HBlankWidth + 160
          blt Next
          lda #$ff
          sta WRITE + PlayerMissileY, x
          geq Next

UpdateMissileLeft:
          lda PlayerMissileX, x
          sec
          sbc # 2
          sta WRITE + PlayerMissileX, x
          cmp # HBlankWidth
          bge Next
          lda #$ff
          sta WRITE + PlayerMissileY, x

Next:
          dex
          bpl Loop

          rts

          .bend
