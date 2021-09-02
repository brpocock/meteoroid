;;; Meteoroid Source/Routines/StartNewGame.s
;;; Copyright © 2021 Bruce-Robert Pocock
StartNewGame:          .block
          .WaitScreenTopMinus 1, -1

          lda #ModeStartGame
          sta GameMode

          ldx #$ff              ; destroy stack. We are here to stay.
          txs

InitGameVars:
          ;; Set up actual game vars for a new game
          lda #ModePlay
          sta GameMode

          lda # 0
          sta CurrentProvince
          sta NextMap
          sta CurrentMap
          sta Score
          sta Score + 1
          sta Score + 2
          sta ClockFrame
          sta ClockSeconds
          sta ClockMinutes
          sta ClockFourHours
          sta AlarmSeconds
          sta AlarmFrames
          sta CountdownSeconds
          sta CountdownFrames
          sta PlayerXFraction
          sta PlayerYFraction
          sta DeltaX
          sta DeltaY
          sta MovementStyle     ; standing

          lda # 80              ; Player start position
          sta BlessedX
          sta PlayerX
          lda # 25
          sta BlessedY
          sta PlayerY
          
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
