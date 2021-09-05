;;; Meteoroid Source/Routines/ScreenTop.s
;;; Copyright © 2021 Bruce-Robert Pocock
TopOfScreenService: .block

          ;; MAGIC — these addresses must be  known and must be the same
	;; in every map bank.

          PlayerSprites = $f100
          MapSprites = PlayerSprites + 16

          .WaitScreenTopMinus 1, 1
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

          .ldacolu COLBLUE, $e
          sta COLUP0

          .ldacolu COLMAGENTA, $e
          sta COLUP1

          sta HMCLR

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
          stx SpriteFlicker

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
          lda #>MapSprites
          sta pp1h
          clc
          lda SpriteAction, x
          and #$07
          cmp # SpriteProvinceDoor
          bne +
          lda # SpriteDoor
+
          ldy AlarmFrames
          beq +
          ldy AlarmSeconds
          beq +
          cmp #SpriteMonster
          bne +
;; TODO          lda #SpriteMonsterPuff
+
          .rept 4
          asl a
          .next
          adc #<MapSprites
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

          lda PlayerY
          clc
          adc # 8
          sta M0LineCounter

          lda #$ff
          sta M1LineCounter

          lda #>PlayerSprites
          sta pp0h
          lda #<PlayerSprites
          sta pp0l

          lda DeltaX
          ora DeltaY
          beq +        ; always show frame 0 unless moving
          lda ClockFrame
          and #$10
          bne +
          ldx #SoundFootstep
          stx NextSound
+
          clc
          adc #<PlayerSprites
          bcc +
          inc pp0h
+
          sta pp0l

TheEnd:
          lda # 0
          sta VBLANK

PrepareTanksToDraw:
          ldx # 6
          lda # 0
-
          sta PixelPointers - 1, x
          dex
          bne -
          lda #%10101010
          ldy # 0
          ldx CurrentTanks

TanksByte:          .macro i, width, offset
          cpx # \offset + \width
          blt EndTanks
          sta PixelPointers + \i - 1
          iny
          .endm

          .TanksByte 1, 2, 0
          .TanksByte 2, 4, 2
          .TanksByte 3, 4, 6
          .TanksByte 4, 2, 10
          .TanksByte 5, 4, 12

EndTanks:
          txa
          and #$03
          tax
          beq DoneTanks
          lda TanksBits, x
          sta PixelPointers, y
DoneTanks:

          stx WSYNC
          ldy # 4
DrawTanks:
          stx WSYNC
          lda TanksColors, y
          sta COLUPF
          lda PixelPointers
          sta PF0
          lda PixelPointers + 1
          sta PF1
          lda PixelPointers + 2
          sta PF2
          .Sleep 20
          lda PixelPointers + 3
          sta PF0
          lda PixelPointers + 4
          sta PF1
          lda PixelPointers + 5
          sta PF2
          dey
          bne DrawTanks

          .SkipLines 3

          lda # 0
          sta PF0
          sta PixelPointers
          sta PixelPointers + 1

          lda CurrentHP
          cmp # 48
          blt ZeroPF2
          sec
          sbc # 48
          .Div 6, Temp
          tax
          lda HPBits, x
          sta PixelPointers + 1
ZeroPF2:

          lda CurrentHP
          cmp # 48
          bge FullPF1
          .Div 6, Temp
          tax
          lda HPBitsReversed, x
          sta PixelPointers
          jmp DrawHP

FullPF1:
          lda #$ff
          sta PixelPointers

DrawHP:
          ldy # 4
DrawHPLoop:
          stx WSYNC
          lda PixelPointers
          sta PF1
          lda PixelPointers + 1
          sta PF2
          .SleepX 30

          lda # 0
          sta PF1
          sta PF2
          
          dey
          bne DrawHPLoop

          .SkipLines 3

          rts

TanksBits:
          .byte %00000000, %10000000, %10100000, %10101000

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
