;;; Meteoroid Source/Banks/Bank04/Bank04.s
;;; Copyright © 2021 Bruce-Robert Pocock
          BANK = $04

          ;;
          ;; Sound and Music services
          ;;

          .include "StartBank.s"

DoLocal:
          .include "PlaySFX.s"
          .include "PlayMusic.s"
          .include "PlaySpeech.s"
          rts

          .include "SoundEffects.s"

          .include "SpeakJetIndex.s"
          ;; Speech index uses a wildcard on this directory
          ;; All files must be included or the index will break
          .include "MeteoroidSpeech.s"
          .include "TitleSpeech.s"
          .include "AtariToday.s"
          .include "Theme.s"
          .include "Victory.s"
          .include "GameOver.s"

          .include "EndBank.s"
