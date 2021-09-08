;;; Meteoroid Source/Routines/DrawMainScreen.s
;;; Copyright © 2021 Bruce-Robert Pocock

DrawMainScreen:    .block

Loop:
          .WaitScreenBottom
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
          lda # 0               ; 2
          sta VBLANK            ; 3

          lda PixelPointers + 4 ; 3
          sta PF0               ; 3
          lda PixelPointers + 5 ; 3
          sta PF1               ; 3
          sty PF2               ; 3
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

          lda # 11                          ; 2
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

          dex                   ; 2
          bne DrawLineTriple    ; 2 (3)

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
          
FractionalMovement: .macro deltaVar, fractionVar, positionVar, pxPerSecond
          .block
          lda \fractionVar
          ldx \deltaVar
          cpx #0
          beq DoneMovement
          bpl MovePlus
MoveMinus:
          sec
          sbc #ceil(\pxPerSecond * $80)
          sta WRITE + \fractionVar
          bcs DoneMovement
          adc #$80
          sta WRITE + \fractionVar
          lda \positionVar
          sec
          sbc # 1
          sta WRITE + \positionVar
          jmp DoneMovement

MovePlus:
          clc
          adc #ceil(\pxPerSecond * $80)
          sta WRITE + \fractionVar
          bcc DoneMovement
          sbc #$80
          sta WRITE + \fractionVar
          lda \positionVar
          clc
          adc # 1
          sta WRITE + \positionVar
DoneMovement:
          .bend
          .endm

          MovementDivisor = 0.85
          ;; Make MovementDivisor  relatively the same in  both directions
	;; so diagonal movement forms a 45° line
          MovementSpeedX = ((40.0 / MovementDivisor) / FramesPerSecond)
          .FractionalMovement DeltaX, PlayerXFraction, PlayerX, MovementSpeedX

CheckWallLeftRight:
          lda DeltaX
          beq WallCheckDone
          bpl CheckWallRight
CheckWallLeft:
          jsr GetPlayerFootPosition
          jsr PeekMap
          bne HitWallLeft
          jsr GetPlayerFootPosition
          dey
          jsr PeekMap
          bne HitWallLeft
          jsr GetPlayerFootPosition
          dey
          dey
          jsr PeekMap
          beq WallCheckDone
HitWallLeft:
          lda # 1
          sta WRITE + DeltaX
          lda PlayerX
          clc
          adc # 1
          sta WRITE + PlayerX
          lda # 0
          sta WRITE + PlayerXFraction
          jmp WallCheckDone

CheckWallRight:
          jsr GetPlayerFootPosition
          jsr PeekMap
          bne HitWallRight
          jsr GetPlayerFootPosition
          dey
          jsr PeekMap
          bne HitWallRight
          jsr GetPlayerFootPosition
          dey
          dey
          jsr PeekMap
          beq WallCheckDone
HitWallRight:
          lda #-1
          sta WRITE + DeltaX
          lda PlayerX
          sec
          sbc # 1
          sta WRITE + PlayerX
          lda # 0
          sta WRITE + PlayerXFraction
          jmp WallCheckDone
          
WallCheckDone:
          
          MovementSpeedY = ((30.0 / MovementDivisor) / FramesPerSecond)
          .FractionalMovement DeltaY, PlayerYFraction, PlayerY, MovementSpeedY

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
          ldy # 2
          lda (MapPointer), y
          dey
          sec
          sbc (MapPointer), y
          sec
          asl a
          asl a                 ; convert to PF pixels
          sbc # 10
          cmp ScrollLeft
          blt ShouldIStayOrShouldIGo

          jsr UncombinePF0

          inc ScrollLeft
          lda ScrollLeft
          adc # 39               ;  screen width
          lsr a                  ; } equivalent to ÷4 ×2
          and #~$01              ; }
          clc
          adc # 3 + 12     ; indices & colors
          tay

          jsr ScrollRight

          lda PlayerX
          sec
          sbc # 4
          sta WRITE + PlayerX

          lda PlayerMissileX
          sec
          sbc # 4
          sta WRITE + PlayerMissileX

          lda BlessedX
          sec
          sbc # 4
          sta WRITE + BlessedX

          ldx # 8
-
          lda SpriteX - 1, x
          sec
          sbc # 4
          sta WRITE + SpriteX - 1, x
          dex
          bne -

          ldx # 4
-
          lda MonsterMissileX - 1, x
          sec
          sbc # 4
          sta WRITE + MonsterMissileX - 1, x
          dex
          bne -

          jsr CombinePF0
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
          
          lda PlayerX
          clc
          adc # 4
          sta WRITE + PlayerX

          lda PlayerMissileX
          clc
          adc # 4
          sta WRITE + PlayerMissileX

          lda BlessedX
          clc
          adc # 4
          sta WRITE + BlessedX

          ldx # 8
-
          lda SpriteX - 1, x
          clc
          adc # 4
          sta WRITE + SpriteX - 1, x
          dex
          bne -

          ldx # 4
-
          lda MonsterMissileX - 1, x
          clc
          adc # 4
          sta WRITE + MonsterMissileX - 1, x
          dex
          bne -

          jsr CombinePF0
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
