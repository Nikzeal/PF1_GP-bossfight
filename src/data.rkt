;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname data) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; LIBRARIES
(require 2htdp/image)
(require racket/base)
(provide (all-defined-out))

;; CONSTANTS

; Background
(define BACKGROUND         (rectangle 1440 900 "solid" "black"))

; Buttons
(define ATK_BOX_UNS        (bitmap/file "../resources/atk.jpeg"))
(define ATK_BOX_SEL        (bitmap/file "../resources/ATK.png"))
(define HEAL_BOX_UNS       (bitmap/file "../resources/heal.jpeg"))
(define HEAL_BOX_SEL       (bitmap/file "../resources/HEAL.png"))
(define ATK_BOX_POSITION   (make-posn 500 800))
(define HEAL_BOX_POSITION  (make-posn 900 800))
(define PL_OFFSET_ATTACK   (make-posn (- (posn-x ATK_BOX_POSITION)  45) (posn-y ATK_BOX_POSITION )))
(define PL_OFFSET_HEAL     (make-posn (- (posn-x HEAL_BOX_POSITION) 45) (posn-y HEAL_BOX_POSITION)))
(define PLAY_UNS           (scale 0.3 (bitmap/file "../resources/play-white.png")))
(define PLAY_SEL           (scale 0.3 (bitmap/file "../resources/play-yellow.png")))
(define PLAY_TEXT_POS      (make-posn 720 400))
(define CREDITS_UNS        (scale 0.3 (bitmap/file "../resources/credits-white.png")))
(define CREDITS_SEL        (scale 0.3 (bitmap/file "../resources/credits-yellow.png")))
(define CREDITS_TEXT_POS   (make-posn 720 500))
(define NAMES              (scale 0.3 (bitmap/file "../resources/names.png")))
(define ENTER              (scale 0.5 (bitmap/file "../resources/enter.png")))

; Player box
(define PL_BOX             (rectangle 400 300 "outline" (pen "white" 10 "solid" "round" "bevel")))
(define PL_BOX_LEFT        500)
(define PL_BOX_RIGHT       900)
(define PL_BOX_BOTTOM      750)
(define PL_BOX_TOP         450)
(define PL_BOX_POSITION    (make-posn 700 600))
(define GAME_OVER          (scale 0.35 (bitmap/file "../resources/GAME-OVER.png")))
(define WIN                (scale 0.35 (bitmap/file "../resources/WIN.png")))
(define QUIT               (scale 0.35 (bitmap/file "../resources/quit.png")))
(define RETRY              (scale 0.35 (bitmap/file "../resources/retry.png")))

; Boss
(define BS_SPRITE_N        (scale 1.2 (bitmap/file "../resources/normal.png")))
(define BS_SPRITE_R        (bitmap/file "../resources/rage.png"))
(define BS_N_POSITION      (make-posn 630 240))
(define BS_R_POSITION      (make-posn 680 240))
(define LP_POSITION_BO     (make-posn 700 70))
(define RG1                (scale 1.7 (bitmap/file "../resources/gif/1.png")))
(define RG2                (scale 1.7 (bitmap/file "../resources/gif/2.png")))
(define RG3                (scale 1.7 (bitmap/file "../resources/gif/3.png")))
(define RG4                (scale 1.7 (bitmap/file "../resources/gif/4.png")))
(define RG5                (scale 1.7 (bitmap/file "../resources/gif/5.png")))
(define RG6                (scale 1.7 (bitmap/file "../resources/gif/6.png")))
(define RG7                (scale 1.7 (bitmap/file "../resources/gif/7.png")))
(define RG8                (scale 1.7 (bitmap/file "../resources/gif/8.png")))
(define RG9                (scale 1.7 (bitmap/file "../resources/gif/9.png")))
(define RG10               (scale 1.7 (bitmap/file "../resources/gif/10.png")))
(define RG11               (scale 1.7 (bitmap/file "../resources/gif/11.png")))
(define RG12               (scale 1.7 (bitmap/file "../resources/gif/12.png")))
(define RG13               (scale 1.7 (bitmap/file "../resources/gif/13.png")))

; Player
(define PL_SPRITE          (center-pinhole (scale 0.3  (bitmap/file "../resources/player.png"))))
(define PL_WIDTH           (image-width PL_SPRITE))
(define PL_HEIGHT          (image-height PL_SPRITE))
(define INITIAL_PLAYER_POS (make-posn 700 600))
(define LP_POSITION_PL     (make-posn 700 800))

; Ticks
(define TICK               1/100)
(define FRAME              1/100)

