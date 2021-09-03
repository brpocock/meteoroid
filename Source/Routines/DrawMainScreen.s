;;; Meteoroid Source/Routines/DrawMainScreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

DrawMainScreen:    .block

Loop:
          .FarJSR MapServicesBank, ServiceTopOfScreen

          .TimeLines KernelLines - 38

;;; 
BeforeKernel:

;;; 
MainDrawLoop:
          lda # 0
          sta LineCounter

          .ldacolu COLGOLD, $f
          sta CTRLPF

          .ldacolu COLGOLD, $0
          sta COLUBK

DrawOneRow:
          ldy LineCounter

          lda # ENABLED
          sta VBLANK
          stx WSYNC
          lda # 0
          sta VBLANK

DrawSomeLines:
          ldx # 5

DrawOneLine:        .macro    playerNumber
          stx WSYNC

          lda BackgroundPF0, y
          sta PF0
          dcp P0LineCounter + \playerNumber
          bcc NoPlayer
          ldy P0LineCounter + \playerNumber
          lda (PixelPointers + \playerNumber), y
          sta GRP0 + \playerNumber
          jmp PlayerDone
NoPlayer:
          lda # 0
          sta GRP0 + \playerNumber
          .Sleep 5
PlayerDone:
          ldy LineCounter
          lda BackgroundPF1L, y
          sta PF1
          lda BackgroundPF2L, y
          sta PF2
          lda BackgroundPF0, y
          lsr a
          lsr a
          lsr a
          lsr a
          sta PF0
          lda BackgroundPF1R, y
          sta PF1
          lda BackgroundPF2R, y
          sta PF2

          .endm

DrawLinePair:
          .DrawOneLine 0
          .DrawOneLine 1

          dex
          bne DrawLinePair

          iny
          sty LineCounter
          cpy # 10
          blt DrawOneRow
;;; 
FillBottomScreen:
          .ldacolu COLBLUE, $6
          sta COLUBK
          lda # 0
          sta PF0
          sta PF1
          sta PF2
          sta GRP0
          sta GRP1
          sta ENABL
;;; 
ScreenJumpLogic:
          lda PlayerY
          cmp #ScreenTopEdge
          blt GoScreenUp
          cmp #ScreenBottomEdge
          bge GoScreenDown

          lda PlayerX
          cmp #ScreenLeftEdge
          blt ScrollScreenLeft
          cmp #ScreenRightEdge
          bge ScrollScreenRight

          gne ShouldIStayOrShouldIGo

ScrollScreenLeft:
          lda ScrollLeft
          beq ShouldIStayOrShouldIGo
          dec ScrollLeft
          lda PlayerX
          clc
          adc # 4
          sta PlayerX
          lda BlessedX
          clc
          adc # 4
          sta BlessedX
          jmp SetUpScreen.ExecuteScroll

ScrollScreenRight:
          ldy # 2
          lda (MapPointer), y
          sec
          sbc # 10
          cmp ScrollLeft
          bge ShouldIStayOrShouldIGo
          inc ScrollLeft
          lda PlayerX
          sec
          sbc # 4
          sta PlayerX
          lda BlessedX
          sec
          sbc # 4
          sta BlessedX
          jmp SetUpScreen.ExecuteScroll

GoScreenUp:
          lda #ScreenBottomEdge - 1
          sta BlessedY
          sta PlayerY
          ldy #0
          geq GoScreen

GoScreenDown:
          lda #ScreenTopEdge + 1
          sta BlessedY
          sta PlayerY
          ldy #1
          ;; fall through
GoScreen:
          lda #0
          sta DeltaX
          sta DeltaY

          ;; FIXME. Find new screen to which to jump.

          lda #ModePlayNewRoom
          sta WRITE + GameMode
          gne ShouldIStayOrShouldIGo

ScreenBounce:
          ;; stuff the player into the middle of the screen
          lda #$7a
          sta PlayerX
          lda #$21
          sta PlayerY

ShouldIStayOrShouldIGo:
          lda GameMode
          cmp #ModePlay
          bne Leave
          .WaitForTimer
          jsr Overscan
          jmp Loop
;;; 
Leave:
          cmp #ModePlayNewRoom
          beq SetUpScreen.NewRoom

          cmp #ModePlayNewRoomDoor
          beq SetUpScreen.NewRoom

          ldx # 0
          stx CurrentMusic + 1

          .WaitForTimer
          jsr Overscan

          lda GameMode
          cmp #ModeSubscreen
          beq ShowSubscreen

UnknownMode:
          brk

ShowSubscreen:
          .FarJSR MapServicesBank, ServiceSubscreen
          jmp SetUpScreen

          .bend
