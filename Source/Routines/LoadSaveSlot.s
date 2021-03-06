;;; Meteoroid Source/Routines/LoadSaveSlot.s
;;; Copyright © 2021 Bruce-Robert Pocock
LoadSaveSlot: .block
          .WaitScreenBottom
          stx WSYNC
          .if TV != NTSC
          stx WSYNC
          .fi
          .WaitScreenTop
          jsr CheckSaveSlot
          bcc ReallyLoadIt

          jmp SelectSlot

ReallyLoadIt:
          ;; OK, loading is much more straightforward than saving.
          ;; When saving, we have to write entire blocks at a time.
          ;; When loading, we can jump around and pick the values
          ;; that interest us directly.
          jsr i2cStartWrite
          lda SaveGameSlot
          clc
          adc #>SaveGameSlotPrefix
          jsr i2cTxByte
          lda #<SaveGameSlotPrefix
          jsr i2cTxByte
          jsr i2cStopWrite
          jsr i2cStartRead

DiscardSignature:
          ldx # 0
-
          jsr i2cRxByte
          cmp SaveGameSignatureString, x
          bne LoadFailed
          inx
          cpx # 5
          blt -

          ldx #SaveSCRamLength
-
          jsr i2cRxByte
          sta WRITE + SaveSCRam, x
          dex
          bne -

          ldx #GlobalGameDataLength
-
          jsr i2cRxByte
          sta GlobalGameData, x
          dex
          bne -

          jsr i2cStopRead

          lda CurrentMap
          sta WRITE + NextMap

          .WaitScreenBottom
          jmp GoPlay

LoadFailed:
          lda #SoundMiss
          sta NextSound
          jmp SelectSlot
          
          .bend
