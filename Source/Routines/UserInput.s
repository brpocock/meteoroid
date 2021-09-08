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
          bne DoneStickUp

CanJump:

          lda #MoveJump
          sta WRITE + MovementStyle
          lda # 0
          sta WRITE + LastActivity

          ldy # 16
          ldx #-10
          lda Equipment
          .BitBit EquipHighJump
          beq +
          ldy # 32
          ldx #-20
+
          sty WRITE + JumpMomentum
          stx WRITE + DeltaY

DoneStickUp:
          lda SWCHA
          and #P0StickDown
          bne DoneStickDown

          lda Equipment
          and #EquipMorph
          beq DoneStickDown

          ;; TODO morphball switching

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

          lda MovementStyle
          cmp #MoveFall
          beq +
          cmp #MoveJump
          beq +
          lda #MoveWalk
          sta WRITE + MovementStyle
          lda # 0
          sta WRITE + LastActivity
+

          ldx DeltaX
          dex
          ldx #-1
          stx WRITE + DeltaX

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

          lda MovementStyle
          cmp #MoveFall
          beq +
          cmp #MoveJump
          beq +
          lda #MoveWalk
          sta WRITE + MovementStyle
          lda # 0
          sta WRITE + LastActivity
+

          ldx #1
          stx WRITE + DeltaX

DoneStickRight:

ApplyStick:

          rts
          .bend
