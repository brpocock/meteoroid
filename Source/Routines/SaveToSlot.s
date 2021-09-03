;;; Meteoroid Source/Routines/SaveToSlot.s
;;; Copyright © 2021 Bruce-Robert Pocock
SaveToSlot:	.block
          .WaitScreenBottom
          .if TV != NTSC
          stx WSYNC
          .fi
          .WaitScreenTop

WriteMasterBlock:
          ;; OK, now we're going to actually write the Master block,
          ;; this is a 5 byte signature, then the Global vars space

          ;; First set the write pointer up for the first block of this
          ;; save game slot
	jsr i2cStartWrite

	lda #>SaveGameSlotPrefix
	jsr i2cTxByte

          .if (SaveGameSlotPrefix & $3f) != 0
          .error "Save routines assume that SaveGameSlotPrefix is aligned to $40"
          .fi
          
	lda SaveGameSlot
          clc
          .rept 6
          asl a
          .next
	jsr i2cTxByte

          ;; The signature is how we can tell that the slot is
          ;; occupied. Really any 2 bytes that are not $00 or $ff
          ;; would suffice, but this works too and we can
          ;; actually spare the space.
	ldx # 0
WriteSignatureLoop:
	lda SaveGameSignatureString, x
	jsr i2cTxByte
	inx
	cpx # 5
	bne WriteSignatureLoop

          ldx #SaveSCRamLength
-
          lda SaveSCRam, x
          jsr i2cTxByte
          dex
          bne -

          ldx #GlobalGameDataLength
-
          lda GlobalGameData, x
          jsr i2cTxByte
          dex
          bne -

          jsr i2cStopWrite

          .WaitScreenBottom
          .WaitScreenTop

          ;; Wait for acknowledge bit
          rts

SaveRetry:
          .WaitScreenBottom
          jmp SaveToSlot
	.bend
