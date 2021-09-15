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
          lda DoorWalkDirection
          bne DoDoorWalking
          lda Pause
          beq +
          rts
+

          lda MovementStyle
          cmp #MoveTeleport
          bne NotTeleporting
          lda TeleportCountdown
          bmi TeleportCountNegative
          sbc # 1
          sta WRITE + TeleportCountdown
          beq TeleportDone
          rts

TeleportCountNegative:
          adc # 1
          sta WRITE + TeleportCountdown
          beq TeleportDone
          rts

TeleportDone:
          lda #MoveStand
          sta WRITE + MovementStyle

NotTeleporting:
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
          lda PlayerMissileY    ; already have a missile flying?
          eor #$ff
          bne ActuallyCheckStick
          lda NewButtons
          beq ActuallyCheckStick
          and #$80
          beq ActuallyCheckStick

FireWeapon:
          lda MovementStyle
          cmp #MoveMorphRest
          beq FireBomb
          cmp #MoveMorphFall
          beq FireBomb
          cmp #MoveMorphRoll
          beq FireBomb

FireMissile:
          lda MapFlags
          and #MapFlagFacing
          bne FireRightwards
FireLeftwards:
          lda MissileDeltaX
          ora #$01
          sta WRITE + MissileDeltaX
          lda PlayerX
          sec
          sbc # 1
FireMissileCommon:  
          sta WRITE + PlayerMissileX
          lda PlayerY
          clc
          sbc # 4
          sta WRITE + PlayerMissileY
          lda # MoveShoot
          sta WRITE + MovementStyle
          gne ActuallyCheckStick

FireBomb:
          lda Equipment
          and #EquipBomb
          beq ActuallyCheckStick
          ;; TODO
          jmp ActuallyCheckStick
          
FireRightwards:
          lda MissileDeltaX
          and #~$01
          sta WRITE + MissileDeltaX
          lda PlayerX
          clc
          adc # 9
          gne FireMissileCommon

ActuallyCheckStick:
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

          ldy # 8
          ldx #-1
          lda Equipment
          .BitBit EquipHighJump
          beq +
          ldy # 12
          ldx #-2
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
          cpx # 0
          bpl RollRight
          ldx #-3
          gne DoneChangingMovement
RollRight:
          ldx # 3
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

DoDoorWalking:
          lda DoorWalkDirection
          bpl DoorWalkingRight
DoorWalkingLeft:
          lda ScrollLeft
          beq AtLeftEnd
          dec ScrollLeft
          rts

AtLeftEnd:
          ;; TODO, wait for next room to be queued
          lda DoorWalkDirection
          cmp #-3
          beq DemolishWallLeft

          ;; Wait for next scene to be loaded
          lda #-2
          sta WRITE + DoorWalkDirection
          rts

DoorWalkingRight:
          ldy # 2
          lda (MapPointer), y
          asl a
          asl a
          sec
          sbc # 39
          cmp ScrollLeft
          bge AtRightEnd
          inc ScrollLeft
          rts

AtRightEnd:
          lda # 1
          sta WRITE + DeltaX
          lda PlayerX
          cmp # HBlankWidth + 160 - 8
          bge AllTheWayRight
          rts

AllTheWayRight:
          lda DoorWalkDirection
          cmp # 3
          beq DemolishWallRight

          ;; Wait for the next scene to be loaded
          lda # 2
          sta WRITE + DoorWalkDirection
          rts

DemolishWallLeft:
          lda DoorWalkColumns
          cmp # 5
          bge ScrollSceneLeft
          clc
          adc # 1
          sta WRITE + DoorWalkColumns
          and #~$07
          lsr a
          lsr a
          lsr a
          ;; TODO remove one column at a time
          lda # 0
          sta BackgroundPF0 + 7
          sta BackgroundPF0 + 8
          sta BackgroundPF0 + 9
          rts

DemolishWallRight:
          lda DoorWalkColumns
          cmp # 5
          bge ScrollSceneRight
          clc
          adc # 1
          sta WRITE + DoorWalkColumns
          and #~$07
          lsr a
          lsr a
          lsr a
          ;; TODO remove one column at a time
          lda # 0
          sta BackgroundPF2R + 7
          sta BackgroundPF2R + 8
          sta BackgroundPF2R + 9
          rts

ScrollSceneLeft:
          lda #MoveWalk          
          sta WRITE + MovementStyle
          lda MapFlags
          and #~MapFlagFacing
          sta WRITE + MapFlags
          rts

ScrollSceneRight:
          lda #MoveWalk
          sta WRITE + MovementStyle
          lda MapFlags
          ora #MapFlagFacing
          sta WRITE + MapFlags
          rts

          .bend
