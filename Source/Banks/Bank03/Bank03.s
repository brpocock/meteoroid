;;; Meteoroid Source/Banks/Bank03/Bank03.s
;;; Copyright © 2021 Bruce-Robert Pocock
	BANK = $03

          .include "StartBank.s"

          .include "Source/Generated/Bank07/SpeakJetIDs.s"

          .include "AttractStory.s"
          .include "Death.s"
          .include "WinnerFireworks.s"

          .include "48Pixels.s"
          .include "VSync.s"
          .include "VBlank.s"
          .include "Overscan.s"
          .include "Prepare48pxMobBlob.s"
          .include "Random.s"

DoLocal:
          cpy #ServiceAttractStory
          beq AttractStory
          cpy #ServiceDeath
          beq Death
          cpy #ServiceFireworks
          beq WinnerFireworks
          brk

          .include "WaitScreenBottom.s"

          .include "EndBank.s"
