;;; Meteoroid Source/Routines/SetUpScroon.s
;;; Copyright © 2021 Bruce-Robert Pocock

SetUpScreen: .block
          .WaitScreenTopMinus 2, -1

          lda # 0
          sta WRITE + SpriteFlicker
          sta WRITE + SpriteCount
          sta WRITE + DeltaX
          sta WRITE + DeltaY
          sta WRITE + PlayerXFraction
          sta WRITE + PlayerYFraction
          sta WRITE + MapFlags
          sta WRITE + CurrentMusic + 1

          lda BlessedX
          sta WRITE + PlayerX
          lda BlessedY
          sta WRITE + PlayerY
          jmp NewRoomTimerRunning
;;; 
NewRoom:
          .WaitForTimer
          stx WSYNC
          .if TV == NTSC
          stx WSYNC
          .fi

          jsr Overscan

          .WaitScreenTopMinus 2, -1

NewRoomTimerRunning:

          lda CurrentProvince

          cmp #PROVINCE

          beq +
          .WaitScreenBottom
          jmp GoPlay
+
          lda NextMap
          sta CurrentMap

SearchForMap:
          lda #>MapData
          sta MapPointer + 1
          lda #<MapData
          sta MapPointer

          ldx CurrentMap
          beq FoundMapData

          ldy # 2
LookForMapData:
          lda (MapPointer), y
          clc
          adc MapPointer
          bcc +
          inc MapPointer + 1
+
          sta MapPointer

          dex
          bne LookForMapData

FoundMapData:
          ldy # 0

          lda #>SpriteList
          sta MapSpritePointer
          lda #<SpriteList
          sta MapSpritePointer + 1

          ldx CurrentMap
          beq FoundSpriteList

LookForSpriteList:
          lda (MapSpritePointer), y
          beq EndOfASpriteList

          lda y
          clc
          adc # 8
          ldy a

          gne LookForSpriteList

EndOfASpriteList:
          lda y
          clc
          adc MapSpritePointer
          bcc +
          inc MapSpritePointer + 1
+
          sta MapSpritePointer

          ldy # 0
          dex
          bne LookForSpriteList

FoundSpriteList:

SpritesDone:
;;; 
          .FarJSR MapServicesBank, ServiceValidateMap
;;; 
          .WaitScreenBottom

          lda #ModePlay
          sta WRITE + GameMode

          lda # 1
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames

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
          sta Background - 1, x
          dex
          bne -

          ldx # 6
-
          sta PixelPointers - 1, x
          dex
          bne -

          ;; Y register contains the offset of the vertical span into the MapPointer table.

;;; 
RotatePixels:       .macro
          ;; Rotate in one pixel at the right of a row, shifting everything else left.
          rol Temp
          ror BackgroundPF2R, x
          rol BackgroundPF1R, x
          bcc +
          lda PixelPointers, x
          ora #$08
          sta PixelPointers, x
          clc
+
          rol PixelPointers, x
          ror BackgroundPF2L, x
          rol BackgroundPF1L, x
          bcc +
          lda BackgroundPF0, x
          ora #$08
          sta BackgroundPF0, x
+
          rol BackgroundPF0, x
          inx
          .endm
;;;

          ;; Rotate in 10 vertical columns
          lda # 10
          sta LineCounter
RotateTimes4:
          ;; For each column, rotate it in 4 times
          lda # 4
          sta P0LineCounter
Rot12:
          ;; Rotate in 12 pixels at the right of the screen
          ldx # 0
          ;; Rotate in the 8 pixels from the first map data byte
          lda (MapPointer), y
          sta Temp
Rot8:
          .RotatePixels
          cpx # 8
          blt Rot8
          ;; Rotate in the 4 pixels from the second map data byte
          iny
          lda (MapPointer), y
          sta Temp
Rot4:
          .RotatePixels
          cpx # 12
          blt Rot4
          ;; return to the upper byte, and
          dey
          ;; repeat each column of 12 pixels, 4 times
          dec P0LineCounter
          ldx P0LineCounter
          bne Rot12
          ;; then move to the next column
          dec LineCounter
          iny
          iny
          ldx LineCounter
          bne RotateTimes4
;;; 
          ;; For each row, combine the PF0 values into one RAM byte
          ldx # 12
CombinePF0:
          lda BackgroundPF0, x
          and #$f0
          sta BackgroundPF0, x
          lda PixelPointers, x
          lsr a
          lsr a
          lsr a
          lsr a
          and #$0f              ; XXX unnecessary?
          ora BackgroundPF0, x
          sta BackgroundPF0, x
          dex
          bne CombinePF0

          ;; fall through to Map
          .bend
