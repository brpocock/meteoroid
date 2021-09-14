;;; Meteoroid Source/Banks/Bank09/Bank09.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $09
          PROVINCE = 4

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
          .include "MapProvince4.s"
          .include "SpritesProvince4.s"



          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Random.s"




          .include "WaitScreenBottom.s"
          .include "EndBank.s"
