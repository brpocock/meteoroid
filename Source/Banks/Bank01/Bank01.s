;;; Meteoroid Source/Banks/Bank01/Bank01.s
;;; Copyright © 2021 Bruce-Robert Pocock
          BANK = $01

          ;; Map Services Bank

          .include "StartBank.s"
          .include "Source/Generated/Bank07/SpeakJetIDs.s"

          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "48Pixels.s"
          .include "Prepare48pxMobBlob.s"
          .include "Failure.s"

DoLocal:
          cpy #ServiceTopOfScreen
          beq TopOfScreenService
          cpy #ServiceNewGame
          beq StartNewGame
          cpy #ServiceValidateMap
          beq ValidateMap
          brk

          .include "CopyPointerText.s"
          .include "ScreenTop.s"
          .include "Random.s"
          .include "StartNewGame.s"
          .include "DecodeScore.s"

          .include "ValidateMap.s"

          .include "CheckSpriteCollision.s"
          .include "CheckPlayerCollision.s"
          .include "SpriteMovement.s"
          .include "UserInput.s"

          .if NOSAVE
          .else
          .include "AtariVox-EEPROM-Driver.s"
          .fi

          .include "WaitScreenBottom.s"

ShowPointerText:
          jsr CopyPointerText
          .FarJMP TextBank, ServiceDecodeAndShowText ; tail call

	.include "EndBank.s"
