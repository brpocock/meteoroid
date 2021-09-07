;;; Meteoroid Source/Routines/ScreenTop.s
;;; Copyright © 2021 Bruce-Robert Pocock

          ;; MAGIC — these addresses must be  known and must be the same
	;; in every map bank.

          PlayerSprites = $f100
          MonsterSprites = $f200
TopOfScreenService: .block

          jsr Overscan
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
          .SleepX 35

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

          .ldacolu COLGOLD, $c
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
          ldx SpriteFlicker
          ldy # 9
NextFlickerCandidate:
          inx
          cpx SpriteCount
          blt FlickerOK
          ldx #0
FlickerOK:
          dey
          beq SetUpSprites
          stx WRITE + SpriteFlicker

PreparePlayer1:
          lda SpriteX, x
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

FindMissileFlicker:
          lda MissileFlicker
          clc
          adc # 1
          and #$03
          sta WRITE + MissileFlicker
          tax

PrepareMissile1:
          lda MonsterMissileX, x
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

SetUpSprites:
          ldx SpriteCount
          beq NoSprites

          ldx SpriteFlicker
          lda SpriteAction, x
          and #$07
          cmp # SpriteProvinceDoor
          bne +
          lda # SpriteDoor
+

          ldx SpriteFlicker
          lda #>MonsterSprites
          sta pp1h
          clc
          lda SpriteIndex, x
          and #$07
          .rept 4
          asl a
          .next
          adc #<MonsterSprites
          bcc +
          inc pp1h
+
          sta pp1l

          ;; FIXME use sprite motion to set facing directions
          lda SpriteAction, x
          cmp #SpriteMonster
          bne FindAnimationFrame

Flippy:
          lda ClockFrame
          .BitBit $20
          bne NoFlip
          lda # 0
          sta REFP1
          geq FindAnimationFrame

NoFlip:
          lda # REFLECTED
          sta REFP1

FindAnimationFrame:
          lda ClockFrame
          .BitBit $10
          bne AnimationFrameReady

          lda pp1l
          clc
          adc # 8
          bcc +
          inc pp1h
+
          sta pp1l

AnimationFrameReady:
          ldx SpriteFlicker
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

          lda PlayerMissileY
          sta M0LineCounter

          lda #$ff              ; TODO
          sta M1LineCounter

          lda #>PlayerSprites
          sta pp0h

          lda MovementStyle
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
