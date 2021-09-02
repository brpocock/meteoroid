;;; Meteoroid Source/Routines/AttractStory.s
;;; Copyright © 2021 Bruce-Robert Pocock

AttractStory:       .block

          lda NewButtons
          beq +
          and # PRESSED | PRESSED>>1
          beq +
          lda #ModeSelectSlot
          sta GameMode
+

          lda AlarmSeconds
          bne +
          lda AlarmFrames
          bne +

          lda #ModeAttractTitle
          sta GameMode
          lda # 20
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames
          sta AttractTitleScroll
          lda # 1
          sta AttractTitleReveal

+
          rts
          .bend
