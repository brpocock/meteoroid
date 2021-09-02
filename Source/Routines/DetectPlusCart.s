;;; Meteoroid Source/Routines/DetectPlusCart.s
;;; Copyright © 2021 Bruce-Robert Pocock

DetectPlusCart:     .block

          lda PlusReadRemaining
          bne +

          lda SWCHB
          ora #SWCHBPlusCart
          sta SWCHB

+
          .bend
          ;; fall through to next cold start routine
