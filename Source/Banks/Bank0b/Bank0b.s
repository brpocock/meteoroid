;;; Meteoroid Source/Banks/Bank0b/Bank0b.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $0b
          PROVINCE = 6

          .include "StartBank.s"

          ;; The addresses of these must be known to the Map Services bank
          .include "PlayerSprite.s"
          .include "MapSprites.s"
DoLocal:
          .include "SetUpScreen.s"
          ;; falls through to
          .include "DrawMainScreen.s"

MapData:
          .include "MapProvince6.s"
          .include "SpritesProvince6.s"
BackgroundMusic:
          .include "Province6.s"

          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Random.s"

          .include "PlayMusic.s"
          rts

          .include "WaitScreenBottom.s"
          .include "EndBank.s"
