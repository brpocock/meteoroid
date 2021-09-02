;;; Meteoroid Source/Banks/Bank02/Bank02.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $02

	.include "StartBank.s"
          .include "Source/Generated/Bank04/SpeakJetIDs.s"
          
          .include "Font.s"

DoLocal:
          cpy #ServiceDecodeAndShowText
          beq DecodeAndShowText
          cpy #ServiceShowText
          beq ShowText
          cpy #ServiceAppendDecimalAndPrint
          beq AppendDecimalAndPrintThunk
          brk

DecodeAndShowText:
          jsr DecodeText
          jmp ShowText

AppendDecimalAndPrintThunk:
          lda Temp
          jmp AppendDecimalAndPrint.BINBCD8

          .include "ShowText.s"
          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "48Pixels.s"
          .include "Prepare48pxMobBlob.s"
          .include "DecodeText.s"
          .include "AppendDecimalAndPrint.s"
          .include "CopyPointerText.s"
          .include "FindHighBit.s"
          .include "Random.s"

          .include "StringsTable.s"
          .include "WaitScreenBottom.s"

CombatText:
          .MiniText "COMBAT"
Victory2Text:
          .MiniText "  WON "

ShowPointerText:
          jsr CopyPointerText
          jmp DecodeAndShowText ; tail call

	.include "EndBank.s"
