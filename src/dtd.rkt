;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Untitled) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)


;; Constants
(define BACKGROUND   (empty-scene 1920 1080))
(define PL_BOX (rectangle 400 "solid" "white"))

(define HP_SPRITE_PL_INITIAL (place-images
    (list
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red"))
    (list
       (make-posn 300 1000)
       (make-posn 400 1000)
       (make-posn 500 1000)
       (make-posn 600 1000)
       (make-posn 700 1000))
    BACKGROUND
))

(define HP_SPRITE_B_INITIAL (place-images
    (list
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red")
       (circle 50 "solid" "red"))
    (list
       (make-posn 300 100)
       (make-posn 400 100)
       (make-posn 500 100)
       (make-posn 600 100)
       (make-posn 700 100)
       (make-posn 300 200)
       (make-posn 400 200)
       (make-posn 500 200)
       (make-posn 600 200)
       (make-posn 700 200))
    BACKGROUND
))


(define KNIFE_SPRITE (bitmap "../resources/knife.png"))
(define BALL_SPRITE  (bitmap "../resources/ball.png"))
(define ARROW_SPRITE (bitmap "../resources/arrow.png"))
(define SWORD_SPRITE (bitmap "../resources/sword.png"))
(define PL_SPRITE    (bitmap "../resources/player.png"))
(define BS_SPRITE_N  (bitmap "../resources/normal.png"))
(define BS_SPRITE_R  (bitmap "../resources/rage.png"))
(define INITIAL_PLAYER_POS (make-posn 500 700))

(define INITIAL_CANVAS (place-images
   (list PL_SPRITE
         BS_SPRITE_N
         PL_BOX
         HP_SPRITE_PL_INITIAL
         HP_SPRITE_B_INITIAL)
   (list IP
         (make-posn 500 100)
         (make-posn 500 900)
         (make-posn 8 14))
   BACKGROUND))


(define-struct none [] #:transparent)
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
(define-struct player [sprite hp position] #:transparent)

;; Data examples
(define INITAL_PLAYER (make-player PL_SPRITE 5 IP) )
(define PL1 (make-player PL_SPRITEP 3 (make-posn 600 750)) )
(define PL2 (make-player PL_SPRITE 3 (make-posn 500 850)) )

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
(define-struct entity [sprite position collided?] #:transparent)

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
(define-struct appState [canvas p e s boss running?] #:transparent)

;; Data examples

(define INITIAL_APP_STATE (make-appState INITIAL_CANVAS INITIAL_PLAYER "boss" 10 #true))
(;define AP2 (make-appState INITIAL_CANVAS INITIAL_PLAYER "boss" 10 #true))
;(define AP3 (make-appState INITIAL_CANVAS INITIAL_PLAYER "boss" 10 #true))
;--------------------------------------------------------------------------------------

; (big-bang INITIAL_APP_STATE
;   (on-tick tick-expr rate-expr)
;   (on-key key-expr)
;   (to-draw draw-expr)
;   (stop-when stop-expr)
;   (stop-when stop-expr last-scene-expr))
 