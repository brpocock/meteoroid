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

          ldx # ( KernelLines - ( 12 * 13 ) ) / 3
-
          stx WSYNC
          dex
          bne -

          lda # 0
          sta VBLANK
          rts

          .bend
