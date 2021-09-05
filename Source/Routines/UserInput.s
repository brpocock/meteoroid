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

HandleStick:
          lda #0
          sta WRITE + DeltaX
          sta WRITE + DeltaY

          lda Pause
          beq +
          rts
+
          lda SWCHA
          .BitBit P0StickUp
          bne DoneStickUp

          ldx #-1
          stx WRITE + DeltaY

DoneStickUp:
          .BitBit P0StickDown
          bne DoneStickDown

          ldx #1
          stx WRITE + DeltaY

DoneStickDown:
          .BitBit P0StickLeft
          bne DoneStickLeft

          lda MapFlags
          and # ~MapFlagFacing
          sta WRITE + MapFlags
          lda #MoveWalk
          sta WRITE + MovementStyle
          lda SWCHA

          ldx #-1
          stx WRITE + DeltaX

DoneStickLeft:
          .BitBit P0StickRight
          bne DoneStickRight

          tax
          lda MapFlags
          ora #MapFlagFacing
          sta WRITE + MapFlags
          lda #MoveWalk
          sta WRITE + MovementStyle

          ldx #1
          stx WRITE + DeltaX

DoneStickRight:

ApplyStick:

FractionalMovement: .macro deltaVar, fractionVar, positionVar, pxPerSecond
          .block
          lda \fractionVar
          ldx \deltaVar
          cpx #0
          beq DoneMovement
          bpl MovePlus
MoveMinus:
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
          jmp DoneMovement

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
DoneMovement:
          .bend
          .endm

          MovementDivisor = 0.85
          ;; Make MovementDivisor  relatively the same in  both directions
	;; so diagonal movement forms a 45° line
          MovementSpeedX = ((40.0 / MovementDivisor) / FramesPerSecond)
          .FractionalMovement DeltaX, PlayerXFraction, PlayerX, MovementSpeedX
          MovementSpeedY = ((30.0 / MovementDivisor) / FramesPerSecond)
          .FractionalMovement DeltaY, PlayerYFraction, PlayerY, MovementSpeedY

          rts
          .bend
