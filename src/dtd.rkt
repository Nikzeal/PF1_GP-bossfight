;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname dtd) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))

(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

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
(define EMPTY (make-entities '() '() ))
(define KNIFES (make-entities (build-list 5 (lambda (n) KNIFE_SPRITE)) (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define ARROWS (make-entities (build-list 5 (lambda (n) ARROW_SPRITE)) (build-list 5 (lambda (n) (make-posn (random 400) (random 300)))) ))
(define SWORD (make-entities (build-list 1 (lambda (n) SWORD_SPRITE)) (build-list 1 (lambda (n) (make-posn (random 400) (random 300)))) ))
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

;--------------------------------------------------------------------------------------

;;; ======== DRAW-ENTITIES ========

; draw-entities: appState -> Image
; draws the appstate on the boss' turn with entities
; header: (define (draw-entities as) INITIAL_CANVAS)

;; TEMPLATE
; (define (draw-turn as)
;   ... (draw-lp (player-hp (appState-p as))) ...
;   ... (draw-lp (appState-boss as)) ...
;   ... (entities-sprites (appState-e as))) ...
;   ... (entities-positions (appState-e as))) ...
;   ... PL_SPRITE ...
;   ... BS_SPRITE_N ...
;   ... PL_BOX ...
;   ... placeholder_rec ...
;   ... (player-position (appState-p as)) ...
; )

(define (draw-entities as)
   (place-images
    (list PL_SPRITE
          BS_SPRITE_N
          PL_BOX
          (draw-lp (player-hp (appState-p as)))
          (draw-lp (appState-boss as))
          placeholder_rec
          placeholder_rec
          ;entities
          (place-images
           (entities-sprites (appState-e as))
           (entities-positions (appState-e as))
           (rectangle 1440 300 "solid" "transparent"))
          )
    (list (player-position (appState-p as))
          BS_SPRITE_POSITION
          PL_BOX_POSITION
          LP_POSITION_PL
          LP_POSITION_BO
          ATK_BOX_POSITION
          HEAL_BOX_POSITION
          PL_BOX_POSITION)
    BACKGROUND))



;;; ======== DRAW-LP ========

; draw-lp: Number -> Image
; draws a certain `n` of images to display 
; header: (define (draw-lp n) HP_SPRITE_PL_INITIAL)

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

;;; ======== DRAW-TURN ========

; draw-turn: appState -> Image
; draws the appstate on the boss' or player's turn
; header: (define (drawTurn as) INITIAL_CANVAS)

;; TEMPLATE
; (define (draw-turn as)
;   ... (draw-lp (player-hp (appState-p as))) ...
;   ... (draw-lp (appState-boss as)) ...
;   ... (draw-entity (appState-e as)) ...
;   ... PL_SPRITE ...
;   ... BS_SPRITE_N ...
;   ... PL_BOX ...
;   ... placeholder_rec ...
;   ... (player-position (appState-p as)) ...
; ) 

;; CODE
(define (draw-turn as)
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

;;; ======== DRAW-STATE ========

; drawAppState: appState -> Image
; display the appState on the scene as an image
; header: (define (drawAppState as) BACKGROUND)

(check-expect (drawAppState INITIAL_APP_STATE) INITIAL_CANVAS)
(check-expect (drawAppState (make-appState BACKGROUND PL1 BALL "boss" 8 #true "still"))
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

;; TEMPLATE


;; CODE 
(define (drawAppState as)
  (cond
    [(and (string=? (appState-s as) "boss") (empty? (entities-sprites (appState-e as)))) (draw-turn as)]
    [else (draw-entities as)]
    ;[(or (= (as-s) "player-attack") (= (as-s) "player-heal")) (draw-action as)]
    ))

;--------------------------------------------------------------------------------------


;;; ======== HANDLE-KEY ========

;; INPUT/OUTPUT
; signature: handle-key: appState Key -> appState
; purpose:   checks for the turn and handles the key events based on it, if its the boss'
;            turn the player can move right, left, up or down, if its the player's turn
;            it can move in two positions, which are the heal and attack box positions
; header:    (define (handle-key state key) INITIAL_APP_STATE)

;; EXAMPLES
;(check-expect (handle-key INITIAL_APP_STATE "right")
 ;             (make-appState BACKGROUND INITIAL_PLAYER NONE "boss" 10 #true "right"))
;(check-expect (handle-key AP2 "left")
 ;             (make-appState BACKGROUND PL1 BALLS "boss" 10 #true "left"))
;(check-expect (handle-key AP3 "up")
;              (make-appState BACKGROUND PL2 BALLS "boss" 10 #true "up"))
;(check-expect (handle-key AP4 "right")
 ;             (make-appState BACKGROUND (make-player PL_SPRITE 5 HEAL_BOX_POSITION)
  ;                           NONE "player" 10 #false "still"))

;; TEMPLATE
; (define (handle-key state key)
;   (cond
;     [(string=? (appState-s state) "boss"  ) ... state ... key ...]
;     [(string=? (appState-s state) "player") ... state ... key ...]
;     [else                                   ... state ... key ...]))

;; CODE
(define (handle-key state key)
  (cond
    ; check if it is the boss turn   -> see boss-key function
    [(string=? (appState-s state) "boss")
     (make-appState (appState-canvas state)
                    (appState-p state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (boss-key key))]
    ; check if it is the player turn -> see player-key funcion
    [(string=? (appState-s state) "player")
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (player-hp (appState-p state))
                                 (player-key key))
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state))]
    [else state]))

;;; ======== BOSS-KEY ========

;; INPUT/OUTPUT
; signature: boss-key: Key -> String
; purpose:   handles the key events for the boss turn
; header:    (define (boss-key state key) "")

;; TEMPLATE
; (define (boss-key key)
;   (cond
;    [(key=? key "right") ...]
;    [(key=? key "left" ) ...]
;    [(key=? key "up"   ) ...]
;    [(key=? key "down" ) ...]
;    [else                ...]))

;; CODE
(define (boss-key key)
  (cond
    ; checks if the pressed key is "right" and return movement as "right"
    [(key=? key "right") "right"]
    ; checks if the pressed key is "left" and return movement as "left"
    [(key=? key "left")  "left" ]
    ; checks if the pressed key is "up" and return movement as "up"
    [(key=? key "up")    "up"   ]
    ; checks if the pressed key is "down" and return movement as "down"
    [(key=? key "down")  "down" ]
    ; if no key is pressed, return the "still" state
    [else                "still"]))

;;; ======== PLAYER-KEY ========

;; INPUT/OUTPUT
; signature: player-key: Key -> Number
; purpose:   handles the key events for the player turn
; header:    (define (player-key state key) 0)

;; TEMPLATE
; (define (player-key key)
;   (cond
;     [(key=? key "left")  ...]
;     [(key=? key "right") ...]
;     [else                ...]))

;; CODE
(define (player-key key)
  (cond
    ; check if the pressed key is "left" and place the player on the attack box
    [(key=? key "left")  ATK_BOX_POSITION]
    ; check if the pressed key is "right" and place the player on the heal box
    [(key=? key "right") HEAL_BOX_POSITION]
    ; if no key is pressed, return the "still" state
    [else       "still"]))

;--------------------------------------------------------------------------------------

;;; ======== HANDLE-RELEASE ========

;; INPUT/OUTPUT
; signature: handle-release: appState Key -> appState
; purpose:   checks for the turn and handles the key events based on it, if its the boss'
;            turn the player movement stops when releasing the key, if its the player's turn
;            it does not do anything
; header:    (define (handle-release state key) INITIAL_APP_STATE)

;; EXAMPLES
;(check-expect (handle-release INITIAL_APP_STATE "right") INITIAL_APP_STATE)
;(check-expect (handle-release AP2               "left" ) AP2              )
;(check-expect (handle-release AP3               "up"   ) AP3              )
;(check-expect (handle-release AP4               "right") AP4              )

;; TEMPLATE
; (define (handle-release state key)
;    (cond
;     [(string=? (appState-s state) "boss") ... state ...]
;     [else                                 ... state ...]))

;; CODE
(define (handle-release state key)
   (cond
     ; check if it is the boss turn -> see boss-release
    [(string=? (appState-s state) "boss")
     (make-appState (appState-canvas state)
                    (appState-p state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    "still")]
    [else state]))

;--------------------------------------------------------------------------------------

;;; ======== TICK ========

;; INPUT/OUTPUT
; signature: tick: appState -> appState
; purpose:   handles the movement of the player every tick so that in the boss' turn it
;            can change position in the box, while in the player's turn it can change
;            position between the two attack and heal boxes
; header:    (define (tick state) INITIAL_APP_STATE)

;; EXAMPLES
(check-expect (tick INITIAL_APP_STATE) INITIAL_APP_STATE)
(check-expect (tick AP2)               (make-appState BACKGROUND
                                                      (make-player PL_SPRITE 3 (make-posn 600 749))
                                                      BALLS "boss" 10 #true "still"))
(check-expect (tick AP3)               (make-appState BACKGROUND
                                                      (make-player PL_SPRITE 3 (make-posn 501 850))
                                                      BALLS "boss" 10 #true "still"))
(check-expect (tick AP4)               AP4)

;; TEMPLATE
; (define (tick state)
;   (cond
;     [(string=? (appState-s state) "boss"  ) ... state ...]
;     [(string=? (appState-s state) "player") ... state ...]))

;; CODE
(define (tick state)
  (cond
    ; check if it is the boss turn   -> see boss-tick
    [(string=? (appState-s state) "boss"  ) (boss-tick state)]
    ; check if it is the player turn -> see player-tick
    [(string=? (appState-s state) "player") (player-tick state)]
    [else state]))

;;; ======== BOSS-TICK ========

;; INPUT/OUTPUT
; signature: boss-tick: appState player -> appState
; purpose:   when it's the boss' turn, checks if the player is in the borders of the box,
;            in that case it handles the movement normally, otherwise it changes the position
;            to "still"
; header:    (define (boss-tick state) INITIAL_APP_STATE)

;; TEMPLATE
; (define (boss-tick state)
;   (cond
;     [(and (< 500 (posn-x (player-position (appState-p state))) 900)
;           (< 450 (posn-y (player-position (appState-p state))) 750))
;           ... state ...]
;     [else ... state ...]))

;; CODE
(define (boss-tick state)
  (cond
    ; check if the player is inside the box  -> see boss-tick-box
    [(and (< (+ PL_BOX_LEFT (/ PL_WIDTH 2)) (posn-x (player-position (appState-p state))) (- PL_BOX_RIGHT (/ PL_WIDTH 2)))
          (< (+ PL_BOX_TOP (/ PL_HEIGHT 2))  (posn-y (player-position (appState-p state))) (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
          (make-appState (appState-canvas state)
                    (make-player PL_SPRITE  (player-hp (appState-p state)) (boss-tick-box state))
                    (entity-move state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state))]
    ; check if the player is outside the box -> see boss-tick-border
    [else
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE  (player-hp (appState-p state)) (boss-tick-border state))
                    (entity-move state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state))]))

;;; ======== ENTITY-MOVE  ========

;; INPUT/OUTPUT
; signature: entity-move: appState -> entity
; purpose:   handles the movement of the entities accross the canvas
; header:    (define (entity-move state) BALL)

;; TEMPLATE
;(define (entity-move state)
;  (cond
;    [(and (empty? (entities-sprites (appState-e state)))
;          (empty? (entities-positions (appState-e state))))
;     ... BALL_SPRITE ... (random 400) ... (random 300) ...]
;    [else ... (entities-sprites (appState-e state)) ...
;     ... BASE_SPEED ... FRAME ... (entities-positions (appState-e state))]))


;; CODE
(define (entity-move state)
  (cond
    [(and (empty? (entities-sprites (appState-e state)))
          (empty? (entities-positions (appState-e state))))
     (make-entities (build-list  7 (lambda (n) BALL_SPRITE)) (build-list 7 (lambda (n) (make-posn (random 200) (+ (random 250) 51)))))]
    [else  (entity-reset (appState-e state))]))

;(define posns (list (make-posn 10 20) (make-posn 30 20) (make-posn 40 20)))
;;; ======== ENTITY-RESET ========

; signature: entity-reset: entities -> entities
; purpose:   resets the entities x positions to the opposite border when they go out of a border
; header:    (define (entity-reset en) BALLS)
 
;; TEMPLATE
;(define (entity-reset en)
; (cond
;    [(andmap (lambda (n) (<= 0 (posn-x n) 400))(entities-positions en))
;       ... (entities-sprites en) ... (entities-positions en) ...]
;    [else  ... (entities-sprites en) ... (entities-positions en) ...]))


(define (entity-reset en)
  (cond
    [(ormap (lambda (n)
               (<= 0
                   (posn-x n)
                   1440))
             (entities-positions en))
     (make-entities (entities-sprites en)
                 (map (lambda (n)
                        (make-posn (+ (posn-x n) (* ENTITY_SPEED FRAME)) (posn-y n) ))
                      (entities-positions en)))]
    [else
     (make-entities (entities-sprites en)
                 (map (lambda (n)
                        (make-posn (random 200) (random 300) ))
                      (entities-positions en)))]))


;;; ======== BOSS-TICK-BOX ========

;; INPUT/OUTPUT
; signature: boss-tick-box: appState -> player
; purpose:   handles the movement of the player by looking at the movement in the structure
; header:    (define (boss-tick-box state) INITIAL_APP_STATE)

;; TEMPLATE
; (define (boss-tick-box state)
;   (cond
;     [(or (string=? (appState-movement state) "left") (string=? (appState-movement state) "up")) ... state ...]
;     [(or (string=? (appState-movement state) "right") (string=? (appState-movement state) "down")) ... state ...]
;     [else                                         ... state ....]))


;; CODE
(define (boss-tick-box state)
  (cond
    ; check if movement is "left" or "up" and decrements the x or y position-> see player-move
    [(or (string=? (appState-movement state) "left") (string=? (appState-movement state) "up"))
     (player-move (appState-p state) (appState-movement state) -)]
    ; check if movement is "right" or "down" and increments the x or y position-> see player-move
    [(or (string=? (appState-movement state) "right") (string=? (appState-movement state) "down"))
     (player-move (appState-p state) (appState-movement state) +)]
    [else (player-position (appState-p state))]))

;;; ======== PLAYER-MOVE  ========

;; INPUT/OUTPUT
; signature: player-move: player movement [Number Number -> Number] -> player
; purpose:   changes the position of the player by 100/FRAME pixels
;            based on the movement `m` by increasing or decreasing its position based on the function `fun`
; header:    (define (player-move p m fun) INITIAL_PLAYER)

;; TEMPLATE
;(define (player-move p m fun)
;  (cond
;    [(or (string=? m "right") (string=? m "left")) ... (player-position p) ...]
;    [(or (string=? m "up") (string=? m "down")) ... (player-position p) ...]))

;; CODE
(define (player-move p m fun)
  (cond
    [(or (string=? m "right") (string=? m "left"))
               (make-posn (fun (posn-x (player-position p)) (* BASE_SPEED FRAME))
                          (posn-y (player-position p)))]
    [(or (string=? m "up") (string=? m "down"))
               (make-posn (posn-x (player-position p))
                          (fun (posn-y (player-position p)) (* BASE_SPEED FRAME)))]))


;;; ======== BOSS-TICK-BORDER ========

;; INPUT/OUTPUT
; signature: boss-tick-border: appState -> appState
; purpose:   moves the player by some pixels in the opposite direction of the border it goes into
;            when the player reaches one of the borders of the PL_BOX
; header:    (define (boss-tick-border state) INITIAL_APP_STATE)

;; TEMPLATE
; (define (boss-tick-border state)
;   (cond
;     [(and (<= (posn-x (player-position (appState-p state))) 500)
;           (string=? (appState-movement state) "left" ))
;           ... state ...]
;     [(and (>= (posn-y (player-position (appState-p state))) 750)
;           (string=? (appState-movement state) "down" ))
;           ... state ...]
;     [(and (>= (posn-x (player-position (appState-p state))) 900)
;           (string=? (appState-movement state) "right"))
;           ... state ...]
;     [(and (<= (posn-y (player-position (appState-p state))) 450)
;           (string=? (appState-movement state) "up"   ))
;           ... state ...]
;     [else ... state ...]))

;; CODE
(define (boss-tick-border state)
  (cond
    ; check if the player is against the left border, moves the player x by 1 px before the left border
    [(<= (posn-x (player-position (appState-p state))) (+ PL_BOX_LEFT (/ PL_WIDTH 2)))
     (make-posn (add1 (+ PL_BOX_LEFT (/ PL_WIDTH 2))) (posn-y (player-position (appState-p state))))]
    ; check if the player is against the bottom border, moves the player y by 1 px before the bottom border
    [(>= (posn-y (player-position (appState-p state))) (- PL_BOX_BOTTOM (/ PL_HEIGHT 2)))
     (make-posn (posn-x (player-position (appState-p state))) (sub1 (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))]
    ; check if the player is against the right border, moves the player x by 1 px before the right border
    [(>= (posn-x (player-position (appState-p state))) (- PL_BOX_RIGHT (/ PL_WIDTH 2)))
     (make-posn (sub1 (- PL_BOX_RIGHT (/ PL_WIDTH 2))) (posn-y (player-position (appState-p state))))]
    ; check if the player is against the upper border, moves the player y by 1 px before the top border
    [(<= (posn-y (player-position (appState-p state))) (+ PL_BOX_TOP (/ PL_HEIGHT 2)))
     (make-posn (posn-x (player-position (appState-p state))) (add1 (+ PL_BOX_TOP (/ PL_HEIGHT 2))))]
    [else (player-position (appState-p state))]))

;;; ======== PLAYER-TICK ========

;; INPUT/OUTPUT
; signature: player-tick: appState -> appState
; purpose:   when it's the player's turn, its tick state is still
; header:    (define (player-tick state) INITIAL_APP_STATE)

;; TEMPLATE
; (define (player-tick state) ... state ...)

;; CODE
(define (player-tick state)
  (make-appState (appState-canvas state)
                 (appState-p state)
                 (appState-e state)
                 (appState-s state)
                 (appState-boss state)
                 (appState-running? state)
                 "still"))


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
   (on-tick tick FRAME)
   (on-key handle-key)
   (on-release handle-release)
   (to-draw drawAppState)
   ;(display-mode 'fullscreen)
   ;(on-receive rec-expr)
   (stop-when quit?))

 
 