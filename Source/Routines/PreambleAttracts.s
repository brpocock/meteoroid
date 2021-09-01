;;; Meteoroid Source/Routines/PreambleAttracts.s
;;; Copyright © 2021 Bruce-Robert Pocock

Preamble: .block
          
          .if PUBLISHER

PublisherPresentsMode:
          .SetUpFortyEight AtariAgeLogo
          .ldacolu COLGRAY, $f
          sta COLUBK
          ldy # AtariAgeLogo.Height
          .ldacolu COLTURQUOISE, $8

          .else

BRPPreambleMode:
          .SetUpFortyEight BRPCredit
          ldy # BRPCredit.Height
          .ldacolu COLINDIGO, $8

          .fi

          sta COLUP0
          sta COLUP1

          sta WSYNC

          lda AlarmSeconds
          bne StillPresenting
          lda AlarmFrames
          bne StillPresenting

          lda # 30
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames
          lda #ModeAttractTitle
          sta GameMode
          
StillPresenting:
SingleGraphicAttract:

          .SkipLines 71

          sty LineCounter
          jsr ShowPicture

          .if PUBLISHER
            .SetUpFortyEight AtariAgeText
            ldy #AtariAgeText.Height
          sty LineCounter
          sty WSYNC
            jsr ShowPicture
          .fi

          jmp Attract.DoneKernel

          .bend
