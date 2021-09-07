;;; Meteoroid Source/Routines/ScrollRight.s
;;; Copyright © 2021 Bruce-Robert Pocock

ScrollRight:        .block

RotatePixels:       .macro
          ;; Rotate in one pixel at the right of a row, shifting everything else left.
          rol Temp
          ror BackgroundPF2R, x
          rol BackgroundPF1R, x
          ror PixelPointers, x
          lda PixelPointers, x
          clc
          and #$0f
          beq +
          sec
+
          ror BackgroundPF2L, x
          rol BackgroundPF1L, x
          ror BackgroundPF0, x
          lda BackgroundPF0, x
          clc
          and #$0f
          beq +
          sec
+
          .endm
;;; 

Rot12:
          ;; Rotate in 12 pixels at the right of the screen
          ldx # 0
          ;; Rotate in the 8 pixels from the first map data byte
          lda (MapPointer), y
          sta Temp
Rot8:
          .RotatePixels
          inx
          cpx # 8
          blt Rot8

          ;; Rotate in the 4 pixels from the second map data byte
          iny
          lda (MapPointer), y
          sta Temp
Rot4:
          .RotatePixels
          inx
          cpx # 12
          blt Rot4

          rts

          .bend
;;; 

ScrollBack:        .block

RotatePixelsBack:       .macro
          ;; Rotate in one pixel at the left of a row, shifting everything else right.
          rol Temp
          rol BackgroundPF0, x
          lda #$01
          and BackgroundPF0, x
          beq +
          lda BackgroundPF0, x
          ora #$10
          and #$f0
          sta BackgroundPF0, x
+
          ror BackgroundPF1L, x
          rol BackgroundPF2L, x
          rol PixelPointers, x
          lda #$01
          and PixelPointers, x
          beq +
          lda PixelPointers, x
          ora #$10
          and #$f0
          sta PixelPointers, x
+
          ror BackgroundPF1R, x
          rol BackgroundPF2R, x
          .endm

;;; 

Rot12:
          ;; Rotate in 12 pixels at the left of the screen
          ldx # 0
          ;; Rotate in the 8 pixels from the first map data byte
          lda (MapPointer), y
          sta Temp
Rot8:
          .RotatePixelsBack
          inx
          cpx # 8
          blt Rot8

          ;; Rotate in the 4 pixels from the second map data byte
          iny
          lda (MapPointer), y
          sta Temp
Rot4:
          .RotatePixelsBack
          inx
          cpx # 12
          blt Rot4
          
          rts

          .bend
          
;;; 
CombinePF0:         .block
          ;; For each row, combine the PF0 values into one RAM byte
          ldx # 12
CombinePF0Loop:
          lda BackgroundPF0 - 1, x
          and #$f0
          sta BackgroundPF0 - 1, x
          lda PixelPointers - 1, x
          lsr a
          lsr a
          lsr a
          lsr a
          ora BackgroundPF0 - 1, x
          sta BackgroundPF0 - 1, x
          dex
          bne CombinePF0Loop

          rts
          
          .bend
;;; 
UncombinePF0:       .block

          ldx # 12
UncombinePF0Loop:
          lda BackgroundPF0 - 1, x
          tay
          and #$f0
          sta BackgroundPF0 - 1, x
          tya
          and #$0f
          asl a
          asl a
          asl a
          asl a
          sta PixelPointers - 1, x
          dex
          bne UncombinePF0Loop

          rts

          .bend
          
