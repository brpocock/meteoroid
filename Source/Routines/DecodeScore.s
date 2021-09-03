;;; Meteoroid Source/Routines/DecodeScore.s
;;; Copyright © 2021 Bruce-Robert Pocock

DecodeScore:        .block
          lda Score             ; rightmost digit
          and #$0f
          sta WRITE + StringBuffer + 5

          lda Score
          and #$f0
          clc
          ror a
          ror a
          ror a
          ror a
          sta WRITE + StringBuffer + 4

          lda Score + 1
          and #$0f
          sta WRITE + StringBuffer + 3

          lda Score + 1
          and #$f0
          ror a
          ror a
          ror a
          ror a
          sta WRITE + StringBuffer + 2

          lda Score + 2
          and #$0f
          sta WRITE + StringBuffer + 1

          lda Score + 2         ; leftmost digit
          and #$f0
          ror a
          ror a
          ror a
          ror a
          sta WRITE + StringBuffer + 0

          rts
          .bend
