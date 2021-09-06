;;; Meteoroid Source/Routines/Subscreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

Subscreen:          .block

          lda # 0
          sta WRITE + NewButtons

Loop:
          .WaitScreenBottom
          .WaitScreenTop

          .ldacolu COLPURPLE, $4
          sta COLUBK

          lda # 0
          sta PF0
          sta PF1
          sta PF2

          lda NewButtons
          beq Loop

          rts

          .bend
