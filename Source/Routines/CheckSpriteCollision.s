;;; Meteoroid Source/Routines/CheckSpriteCollision.s
;;; Copyright © 2021 Bruce-Robert Pocock

CheckSpriteCollision:         .block
          lda CXP1FB
          and #$c0           ; collision with playfield or ball
          beq Bye

          ldx SpriteFlicker
          cpx #$ff
          beq Bye

          lda MapFlags
          .BitBit MapFlagRandomSpawn
          bne NoRePosition
          lda AlarmFrames
          bne NoRePosition
          lda AlarmSeconds
          bne NoRePosition
          lda # 0
          sta WRITE + SpriteX, x
          jsr ValidateMap.CheckSpriteSpawn
          jmp Bye

NoRePosition
          ldx SpriteFlicker
          lda SpriteMotion, x
          beq Bye
CheckLeft:
          .BitBit SpriteMoveLeft
          beq CheckRight

          lda SpriteX, x
          clc
          adc # 2
          sta WRITE + SpriteX, x
          eor # SpriteMoveLeft | SpriteMoveRight
          gne CheckUp

CheckRight:
          .BitBit SpriteMoveRight
          beq CheckUp

          lda SpriteX, x
          sec
          sbc # 2
          sta WRITE + SpriteX, x
          eor # SpriteMoveLeft | SpriteMoveRight
          ;; fall through
CheckUp:
          .BitBit SpriteMoveUp
          beq CheckDown

          lda SpriteY, x
          clc
          adc # 2
          sta WRITE + SpriteY, x
          eor # SpriteMoveUp | SpriteMoveDown
          gne Done

CheckDown:
          .BitBit SpriteMoveDown
          beq Done

          lda SpriteY, x
          sec
          sbc # 2
          sta WRITE + SpriteY, x
          eor # SpriteMoveUp | SpriteMoveDown
          ;; fall through
Done:
          sta SpriteMotion, x
Bye:
          rts
          .bend