; Speed
(define BASE_SPEED         600 )
(define ENTITY_SPEED       2000)

; HP sprites
(define PL_HP              (scale 0.65 (bitmap/file "../resources/heart.png")))

; Ball (entity)
(define BALL_SPRITE        (scale 0.2 (bitmap/file "../resources/ball.png")))
(define BALL_HEIGHT        (image-height BALL_SPRITE))
(define BALL_WIDTH         (image-width BALL_SPRITE))

; Initial canvas
(define INITIAL_CANVAS (place-images
   (list PL_SPRITE
         BS_SPRITE_N
         PL_BOX
         (beside PL_HP PL_HP PL_HP PL_HP PL_HP)
         (above (beside PL_HP PL_HP PL_HP PL_HP PL_HP)
                (beside PL_HP PL_HP PL_HP PL_HP PL_HP))
         ATK_BOX_UNS
         HEAL_BOX_UNS)
   (list INITIAL_PLAYER_POS
         BS_N_POSITION
         PL_BOX_POSITION
         LP_POSITION_PL
         LP_POSITION_BO
         ATK_BOX_POSITION
         HEAL_BOX_POSITION
         )
   BACKGROUND))

; Empty structure
(define-struct none [] #:transparent)
(define NONE (make-none))

;--------------------------------------------------------------------------------------

; entities is a structure (make-entities player enemies)
; where:
;  - player-lp is a Number
;  - player-pos is a Posn
;  - enemies is one of:
;      - '()
;      - (cons Posn List<Posn>)
; interpretation: the player's life points, position and the entities positions 
(define-struct entities [player-lp player-pos enemies] #:transparent)

;; Data examples
(define PLAYER         (make-entities 5 (make-posn 500 400) '()))
(define PLAYER_ATK     (make-entities 5 PL_OFFSET_ATTACK    '()))
(define PLAYER_HEAL    (make-entities 5 PL_OFFSET_HEAL      '()))
(define PLAYER_PLAY    (make-entities 5 PLAY_TEXT_POS       '()))
(define PLAYER_CREDITS (make-entities 5 CREDITS_TEXT_POS       '()))
(define PLAYER_ENT  (make-entities 5 (make-posn 500 400)
                                   (build-list 7 (lambda (n) (make-posn 400 300)))))
(define MENU        (make-entities 5 (make-posn 720 400) '()))
(define E1          (make-entities 5 (make-posn 500 400)
                                   (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define E2          (make-entities 5 (make-posn 500 400)
                                   (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define E3          (make-entities 5 (make-posn 500 400)
                                   (build-list 1 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define E4          (make-entities 5 INITIAL_PLAYER_POS
                                   '()))

;--------------------------------------------------------------------------------------

; a substate is one of:
;  - "menu"
;  - "credits"
;  - "player"
;  - "boss"
;  - "end"
;  - "rage"
; interpretation: indicates if it is the `boss` turn or the `player` turn, if
;                 the player is in the `menu` or is watching `credits`, if the
;                 game `end`ed or there is the `rage` transition.

; a movement is one of:
;  - "right"
;  - "left"
;  - "up"
;  - "down"
;  - "still"
; interpretation: indicates if the player is moving `left`, `right`, `up`, `down` or
;                 just staying `still`

; an appState is a structure: (make-appState canvas e s boss running? movement change-turn)
;  where: - canvas        : Image
;         - e             : entities
;         - s             : substate
;         - boss          : Number
;         - running?      : Boolean
;         - movement      : movement
;         - change-turn   : Number
;interpretation: a structure that describes the state of the application displayed as a `canvas`
;                that initially contains a box with a player `e-entities player` inside, the
;                image of the boss and the images of the life points. The canvas gets updated
;                by adding elements of the list `e-entities enemies` based on the `s` and the
;                `boss` value. When wether the `e-entities player` or the boss has a lifepoints
;                value of 0 the `s` is set to end and if the player presses the "q" key, `running?`
;                becomes false and the application quits. `movement` describes the current direction
;                of the player `e-entities player`. `change-turn` is a counter to keep track of
;                the tick to call a specific function when aproximatively 20 seconds pass.
;                `enemies-count` keeps track of the number of entities in the state.
(define-struct appState [canvas e s boss running? movement change-turn] #:transparent)

;; Data examples
(define MENU_APP_STATE (make-appState BACKGROUND MENU "menu" 10  #true "still" 0))
(define GAME_APP_STATE (make-appState BACKGROUND E4   "boss" 10 #true "still" 0))
(define END_APP_STATE  (make-appState BACKGROUND NONE  "end" 0  #false "still" 0))