;;; Meteoroid Source/Routines/CheckPlayerCollision.s
;;; Copyright © 2021 Bruce-Robert Pocock

CheckPlayerCollision:         .block
          lda CXP0FB

          lda CXPPMM
          .BitBit $80              ; hit other sprite
          beq PlayerMoveOK         ; did not hit

BumpSprite:
          ldx SpriteFlicker
          cpx #$ff
          beq PlayerMoveOK
          lda SpriteAction, x

          cmp #SpriteEquipment
          beq PickUpEquipment

          cmp #SpriteMonster
          beq FightWithSprite

          gne PlayerMoveOK      ; No action

PickUpEquipment:
          lda SpriteHP, x
          ora Equipment
          sta Equipment

          lda # 0
          sta WRITE + SpriteHP, x

          lda #SoundVictory
          sta WRITE + NextSound

          rts
          
FightWithSprite:
          ldx SpriteFlicker     ; ? Seems unnecessary XXX

FightWithSpriteX:
          lda DeltaX
          beq DoneKnockBackFight ; TODO monster movement
          clc
          adc #$80
          sta WRITE + DeltaX
DoneKnockBackFight:
          lda DeltaY
          sec
          sbc # 3
          sta WRITE + DeltaY
          lda MovementStyle
          cmp #MoveMorphRest
          beq HurtMorphFall
          cmp #MoveMorphRoll
          beq HurtMorphFall
          cmp #MoveMorphFall
          beq HurtMorphFall
          lda #MoveFall
          sta WRITE + MovementStyle
          gne HurtMe

HurtMorphFall:
          lda #MoveMorphFall
          sta WRITE + MovementStyle

HurtMe:  
          lda CurrentHP
          sec
          sbc # 1
          bmi +
          sta CurrentHP
          rts
+
          lda # 0
          sta CurrentHP
          lda CurrentTanks
          bne +
          .FarJSR AnimationsBank, ServiceDeath

+
          sec
          sbc # 1
          sta CurrentTanks
          lda # MaxHP
          sta CurrentHP
          rts
          
DoorWithSprite:
          lda SpriteAction, x   ; TODO
          sta NextMap
          ldy #ModePlayNewRoomDoor
          sty GameMode
          rts

PlayerMoveOK:
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

          .bend
