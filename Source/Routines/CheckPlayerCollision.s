;;; Meteoroid Source/Routines/CheckPlayerCollision.s
;;; Copyright © 2021 Bruce-Robert Pocock

CheckPlayerCollision:         .block
          lda CXP0FB
          and #$c0              ; hit playfield or ball
          beq NoBumpWall
          bne NoBumpWall        ; XXX
          jsr BumpWall
          rts

NoBumpWall:
          lda CXPPMM
          .BitBit $80              ; hit other sprite
          beq PlayerMoveOK         ; did not hit

BumpSprite:
          jsr BumpWall

          ldx SpriteFlicker
          lda SpriteAction, x

          cmp #SpriteDoor       ; Doors ignore cooldown timer
          beq DoorWithSprite

          cmp #SpriteMonster
          beq FightWithSprite
          and #SpriteProvinceDoor
          cmp #SpriteProvinceDoor
          bne PlayerMoveOK      ; No action
          geq ProvinceChange

FightWithSprite:
          ldx SpriteFlicker     ; ? Seems unnecessary XXX
FightWithSpriteX:
          lda CurrentHP
          sbc SpriteHP, x       ; TODO
          bpl +
          lda # 0
+
          sta CurrentHP
          ;; TODO: knock back?
          rts

DoorWithSprite:
          lda SpriteAction, x   ; TODO
          sta NextMap
          ldy #ModePlayNewRoomDoor
          sty GameMode
          rts

PlayerMoveOK:
          lda ClockFrame
          and #$03
          bne DonePlayerMove
          lda PlayerX
          sta WRITE + BlessedX
          lda PlayerY
          sta WRITE + BlessedY
DonePlayerMove:
          rts

ProvinceChange:
          stx P0LineCounter
          ldx #$ff              ; smash the stack
          txs
          .WaitForTimer         ; finish up VBlank cycle
          ldx # 0
          stx VBLANK
          ;; WaitScreenTop without VSync/VBlank
          .if TV == NTSC
          .TimeLines KernelLines - 2
          .else
          lda #$fe
          sta TIM64T
          .fi
          .WaitScreenBottom
          .WaitScreenTop
          ldx P0LineCounter
          lda SpriteAction, x
          and #$f0
          clc
          lsr a
          lsr a
          lsr a
          lsr a
          sta CurrentProvince
          lda SpriteAction, x   ; TODO
          sta NextMap
          ldy #ModePlayNewRoomDoor
          sty GameMode
          .WaitScreenBottom
          jmp GoPlay

;;; 
BumpWall:
          sta CXCLR

          lda BlessedX
          cmp PlayerX
          beq +
          sta WRITE + PlayerX
          jmp BumpY
+
          lda DeltaX
          bne ShoveX
          jsr Random
          and # 1
          bne ShoveX
          lda #-1
ShoveX:
          sta WRITE + DeltaX
          clc
          adc PlayerX
          sta WRITE + PlayerX

BumpY:
          lda BlessedY
          cmp PlayerY
          beq +
          sta WRITE + PlayerY
          jmp DoneBump
+
          lda DeltaY
          bne ShoveY
          jsr Random
          and # 1
          bne ShoveY
          lda #-1
ShoveY:
          sta WRITE + DeltaY
          clc
          adc PlayerY
          sta WRITE + PlayerY

          lda # 0
          sta WRITE + PlayerXFraction
          sta WRITE + PlayerYFraction
DoneBump:
          lda #SoundBump
          sta WRITE + NextSound

          rts
          .bend
