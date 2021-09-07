;;; Meteoroid Source/Routines/PerformGravity.s
;;; Copyright © 2021 Bruce-Robert Pocock

PerformGravity:     .block

          ldx # 1
          stx LineCounter
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

          iny                   ; round up to the next line
          tya
          lsr a                 ; divide by 4 to get logical row
          lsr a
          sta Temp              ; logical row number

          ;; find offset into map data
          lda PlayerX - 1, x

          cpx # 1               ; player, not sprite
          bne FindOffsetForSprite
FindOffsetForPlayer:
          lsr a
          lsr a
          clc
          adc ScrollLeft
          lsr a
          lsr a
          tax
          ldy PlayerY
          jsr PeekMap
          beq CanFall           ; it's blank, falling is OK
          lda #MoveStand        ; stop falling, we've landed on ground
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

;;; 

PeekMap:  .block
          ;; Input coördinates in X and Y registers
          txa
          asl a
          sta Temp
          tya
          lsr a
          lsr a
          tay
          cpy # 8
          blt +
          clc
          adc # 1
+
          clc
          adc Temp
          clc
          adc # 15              ; skip header (3) and colors (12)
          tay
          lda Temp
          and #$07
          tax
          inx
          lda BitMask, x
          and (MapPointer), y   ; Returns zero or non-zero
          rts
          .bend
