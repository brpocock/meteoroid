;;; Meteoroid Source/Routines/Attract.s
;;; Copyright © 2021 Bruce-Robert Pocock

Attract:  .block
          ;;
          ;; Title screen and attract sequence
          ;;

          .WaitScreenTop

          ldx #$80
          lda #0
ZeroRAM:
          sta $80 - 1, x
          sta RAMWrite - 1, x
          dex
          bne ZeroRAM

WarmStart:
          ldx #$ff
          txs
          jsr SeedRandom

          lda # SoundAtariToday
          sta NextSound

          .if PUBLISHER
            lda #ModePublisherPresents
          .else
            lda #ModeBRPPreamble
          .fi
          sta GameMode

          lda # CTRLPFREF
          sta CTRLPF

          lda # 4
          sta DeltaY
          ;lda # 4
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
          sta AttractHasSpoken
DoneTitleSpeech:
          .ldacolu COLRED, $6
          sta COLUP0
          sta COLUP1

          .ldacolu COLGRAY, 0
          sta WSYNC
          sta COLUBK

          .SetUpFortyEight Title
          ldy #Title.Height
          sty LineCounter
          jsr ShowPicture

PrepareFillAttractBottom:

          lda AlarmSeconds
          bne DoneKernel
          lda AlarmFrames
          bne DoneKernel

          sta AlarmFrames       ; zero
          lda # 8
          sta AlarmSeconds
          lda #ModeAttractCopyright
          sta GameMode
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
          sta GameMode
          .WaitScreenBottom
          .if NOSAVE
          jmp BeginOrResume
          .else
          jmp SelectSlot
          .fi
;;; 
          .bend
