;;; Meteoroid Source/Common/48Pixels.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;; Macros for setting up 48px graphics and text


SetUpFortyEight:          .macro Graphics
          lda #<(\Graphics + \Graphics.Height * 0 - 1)
          sta PixelPointers + 0
          lda #>(\Graphics + \Graphics.Height * 0 - 1)
          sta PixelPointers + 1
          lda #<(\Graphics + \Graphics.Height * 1 - 1)
          sta PixelPointers + 2
          lda #>(\Graphics + \Graphics.Height * 1 - 1)
          sta PixelPointers + 3
          lda #<(\Graphics + \Graphics.Height * 2 - 1)
          sta PixelPointers + 4
          lda #>(\Graphics + \Graphics.Height * 2 - 1)
          sta PixelPointers + 5
          lda #<(\Graphics + \Graphics.Height * 3 - 1)
          sta PixelPointers + 6
          lda #>(\Graphics + \Graphics.Height * 3 - 1)
          sta PixelPointers + 7
          lda #<(\Graphics + \Graphics.Height * 4 - 1)
          sta PixelPointers + 8
          lda #>(\Graphics + \Graphics.Height * 4 - 1)
          sta PixelPointers + 9
          lda #<(\Graphics + \Graphics.Height * 5 - 1)
          sta PixelPointers + $a
          lda #>(\Graphics + \Graphics.Height * 5 - 1)
          sta PixelPointers + $b

          .endm

          .enc "minifont"
          .cdef "09", 0
          .cdef "az", 10
          .cdef "AZ", 10
          .cdef "..", 36
          .cdef "!!", 37
          .cdef "??", 38
          .cdef "--", 39
          .cdef "  ", 40
          .cdef "++", 41
          .enc "none"

          .enc "minifont-extended"
          .cdef "09", 0
          .cdef "az", 10
          .cdef "AZ", 10
          .cdef "..", 36
          .cdef "!!", 37
          .cdef "??", 38
          .cdef "--", 39
          .cdef "  ", 40
          .cdef "++", 41
          .cdef ",,", 42
          .cdef "''", 43
          .cdef "<<", 44
          .cdef ">>", 45
          .enc "none"

MiniText:          .macro String
          .enc "minifont"
          .if len(\String) != 6
          .error "String length for .MiniText must be 6 ", \String, " is ", len(\String)
          .fi
          .byte \String[0]
          .byte \String[1]
          .byte \String[2]
          .byte \String[3]
          .byte \String[4]
          .byte \String[5]
          .enc "none"
          .endm

Pack6:   .macro byteA, byteB, byteC, byteD
          .byte ((\byteA & $3f) << 2) | ((\byteB & $30) >> 4)
          .byte ((\byteB & $0f) << 4) | ((\byteC & $3c) >> 2)
          .byte ((\byteC & $03) << 6) | (\byteD & $3f)
          .endm

SignText: .macro string
          .enc "minifont-extended"
          .if len(\string) != 12
          .error "String length for .SignText must be 12 ", \string, " is ", len(\string)
          .fi
          .Pack6 \string[0], \string[1], \string[2], \string[3]
          .Pack6 \string[4], \string[5], \string[6], \string[7]
          .Pack6 \string[8], \string[9], \string[10], \string[11]
          .enc "none"
          .endm

LoadString:          .macro String
          .enc "minifont"
          .if len(\String) != 6
          .error "String length for .LoadString must be 6 ", \String, " is ", len(\String)
          .fi
          lda #\String[0]
          sta WRITE + StringBuffer + 0
          lda #\String[1]
          sta WRITE + StringBuffer + 1
          lda #\String[2]
          sta WRITE + StringBuffer + 2
          lda #\String[3]
          sta WRITE + StringBuffer + 3
          lda #\String[4]
          sta WRITE + StringBuffer + 4
          lda #\String[5]
          sta WRITE + StringBuffer + 5
          .enc "none"

          .endm

          .enc "none"
