;;; Meteoroid Source/Routines/ScreenTop.s
;;; Copyright © 2021 Bruce-Robert Pocock

          ;; MAGIC — these addresses must be  known and must be the same
	;; in every map bank.

          PlayerSprites = $f100
          MapSprites = $f200
TopOfScreenService: .block

          lda ClockFrame
          and #$01
          bne +
          stx WSYNC
+
          jsr VSync

;;; 
          lda # 0
          sta VBLANK
PrepareTanksToDraw:
          ldx # 6
          lda # 0
-
          sta PixelPointers - 1, x
          dex
          bne -

SetUpTanksBitmap:
          lda CurrentTanks
          cmp # 4
          bge +
          tax
          lda TanksBits, x
          sta PixelPointers + 0
          jmp EndTanks
+
          ldx TanksBits + 4
          stx PixelPointers + 0
          sec
          sbc # 4
          cmp # 4
          bge +
          tax
          lda TanksBitsReversed, x
          sta PixelPointers + 1
          jmp EndTanks
+
          ldx TanksBitsReversed + 4
          stx PixelPointers + 1

          ;; TODO: More than 8 tanks?

EndTanks:

          stx WSYNC
          ldy # 4
DrawTanks:
          stx WSYNC
          lda TanksColors, y
          sta COLUPF
          lda PixelPointers + 0
          sta PF1
          lda PixelPointers + 1
          sta PF2
          .Sleep 20
          lda PixelPointers + 2
          sta PF0
          lda PixelPointers + 3
          sta PF1
          lda PixelPointers + 4
          sta PF2
          dey
          bne DrawTanks

          .SkipLines 3

          .ldacolu COLYELLOW, $a
          sta COLUPF

PrepareForHPBar:
          lda # 0
          sta PF0
          sta PixelPointers
          sta PixelPointers + 1

          lda CurrentHP
          lsr a
          cmp # 15
          blt +
          lda #$ff
          sta PixelPointers + 1
          sta PixelPointers + 0
          jmp DrawHP
+
          cmp # 8
          blt ZeroPF2
          sec
          sbc # 8
          tax
          lda HPBitsReversed, x
          sta PixelPointers + 1
          jmp PF1ForHP
ZeroPF2:
          .ldacolu COLORANGE, $a
          sta COLUPF

PF1ForHP:
          lda CurrentHP
          lsr a
          cmp # 8
          bge FullPF1
          tax
          lda HPBits, x
          sta PixelPointers
          jmp DrawHP

FullPF1:
          lda #$ff
          sta PixelPointers

DrawHP:
          .ldacolu COLGOLD, $4
          sta COLUPF

          ldy # 4
DrawHPLoop:
          stx WSYNC
          lda PixelPointers
          sta PF1
          lda PixelPointers + 1
          sta PF2
          .SleepX 32

          lda # 0
          sta PF1
          sta PF2

          dey
          bne DrawHPLoop

          .SkipLines 3
;;; 
          lda # ENABLED
          sta VBLANK
          lda # 0
          sta CTRLPF
          sta VDELP0
          sta VDELP1
          lda # NUSIZMissile2
          sta NUSIZ0
          sta NUSIZ1

          lda Equipment
          and #EquipBarrierSuit
          beq NoBarrier
          .if TV == SECAM
          lda #COLRED
          .else
          .ldacolu COLORANGE, $c
          .fi
          gne SuitColor
NoBarrier:
          .ldacolu COLGOLD, $c
SuitColor:
          sta COLUP0

          .ldacolu COLMAGENTA, $e
          sta COLUP1

          sta HMCLR

PrepareP0:
          lda PlayerX
          sec
          sta WSYNC
P0HPos:
          sbc # 15
          bcs P0HPos
          sta RESP0

          eor #$07
          asl a
          asl a
          asl a
          asl a
          sta HMP0

          lda MapFlags
          and #MapFlagFacing
          sta REFP0

PrepareMissile0:
          lda PlayerMissileX
          sec
          sta WSYNC
M0HPos:
          sbc # 15
          bcs M0HPos
          sta RESM0

          eor #$07
          asl a
          asl a
          asl a
          asl a
          sta HMM0

          ldx SpriteCount
          beq NoSprites

          stx CXCLR

          lda ScrollLeft
          lsr a                 ; ÷ 4 PF px per block
          lsr a
          sta Temp              ; Scroll Left in screen blocks
          ldx SpriteFlicker
          ldy SpriteCount       ; don't loop forever if you can't find one
          iny
NextFlickerCandidate:
          inx
          cpx SpriteCount
          blt FlickerOK
          ldx #0
FlickerOK:
          dey
          beq NoP1
