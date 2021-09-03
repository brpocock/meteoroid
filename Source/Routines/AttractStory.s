;;; Meteoroid Source/Routines/AttractStory.s
;;; Copyright © 2021 Bruce-Robert Pocock

AttractStory:       .block

          lda NewButtons
          beq +
          and # PRESSED | PRESSED>>1
          beq +
          lda #ModeSelectSlot
          sta WRITE + GameMode
+

          lda AlarmSeconds
          bne +
          lda AlarmFrames
          bne +

          lda #ModeAttractTitle
          sta WRITE + GameMode
          lda # 20
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames
          sta WRITE + AttractTitleScroll
          lda # 1
          sta WRITE + AttractTitleReveal

+
          rts
          .bend
