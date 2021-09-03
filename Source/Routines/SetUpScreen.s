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

          ;; Rotate in the first screen 4 pixels at a time

          lda # 10
          sta LineCounter
Rot12:
          ldx # 0
          lda (MapPointer), y
Rot8:
          rol a
          asl PixelPointers + 0, x
          asl PixelPointers + 0, x
          asl PixelPointers + 0, x
          rol PixelPointers + 0, x
          rol BackgroundPF1R, x
          asl BackgroundPF1R, x
          asl BackgroundPF1R, x
          asl BackgroundPF1R, x
          rol BackgroundPF2R, x
          asl BackgroundPF2R, x
          asl BackgroundPF2R, x
          asl BackgroundPF2R, x
          rol BackgroundPF2L, x
          asl BackgroundPF2L, x
          asl BackgroundPF2L, x
          asl BackgroundPF2L, x
          rol BackgroundPF1L, x
          asl BackgroundPF1L, x
          asl BackgroundPF1L, x
          asl BackgroundPF1L, x
          rol BackgroundPF0, x
          asl BackgroundPF0, x
          asl BackgroundPF0, x
          asl BackgroundPF0, x
          inx
          cpx # 8
          blt Rot8
          iny
          lda (MapPointer), y
Rot4:
          rol a
          asl PixelPointers + 0, x
          asl PixelPointers + 0, x
          asl PixelPointers + 0, x
          rol PixelPointers + 0, x
          ror BackgroundPF1R, x
          lsr BackgroundPF1R, x
          lsr BackgroundPF1R, x
          lsr BackgroundPF1R, x
          rol BackgroundPF2R, x
          asl BackgroundPF2R, x
          asl BackgroundPF2R, x
          asl BackgroundPF2R, x
          rol BackgroundPF0, x
          asl BackgroundPF0, x
          asl BackgroundPF0, x
          asl BackgroundPF0, x
          ror BackgroundPF1L, x
          lsr BackgroundPF1L, x
          lsr BackgroundPF1L, x
          lsr BackgroundPF1L, x
          rol BackgroundPF2L, x
          asl BackgroundPF2L, x
          asl BackgroundPF2L, x
          asl BackgroundPF2L, x
          inx
          cpx # 12
          blt Rot4
          dec LineCounter
          ldx LineCounter
          bne Rot12

          ;; fall through to Map
          .bend
