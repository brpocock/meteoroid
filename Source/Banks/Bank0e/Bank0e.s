;;; Meteoroid Source/Banks/Bank0e/Bank0e.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $0e
          PROVINCE = 9

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
          .include "MapProvince9.s"
          .include "SpritesProvince9.s"



          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Random.s"




          .include "WaitScreenBottom.s"
          .include "EndBank.s"
