;;; Meteoroid Source/Routines/Attract.s
;;; Copyright © 2021 Bruce-Robert Pocock

Attract:  .block
          ;;
          ;; Title screen and attract sequence
          ;;

          .WaitScreenTop

          lda # 1
          sta WRITE + AttractTitleScroll
          sta WRITE + AttractTitleReveal

WarmStart:
          ldx #$ff
          txs
          jsr SeedRandom

          lda # SoundAtariToday
          sta WRITE + NextSound

          .if PUBLISHER
            lda #ModePublisherPresents
          .else
            lda #ModeBRPPreamble
          .fi
          sta WRITE + GameMode

          lda # CTRLPFREF
          sta CTRLPF

          lda # 4
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames

;;; 
Loop:
          .WaitScreenBottom
          .WaitScreenTop

          lda GameMode
          cmp #ModeAttractStory
          beq StoryMode

          .if TV == NTSC
          .SkipLines 4
          .fi
          jsr Prepare48pxMobBlob

          lda GameMode
          cmp #ModeAttractTitle
          beq TitleMode
          cmp #ModeAttractCopyright
          beq CopyrightMode
          cmp #ModeCreditSecret
          beq Credits
          .if PUBLISHER
            cmp #ModePublisherPresents
            beq Preamble.PublisherPresentsMode
          .else
            cmp #ModeBRPPreamble
            beq Preamble.BRPPreambleMode
          .fi
;;; 
StoryMode:
          .FarJSR AnimationsBank, ServiceAttractStory

          lda GameMode
          cmp #ModeAttractStory
          beq Loop
          cmp #ModeAttractTitle
          beq Loop
          jmp Leave
;;; 
TitleMode:
          lda AttractHasSpoken
          cmp #<Phrase_TitleIntro
          beq DoneTitleSpeech

          lda #>Phrase_TitleIntro
          sta CurrentUtterance + 1
          lda #<Phrase_TitleIntro
          sta CurrentUtterance
          sta WRITE + AttractHasSpoken
DoneTitleSpeech:
          .ldacolu COLRED, $6
          sta COLUP0
          sta COLUP1

          .ldacolu COLGRAY, 0
          sta WSYNC
          sta COLUBK

          ldy AttractTitleScroll
-
          stx WSYNC
          dey
          bne -

          .SetUpFortyEight Title
          ldy AttractTitleReveal
          sty LineCounter
          jsr ShowPicture

          lda ClockFrame
          and #$07
          bne PrepareFillAttractBottom
          ldy AttractTitleReveal
          cpy # Title.Height
          beq +
          ldx AttractTitleReveal
          inx
          stx WRITE + AttractTitleReveal
          gne PrepareFillAttractBottom

+
	ldx AttractTitleScroll
          cpx # (KernelLines / 2) - Title.Height
          bge PrepareFillAttractBottom
          inx
          stx WRITE + AttractTitleScroll

PrepareFillAttractBottom:

          lda AlarmSeconds
          bne DoneKernel
          lda AlarmFrames
          bne DoneKernel

          sta AlarmFrames       ; zero
          lda # 8
          sta AlarmSeconds
          lda #ModeAttractCopyright
          sta WRITE + GameMode
          ;; fall through
;;; 
DoneKernel:
          lda NewSWCHB
          beq +
          and #SWCHBSelect
          beq Leave
+
          lda NewButtons
          beq +
          and #PRESSED
          beq Leave
+

          jmp Loop

Leave:
          lda #ModeSelectSlot
          sta WRITE + GameMode
          .WaitScreenBottom
          .if NOSAVE
          jmp BeginOrResume
          .else
          jmp SelectSlot
          .fi
;;; 
          .bend
