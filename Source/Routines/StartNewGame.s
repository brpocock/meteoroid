;;; Meteoroid Source/Routines/StartNewGame.s
;;; Copyright © 2021 Bruce-Robert Pocock
StartNewGame:          .block
          .WaitScreenTopMinus 1, -1

          lda #ModeStartGame
          sta WRITE + GameMode

          ldx #$ff              ; destroy stack. We are here to stay.
          txs

InitGameVars:
          ;; Set up actual game vars for a new game
          lda #ModePlay
          sta WRITE + GameMode

          lda # 0
          sta CurrentProvince
          sta WRITE + NextMap
          sta WRITE + CurrentMap
          sta WRITE + Score
          sta WRITE + Score + 1
          sta WRITE + Score + 2
          sta ClockFrame
          sta ClockSeconds
          sta ClockMinutes
          sta ClockFourHours
          sta AlarmSeconds
          sta AlarmFrames
          sta CountdownSeconds
          sta CountdownFrames
          sta WRITE + PlayerXFraction
          sta WRITE + PlayerYFraction
          sta WRITE + DeltaX
          sta WRITE + DeltaY
          sta MovementStyle     ; standing

          lda # 160              ; Player start position
          sta WRITE + BlessedX
          sta WRITE + PlayerX
          lda # 16
          sta WRITE + BlessedY
          sta WRITE + PlayerY

          lda # 0
          sta ScrollLeft

          lda # 100
          sta CurrentHP
          lda # 1
          sta CurrentTanks
          sta MaxTanks

          .WaitScreenBottom
          .if TV != NTSC
          stx WSYNC
          .fi

          .WaitScreenTopMinus 1, -1

          jsr i2cStartWrite
          bcc LetsStart
          jsr i2cStopWrite
          brk

LetsStart:
          lda SaveGameSlot
          clc
          adc #>SaveGameSlotPrefix
          jsr i2cTxByte
          clc
          ;; if this is non-zero other things will bomb
          .if ($3f & SaveGameSlotPrefix) != 0
          .error "SaveGameSlotPrefix should be $40-aligned, got ", SaveGameSlotPrefix
          .fi
          lda #<SaveGameSlotPrefix
          jsr i2cTxByte

          lda SaveGameSlot
          clc
          .rept 6
          asl a
          .next
          jsr i2cTxByte

          jsr i2cStopWrite

          .WaitScreenBottom
Leave:
          .FarJSR SaveKeyBank, ServiceSaveToSlot

          jmp GoPlay

          .bend
