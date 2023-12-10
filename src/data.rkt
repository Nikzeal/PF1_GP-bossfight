;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname data) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; LIBRARIES
(require 2htdp/image)
(require racket/base)
(provide (all-defined-out))

;--------------------------------------------------------------------------------------

;; CONSTANTS

; Background
(define BACKGROUND (rectangle 1440 900 "solid" "black"))

; Buttons
(define ATK_BOX (bitmap/file "../resources/atk.jpeg"))
(define HEAL_BOX (bitmap/file "../resources/heal.jpeg"))
(define ATK_BOX_POSITION (make-posn 500 800))
(define HEAL_BOX_POSITION (make-posn 900 800))
(define PLAY_TEXT_POS (make-posn 720 400))
(define CREDITS_TEXT_POS (make-posn 720 500))


; Player box
(define PL_BOX (rectangle 400 300 "outline" (pen "white" 10 "solid" "round" "bevel")))
(define PL_BOX_LEFT 500)
(define PL_BOX_RIGHT 900)
(define PL_BOX_BOTTOM 750)
(define PL_BOX_TOP 450)
(define PL_BOX_POSITION (make-posn 700 600))

; Boss
(define BS_SPRITE_N  (scale 1.2 (bitmap/file "../resources/normal.png")))
(define BS_SPRITE_R  (bitmap/file "../resources/rage.png"))
(define BS_SPRITE_POSITION (make-posn 500 200))
(define LP_POSITION_BO  (make-posn 700 70))

; Player
(define PL_SPRITE (center-pinhole (scale 0.3  (bitmap/file "../resources/player.png"))))
(define PL_WIDTH (image-width PL_SPRITE))
(define PL_HEIGHT (image-height PL_SPRITE))
(define INITIAL_PLAYER_POS (make-posn 700 600))
(define LP_POSITION_PL (make-posn 700 800))

; Ticks
(define TICK 1/100)
(define FRAME 1/100)

; Speed
(define BASE_SPEED 600)
(define ENTITY_SPEED 2000)

; HP sprites
(define PL_HP (scale 0.65 (bitmap/file "../resources/heart.png")))
; (define PL_LP (scale 0.02 (bitmap/file "../resources/heart-pl.png")))
; (define BOSS_LP (scale 0.02(bitmap/file "../resources/heart-boss.png")))
(define HP_SPRITE_10 (above (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP)
       (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP)))

(define HP_SPRITE_9 (above (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP)
       (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP)))

(define HP_SPRITE_8 (above (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP)
       (beside
          PL_HP
          PL_HP
          PL_HP)))

(define HP_SPRITE_7 (above (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP)
       (beside
          PL_HP
          PL_HP)))

(define HP_SPRITE_6 (above (beside
          PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP)
          PL_HP))

(define HP_SPRITE_5
    (beside
       PL_HP
          PL_HP
          PL_HP
          PL_HP
          PL_HP))

(define HP_SPRITE_4 
    (beside
       PL_HP
          PL_HP
          PL_HP
          PL_HP
       ))

(define HP_SPRITE_3
    (beside
       PL_HP
          PL_HP
          PL_HP
       ))

(define HP_SPRITE_2
    (beside PL_HP
          PL_HP))

(define HP_SPRITE_1 PL_HP)

; Knife (entity)
(define KNIFE_SPRITE (bitmap/file "../resources/knife.png"))

; Ball (entity)
(define BALL_SPRITE  (scale 0.2 (bitmap/file "../resources/ball.png")))
(define BALL_HEIGHT (image-height BALL_SPRITE))
(define BALL_WIDTH (image-width BALL_SPRITE))

; Arrow (entity)
(define ARROW_SPRITE (bitmap/file "../resources/arrow.png"))

; Sword (entity)
(define SWORD_SPRITE (bitmap/file "../resources/sword.png"))



; Gameover canvas
(define GAMEOVER_CANVAS (place-images
   (list 
   )
   (list 
   )
   BACKGROUND))

; Victory canvas
(define VICTORY_CANVAS (place-images
   (list 
   )
   (list 
   )
   BACKGROUND))

; Initial canvas
(define INITIAL_CANVAS (place-images
   (list PL_SPRITE
         BS_SPRITE_N
         PL_BOX
         HP_SPRITE_5
         HP_SPRITE_10
         ATK_BOX
         HEAL_BOX)
   (list INITIAL_PLAYER_POS
         BS_SPRITE_POSITION
         PL_BOX_POSITION
         LP_POSITION_PL
         LP_POSITION_BO
         ATK_BOX_POSITION
         HEAL_BOX_POSITION
         )
   BACKGROUND))

; Empty structure
(define-struct none [])
(define NONE (make-none))

;--------------------------------------------------------------------------------------

; entities is a structure (make-entities player enemies)
; Where:
;  - player-lp is a Number
;  - player-pos is a Posn
;  - enemies is one of:
;      - '()
;      - (cons Posn List<Posn>)
; interpretation: the player's life points, position and the entities positions 
(define-struct entities [player-lp player-pos enemies])
;; Data examples
(define PLAYER  (make-entities 5 (make-posn 500 400) '() ))
(define MENU  (make-entities 5 (make-posn 720 400) '() ))
(define E1 (make-entities 5 (make-posn 500 400)
                              (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define E2 (make-entities 5 (make-posn 500 400)
                              (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define E3  (make-entities 5 (make-posn 500 400)
                              (build-list 1 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define E4  (make-entities 5 INITIAL_PLAYER_POS
                              (build-list 7 (lambda (n) (make-posn (random 200) (+ 450 (random 300))))) ))

;--------------------------------------------------------------------------------------

; a substate is one of:
;  - "menu"
;  - "player"
;  - "boss"
;  - "lost"
;  - "win"
; interpretation: indicates if it is the `boss` turn or the `player` turn

; a movement is one of:
;  - "right"
;  - "left"
;  - "up"
;  - "down"
;  - "still"
; interpretation: indicates if the player is moving `left`, `right`, `up`, `down` or
;                 just staying `still`

; an appState is a structure: (make-appState canvas p e s boss running?)
;  where: - canvas        : Image
;         - e             : entities
;         - s             : substate
;         - boss          : Number
;         - running?      : Boolean
;         - movement      : movement
;         - change-turn   : Number
;         - entities-count: Number
;interpretation: a structure that describes the state of the application displayed as a `canvas`
;                that initially contains a box with a player `e-entities player` inside, the image of the boss and the images
;                of the life points. The canvas gets updated by adding elements of the list `e-entities enemies` based on the `s` 
;                and the `boss` value. When wether the `e-entities player` or the boss has a lifepoints value of 0 the `running?`
;                is set to #false and the application quits. `movement` describes the current direction of the player `e-entities player`.
;                `change-turn` is a counter to keep track of the tick to call a specific function when 20 seconds pass.
;                `enemies-count` keeps track of the number of entities in the state.
(define-struct appState [canvas e s boss running? movement change-turn])

;; Data examples
(define MENU_APP_STATE (make-appState BACKGROUND MENU "menu" 6  #true "still" 0))
(define GAME_APP_STATE (make-appState BACKGROUND E4   "boss" 6 #true "still" 0))
(define WIN_APP_STATE  (make-appState BACKGROUND NONE  "win" 0  #false "still" 0))
(define LOST_APP_STATE (make-appState BACKGROUND NONE "lost" 0  #false "still" 0))