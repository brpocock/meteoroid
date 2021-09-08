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

          ;; TODO real sprite list loading code
          ;; XXX for now just set up a bogus sprite to test against

          lda #SpriteEquipment
          sta WRITE + SpriteAction
          lda # 0
          sta WRITE + SpriteXH
          lda # 8 * 4 + HBlankWidth
          sta WRITE + SpriteX
          lda # 8 * 4
          sta WRITE + SpriteY
          lda # 0
          sta WRITE + SpriteIndex

          lda # 1
          sta WRITE + SpriteCount

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

SetMapPointerIndex:
          ;; Y register contains the offset of the vertical span into the MapPointer table.
          lda ScrollLeft
          lsr a
          and #$7e
          clc
          adc # 15              ; skip row, offset, and run length, and color data
          tay

;;; 
RotateIn40Pixels:
          ;; Rotate in 40 vertical pixel columns

          ldy # 0
          sty LineCounter
Rot40:
          lda ScrollLeft
          clc
          adc LineCounter
          lsr a                 ; } equivalent to ÷4 then ×2
          and #~$01             ; }
          clc
          adc # 3 + 12
          tay

          jsr ScrollRight

          inc LineCounter
          ldy LineCounter
          cpy # 40
          blt Rot40

          jsr CombinePF0

          .WaitScreenBottom

          ;; fall through to Map
          .bend
