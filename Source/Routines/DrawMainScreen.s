s;;; Meteoroid Source/Routines/DrawMainScreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

DrawMainScreen:    .block

Loop:
          .FarJSR MapServicesBank, ServiceTopOfScreen

;;; 
MainDrawLoop:
          lda # 0
          sta LineCounter

          .ldacolu COLGOLD, $0
          sta COLUBK

          ;; Shift the screen slightly on odd/even frames to blur the VBLANK lines
          lda ClockFrame
          and #$01
          beq +
          stx WSYNC
+
          stx WSYNC

DrawOneRow:
          ldy LineCounter

          lda # ENABLED
          sta VBLANK
          ldy LineCounter
          lda BackgroundPF0, y
          sta PixelPointers + 4
          and #$0f
          tax
          lda PF0Shift, x
          sta PixelPointers + 7
          lda BackgroundPF1L, y
          sta PixelPointers + 5
          lda BackgroundPF2L, y
          sta PixelPointers + 6
          lda BackgroundPF1R, y
          sta PixelPointers + 8
          lda BackgroundPF2R, y
          sta PixelPointers + 9
          iny
          iny
          iny
          lda (MapPointer), y
          sta COLUPF
          stx WSYNC
          lda # 0
          sta VBLANK

DrawSomeLines:
          ldx # 3

;;; 
          
DrawOneLine:        .macro    playerNumber
          stx WSYNC             ; 3 / 3

          lda PixelPointers + 4 ; 3 / 6
          sta PF0               ; 3 / 9
          lda PixelPointers + 5 ; 3 / 12
          sta PF1               ; 3 / 15
          lda PixelPointers + 6 ; 3 / 18
          sta PF2               ; 3 / 21

          .if \playerNumber == 2 ; missile

          lda # 0               ; 2 / 23
          sta ENAM0             ; 3 / 26
          sta ENAM1             ; 3 / 29
          lda # 1               ; 2 / 31
          dcp M0LineCounter     ; 5 / 36
          blt NoM0              ; 2 (3) / 38 (39)
          lda # ENABLED         ; 2 / 40
          sta ENAM0             ; 3 / 43
NoM0:

          .else                 ; player 0 or 1

          lda # 16                                   ; 2 / 23
          dcp P0LineCounter + \playerNumber ; 5 / 28
          blt NoPlayer                      ; 2 (3) / 30 (31)
          ldy P0LineCounter + \playerNumber ; 3 / 33
          lda (PixelPointers + \playerNumber * 2), y ; 5 / 38
          sta GRP0 + \playerNumber                   ; 3 / 41
          jmp PlayerDone                             ; 3 / 44
NoPlayer:
          lda # 0               ; 2 / 33
          sta GRP0 + \playerNumber ; 3 / 36
          .Sleep 8                 ; 8 / 44
PlayerDone:

          .fi                   ; end of sprite §

          lda PixelPointers + 7 ; 3 / 45
          sta PF0               ; 3 / 48
          lda PixelPointers + 8 ; 3 / 51
          sta PF1               ; 3 / 54
          lda PixelPointers + 9 ; 3 / 57
          sta PF2               ; 3 / 60

          .endm

;;; 

DrawLineTriple:
          .DrawOneLine 0
          .DrawOneLine 1
          .DrawOneLine 2

          dex
          bne DrawLineTriple

          inc LineCounter
          ldy LineCounter
          cpy # 12
          blt DrawOneRow

;;; 
FillBottomScreen:
          lda # ENABLED
          sta VBLANK
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
          .WaitScreenBottom
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


PF0Shift:
          ;; fast way to (ash x -4)
          .byte $00, $10, $20, $30, $40, $50, $60, $70
          .byte $80, $90, $a0, $b0, $c0, $d0, $e0, $f0

          
          .bend
