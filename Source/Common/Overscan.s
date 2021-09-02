;;; Meteoroid Source/Common/Overscan.s
;;; Copyright © 2021 Bruce-Robert Pocock

Overscan: .block
          .TimeLines OverscanLines

          ldx #SFXBank
          jsr FarCall

          .weak
          DoMusic = 0
          .endweak

          .if DoMusic
          jsr DoMusic
          .fi

          .WaitForTimer

          sta WSYNC
          rts
          .bend
