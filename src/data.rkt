;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname data) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require racket/base)
(provide (all-defined-out))

;; Constants
(define BACKGROUND (rectangle 1440 900 "solid" "black"))
(define placeholder_rec (rectangle 150 50 "outline" (pen "white" 5 "solid" "round" "bevel")))
(define PL_BOX (rectangle 400 300 "outline" (pen "white" 10 "solid" "round" "bevel")))
(define PL_BOX_LEFT 500)
(define PL_BOX_RIGHT 900)
(define PL_BOX_BOTTOM 750)
(define PL_BOX_TOP 450)
(define BS_SPRITE_POSITION (make-posn 500 200))
(define PL_BOX_POSITION (make-posn 700 600))
(define ATK_BOX_POSITION (make-posn 500 800))
(define HEAL_BOX_POSITION (make-posn 900 800))
(define LP_POSITION_BO  (make-posn 700 70))
(define LP_POSITION_PL (make-posn 700 800))
(define INITIAL_PLAYER_POS (make-posn 700 600))
(define FRAME 1/100)
(define TURN 20)
(define BASE_SPEED 600)
(define ENTITY_SPEED 2000)
(define PL_LP (scale 0.02 (bitmap/file "../resources/heart-pl.png")))
(define BOSS_LP (scale 0.02(bitmap/file "../resources/heart-boss.png")))
(define PL_HP (scale 0.65 (bitmap/file "../resources/heart.png")))   

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

(define KNIFE_SPRITE (bitmap/file "../resources/knife.png"))
(define BALL_SPRITE  (scale 0.2 (bitmap/file "../resources/ball.png")))
(define BALL_HEIGHT (image-height BALL_SPRITE))
(define BALL_WIDTH (image-width BALL_SPRITE))
(define ARROW_SPRITE (bitmap/file "../resources/arrow.png"))
(define SWORD_SPRITE (bitmap/file "../resources/sword.png"))
(define PL_SPRITE    (center-pinhole (scale 0.3  (bitmap/file "../resources/player.png"))))
(define PL_WIDTH (image-width PL_SPRITE))
(define PL_HEIGHT (image-height PL_SPRITE))
(define BS_SPRITE_N  (scale 1.2 (bitmap/file "../resources/normal.png")))
(define BS_SPRITE_R  (bitmap/file "../resources/rage.png"))



(define INITIAL_CANVAS (place-images
   (list PL_SPRITE
         BS_SPRITE_N
         PL_BOX
         HP_SPRITE_5
         HP_SPRITE_10
         placeholder_rec
         placeholder_rec)
   (list INITIAL_PLAYER_POS
         BS_SPRITE_POSITION
         PL_BOX_POSITION
         LP_POSITION_PL
         LP_POSITION_BO
         ATK_BOX_POSITION
         HEAL_BOX_POSITION
         )
   BACKGROUND))


(define-struct none [] )
(define NONE (make-none))

;--------------------------------------------------------------------------------------

; a player is a structure :(make-player sprite hp position)
;  where:
;  - sprite   :   Image
;  - hp       :   Number
;  - position :   Posn
; interpretation: a structure that represents the player's status displayed
;                 with a `sprite` image, some `hp` life points
;                 at position `position`             
(define-struct player [sprite hp position] )

;; Data examples
(define INITIAL_PLAYER (make-player PL_SPRITE 5 INITIAL_PLAYER_POS) )
(define PL1 (make-player PL_SPRITE 3 (make-posn 600 750)))
(define PL2 (make-player PL_SPRITE 3 (make-posn 500 850)))

;--------------------------------------------------------------------------------------

; an entities is a structure (make-entity sprites positions)
; Where:
;  - sprites is one of:
;      - '()
;      - (cons Image List<Image>)
;  - positions is one of:
;      - '()
;      - (cons Posn List<Posn>)
; interpretation: a list that represents all the entities' `sprites` at positions `positions` 
(define-struct entities [sprites positions])
;; Data examples
(define EMPTY  (make-entities '() '() ))
(define KNIFES (make-entities (build-list 5 (lambda (n) KNIFE_SPRITE)) (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define ARROWS (make-entities (build-list 5 (lambda (n) ARROW_SPRITE)) (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define SWORD  (make-entities (build-list 1 (lambda (n) SWORD_SPRITE)) (build-list 1 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define BALLS  (make-entities (build-list 5 (lambda (n) BALL_SPRITE))  (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))

;--------------------------------------------------------------------------------------

; a substate is one of:
;       - "player"
;       - "boss"

; a movement is one of:
;       - "right"
;       - "left"
;       - "up"
;       - "down"
;       - "still"


; an appState is a structure: (make-appState canvas p e s boss running?)
;  where:
;  - canvas     : Image
;  - p          : player
;  - e          : entities
;  - s          : substate
;  - boss       : Number
;  - running?   : Boolean
;  - movement   : movement
;interpretation: a structure that describes the state of the application displayed as a `canvas`
;                that initially contains a box with a player `p` inside, the image of the boss and the images
;                of the life points. The canvas gets updated by adding elements of the list `e` based on the `s` 
;                and the `boss` value. When wether the `p` or the boss has a lifepoints value of 0 the `running?`
;                is set to #false and the application quits. `movement` describes the current direction of
;                the player `p`.
(define-struct appState [canvas p e s boss running? movement])

;; Data examples

(define INITIAL_APP_STATE (make-appState BACKGROUND INITIAL_PLAYER EMPTY "boss" 10 #true "still"))
(define AP2 (make-appState BACKGROUND PL1 BALLS "boss" 10 #true "still"))
(define AP3 (make-appState BACKGROUND PL2 KNIFES "boss" 10 #true "still"))
(define AP4 (make-appState BACKGROUND INITIAL_PLAYER NONE "player" 10 #false "still"))