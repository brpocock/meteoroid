;;; Meteoroid Source/Banks/Bank04/Bank04.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $09
          PROVINCE = 2

          .include "StartBank.s"

          ;; The addresses of these must be known to the Map Services bank
          .include "PlayerSprite.s"
          .include "MapSprites.s"
DoLocal:
          .include "SetUpScreen.s"
          ;; falls through to
          .include "DrawMainScreen.s"

          .include "MapsProvince0.s"
          .include "Maps0RLE.s"

          .include "Province0.s"

          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Random.s"

          .include "PlayMusic.s"
          rts

          .include "WaitScreenBottom.s"
          .include "EndBank.s"
