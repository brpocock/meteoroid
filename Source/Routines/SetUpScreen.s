;;; Meteoroid Source/Routines/SetUpScroon.s
;;; Copyright © 2021 Bruce-Robert Pocock

SetUpScreen: .block
          .WaitScreenTop

          lda # 0
          sta WRITE + SpriteFlicker
          sta WRITE + SpriteCount
          sta WRITE + DeltaX
          sta WRITE + DeltaY
          sta WRITE + PlayerXFraction
          sta WRITE + PlayerYFraction
          sta WRITE + MapFlags
          sta WRITE + CurrentMusic + 1

          lda #<BackgroundMusic
          sta CurrentMusic
          lda #>BackgroundMusic
          sta CurrentMusic + 1

          lda BlessedX
          sta WRITE + PlayerX
          lda BlessedY
          sta WRITE + PlayerY

          lda #MoveTeleport
          sta WRITE + MovementStyle

          lda # FramesPerSecond * 2
          sta WRITE + TeleportCountdown

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

          lda #<SpriteList
          sta MapSpritePointer
          lda #>SpriteList
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

          ldy # 0
          ldx # 0

          lda (MapSpritePointer), y
LoadNextSprite:
          sta WRITE + SpriteAction, x
          cmp #SpriteEquipment
          bne DefinitelyLoadSprite
          iny
          lda (MapSpritePointer), y
          bit Equipment
          beq LoadEquipmentSprite
          lda # 0
          geq LoadEquipmentSprite

DefinitelyLoadSprite:
          iny
          lda (MapSpritePointer), y
LoadEquipmentSprite:
          sta WRITE + SpriteHP, x
          iny
          lda (MapSpritePointer), y
          sta WRITE + SpriteX, x
          iny
          lda (MapSpritePointer), y
          sta WRITE + SpriteXH, x
          iny
          lda (MapSpritePointer), y
          sta WRITE + SpriteY, x
          iny
          lda (MapSpritePointer), y
          sta WRITE + SpriteIndex, x
          iny
          lda (MapSpritePointer), y
          sta WRITE + SpriteMotion, x
          iny

          inx
          lda (MapSpritePointer), y
          bne LoadNextSprite

          stx WRITE + SpriteCount

SpritesDone:
;;; 
          .FarJSR MapServicesBank, ServiceValidateMap
;;; 
          .WaitScreenBottom

          .WaitScreenTop
          lda #ModePlay
          sta WRITE + GameMode

          lda # 1
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames

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

;;; 
RotateIn40Pixels:
          ;; Rotate in 40 vertical pixel columns

          lda # 40
          sta LineCounter

RotateColumn:
          lda ScrollLeft
          adc LineCounter
          lsr a
          and #~$01
          clc
          adc # 15
          tay

          jsr ScrollBack

          dec LineCounter
          ldy LineCounter
          bpl RotateColumn

          jsr CombinePF0

          .WaitScreenBottom

          ;; fall through to Map
          .bend
