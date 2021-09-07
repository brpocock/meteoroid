;;; Meteoroid Source/Routines/PerformGravity.s
;;; Copyright © 2021 Bruce-Robert Pocock

PerformGravity:     .block

          ldx # 1
Loop:
          lda MovementStyle - 1, x
          cmp #MoveStand
          beq Next
          cmp #MoveJump
          beq AgeJump
          cmp #MoveFall
          bne Next
          lda PlayerY - 1, x
          clc
          adc # 1
          sta WRITE + PlayerY - 1, x

          tay
          ;; keep falling until we land on a 4-pixel boundary
          and #$03
          cmp #$03
          bne Next
          iny
          tya
          lsr a
          lsr a
          sta Temp              ; Y offset

          ;; find offset into map data
          lda PlayerX - 1, x
          and #$fc
          lsr a
          lsr a

          cpx # 1               ; player
          bne FindOffsetForSprite
FindOffsetForPlayer:
          clc
          adc ScrollLeft
          and #$fc
          lsr a
          adc # 15
          tay
          lda Temp              ; Y offset saved previously
          cmp # 8
          blt +
          iny
+
          lda (MapPointer), y
          sta Pointer           ; just need another temp var!
          lda Temp
          and #$07
          tay
          lda BitMask, y
          and Pointer
          beq CanFall
          lda #MoveStand
          sta WRITE + MovementStyle

FindOffsetForSprite:
          ;; TODO
          
CanFall:
          jmp Next

AgeJump:
          cpx # 1               ; is this the player?
          beq +
          brk                   ; if not, we should not register as a jump per se.
+
          ldy JumpMomentum
          dey
          sty WRITE + JumpMomentum
          beq StopJump
          lda PlayerY
          sec
          sbc # 2
          sta WRITE + PlayerY
          jmp Next
StopJump:
          lda # MoveFall
          sta WRITE + MovementStyle

Next:
          dex
          bne Loop

          rts

          .bend
