;;; Meteoroid Source/Routines/SetUpScroon.s
;;; Copyright © 2021 Bruce-Robert Pocock

SetUpScreen: .block
          .WaitScreenTopMinus 2, -1

          lda # 0
          sta SpriteFlicker
          sta SpriteCount
          sta DeltaX
          sta DeltaY
          sta PlayerXFraction
          sta PlayerYFraction
          sta MapFlags
          sta CurrentMusic + 1

          lda BlessedX
          sta PlayerX
          lda BlessedY
          sta PlayerY
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
          sta MapPointer + WRITE + 1
          lda #<MapData
          sta MapPointer + WRITE

          ldx CurrentMap
          beq FoundMapData

          ldy # 2
LookForMapData:
          lda (MapPointer), y
          clc
          adc MapPointer
          bcc +
          inc MapPointer + WRITE + 1
+
          sta MapPointer + WRITE

          dex
          bne LookForMapData

FoundMapData:
          ldy # 0

          lda #>SpriteList
          sta MapSpritePointer + WRITE
          lda #<SpriteList
          sta MapSpritePointer + WRITE + 1

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
          inc MapSpritePointer + WRITE + 1
+
          sta MapSpritePointer + WRITE

          ldy # 0
          dex
          bne LookForSpriteList

FoundSpriteList:


          ;; Skipping over a room means searching for the end of the list
SkipRoom:
          lda (Pointer), y         ; .y = 0
          ;; End of list? Then one room down, .x more to go
          beq SkipRoomDone
          ;; Not end of list, so we have to skip 6 bytes
          lda Pointer
          clc
          adc # 6
          bcc +
          inc Pointer + 1
+
          sta Pointer
          ;; Then keep going, look for end of the room's list
          jmp SkipRoom

SkipRoomDone:
          ;; We've reached the end of one room
          dex
          ;; Are we done? Then the next entry is this room
          beq FoundSprites
          ;; Not done yet — skip a/more room[s]
          lda Pointer
          clc
          adc # 1
          bcc +
          inc Pointer + 1
+
          sta Pointer
          jmp SkipRoom

          ;; OK, we found "our" sprite list head at (Pointer) + 1
FoundSprites:
          lda Pointer
          clc
          adc #1
          bcc +
          inc Pointer + 1
+
          sta Pointer

DoneFinding:
          ;; Start with 0 sprites
          ;; There can be up to 4
          ;;; ldx # 0                ; this is already the case
          stx SpriteCount
          stx SpriteFlicker

SetUpSprite:
          ;; .y varies from 0 to max 25 when all 4 sprites are used
          lda (Pointer), y         ; .y = .x × 6 + 0
          ;; End of sprite list?
          beq SpritesDone
          iny
          sty Temp
          sta SpriteIndex, x
          cmp #$ff
          beq SpritePresentAndYSet

          tay                   ; has the combat been conquered?
          and #$38
          lsr a
          lsr a
          lsr a
          stx SpriteCount
          tax
          tya
          and #$07
          tay

          lda ProvinceFlags, x
          ldx SpriteCount
          and BitMask, y
          beq SpritePresent
          ;; fall through
SpriteAbsent:
          lda Temp
          clc
          adc # 5               ; already been incremented once
          tay
          gne SetUpSprite

MoreSprites:
          sta SpriteMotion, x
          iny
          inc SpriteCount
          inx
          gne SetUpSprite

SpritePresent:
          ldy Temp
SpritePresentAndYSet:
          lda (Pointer), y
          cmp #SpriteFixed
          beq AddFixedSprite
          cmp #SpriteWander
          beq AddWanderingSprite
          ;; fall through
AddRandomEncounter:
          iny
          lda (Pointer), y
          sta SpriteX, x
          iny
          lda (Pointer), y
          ora #$80              ; ensure position off screen
          sta SpriteY, x
          iny
          lda (Pointer), y
          sta SpriteAction, x
          iny
          lda (Pointer), y         ; .y = .x × 6 + 5
          sta SpriteParam, x
          lda # SpriteRandomEncounter
          gne MoreSprites

AddFixedSprite:
          jsr AddPlacedSprite
          lda # 0
          ;; .y = .x⁺¹ × 6   (start of next entry)
          ;; Go back looking for more sprites
          geq MoreSprites

AddWanderingSprite:
          jsr AddPlacedSprite
          lda # SpriteMoveIdle
          ;; .y = .x⁺¹ × 6   (start of next entry)
          ;; Go back looking for more sprites
          gne MoreSprites

AddPlacedSprite:
          iny
          lda (Pointer), y         ; .y = .x × 6 + 2
          sta SpriteX, x
          iny
          lda (Pointer), y         ; .y = .x × 6 + 3
          sta SpriteY, x
          iny
          lda (Pointer), y         ; .y = .x × 6 + 4
          sta SpriteAction, x
          iny
          lda (Pointer), y         ; .y = .x × 6 + 5
          sta SpriteParam, x
          rts

SpritesDone:
;;; 
          .FarJSR MapServicesBank, ServiceValidateMap
;;; 
          .WaitScreenBottom

          lda #ModePlay
          sta GameMode

          lda # 1
          sta AlarmSeconds
          lda # 0
          sta AlarmFrames

          ;; fall through to Map
          .bend