FoundFlickerCandidate:
CheckVisibility:
          lda SpriteHP, x
          beq NextFlickerCandidate
          lda SpriteX, x
          lsr a                 ; ÷4 px per PF px
          lsr a
          lsr a                 ; ÷4 PF px per block
          lsr a
          clc
          adc SpriteXH, x       ; units are blocks
          cmp Temp
          blt NextFlickerCandidate
          pha
          lda Temp
          adc #11
          sta Temp
          pla
          cmp Temp
          bge NextFlickerCandidate

PreparePlayer1:
          ;; fix X to be screen-relative
          ;; XH / X is of the form
          ;; hhhh xxxx xxxx
          ;; ScrollLeft is of the form
          ;; 00ss ssss ss00
          ;; We're going to use Pointer as an additional 16-bit workspace
          lda SpriteXH, x
          lsr a
          lsr a
          lsr a
          lsr a
          sta Pointer + 1
          lda SpriteX, x
          sta Pointer
          ;; and we'll be evil and combine Temp and LineCounter to make a second 16-bit value
          lda # 0
          sta LineCounter
          lda ScrollLeft
          rol a
          rol LineCounter
          rol a
          rol LineCounter
          sta Temp
          ;; Now a 16-bit subtraction
          lda Pointer + 1
          sec
          sbc LineCounter
          bne NoP1
          lda Pointer
          sec
          sbc Temp
          bcc NoP1
          cmp #$40
          blt NoP1
          cmp #$40 + 160
          blt SetP1

NoP1:
          ldx #$ff
          stx WRITE + SpriteFlicker
          stx P1LineCounter
          lda # 15

SetP1:
          stx WRITE + SpriteFlicker
          sec
          sta WSYNC
P1HPos:
          sbc # 15
          bcs P1HPos
          sta RESP1

          eor #$07
          asl a
          asl a
          asl a
          asl a
          sta HMP1
          
SetUpSprites:
          ldx SpriteCount
          beq NoSprites
          ldx SpriteFlicker
          cpx #$ff
          beq NoSprites

          ldx SpriteFlicker
          lda #>MapSprites
          sta pp1h
          lda SpriteIndex, x
          .Mul 12, Temp
          clc
          adc #<MapSprites
          bcc +
          inc pp1h
+
          sta pp1l

          ;; TODO animation frames
          ;; TODO set REFP1 based on sprite facing direction
          ;; TODO maybe have wide monsters NUSIZDouble
          lda # NUSIZMissile2
          sta NUSIZ1

          lda SpriteY, x
          sta P1LineCounter

          jmp P1Ready

NoSprites:
          lda #$ff
          sta P1LineCounter

P1Ready:
          lda PlayerY
          ldy NextMap
          cpy CurrentMap
          beq +
          ;; new screen being loaded: player is off the screen
          lda #$ff
+
          sta P0LineCounter
          lda #0
          sta PF0
          sta PF1
          sta PF2

FindMissileFlicker:
          lda MissileFlicker
          clc
          adc # 1
          and #$03
          sta WRITE + MissileFlicker
          tax

PrepareMissile1:
          lda MonsterMissileX, x
          beq NoMissile1
          sec
          sta WSYNC
M1HPos:
          sbc # 15
          bcs M1HPos
          sta RESM1

          eor #$07
          asl a
          asl a
          asl a
          asl a
          sta HMM1

          lda MonsterMissileY, x
NoMissile1:
          ;; A will be zero if we branched here to skip M1 for this frame
          sta M1LineCounter

          lda PlayerMissileY
          sta M0LineCounter

          lda #>PlayerSprites
          sta pp0h

          ldy MovementStyle
          cpy #MoveWalk
          bne +
          lda LastActivity
          cmp #8
          bge +
          lda ClockFrame
          and #$08
          beq +
          ldy #MoveWalkStep
+
          tya
          .Mul 12, Temp
          clc
          adc #<PlayerSprites
          bcc +
          inc pp0h
+
          sta pp0l

TheEnd:
          stx WSYNC
          .SleepX 71
          stx HMOVE

          rts

TanksBits:
          .byte %00000000, %10000000, %10100000, %10101000, %10101010

TanksBitsReversed:
          .byte %00000000, %00000001, %00000101, %00010101, %01010101

TanksColors:
          .colu COLGOLD, $4
          .colu COLRED, $0
          .colu COLRED, $6
          .colu COLRED, $6
          .colu COLGOLD, $a

HPBits:
          .byte %10000000, %11000000, %11100000, %11110000
          .byte %11111000, %11111100, %11111110, %11111111

HPBitsReversed:
          .byte %00000001, %00000011, %00000111, %00001111
          .byte %00011111, %00111111, %01111111, %11111111

          .bend
