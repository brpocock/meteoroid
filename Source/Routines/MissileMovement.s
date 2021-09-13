;;; Meteoroid Source/Routines/MissileMovement.s
;;; Copyright © 2021 Bruce-Robert Pocock

MissileMovement:    .block

          ldx # 4
Loop:
          lda PlayerMissileX, x
          beq Next

          lda BitMask, x
          bit MissileDeltaX
          bne UpdateMissileLeft
UpdateMissileRight:
          lda PlayerMissileX, x
          clc
          adc # 3
          sta WRITE + PlayerMissileX, x
          cmp # ScreenRightEdge
          blt Next
          lda # 0
          sta WRITE + PlayerMissileX, x
          geq Next

UpdateMissileLeft:
          lda PlayerMissileX, x
          sec
          sbc # 3
          sta WRITE + PlayerMissileX, x
          cmp # ScreenLeftEdge
          bge Next
          lda # 0
          sta WRITE + PlayerMissileX, x

Next:
          dex
          bpl Loop

          rts

          .bend
