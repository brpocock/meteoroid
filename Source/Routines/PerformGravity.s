;;; Meteoroid Source/Routines/PerformGravity.s
;;; Copyright © 2021 Bruce-Robert Pocock

PerformGravity:     .block

          ldx # 9
          stx LineCounter
Loop:
          lda MovementStyle - 1, x
          cmp #MoveStand
          beq Next
          cmp #MoveJump
          beq DefyingGravity
          cmp #MoveWalk
          beq CheckWalkFloor
          cmp #MoveFall
          bne Next
KeepFalling:
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

          cpx # 1               ; player, not sprite
          beq +
          jsr PeekSpriteFloor
          beq CanFall
          jmp StartStanding
+
          jsr PeekPlayerFloor
          beq CanFall           ; it's blank, falling is OK
StartStanding:
          lda #MoveStand        ; stop falling, we've landed on ground
          sta WRITE + MovementStyle
          jmp Next
          
CanFall:
CanStand:
          jmp Next

CheckWalkFloor:
          cpx # 1
          beq +
          jsr PeekSpriteFloor
          beq StartFalling
          jmp CanStand
+
          jsr PeekPlayerFloor
          beq StartFalling
          jmp CanStand
StartFalling:
          lda #MoveFall
          sta WRITE + MovementStyle - 1, x
          jmp Next

DefyingGravity:
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
          dec LineCounter
          ldx LineCounter
          bne Loop

          rts

          .bend

;;; 


PeekPlayerFloor:
          ldy PlayerY
          iny
          lda PlayerX
          lsr a                 ; convert to playfield pixels
          lsr a
          clc
          adc ScrollLeft
          lsr a                 ; convert to background blocks
          lsr a
          tax
          jmp PeekMap           ; tail call

PeekSpriteFloor:
          ldy PlayerY - 1, x
          iny
          lda PlayerX - 1, x
          lsr a                 ; convert to playfield pixels
          lsr a
          lsr a                 ; convert to background blocks
          lsr a
          sta Temp
          lda SpriteXH - 2, x
          and #$f0
          ora Temp
          tax
          ;; fall through

;;; 
PeekMap:  .block
          ;; Input coördinates in X and Y registers
          txa
          asl a                 ; X × 2 (bytes per column)
          clc
          adc # 15              ; skip header (3) and colors (12)
          sta Temp              ; working idea of index

          tya                   ; examine Y index
          tax                   ; copy to X
          and #~$03
          lsr a                 ; ÷ 4 (line triples per row)
          lsr a

          ldy Temp              ; index into map data of first byte
          cmp # 8               ; first or second byte?
          blt +
          iny
+
          ;; A has the Y value in rows
          and #$07              ; get the bit index
          tax
          lda BitMask, x
          and (MapPointer), y   ; Returns zero or non-zero
          rts
          .bend
