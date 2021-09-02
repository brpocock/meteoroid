;;; Meteoroid Source/Common/Enums.s
;;; Copyright © 2021 Bruce-Robert Pocock
;;;
;;; Enumerated values used in various places.
;;; 

;;; 
;;; Game modes are set up as a major (upper nybble) and minor (lower nybble)
;;; mode. The major mode usually indicates which kernel will be used; the
;;; minor modes allow the game mode to track its own sub-states.
          
          ModeColdStart = $00

          ModeAttract = $10
          ModeAttractTitle = $11
          ModeAttractCopyright = $12
          ModeAttractStory = $13
          ModeCreditSecret = $14
          ModeBRPPreamble = $1e
          ModePublisherPresents = $1f

          ModeSelectSlot = $20
          ModeEraseSlot = $21
          ModeErasing = $22
          ModeStartGame = $24
          ModePlusCardSlot = $25

          ModePlay = $30
          ModePlayNewRoom = $31
          ModePlayNewRoomDoor = $32

          ModeSubscreen = $70

          ModeSignpost = $80
          ModeSignpostDone = $81
          ModeSignpostSetFlag = $82
          ModeSignpostClearFlag = $83

          ModeDeath = $90
;;; 
;;; Sounds in the library (index values)
          SoundDrone = 1
          SoundChirp = 2
          SoundDeleted = 3
          SoundHappy = 4
          SoundBump = 5
          SoundHit = SoundBump
          SoundMiss = SoundDeleted
          SoundError = 6
          SoundSweepUp = 7
          SoundAtariToday = 8
          SoundVictory = 9
          SoundGameOver = 10
          SoundFootstep = 11
;;; 
;;; Status Effects for player or enemies 
          StatusSleep = $01
          StatusAttackDown = $04
          StatusDefendDown = $08
          StatusMuddle = $10
          StatusAttackUp = $40
          StatusDefendUp = $80
;;; 
          MoveEffectsToEnemy = $1f
          MoveEffectsToSelf = $e0
;;; 
          LevelUpAttack = $01
          LevelUpDefend = $02
          LevelUpMaxHP = $04
;;; 
;;; Sprite types
          RandomEncounter = $80
          SpriteFixed = $40
          SpriteWander = $20

          SpriteMoveNone = $00
          SpriteMoveIdle = $01
          SpriteRandomEncounter = $02
          SpriteMoveLeft = $10
          SpriteMoveRight = $20
          SpriteMoveUp = $40
          SpriteMoveDown = $80
;;; 
;;; Sprite actions
          SpriteCombat = $00
          SpriteGrizzardDepot = $01
          SpriteGrizzard = $02
          SpriteDoor = $03
          SpriteSign = $04
          SpritePerson = $05
          SpriteMajorCombat = $06
          SpriteCombatPuff = $07
          SpriteProvinceDoor = $07
;;; 
          ;; Save game slot address.
          ;; Must be page-aligned
          ;; Uses the subsequent 12 64-byte blocks
          .if DEMO
          SaveGameSlotPrefix = $3300
          .else
          ;; https://atariage.com/atarivox/atarivox_mem_list.html
          SaveGameSlotPrefix = $1040
          .fi
          
          ;; Must be exactly 5 bytes for the driver routines to work
          .enc "ascii"
          SaveGameSignature = "metr0"
          .enc "none"
;;; 
;;; Special Memory Banks

          ColdStartBank = $00
          SaveKeyBank = $00
          MapServicesBank = $01
          FailureBank = $01
          TextBank = $02
          AnimationsBank = $03
          FinaleBank = $03
          SFXBank = $04
          Province0Bank = $05
          .if DEMO
          ProvincesCount = 3
          .else
          ProvincesCount = 11
          .fi

;;; 
;;; Text bank provides multiple services, selected with .y

          ServiceAppendDecimalAndPrint = $0e
          ServiceCombatOutcome = $14
          ServiceDecodeAndShowText = $01
          ServiceFetchGrizzardMove = $13
          ServiceLearntMove = $18
          ServiceLevelUp = $1a
          ServiceNewGame = $0f
          ServiceShowGrizzardName = $03
          ServiceShowGrizzardStats = $04
          ServiceShowMove = $06
          ServiceShowMoveDecoded = $17
          ServiceShowText = $02
          ServiceCombatIntro = $1b
          ServiceCombatVictory = $1c

;;; Map services bank, same

          ServiceBottomOfScreen = $09
          ServiceSubscreen = $19
          ServiceTopOfScreen = $08
          ServiceValidateMap = $1d

;;; Animations services

          ServiceDrawGrizzard = $05
          ServiceAttractStory = $15
          ServiceDeath = $0d
          ServiceDrawMonsterGroup = $0b
          ServiceFireworks = $0a

;;; Also the cold start / save game bank

          ServiceColdStart = $00
          ServiceSaveToSlot = $10
          ServiceAttract = $1e
;;; 
;;; Screen boundaries for popping to the next screen

          ScreenLeftEdge = $30
          ScreenRightEdge = $c8
          ScreenTopEdge = 8
          ScreenBottomEdge = 75
;;; 
;;; Localization

          LangEng = $0e
          LangSpa = $05
          LangFra = $0f

;;; 
;;; MapFlags values
          MapFlagSpritesMoved = $01
          MapFlagRandomSpawn = $04
          MapFlagFacing = $08   ; matches REFP0 REFLECTED bit

;;; 
;;; Equipment

          EquipMorph = $01
          EquipCharge = $02
          EquipBomb = $04
          EquipMissile = $08
          EquipFreeze = $10
          EquipBarrierSuit = $20
          EquipScubaSuit = $40

;;; 
;;; Movement Style

          MoveStand = $00
          MoveWalk = $01
          MoveJump = $02
          MoveFall = $03
          MoveMorphRest = $04
          MoveMorphRoll = $05
          MoveFloat = $06
          MoveSwim = $07
          MoveSink = $08
