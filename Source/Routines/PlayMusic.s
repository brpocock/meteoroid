;;; Meteoroid Source/Routines/PlayMusic.s
;;; Copyright © 2021 Bruce-Robert Pocock
DoMusic:
          lda CurrentMusic + 1
          bne PlayMusic

LoopMusic:
          ;; Don't loop if there's currently a sound effect playing
          ;; e.g. Atari Today jingle, victory music from combat, &c.
          ;; Both can play at the same time, but don't *start*
          ;; playing until the last sound effect has ended
          lda CurrentSound + 1
          bne TheEnd

          .switch BANK
          .case SFXBank

          lda GameMode
          .if PUBLISHER
          cmp #ModePublisherPresents
          .else
          cmp #ModeBRPPreamble
          .fi
          beq TheEnd
          and #$f0
          cmp #ModeAttract
          bne TheEnd

          lda #>SongTheme
          sta WRITE + CurrentMusic + 1
          lda #<SongTheme
          sta WRITE + CurrentMusic

          .default

          lda #>BackgroundMusic
          sta WRITE + CurrentMusic + 1
          lda #<BackgroundMusic
          sta WRITE + CurrentMusic

          .endswitch

          jmp ReallyPlayMusic

PlayMusic:
          .if BANK == SFXBank
          lda GameMode
          and #$f0
          cmp #ModeAttract
          bne TheEnd
          .fi

          ldx NoteTimer
          dex
          stx WRITE + NoteTimer
          bne TheEnd

          ;; make the notes slightly more staccatto
          lda # 0
          sta AUDF1
          sta AUDC1
          sta AUDV1

ReallyPlayMusic:
          ldy #0
          lax (CurrentMusic), y
          and #$0f
          sta AUDC1

          txa
          and #$f0
          clc
          .rept 4
          ror a
          .next
          sta AUDV1

          iny                   ; 1
          lda (CurrentMusic), y
          and #$7f
          sta AUDF1

          iny                   ; 2
          lda (CurrentMusic), y
          sta WRITE + NoteTimer

          dey                   ; 1
          lda (CurrentMusic), y
          bmi LoopMusic

          lda # 3
          clc
          adc CurrentMusic
          bcc +
          ldx CurrentMusic + 1
          inx
          stx WRITE + CurrentMusic + 1
+
          sta WRITE + CurrentMusic

          jmp TheEnd

TheEnd:
