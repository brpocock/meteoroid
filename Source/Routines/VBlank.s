;;; Meteoroid Source/Common/VBlank.s
;;; Copyright © 2021 Bruce-Robert Pocock

VBlank: .block
          sta WSYNC
          .TimeLines VBlankLines

          lda # 0
          sta WRITE + NewSWCHA
          sta WRITE + NewSWCHB
          sta WRITE + NewButtons

          lda SWCHA
          and #$f0
          cmp DebounceSWCHA
          beq +
          sta WRITE + DebounceSWCHA
          sta WRITE + NewSWCHA          ; at least two directions will be "1" bits
+
          lda SWCHB
          cmp DebounceSWCHB
          beq +
          sta WRITE + DebounceSWCHB
          ora #$40              ; guarantee at least one "1" bit
          sta WRITE + NewSWCHB
+

          lda SWCHB
          .BitBit SWCHBP0Genesis
          beq NotGenesis
          lda INPT1
          and #PRESSED
          lsr a
          sta WRITE + NewButtons
          jmp FireButton
NotGenesis:
          lda #$40
          sta WRITE + NewButtons
FireButton:
          lda INPT4
          and #PRESSED
          ora NewButtons

          cmp DebounceButtons
          bne ButtonsChanged
          lda # 0
          sta WRITE + NewButtons
          geq DoneButtons

ButtonsChanged:
          sta WRITE + DebounceButtons
          ora #$01              ; guarantee non-zero if it changed
          sta WRITE + NewButtons

DoneButtons:

          .if BANK == MapServicesBank
          
          lda GameMode
          cmp #ModePlay
          bne NotPlaying

          jsr CheckSpriteCollision
          jsr SpriteMovement
          jsr BulletMovement
          jsr PerformGravity
          jsr CheckPlayerCollision
          jsr UserInput

          .fi

NotPlaying:

          .WaitForTimer

          ldx # 0
          stx VBLANK
          rts
          .bend
