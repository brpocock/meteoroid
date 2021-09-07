;;; Meteoroid Source/Banks/Bank08/Bank08.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $08
          PROVINCE = 3

          .include "StartBank.s"

          ;; The addresses of these must be known to the Map Services bank
          .include "PlayerSprite.s"
          .include "MapSprites.s"
DoLocal:
          .include "SetUpScreen.s"
          ;; falls through to
          .include "DrawMainScreen.s"

          .include "ScrollRight.s"
          .include "PeekMap.s"
          .include "PerformGravity.s"

MapData:
          .include "MapProvince3.s"
          .include "SpritesProvince3.s"
BackgroundMusic:
          .include "Province3.s"

          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Random.s"

          .include "PlayMusic.s"
          rts

          .include "WaitScreenBottom.s"
          .include "EndBank.s"
