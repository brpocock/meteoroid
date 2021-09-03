;;; Meteoroid Source/Routines/ColdStart.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;; Cold start routines
;;;
;;; This routine is called once at startup, and must be in Bank 0.
;;;
;;; After a Game Over, this may be called again to return to the title
;;; screen with a full reset.
ColdStart:
	.block
          sei
          cld
          lda #ENABLED          ; turn off display, and
          sta VSYNC
          sta VBLANK
          ldy #0                ; clear sound so we don't squeak
          sty AUDC0
          sty AUDC1
          sty AUDV0             ; (I hear it's really bad squeaky on SECAM?)
          sty AUDV1

          sty SWACNT

          ;; only set inputs on the bits that we can actually read
          ;; AKA the “Combat flags trick”
          .if TV == SECAM
          lda # $ff - (SWCHBReset | SWCHBSelect | SWCHBP0Advanced | SWCHBP1Advanced)
          .else
          lda # $ff - (SWCHBReset | SWCHBSelect | SWCHBColor | SWCHBP0Advanced | SWCHBP1Advanced)
          .fi
          sta SWBCNT

ResetStack:
          ldx #$ff
          txs

          ;; Fall through to DetectConsole
	.bend
