;;; Meteoroid Source/Routines/UserInput.s
;;; Copyright © 2021 Bruce-Robert Pocock

UserInput: .block
CheckSwitches:
          lda NewSWCHB
          beq NoSelect
          .BitBit SWCHBReset
          bne NoReset
          .WaitForTimer
          ldx # 0
          stx VBLANK
          .if TV == NTSC
          .TimeLines KernelLines - 1
          .else
          lda #$ff
          sta TIM64T
          .fi
          jmp GoQuit

NoReset:
          and # SWCHBSelect
          bne NoSelect
          lda #ModeSubscreen
          sta WRITE + GameMode
NoSelect:
          .if TV == SECAM

          lda DebounceSWCHB
          and # SWCHBP0Advanced
          sta WRITE + Pause

          .else

          lda DebounceSWCHB
          .BitBit SWCHBColor
          bne NoPause
          .BitBit SWCHB7800
          beq +
          lda Pause
          eor #$ff
+
          sta WRITE + Pause
          jmp SkipSwitches

NoPause:
          lda # 0
          sta WRITE + Pause

          .fi
SkipSwitches:
;;; 

HandleUserMovement:

ReturnIfPaused:
          lda Pause
          beq +
          rts
+
          lda MovementStyle
          cmp #MoveWalk
          bne +
          lda LastActivity
          cmp # FramesPerSecond * 2
          blt +
          lda #MoveStand
          sta WRITE + MovementStyle
          gne HandleStick
+         
          lda MovementStyle
          cmp #MoveMorphRoll
          bne HandleStick
          lda #MoveMorphRest
          sta WRITE + MovementStyle
          
HandleStick:
          lda NewSWCHA          ; only when first pressed
          beq +
          and #P0StickUp
          beq DoJump
+
          lda NewButtons
          beq DoneStickUp
          and #$40
          bne DoneStickUp

DoJump:
          lda MovementStyle
          cmp #MoveStand
          beq CanJump
          cmp #MoveWalk
          beq CanJump
          cmp #MoveMorphRest
          bne DoneStickUp
MorphBack:
          lda #MoveFall
          sta WRITE + MovementStyle
          lda PlayerY
          sbc # 1
          sta WRITE + PlayerY
          jmp DoneStickUp

CanJump:
          lda #MoveJump
          sta WRITE + MovementStyle
          lda # 0
          sta WRITE + LastActivity

          ldy # 16
          ldx #-20
          lda Equipment
          .BitBit EquipHighJump
          beq +
          ldy # 32
          ldx #-40
+
          sty WRITE + JumpMomentum
          stx WRITE + DeltaY

DoneStickUp:
          lda SWCHA
          and #P0StickDown
          bne DoneStickDown

MaybeMorph:
          lda Equipment
          and #EquipMorph
          beq DoneStickDown

Metamorphosis:
          lda MovementStyle
          cmp #MoveWalk
          beq Morph
          cmp #MoveStand
          bne DoneStickDown
Morph:
          lda #MoveMorphFall
MorphMorph:
          sta WRITE + MovementStyle
          lda PlayerY
          sbc # 4
          sta WRITE + PlayerY
          jmp DoneStickDown

DoneStickDown:
          lda SWCHA
          and #P0StickLeft
          beq StickLeft

          lda DeltaX
          bpl DoneStickLeft
          lda # 0
          sta WRITE + DeltaX
          geq DoneStickLeft

StickLeft:
          lda MapFlags
          and # ~MapFlagFacing
          sta WRITE + MapFlags
          ldx #-1
          jsr SetMovementHorizontal

DoneStickLeft:
          lda SWCHA
          and #P0StickRight
          beq StickRight

          lda DeltaX
          bmi DoneStickRight
          lda # 0
          sta WRITE + DeltaX
          geq DoneStickRight

StickRight:
          tax
          lda MapFlags
          ora #MapFlagFacing
          sta WRITE + MapFlags
          ldx # 1
          jsr SetMovementHorizontal

DoneStickRight:

ApplyStick:

          rts

SetMovementHorizontal:     
          lda MovementStyle
          cmp #MoveFall
          beq DoneChangingMovement
          cmp #MoveMorphFall
          beq DoneChangingMovement
          cmp #MoveJump
          beq DoneChangingMovement
          cmp #MoveMorphRest
          bne StartRollMaybe
MoveByRolling:
          lda #MoveMorphRoll
          sta WRITE + MovementStyle
          gne DoneChangingMovement

StartRollMaybe:
          lda #MoveMorphRoll
          beq MoveByRolling
MoveByWalking:
          lda #MoveWalk
          sta WRITE + MovementStyle
          lda # 0
          sta WRITE + LastActivity
DoneChangingMovement:
          stx WRITE + DeltaX

          rts

          .bend
