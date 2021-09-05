s;;; Meteoroid Source/Routines/DrawMainScreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

DrawMainScreen:    .block

Loop:
          .FarJSR MapServicesBank, ServiceTopOfScreen

;;; 
MainDrawLoop:
          lda # 0
          sta LineCounter

          stx WSYNC

          lda ClockFrame
          and #$01
          beq +
          stx WSYNC
+

DrawOneRow:
          lda # ENABLED         ; 2
          sta VBLANK            ; 3
          stx WSYNC             ; 3
          ldy LineCounter       ; 3 / 3
          lda BackgroundPF0, y  ; 4 / 7
          sta PixelPointers + 4 ; 3 / 10
          and #$0f              ; 2 / 12
          tax                   ; 2 / 14
          lda PF0Shift, x       ; 4 / 18
          sta PixelPointers + 7 ; 3 / 21
          lda BackgroundPF1L, y ; 4 / 25
          sta PixelPointers + 5 ; 3 / 28
          lda BackgroundPF2L, y ; 4 / 32
          sta PixelPointers + 6 ; 3 / 35
          lda BackgroundPF1R, y ; 4 / 39
          sta PixelPointers + 8 ; 3 / 42
          lda BackgroundPF2R, y ; 4 / 46
          sta PixelPointers + 9 ; 3 / 49
          iny                   ; 2 / 51
          iny                   ; 2 / 53
          iny                   ; 2 / 55
          ;; lda (MapPointer), y   ; 5 / 60
          lda # COLGREEN | $e
          .Sleep 3
          sta COLUPF            ; 3 / 63

DrawSomeLines:
          ldx # 4               ; 2 / 70

;;; 
DrawPlayerLine:        .macro    playerNumber
          stx WSYNC             ; 3
          lda # 0               ; 2 / 2
          sta VBLANK            ; 3 / 5

          lda PixelPointers + 4 ; 3 / 8
          sta PF0               ; 3 / 11
          lda PixelPointers + 5 ; 3 / 14
          sta PF1               ; 3 / 17
          lda PixelPointers + 6 ; 3 / 20
          sta PF2               ; 3 / 23
          lda PixelPointers + 10 + \playerNumber ; 3
          sta GRP0 + \playerNumber ; 3
          lda # 0               ; 2
          sta PixelPointers + 10 + \playerNumber ; 3
          lda PixelPointers + 7 ; 3
          sta PF0               ; 3
          lda PixelPointers + 8 ; 3
          sta PF1               ; 3
          lda PixelPointers + 9 ; 3
          sta PF2               ; 3

          lda # 15                          ; 2
          dcp P0LineCounter + \playerNumber ; 5
          blt NoPlayer                      ; 2 (3)
          ldy P0LineCounter + \playerNumber ; 3
          lda (pp0l + \playerNumber * 2), y ; 5
          sta PixelPointers + 10 + \playerNumber ; 3
NoPlayer:

          .endm

;;; 
DrawLineTriple:
          .DrawPlayerLine 0
;;; 
DrawMissileLine:    
          stx WSYNC             ; 3

          lda PixelPointers + 4 ; 3 / 3
          sta PF0               ; 3 / 6
          lda PixelPointers + 5 ; 3 / 9
          sta PF1               ; 3 / 12
          lda PixelPointers + 6 ; 3 / 15
          sta PF2               ; 3 / 18
          lda # 0               ; 2 / 20

          sta ENAM0             ; 3 / 23
          sta ENAM1             ; 3 / 26

          lda # 1               ; 2
          dcp M0LineCounter     ; 5 
          blt NoM0              ; 2 (3)
          lda # ENABLED         ; 2
          sta ENAM0             ; 3
NoM0:

          lda PixelPointers + 7 ; 3
          sta PF0               ; 3
          lda PixelPointers + 8 ; 3
          sta PF1               ; 3
          lda PixelPointers + 9 ; 3
          sta PF2               ; 3

          lda # 1               ; 2
          dcp M1LineCounter     ; 5
          blt NoM1              ; 2 (3)
          lda # ENABLED         ; 2
          sta ENAM1             ; 3
NoM1:

;;; 
          .DrawPlayerLine 1

          dex                   ; 2 / 66 (58)
          bne DrawLineTriple    ; 2 (3) / 68 (60)

          inc LineCounter       ; 5 / 73 (65)
          ldy LineCounter       ; 3 / 76* (68)
          cpy # 12              ; 2 / 78* (70)
          blt DrawOneRow        ; 2 (3) / 80* (72)
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
