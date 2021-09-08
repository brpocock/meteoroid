;;; Meteoroid Source/Banks/Bank04/Bank04.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $05
          PROVINCE = 0

          .include "StartBank.s"

          ;; The addresses of these must be known to the Map Services bank
          .include "PlayerSprite.s"
          .align $100
          .include "MapSprites.s"
DoLocal:
          .include "SetUpScreen.s"
          ;; falls through to
          .include "DrawMainScreen.s"

          .include "ScrollRight.s"
          .include "PeekMap.s"
          .include "PerformGravity.s"

          .include "VSync.s"
          .include "Overscan.s"

          .include "Random.s"
          .include "PlayMusic.s"
          rts

          .include "WaitScreenBottom.s"

MapData:  
          .include "MapProvince0.s"
          .include "SpritesProvince0.s"

BackgroundMusic:
          .include "Province0.s"

          .include "EndBank.s"
