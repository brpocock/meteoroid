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
          sta $80, x
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

          .if STARTER == 1
          lda #$80
          sta PlayerYFraction
          .fi

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

          .switch STARTER

          .case 0               ; Dirtex

          .SkipLines 20
          .ldacolu COLORANGE, $a
          sta COLUBK
          .SkipLines 10

          .case 1               ; Aquax

          .SkipLines 30
          .ldacolu COLSPRINGGREEN, $4
          sta COLUBK

          .case 2               ; Airex

          .SkipLines 20
          .ldacolu COLGREEN, $4
          sta COLUBK
          .ldacolu COLTURQUOISE, $e
          sta COLUPF

          lda #$ff
          sta PF0
          lda #$f0
          sta PF1
          .SkipLines 2

          lda #$ff
          sta PF0
          lda #$d5
          sta PF1
          .SkipLines 4

          lda #$aa
          sta PF0
          lda #$88
          sta PF1
          .SkipLines 6

          lda # 0
          sta PF0
          sta PF1
          sta PF2

          .endswitch

          .SkipLines 12

          .switch STARTER
          .case 0
          .ldacolu COLGREEN, $e
          .case 1
          .ldacolu COLBROWN, $6
          .case 2
          .if TV == SECAM
          lda #COLBLUE
          .else
          .ldacolu COLTEAL, $e
          .fi
          .default
          .error "STARTER ∈ (0 1 2), ¬ ", STARTER
          .endswitch

          sta COLUP0
          sta COLUP1

          sta WSYNC             ; just for line count


          jmp PrepareFillAttractBottom


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

          .if STARTER == 2
          lda # 0
          sta GRP0
          sta GRP1
          .fi

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
