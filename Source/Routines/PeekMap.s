;;; Meteoroid Source/Routines/PeekMap.s
;;; Copyright © 2021 Bruce-Robert Pocock

PeekMap:  .block
          ;; Input coördinates in X and Y registers
          ;; already Y ÷ 4 and X ÷ 16 to get block position
          txa
          asl a                 ; X × 2 (bytes per column)
          clc
          adc # 15              ; skip header (3) and colors (12)
          sta Temp              ; working idea of index

          tya                   ; examine Y row

          ldy Temp              ; index into map data of first byte
          cmp # 8               ; first or second byte?
          blt +
          iny
+
          ;; A has the Y value in rows
          and #$07              ; get the bit index
          eor #$07              ; invert it for map's orientation
          tax
          lda BitMask, x
          and (MapPointer), y   ; Returns zero or non-zero
          rts
          .bend

;;; 

GetPlayerFootPosition:
          lda PlayerY
          and #~$03             ; 4 sprite lines per row
          lsr a
          lsr a
          tay
          lda PlayerX
          sec
          sbc #HBlankWidth
          lsr a                 ; convert to playfield pixels
          lsr a
          clc
          adc ScrollLeft
          lsr a                 ; convert to background blocks
          lsr a
          tax
          rts

GetSpriteFootPosition:
          lda PlayerY - 1, x
          and #~$03
          lsr a
          lsr a
          tay
          lda PlayerX - 1, x
          lsr a                 ; convert to playfield pixels
          lsr a
          lsr a                 ; convert to background blocks
          lsr a
          sec
          sbc #HBlankWidth
          sta Temp
          lda SpriteXH - 2, x
          and #$f0
          ora Temp
          tax
          rts

