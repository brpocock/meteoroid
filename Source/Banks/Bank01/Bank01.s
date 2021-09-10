;;; Meteoroid Source/Banks/Bank01/Bank01.s
;;; Copyright © 2021 Bruce-Robert Pocock
          BANK = $01

          ;; Map Services Bank

          .include "StartBank.s"
          .include "Source/Generated/Bank04/SpeakJetIDs.s"

          .include "48Pixels.s"
          .include "Prepare48pxMobBlob.s"
          .include "Failure.s"
          .include "SpriteColors.s"

DoLocal:
          cpy #ServiceTopOfScreen
          beq TopOfScreenService
          cpy #ServiceNewGame
          beq StartNewGame
          cpy #ServiceValidateMap
          beq ValidateMap
          cpy #ServiceSubscreen
          beq Subscreen
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

          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"

          .include "Subscreen.s"

          .include "AtariVox-EEPROM-Driver.s"

          .include "WaitScreenBottom.s"

ShowPointerText:
          jsr CopyPointerText
          .FarJMP TextBank, ServiceDecodeAndShowText ; tail call

	.include "EndBank.s"
