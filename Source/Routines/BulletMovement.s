;;; Meteoroid Source/Routines/BulletMovement.s
;;; Copyright © 2021 Bruce-Robert Pocock

BulletMovement:     .block

          ldx PlayerMissileX
          inx
          stx WRITE + PlayerMissileX

          rts

          .bend
