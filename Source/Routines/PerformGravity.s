;;; Meteoroid Source/Routines/PerformGravity.s
;;; Copyright © 2021 Bruce-Robert Pocock

PerformGravity:     .block

CheckForForcedMorph:
          lda Equipment
          and #EquipMorph
          beq NoMorph

          lda MovementStyle
          cmp #MoveWalk
          beq CheckHeadroom
          cmp #MoveStand
          bne NoMorph
CheckHeadroom:
          ldx # 4
          jsr GetPlayerFootPosition
          dey
          jsr PeekMap
          bne ForceMorph
          ldx # 4
          jsr GetPlayerFootPosition
          dey
          dey
          jsr PeekMap
          beq NoMorph
ForceMorph:
          lda #MoveMorphFall
          sta WRITE + MovementStyle

NoMorph:

;;; 

FractionalMovement: .macro deltaVar, fractionVar, positionVar, pxPerSecond
          .block
          lda \fractionVar
          ldx \deltaVar
          beq DoneMovement
          bpl MovePlus
MoveMinus:
          txa
          eor #$ff
          tax
          inx
MoveMinusLoop:
          sec
          sbc #ceil(\pxPerSecond * $80)
          sta WRITE + \fractionVar
          bcs DoneMovement
          adc #$80
          sta WRITE + \fractionVar
          lda \positionVar
          sec
          sbc # 1
          sta WRITE + \positionVar
          dex
          bne MoveMinusLoop
          geq DoneMovement

MovePlus:
          clc
          adc #ceil(\pxPerSecond * $80)
          sta WRITE + \fractionVar
          bcc DoneMovement
          sbc #$80
          sta WRITE + \fractionVar
          lda \positionVar
          clc
          adc # 1
          sta WRITE + \positionVar
          dex
          bne MovePlus 

DoneMovement:
          .bend
          .endm

          MovementDivisor = 0.85
          ;; Make MovementDivisor  relatively the same in  both directions
	;; so diagonal movement forms a 45° line
          MovementSpeedX = ((40.0 / MovementDivisor) / FramesPerSecond)
          .FractionalMovement DeltaX, PlayerXFraction, PlayerX, MovementSpeedX

CheckWallLeftRight:
          lda DeltaX
          beq WallCheckDone
          bpl CheckWallRight
CheckWallLeft:
          ldx # 0
          jsr GetPlayerFootPosition
          jsr PeekMap
          bne HitWallLeft
          lda MovementStyle
          cmp #MoveMorphRoll
          beq WallCheckDone
          ldx # 0
          jsr GetPlayerFootPosition
          dey
          jsr PeekMap
          bne HitWallLeft
          ldx # 0
          jsr GetPlayerFootPosition
          dey
          dey
          jsr PeekMap
          beq WallCheckDone
HitWallLeft:
          lda # 1
          sta WRITE + DeltaX
          lda PlayerX
          clc
          adc # 1
          sta WRITE + PlayerX
          lda # 0
          sta WRITE + PlayerXFraction
          jmp WallCheckDone

CheckWallRight:
          ldx # 7
          jsr GetPlayerFootPosition
          jsr PeekMap
          bne HitWallRight
          lda MovementStyle
          cmp #MoveMorphRoll
          beq WallCheckDone
          ldx # 7
          jsr GetPlayerFootPosition
          dey
          jsr PeekMap
          bne HitWallRight
          ldx # 7
          jsr GetPlayerFootPosition
          dey
          dey
          jsr PeekMap
          beq WallCheckDone
HitWallRight:
          lda #-1
          sta WRITE + DeltaX
          lda PlayerX
          sec
          sbc # 1
          sta WRITE + PlayerX
          lda # 0
          sta WRITE + PlayerXFraction
          jmp WallCheckDone
          
WallCheckDone:
;;; 
          MovementSpeedY = ((30.0 / MovementDivisor) / FramesPerSecond)
          .FractionalMovement DeltaY, PlayerYFraction, PlayerY, MovementSpeedY

;;; 

          ldx # 9
          stx LineCounter
Loop:
          cpx # 1
          bne Next              ; XXX Until sprite movement is brought in line
          lda MovementStyle - 1, x
          cmp #MoveStand
          beq Next
          cmp #MoveJump
          beq DefyingGravity
          cmp #MoveWalk
          beq CheckWalkFloor
          cmp #MoveMorphRoll
          beq CheckWalkFloor
          cmp #MoveMorphFall
          beq KeepFalling
          cmp #MoveFall
          bne Next
KeepFalling:
          cpx # 1
          bne +
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
          ldx # 4
          jsr GetPlayerFootPosition
          iny
          jsr PeekMap           ; tail call
          beq CanFall
StartStanding:
          ldx LineCounter
          lda MovementStyle - 1, x
          cmp #MoveMorphFall
          bne +
          lda #MoveMorphRest
          gne SettleDown
+
          lda #MoveStand        ; stop falling, we've landed on ground
SettleDown:
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
          ldx # 4
          jsr GetPlayerFootPosition
          iny
          jsr PeekMap
          bne CanStand
StartFalling:
          ldx LineCounter
          lda MovementStyle - 1, x
          cmp #MoveMorphRoll
          bne +
          lda #MoveMorphFall
          gne FallDown
+
          lda #MoveFall
FallDown:
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
          ldx # 4
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

