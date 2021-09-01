;;; -*- asm -*-
;;;
;;; Meteoroid
;;;
;;; Copyright © 2021, Bruce-Robert Pocock <brpocock@star-hope.org>
;;;
;;; Most rights reserved. (See COPYING for details.)
;;;

;;; Start of each ROM bank

          .weak
          DEMO := false
          PUBLISHER := false
          TV := NTSC
          NOSAVE := false
          .endweak

          .weak
          .if DEMO
          STARTER := 1          ; Start with Aquax in the demo
          .else
          STARTER := 0          ; Should come from build command-line
          .fi
          .endweak

          .enc "Unicode"
          .cdef $00, $1ffff, 0

	.include "Math.s"
	.include "VCS.s"
	.include "Enums.s"
	.include "ZeroPage.s"
	.include "VCS-Consts.s"
	.include "Macros.s"

	* = $f000
	.offs -$f000

          .enc "Unicode"
RAMRead:
          .fill 128, "Meteoroid, © 2021 Bruce-Robert Pocock. EFSC RAM goes here."
RAMWrite:
          .fill 128, "Meteoroid, © 2021 Bruce-Robert Pocock. EFSC RAM goes here."

          .enc "none"
          
