;;; Meteoroid Source/Routines/Doors.s
;;; Copyright © 2021 Bruce-Robert Pocock

Doors:    .block

          lda ClockFrame
          and #$03
          bne Return

          lda DoorMode
          ldx DoorDirection

          cmp #DoorScrollToEnd
          beq ScrollToEnd
          cmp #DoorDestroyBlocks
          beq DestroyBlocks

Return:
          rts

;;; 
ScrollToEnd:
          lda ScrollLeft
          cpx #-1
          bne ScrollingToRight
          ;; has to happen on main screen routine
          ;; since we don't know how far right to go

ScrollToLeft:
          cmp # 0
          bne KeepScrollingLeft
DoneScrollingToDoor:
          sta WRITE + DoorColumns
          lda #DoorDestroyBlocks
          sta WRITE + DoorMode
ScrollingToRight:
          rts

;;; 
DestroyBlocks:
          cpx #-1
          beq DestroyLeftBlocks

DestroyRightBlocks:
          lda # 7
          sec
          sbc DoorColumns
          tax
          lda BitMask, x
          eor #$ff
          sta Temp
          ldx DoorYPosition
          lda BackgroundPF2R, x
          and Temp
          sta BackgroundPF2R, x
          inx
          lda BackgroundPF2R, x
          and Temp
          sta BackgroundPF2R, x
          inx
          lda BackgroundPF2R, x
          and Temp
          sta BackgroundPF2R, x
          
NextBlocksToDestroy:
          lda DoorColumns
          cmp # 8
          blt DestroyMoreBlocks
          lda # 0
          sta WRITE + DoorColumns
          sta WRITE + DoorMode

          rts

DestroyLeftBlocks:
          ldx DoorColumns
          lda BitMask, x
          eor #$ff
          sta Temp
          ldx DoorYPosition
          lda BackgroundPF0, x
          and Temp
          sta BackgroundPF0, x
          inx
          lda BackgroundPF0, x
          and Temp
          sta BackgroundPF0, x
          inx
          lda BackgroundPF0, x
          and Temp
          sta BackgroundPF0, x

          jmp NextBlocksToDestroy

DestroyMoreBlocks:
          clc
          adc # 1
          sta WRITE + DoorColumns

          rts
;;; 

          
KeepScrollingLeft:
          sec
          sbc # 1
          sta ScrollLeft
          rts

;;; 
          .bend
