;;; Meteoroid Source/Common/Overscan.s
;;; Copyright © 2021 Bruce-Robert Pocock

Overscan: .block
          .TimeLines OverscanLines

          ldx #SFXBank
          jsr FarCall

          .if BANK >= Province0Bank
          jsr DoMusic
          jsr PerformGravity
          .fi

          .WaitForTimer

          sta WSYNC
          rts
          .bend
