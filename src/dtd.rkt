;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname dtd) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
  (require mrlib/gif)
(require 2htdp/image)
(require 2htdp/universe)


;; Constants
(define BACKGROUND (rectangle 1920 1080 "solid" "blue"))
(define placeholder_rec (rectangle 150 50 "outline" (pen "white" 5 "solid" "round" "bevel")))
(define PL_BOX (rectangle 400 300 "outline" (pen "white" 10 "solid" "round" "bevel")))

(define HP_SPRITE_PL_INITIAL 
    (beside
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")
       (circle 20 "solid" "red")))

(define HP_SPRITE_B_INITIAL (above (beside
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

(define KNIFE_SPRITE (bitmap/file "../resources/knife.png"))
(define BALL_SPRITE  (bitmap/file "../resources/ball.png"))
(define ARROW_SPRITE (bitmap/file "../resources/arrow.png"))
(define SWORD_SPRITE (bitmap/file "../resources/sword.png"))
(define PL_SPRITE    (scale 0.4 (bitmap/file "../resources/player.png")))
(define BS_SPRITE_N  (scale 1.4 (bitmap/file "../resources/normal.png")))
(define BS_SPRITE_R  (bitmap/file "../resources/rage.png"))
(define INITIAL_PLAYER_POS (make-posn 700 800))

(define INITIAL_CANVAS (place-images
   (list PL_SPRITE
         BS_SPRITE_N
         PL_BOX
         HP_SPRITE_PL_INITIAL
         HP_SPRITE_B_INITIAL
         placeholder_rec
         placeholder_rec)
   (list INITIAL_PLAYER_POS
         (make-posn 600 300)
         (make-posn 700 800)
         (make-posn 700 1000)
         (make-posn 700 70)
         (make-posn 500 1000)
         (make-posn 900 1000))
   BACKGROUND))


(define-struct none [] )
(define NONE (make-none))

; an hp_general is a structure: (make-hp_general images positions)
;   where:
;   - images: List<Image>
;   - positions: List<Posn>
; interpretation: a structure that describes the hp of some sprite
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

(define INITIAL_APP_STATE (make-appState INITIAL_CANVAS INITIAL_PLAYER NONE "boss" 10 #true))
;(define AP2 (make-appState INITIAL_CANVAS INITIAL_PLAYER "boss" 10 #true))
;(define AP3 (make-appState INITIAL_CANVAS INITIAL_PLAYER "boss" 10 #true))

;--------------------------------------------------------------------------------------

; drawAppState: appState -> Image
; 

; handle-key: appState -> appState
;

; quit?: appState -> appState
;

; (big-bang INITIAL_CANVAS
;   (on-tick tick-expr rate-expr)
;   (on-key handle-key)
;   (to-draw drawAppState)
;   (stop-when quit?)
;   )

 
 