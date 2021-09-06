;;; Meteoroid Source/Banks/Bank0a/Bank0a.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $0a
          PROVINCE = 5

          .include "StartBank.s"

          ;; The addresses of these must be known to the Map Services bank
          .include "PlayerSprite.s"
          .include "MapSprites.s"
DoLocal:
          .include "SetUpScreen.s"
          ;; falls through to
          .include "DrawMainScreen.s"
          .include "ScrollRight.s"

MapData:
          .include "MapProvince5.s"
          .include "SpritesProvince5.s"
BackgroundMusic:
          .include "Province5.s"

          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Random.s"

          .include "PlayMusic.s"
          rts

          .include "WaitScreenBottom.s"
          .include "EndBank.s"
