;;;
;;;
;;; *** METEOROID ***
;;;
;;;
;;; Copyright © 2021, Bruce-Robert Pocock
;;;

          BANK = $00

          .include "StartBank.s"
          .include "Source/Generated/Bank07/SpeakJetIDs.s"

;;; Start with page-aligned bitmaps
          .include "Title.s"

          .align $100, 0
          .if PUBLISHER
            .include "AtariAgeLogo.s"
            .align $100, 0
            .include "AtariAgeText.s"
          .else
            .include "BRPCredit.s"
            .align $100, 0
            .fill 66, 0            ; leave space for publisher name
          .fi

          .include "ShowPicture.s"

DoLocal:
          cpy #ServiceColdStart
          beq ColdStart
          cpy #ServiceSaveToSlot
          beq SaveToSlot
          cpy #ServiceAttract
          beq Attract.WarmStart
          brk

Quit:
          ldy #ServiceColdStart
          ;; falls through to
	.include "ColdStart.s"
          ;; falls through to
          .include "DetectConsole.s"
          ;; falls through to
          .include "DetectGenesis.s"
          ;; falls through to
          .include "Attract.s"

          .include "SaveToSlot.s"
          .include "SelectSlot.s"
          .include "LoadSaveSlot.s"
          .include "AtariVox-EEPROM-Driver.s"
          .include "CheckSaveSlot.s"
          .include "EraseSlotSignature.s"

          .include "Random.s"
          .include "48Pixels.s"
          .include "Prepare48pxMobBlob.s"
          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "PreambleAttracts.s"
          .include "AttractCopyright.s"
          .include "Credits.s"
          .include "CopyPointerText.s"
          .include "Bank0Strings.s"
          .include "WaitScreenBottom.s"

ShowPointerText:
          jsr CopyPointerText
          ;; fall through
ShowText:
          .FarJMP TextBank, ServiceDecodeAndShowText

          .include "EndBank.s"
