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
          lda DeltaY
          cmp # 12              ; terminal velocity
          bge +
          clc
          adc # 1
          sta WRITE + DeltaY
+
          
          ;; find offset into map data

          cpx # 1               ; player, not sprite
          beq +
          jsr GetSpriteFootPosition
          iny
          jsr PeekMap
          bne StartStanding
          lda # 0               ; TODO fat sprites
          beq CanFall
          jsr GetSpriteFootPosition
          inx
          iny
          jsr PeekMap
          beq CanFall
          gne StartStanding
+
          jsr GetPlayerFootPosition
          iny
          jsr PeekMap           ; tail call
          beq CanFall
StartStanding:
          ldx LineCounter
          lda #MoveStand        ; stop falling, we've landed on ground
          sta WRITE + MovementStyle - 1, x
          lda PlayerY - 1, x
          ora #$03
          sta WRITE + PlayerY - 1, x
          cpx # 1
          bne Next
          lda # 0
          sta WRITE + DeltaX
          sta WRITE + DeltaY
          jmp Next
          
CanFall:
CanStand:
          jmp Next

CheckWalkFloor:
          cpx # 1
          beq +
          jsr GetSpriteFootPosition
          iny
          jsr PeekMap
          bne CanStand
          jsr GetSpriteFootPosition
          lda # 0               ; TODO fat sprites
          beq StartFalling
          inx
          iny
          jsr PeekMap
          bne CanStand
          geq StartFalling
+
          jsr GetPlayerFootPosition
          iny
          jsr PeekMap
          bne CanStand
StartFalling:
          lda #MoveFall
          ldx LineCounter
          sta WRITE + MovementStyle - 1, x
          cpx # 1
          bne Next
          lda # 1
          sta WRITE + DeltaY
          jmp Next

DefyingGravity:
          cpx # 1               ; is this the player?
          beq +
          brk                   ; if not, we should not register as a jump per se (yet?).
+
          ldy JumpMomentum
          dey
          sty WRITE + JumpMomentum
          beq StopJump

          ;; check headroom for collision with brick above
          jsr GetPlayerFootPosition
          dey
          dey
          dey
          jsr PeekMap
          bne StopJump

JumpClear:          
          ;; OK, let's jump some more
          lda #-2
          sta WRITE + DeltaY
          jmp Next

StopJump:
          lda # MoveFall
          sta WRITE + MovementStyle
          lda # 2
          sta WRITE + DeltaY

Next:
          dec LineCounter
          ldx LineCounter
          bne Loop

          rts

          .bend

