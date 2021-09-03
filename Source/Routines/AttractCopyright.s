;;; Meteoroid Source/Routines/AttractCopyright.s
;;; Copyright © 2021 Bruce-Robert Pocock

CopyrightMode:      .block
          lda AttractHasSpoken
          cmp #<Phrase_TitleCopyright
          beq DoneCopyrightSpeech

          lda #>Phrase_TitleCopyright
          sta CurrentUtterance + 1
          lda #<Phrase_TitleCopyright
          sta CurrentUtterance
          sta WRITE + AttractHasSpoken
DoneCopyrightSpeech:
          .SkipLines 24

          .ldacolu COLGOLD, $e
          sta COLUP0
          sta COLUP1

          .SetPointer CopyText
          jsr ShowPointerText
          .SetPointer RightText
          jsr ShowPointerText
          .SetPointer Text2021
          jsr ShowPointerText
          .SetPointer BruceText
          jsr ShowPointerText
          .SetPointer RobertText
          jsr ShowPointerText
          .SetPointer PocockText
          jsr ShowPointerText

          lda AlarmSeconds
          bne StillCopyright
          lda AlarmFrames
          bne StillCopyright

          lda # 30
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames
          lda #ModeAttractStory
          sta WRITE + GameMode
;;; 
StillCopyright:
          lda NewSWCHA
          beq Done
          and #P0StickUp
          bne Done
          lda #ModeCreditSecret
          sta WRITE + GameMode

Done:
          jmp Attract.DoneKernel

          .bend
