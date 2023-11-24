;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname dtd) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
  (require mrlib/gif)
(require 2htdp/image)
(require 2htdp/universe)


;; Constants
(define BACKGROUND (rectangle 1440 900 "solid" "black"))
(define placeholder_rec (rectangle 150 50 "outline" (pen "white" 5 "solid" "round" "bevel")))
(define PL_BOX (rectangle 400 300 "outline" (pen "white" 10 "solid" "round" "bevel")))
(define BS_SPRITE_POSITION (make-posn 500 200))
(define PL_BOX_POSITION (make-posn 700 600))
(define ATK_BOX_POSITION (make-posn 500 800))
(define HEAL_BOX_POSITION (make-posn 900 800))
(define LP_POSITION_BO  (make-posn 700 70))
(define LP_POSITION_PL (make-posn 700 800))
(define INITIAL_PLAYER_POS (make-posn 700 600))

(define HP_SPRITE_10 (above (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))
       (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))))

(define HP_SPRITE_9 (above (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))
       (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))))

(define HP_SPRITE_8 (above (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))
       (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))))

(define HP_SPRITE_7 (above (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))
       (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))))

(define HP_SPRITE_6 (above (beside
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red")
          (circle 20 "solid" "red"))
                       (circle 20 "solid" "red")))

(define HP_SPRITE_5
    (beside
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")))

(define HP_SPRITE_4 
    (beside
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       ))

(define HP_SPRITE_3
    (beside
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       ))

(define HP_SPRITE_2
    (beside
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")))

(define HP_SPRITE_1 (circle 20 "solid" "red"))

(define KNIFE_SPRITE (bitmap/file "../resources/knife.png"))
(define BALL_SPRITE  (bitmap/file "../resources/ball.png"))
(define ARROW_SPRITE (bitmap/file "../resources/arrow.png"))
(define SWORD_SPRITE (bitmap/file "../resources/sword.png"))
(define PL_SPRITE    (scale 0.4 (bitmap/file "../resources/player.png")))
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

; an entity is one of:
; - NONE
; - a structure: (make-entity sprite position collided?)
;    where:
;    - sprite    :   Image
;    - position  :   Posn
;    - collided? :   Boolean
; interpretation: a structure that represents an entity's status displayed
;                 with a `sprite` image, at a position `position` and based on
;                 `collided?`, which states wether the entity has collided with the player
(define-struct entity [sprite position collided?])

;; Data examples
(define KNIFE (make-entity KNIFE_SPRITE (make-posn 400 499) #false))
(define ARROW (make-entity ARROW_SPRITE (make-posn 400 499) #false))
(define SWORD (make-entity SWORD_SPRITE (make-posn 400 499) #false))
(define BALL  (make-entity BALL_SPRITE  (make-posn 400 499) #false))

;--------------------------------------------------------------------------------------

; a substate is one of:
;       - "player"
;       - "boss"
;       - "player-attack"
;       - "player-heal"

; an appState is a structure: (make-appState canvas p e s boss running?)
;  where:
;  - canvas     : Image
;  - p          : player
;  - e          : entity
;  - s          : substate
;  - boss       : Number
;  - running?   : Boolean
;interpretation: a structure that describes the state of the application displayed as a `canvas`
;                that initially contains a box with a player `p` inside, the image of the boss and the images
;                of the life points. The canvas gets updated by adding some `e` based on the `s` and
;                `boss` number. When wether the `p` or the boss has a lifepoints value of 0 the `running?`
;                is set to #false and the application quits
(define-struct appState [canvas p e s boss running?])

;; Data examples

(define INITIAL_APP_STATE (make-appState BACKGROUND INITIAL_PLAYER NONE "boss" 10 #true))
(define AP2 (make-appState BACKGROUND PL1 BALL "boss" 10 #true))
(define AP3 (make-appState BACKGROUND PL2 BALL "boss" 10 #true))
(define AP4 (make-appState BACKGROUND INITIAL_PLAYER NONE "player" 10 #false))

;--------------------------------------------------------------------------------------

;draw-lp: Number -> Image
; draws a certain `n` of images to display 
; header: (define (draw-lp n) HP_SPRITE_PL_INITIAL)
;(build-list 5 (lambda (n) (circle 10 "solid" "red")))

(define (draw-lp n)
  (cond
    [(= n 1) HP_SPRITE_1]
    [(= n 2) HP_SPRITE_2]
    [(= n 3) HP_SPRITE_3]
    [(= n 4) HP_SPRITE_4]
    [(= n 5) HP_SPRITE_5]
    [(= n 6) HP_SPRITE_6]
    [(= n 7) HP_SPRITE_7]
    [(= n 8) HP_SPRITE_8]
    [(= n 9) HP_SPRITE_9]
    [else HP_SPRITE_10]))

; drawTurn: as -> Image
; draws the appstate on the boss' or player's turn
; header: (define (drawTurn as) INITIAL_CANVAS)

;; Template
;(define (drawTurn as)
;  ... (draw-lp (player-hp (appState-p as))) ...
;  ... (draw-lp (appState-boss as)) ...
;  ... (draw-entity (appState-e as)) ...
;  ... PL_SPRITE ...
;  ... BS_SPRITE_N ...
;  ... PL_BOX ...
;  ... placeholder_rec ...
;  ... (player-position (appState-p as)) ...
;) 


(define (drawTurn as)
   (place-images
    (list PL_SPRITE
          BS_SPRITE_N
          PL_BOX
          (draw-lp (player-hp (appState-p as)))
          (draw-lp (appState-boss as))
          placeholder_rec
          placeholder_rec)
    (list (player-position (appState-p as))
          BS_SPRITE_POSITION
          PL_BOX_POSITION
          LP_POSITION_PL
          LP_POSITION_BO
          ATK_BOX_POSITION
          HEAL_BOX_POSITION)
    BACKGROUND))

; drawAppState: appState -> Image
; display the appState on the scene as an image
; header: (define (drawAppState as) BACKGROUND)

(check-expect (drawAppState INITIAL_APP_STATE) INITIAL_CANVAS)
(check-expect (drawAppState (make-appState BACKGROUND PL1 BALL "boss" 8 #true))
              (place-images
               (list PL_SPRITE
                     BS_SPRITE_N
                     PL_BOX
                     (draw-lp (player-hp PL1))
                     (draw-lp 8)
                     placeholder_rec
                     placeholder_rec)
               (list (player-position PL1)
                     BS_SPRITE_POSITION
                      PL_BOX_POSITION
                      LP_POSITION_PL
                      LP_POSITION_BO
                      ATK_BOX_POSITION
                      HEAL_BOX_POSITION)
               BACKGROUND))

;; template
(define (drawAppState as)
  (cond
    [(or (string=? (appState-s as) "boss") (string=? (appState-s as) "player")) (drawTurn as)]
    [else (error "not the expected state")]
    ;[(or (= (as-s) "player-attack") (= (as-s) "player-heal")) (drawAction as)]
    ))
;--------------------------------------------------------------------------------------

; handle-key: appState -> appState
;

;--------------------------------------------------------------------------------------
; quit? appState -> Boolean
; checks if the application has quit or not, i.e. the player has won or lost
; header: (define (quit? appState) #true)

(check-expect (quit? INITIAL_APP_STATE) #false)
(check-expect (quit? AP4) #true)

;;Template
;(define (quit? as)
;  (cond
;    [(= (appState-running? as) #true) ... #false ....]
;    [else ... #true ...]))

(define (quit? as)
  (cond
    [(appState-running? as) #false]
    [else #true]))

 (big-bang INITIAL_APP_STATE
;   (on-tick tick-expr rate-expr)
;   (on-key handle-key)
   (to-draw drawAppState)
   (stop-when quit?))

 
 