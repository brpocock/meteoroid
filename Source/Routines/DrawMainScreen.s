;;; Meteoroid Source/Routines/DrawMainScreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

DrawMainScreen:    .block

Loop:
          .FarJSR MapServicesBank, ServiceTopOfScreen

          .TimeLines KernelLines - 34

ExecuteScroll:
          lda # 15              ; skip row, offset, and run length, and color data
          clc
          adc ScrollLeft
          adc ScrollLeft
          tay

RotateMapToSCRam:
          ;; Map data is stored in vertical strips.
          ;; These have to be rotated into the Background array.

ClearBackgroundArray:
          ldx # 60
          lda # 0
-
          sta Background + WRITE - 1, x
          dex
          bne -

          ldx # 6
-
          sta PixelPointers - 1, x
          dex
          bne -

          ;; Y register contains the offset of the vertical span into the MapPointer table.


          ;; TODO this is where the magic is supposed to happen. 
;;; 
BeforeKernel:

;;; 
MainDrawLoop:
          lda # 0
          sta CurrentDrawRow + WRITE

          .ldacolu COLGOLD, $0
          sta COLUBK
          
DrawOneRow:

UnpackRowData:
          lda # ENABLED
          sta VBLANK
          ldx CurrentDrawRow

          lda BackgroundPF0, x
          sta PixelPointers + 4
          lsr a
          lsr a
          lsr a
          lsr a
          sta PixelPointers + 9
          lda BackgroundPF1L, x
          sta PixelPointers + 5
          lda BackgroundPF2L, x
          sta PixelPointers + 6
          lda BackgroundPF2R, x
          sta PixelPointers + 7
          lda BackgroundPF1R, x
          sta PixelPointers + 8

          txa
          clc
          adc # 3
          tay
          lda (MapPointer), y
          sta COLUPF

          lda # 0
          sta VBLANK

DrawSomeLines:
          .if TV == NTSC
          ldx # 7
          .else
          ldx # 8
          .fi

DrawOneLine:        .macro    playerNumber
          stx WSYNC

          lda PixelPointers + 4
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
          lda PixelPointers + 5
          sta PF1
          lda PixelPointers + 6
          sta PF2
          .Sleep 4
          lda PixelPointers + 7
          sta PF2
          lda PixelPointers + 8
          sta PF1
          lda PixelPointers + 9
          sta PF0

          .endm

DrawLinePair:
          .DrawOneLine 0
          .DrawOneLine 1

          dex
          bne DrawLinePair

          lda CurrentDrawRow
          clc
          adc # 1
          cmp # 10
          sta CurrentDrawRow + WRITE
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
          jmp ExecuteScroll

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
          jmp ExecuteScroll

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
          sta GameMode
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
