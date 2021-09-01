;;; Meteoroid Source/Banks/Bank04/OverworldMaps.s
;;; Copyright © 2021 Bruce-Robert Pocock

          ;; How many maps are in these tables?
MapCount = 61

;;; Foreground and background colors
;;; Remember SECAM and don't make these too similar

MapColors:
          ;; 0
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          ;; 10
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          ;; 20
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          ;; 30
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          ;; 40
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          ;; 50
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN
          ;; 60
          .colors COLYELLOW, COLBROWN
          .colors COLYELLOW, COLBROWN

;;; Links up, down, left, right are map indices in this bank
MapLinks:
          .byte $ff, $ff, 1, $ff
          .byte 18, $ff, 14, 0
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          ;; 5
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          ;; 10
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte 19, $ff, 15, 1
          ;; 15
          .byte 20, $ff, 16, 14
          .byte 21, $ff, 17, 15
          .byte 22, $ff, $ff, 16
          .byte 24, 1, 19, $ff
          .byte 25, 17, 20, 18
          ;; 20
          .byte 26, 15, 21, 19
          .byte 27, 16, 22, 20
          .byte 28, 17, 23, 21
          .byte 29, $ff, $ff, 22
          .byte 30, 18, 25, $ff
          ;; 25
          .byte 31, 19, 26, 24
          .byte 32, 20, 27, 25
          .byte 33, 21, 28, 26
          .byte 34, 22, 29, 27
          .byte $ff, 23, $ff, 28
          ;; 30
          .byte 35, 24, 31, $ff
          .byte 36, 25, 32, 30
          .byte 37, 26, 27, 25
          .byte 38, 27, 34, 32
          .byte 39, 28, $ff, 33
          ;; 35
          .byte 40, 30, 36, $ff
          .byte 41, 31, 37, 35
          .byte 42, 32, 38, 36
          .byte 43, 33, 39, 37
          .byte $ff, 34, $44, 33
          ;; 40
          .byte 44, 30, 36, $ff
          .byte 45, 36, 42, 40
          .byte 46, 37, 43, 41
          .byte 47, 38, $ff, 42
          .byte $ff, 40, 45, $ff
          ;; 45
          .byte 48, 41, 46, 44
          .byte 49, 42, 47, 45
          .byte 50, 43, $ff, 46
          .byte 51, 45, 49, $ff
          .byte 52, 46, 50, 48
          ;; 50
          .byte 53, 47, $ff, 49
          .byte $ff, 48, 52, $ff
          .byte $ff, 49, 53, 51
          .byte $ff, 50, $ff, 52
          .byte $ff, $ff, $ff, $ff
          ;; 55
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff
          ;; 60
          .byte $ff, $ff, $ff, $ff
          .byte $ff, $ff, $ff, $ff

;;; RLE Map data for each screen.

;;; Note that it can be reused, so the same basic layout, potentially
;;; in different colors, can appear in several places.
          MapRLE = (
          ;; 0
          Map_SouthDock,
          Map_SouthShoreCorner,
          Map_FourWay,
          Map_FourWay,
          Map_FourWay,
          ;; 5
          Map_FourWay,
          Map_FourWay,
          Map_FourWay,
          Map_FourWay,
          Map_FourWay,
          ;; 10
          Map_FourWay,
          Map_FourWay,
          Map_FourWay,
          Map_FourWay,
          Map_SouthShore,
          ;; 15
          Map_SouthShore,
          Map_SouthShore,
          Map_SouthShore,
          Map_NorthGate,
          Map_NorthWall,
          ;; 20
          Map_NorthWall,
          Map_NorthGate,
          Map_NorthWall,
          Map_NorthWall,
          Map_FourWay,
          ;; 25
          Map_EWPassage,
          Map_EWPassage,
          Map_FourWay,
          Map_EWLarge,
          Map_EWLarge,
          ;; 30
          Map_HouseSouthWall,
          Map_HouseSouthWall,
          Map_HouseSouthWall,
          Map_HouseSouthGate,
          Map_SouthWallCorners,
          ;; 35
          Map_House,
          Map_House,
          Map_House,
          Map_House,
          Map_NorthWallCorners,
          ;; 40
          Map_NorthWallCorners,
          Map_NorthWallCorners,
          Map_NorthGateCorners,
          Map_NorthWallCorners,
          Map_EWLarge,
          ;; 45
          Map_EWPassage,
          Map_FourWay,
          Map_EWLarge,
          Map_SouthWall,
          Map_SouthGate,
          ;; 50
          Map_SouthWall,
          Map_NorthShore,
          Map_NorthShore,
          Map_NorthShore,
          Map_InHouse,
          ;; 55
          Map_InHouse,
          Map_InHouse,
          Map_InHouse,
          Map_InHouse,
          Map_InHouse,
          ;; 60
          Map_InHouse
          )

