;;; Meteoroid Source/Routines/DrawMainScreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

DrawMainScreen:    .block

Loop:
          .WaitScreenBottom
          .FarJSR MapServicesBank, ServiceTopOfScreen

          lda ClockFrame
          and #$01
          bne +
          stx WSYNC
+
;;; 
MainDrawLoop:
          lda # 0
          sta LineCounter

          stx WSYNC

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
          .if TV == SECAM
            lda #COLWHITE       ; 2 / 57
            .Sleep 3            ; 3 / 60
          .else
            lda (MapPointer), y   ; 5 / 60
          .fi
          sta COLUPF            ; 3 / 63

DrawSomeLines:
          ldx # 4               ; 2 / 70

;;; 
DrawPlayerLine:        .macro    playerNumber
          ldy PixelPointers + 6 ; 3
          stx WSYNC             ; 3
          lda # 0               ; 2 / 2
          sta VBLANK            ; 3 / 5
          lda PixelPointers + 4 ; 3 / 8 (3)
          sta PF0               ; 3 / 11 (6)
          lda PixelPointers + 5 ; 3 / 14 (9)
          sta PF1               ; 3 / 17 (12)
          sty PF2               ; 3 / 20 (15)
          lda PixelPointers + 10 + \playerNumber ; 3 / 23 (18)
          sta GRP0 + \playerNumber ; 3 / 26 (21)
          lda # 0               ; 2 / 28 (23)
          sta PixelPointers + 10 + \playerNumber ; 3 / 31 (26)
          lda PixelPointers + 7 ; 3 / 34 (29)
          sta PF0               ; 3 / 37 (32)
          lda PixelPointers + 8 ; 3 / 40 (35)
          sta PF1               ; 3 / 43 (38)
          lda PixelPointers + 9 ; 3 / 46 (41)
          sta PF2               ; 3 / 49 (44)

          lda # 11                          ; 2 / 51 (46)
          dcp P0LineCounter + \playerNumber ; 5 / 56 (51)
          blt NoPlayer                      ; 2 (3) / 58 (53)
          ldy P0LineCounter + \playerNumber ; 3 / 61 (56)
          lda (pp0l + (2 * \playerNumber)), y ; 5 / 66 (61)
          sta PixelPointers + 10 + \playerNumber ; 3 / 69 (64)
NoPlayer:                                        ; from 54-69 cycles

          .endm

;;; 
DrawLineTriple:
          .DrawPlayerLine 0
          .DrawPlayerLine 1
;;; 
DrawMissileLine:    
          ldy PixelPointers + 6 ; 3
          stx WSYNC             ; 3

          lda PixelPointers + 4 ; 3 / 3
          sta PF0               ; 3 / 6
          lda PixelPointers + 5 ; 3 / 9
          sta PF1               ; 3 / 12
          sty PF2               ; 3 / 15
          lda # 0               ; 2 / 17

          sta ENAM0             ; 3 / 20
          sta ENAM1             ; 3 / 23

          lda # 1               ; 2 / 25
          dcp M0LineCounter     ; 5 / 30
          blt NoM0              ; 2 (3) / 32
          lda # ENABLED         ; 2 / 34
          sta ENAM0             ; 3 / 37
NoM0:

          lda PixelPointers + 7 ; 3 / 40 (36)
          sta PF0               ; 3 / 43 (39)
          lda PixelPointers + 8 ; 3 / 46 (42)
          sta PF1               ; 3 / 49 (45)
          lda PixelPointers + 9 ; 3 / 52 (48)
          sta PF2               ; 3 / 55 (51)

          lda # 1               ; 2 / 57 (53)
          dcp M1LineCounter     ; 5 / 62 (58)
          blt NoM1              ; 2 (3) / 64 (60)
          lda # ENABLED         ; 2 / 66 (62)
          sta ENAM1             ; 3 / 69 (65)
NoM1:                           ; // 61-69 cycles

;;; 
;;; 
          dex                   ; 2 / 71
          beq +                 ; 2 (3) / 73
          jmp DrawLineTriple
+
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
          bmi GoScreenUp
          cmp #ScreenBottomEdge
          bge GoScreenDown

          lda PlayerX
          cmp #ScreenLeftEdge
          blt ScrollScreenRight
          cmp #ScreenRightEdge
          bge ScrollScreenLeft
          gne ShouldIStayOrShouldIGo

;;; 
ScrollScreenLeft:
          lda ScrollLeft
          lsr a
          lsr a
          clc
          adc # 11
          sta Temp
          ldy # 2
          lda (MapPointer), y
          cmp Temp
          blt ShouldIStayOrShouldIGo

          jsr UncombinePF0

          inc ScrollLeft
          lda ScrollLeft
          clc
          adc # 39               ;  screen width
          lsr a                  ; } equivalent to ÷4 ×2
          and #~$01              ; }
          clc
          adc # 3 + 12     ; indices & colors
          tay

          jsr ScrollRight

          jsr CombinePF0

MoveSpritesLeft:
          lda PlayerX
          sec
          sbc # 4
          sta WRITE + PlayerX

          lda PlayerMissileX
          sec
          sbc # 4
          cmp # 160 + HBlankWidth
          blt +
          lda # 0
+
          sta WRITE + PlayerMissileX

          lda BlessedX
          sec
          sbc # 4
          sta WRITE + BlessedX

          ldx # 4
-
          lda MonsterMissileX - 1, x
          sec
          sbc # 4
          cmp # 160 + HBlankWidth
          blt +
          lda # 0
+
          sta WRITE + MonsterMissileX - 1, x
          dex
          bne -

DoneScrolling:
          jmp ShouldIStayOrShouldIGo

;;; 
          
ScrollScreenRight:
          ldy # 1
          lda (MapPointer), y
          cmp ScrollLeft
          bge DoneScrolling

          jsr UncombinePF0

          dec ScrollLeft
          lda ScrollLeft
          lsr a
          and #~$01
          clc
          adc # 15
          tay

          jsr ScrollBack
          
          jsr CombinePF0

MoveSpritesRight:
          lda PlayerX
          clc
          adc # 4
          sta WRITE + PlayerX

          lda PlayerMissileX
          clc
          adc # 4
          cmp # 160 + HBlankWidth
          blt +
          lda # 0
+
          sta WRITE + PlayerMissileX

          lda BlessedX
          clc
          adc # 4
          sta WRITE + BlessedX

          ldx # 4
-
          lda MonsterMissileX - 1, x
          clc
          adc # 4
          cmp # 160 + HBlankWidth
          blt +
          lda # 0
+
          sta WRITE + MonsterMissileX - 1, x
          dex
          bne -

DoneScrollingBack:
          jmp ShouldIStayOrShouldIGo

GoScreenUp:
          ldy #0
          lda (MapPointer), y
          beq DoneScrollingBack

          lda #ScreenBottomEdge - 1
          sta WRITE + BlessedY
          sta WRITE + PlayerY
          geq GoScreen

GoScreenDown:
          lda #1
          sta WRITE + BlessedY
          sta WRITE + PlayerY
          ldy #1
          ;; fall through
GoScreen:
          lda #0
          sta WRITE + DeltaX
          sta WRITE + DeltaY

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