MapRLEL:  .byte <MapRLE
MapRLEH:  .byte >MapRLE

;;; Maps can have left or right sides added by the Ball
;;;
;;; This lets the exits be asymmetrical, even though the playfield is in
;;; reflected mode
;;; $80 = left, $40 = right ball.
MapSides:
          .byte $40, 0, 0, 0, 0
          .byte 0, 0, 0, 0, 0
          ;; 10
          .byte 0, 0, 0, 0, 0
          .byte 0, 0, $80, $40, 0
          ;; 20
          .byte 0, 0, $80, 0, $40
          .byte 0, 0, 0, 0, $80
          ;; 30
          .byte $40, 0, 0, 0, $80
          .byte $40, 0, 0, 0, $80
          ;; 40
          .byte $40, 0, 0, $80, $40
          .byte 0, 0, $80, $40, 0
          ;; 50
          .byte $80, $40, 0, $80, 0
          .byte 0, 0, 0, 0, 0
          ;; 60
          .byte 0, 0

;;; The Sprites Lists
;;;
;;; Each screen can have a list of sprites here, ending with a zero
;;; byte. Each sprite is a 5-byte structure, with its type, X, Y,
;;; action, and action-parameter listed.
;;;
;;; A fixed sprite appears at the given position and stays there.
;;; Moving sprites wander the screen, obeying walls.
;;; Random encounters occupy a sprite data slot but are not actually
;;; visible on the screen.
SpriteList:
          ;; Room 0
          .byte 0

          ;; Room 1
          .byte 0

          ;; Room 2
          .byte 0

          ;; Room 3
          .byte 0

          ;; Room 4
          .byte 0

          ;; Room 5
          .byte 0

          ;; Room 6
          .byte 0

          ;; Room 7
          .byte 0

          ;; Room 8
          .byte 0

          ;; Room 9
          .byte 0

          ;; Room 10
          .byte 0

          ;; Room 11
          .byte 0

          ;; Room 12
          .byte 0

          ;; Room 13
          .byte 0

	;;Room 14
	.byte 0

	;;Room 15
	.byte 0

	;;Room 16
	.byte 0

	;;Room 17
	.byte 0

	;;Room 18
	.byte 0

	;;Room 19
	.byte 0

	;;Room 20
	.byte 0

	;;Room 21
	.byte 0

	;;Room 22
	.byte 0

	;;Room 23
	.byte 0

	;;Room 24
	.byte 0

	;;Room 25
	.byte 0

	;;Room 26
	.byte 0

	;;Room 27
	.byte 0

	;;Room 28
	.byte 0

	;;Room 29
	.byte 0

	;;Room 30
	.byte 0

	;;Room 31
	.byte 0

	;;Room 32
	.byte 0

	;;Room 33
	.byte 0

	;;Room 34
	.byte 0

	;;Room 35
	.byte 0

	;;Room 36
	.byte 0

	;;Room 37
	.byte 0

	;;Room 38
	.byte 0

	;;Room 39
	.byte 0

	;;Room 40
	.byte 0

	;;Room 41
	.byte 0

	;;Room 42
	.byte 0

	;;Room 43
	.byte 0

	;;Room 44
	.byte 0

	;;Room 45
	.byte 0

	;;Room 46
	.byte 0

          ;; Room 47
          .byte 0

          ;; Room 48
          .byte 0

          ;; Room 49
          .byte 0

          ;; Room 50
          .byte 0

          ;; Room 51
          .byte 0

          ;; Room 52
          .byte 0

          ;; Room 53
          .byte 0

          ;; Room 54
          .byte 0

          ;; Room 55
          .byte 0

          ;; Room 56
          .byte 0

          ;; Room 57
          .byte 0

          ;; Room 58
          .byte 0

          ;; Room 59
          .byte 0

          ;; Room 60
          .byte 0

          ;; Room 61
          .byte 0
          .fill 200
