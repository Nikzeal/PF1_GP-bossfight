;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname on-tick) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; LIBRARIES
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

(require "data.rkt")

(provide (all-defined-out))

;;; ======== TICK ========

;; INPUT/OUTPUT
; signature: tick: appState -> appState
; purpose:   handles the movement of the player every tick so that in the boss' turn it
;            can change the player position in the box and the entities position, while
;            in the player's turn it can change position between the two attack and heal boxes
;            It handles the rage transition time too.
; header:    (define (tick state) GAME_APP_STATE)

;; EXAMPLES
(check-expect (tick MENU_APP_STATE) MENU_APP_STATE)
(check-expect (tick END_APP_STATE ) END_APP_STATE)

;; TEMPLATE
; (define (tick state)
;   (cond
;     [(and (< (appState-change-turn state) 117) (string=? (appState-s state) "rage")) ... state ...]
;     [(and (= (appState-change-turn state) 117) (string=? (appState-s state) "rage")) ... state ...]
;     [(and (< (appState-change-turn state) 30 ) (string=? (appState-s state) "boss")) ... state ...]
;     [(and (< (appState-change-turn state) 500) (string=? (appState-s state) "boss")) ... state ...]
;     [(= (appState-change-turn state) 500)                                            ... state ...]
;     [else                                                                            ... state ...]))

;; CODE
(define (tick state)
  (cond
    ; handles the tick counter during the rage transition 
    [(and (< (appState-change-turn state) 117) (string=? (appState-s state) "rage"))
     (make-appState (appState-canvas state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    (add1 (appState-change-turn state)))]
    ; stop and reset the timer and pass state to "boss"
     [(and (= (appState-change-turn state) 117) (string=? (appState-s state) "rage"))
     (make-appState (appState-canvas state)
                    (appState-e state)
                    "boss"
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    0)]
    ; boss turn, make 30 ticks pass and position player at the center of the box
    ; after 30 ticks the turn starts
    [(and (< (appState-change-turn state) 30) (string=? (appState-s state) "boss"))
      (make-appState (appState-canvas state)
                     (make-entities
                      (entities-player-lp (appState-e state))
                      (boss-tick state)
                      (entities-enemies (appState-e state)))
                     (appState-s state)
                     (appState-boss state)
                     (appState-running? state)
                     (appState-movement state)
                     (add1 (appState-change-turn state)))]
    [(and (< (appState-change-turn state) 500) (string=? (appState-s state) "boss"))
      (make-appState (appState-canvas state)
                     (make-entities
                      (collision
                       (entities-player-pos (appState-e state))
                       (entities-player-lp (appState-e state))
                       (entities-enemies (appState-e state)))
                      (boss-tick state)
                      (entity-move state))
                     (end! (appState-s state) (appState-boss state) (entities-player-lp (appState-e state)))
                     (appState-boss state)
                     (appState-running? state)
                     (appState-movement state)
                     (add1 (appState-change-turn state)))]
    ; at 500 ticks, the tick counter resets to 0 and it begins the player turn
    [(= (appState-change-turn state) 500)
     (make-appState (appState-canvas state)
                    (make-entities
                     (entities-player-lp (appState-e state))
                     PL_OFFSET_ATTACK
                     '())
                    "player"
                    (appState-boss state)
                    (appState-running? state)
                    "still"
                    0)]
    ; all the other states: menu, player 
    [else state]))

;;; ======== COLLISION ========

;; INPUT/OUTPUT
; signature: collsion: Posn Number List<Posn> -> Number
; purpose:   remove a hp if the player collided with an entity
; header:    (define (collision player-pos player-lp enemies) 0)

;; EXAMPLES
(check-expect (collision (make-posn 500 500) 5 (list (make-posn 499 501) (make-posn 400 100))) 4)
(check-expect (collision (make-posn 500 500) 3 (list (make-posn 200 501) (make-posn 400 100))) 3)
(check-expect (collision (make-posn 500 500) 1 (list (make-posn 499 501) (make-posn 500 500))) 0)

;; TEMPLATE
; (define (collision player-pos player-lp enemies)
;   (cond
;     [(ormap (lambda (n) (>= 36 (distance n player-pos))) enemies) ...]
;     [else                                                         ...]))

;; CODE
(define (collision player-pos player-lp enemies)
  (cond
    [(ormap (lambda (n) (>= 36 (distance n player-pos))) enemies)
     (sub1  player-lp)]
    [else   player-lp]))

;;; ======== DISTANCE ========

;; INPUT/OUTPUT
; signature: distance: Posn Posn -> Number
; purpose:   compute the distance between two posns
; header:    (define (distance x y) 0)

;; TEMPLATE
; (define (distance x y)
;   ... (posn-x y) ... (posn-x x) ...
;   ... (posn-y y) ... (posn-y x) ...)

;; CODE
(define (distance x y)
  (sqrt (+ (sqr (- (posn-x y) (posn-x x)))
           (sqr (- (posn-y y) (posn-y x))))))

;;; ======== END! ========

;; INPUT/OUTPUT
; signature: end!: String Number Number -> String
; purpose:   check if the player has lost or won
; header:    (define (end! state boss-lp player-lp) "")

;; EXAMPLES
(check-expect (end! "boss"   7 4 ) "boss"  )
(check-expect (end! "player" 10 2) "player")
(check-expect (end! "player" 0 2 ) "end"   )

;; TEMPLATE
; (define (end! state boss-lp player-lp)
;   (cond
;     [(or (= boss-lp 0) (= player-lp 0)) ...]
;     [else                               ...]))

;; CODE
(define (end! state boss-lp player-lp)
  (cond
    [(or (= boss-lp 0) (= player-lp 0)) "end"]
    [else state]))

;;; ======== BOSS-TICK ========

;; INPUT/OUTPUT
; signature: boss-tick: appState -> Posn
; purpose:   when it's the boss' turn, checks if the player is in the borders of the box,
;            in that case it handles the movement normally, otherwise it changes the position
;            to "still". If the player is against the border, some movement are limited (he
;            cannot surpass the box borders)
; header:    (define (boss-tick state) (make-posn 0 0))

;; EXAMPLES
(check-expect (boss-tick MENU_APP_STATE) (make-posn 700 600))
(check-expect (boss-tick GAME_APP_STATE) INITIAL_PLAYER_POS)
(check-expect (boss-tick END_APP_STATE ) (make-posn 700 600))

;; TEMPLATE
; (define (boss-tick state)
;   (cond
;     [(and (< (+ PL_BOX_LEFT   (/ PL_WIDTH  2))
;              (posn-x (player-position (appState-p state)))
;              (- PL_BOX_RIGHT  (/ PL_WIDTH  2)))
;           (< (+ PL_BOX_TOP    (/ PL_HEIGHT 2))
;              (posn-y (player-position (appState-p state)))
;              (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
;           ...]
;     [else ...]))

;; CODE
(define (boss-tick state)
  (cond
    ; it displays the player in the center of the box at the start of the turn
    [(< (appState-change-turn state) 1) INITIAL_PLAYER_POS]
    ; check if the player is inside the box  -> see boss-tick-box
    [(and (< (+ PL_BOX_LEFT   (/ PL_WIDTH  2))
             (posn-x (entities-player-pos (appState-e state)))
             (- PL_BOX_RIGHT  (/ PL_WIDTH  2)))
          (< (+ PL_BOX_TOP    (/ PL_HEIGHT 2))
             (posn-y (entities-player-pos (appState-e state)))
             (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
     (boss-tick-box state)]
    ; check if the player is outside the box -> see boss-tick-border
    [else
     (boss-tick-border state)]))

;;; ======== BOSS-TICK-BOX ========

;; INPUT/OUTPUT
; signature: boss-tick-box: appState -> Posn
; purpose:   handles the movement of the player by looking at the movement in the structure
; header:    (define (boss-tick-box state) (make-posn 0 0))

;; EXAMPLES
(check-expect (boss-tick MENU_APP_STATE) (make-posn 700 600))
(check-expect (boss-tick GAME_APP_STATE) INITIAL_PLAYER_POS)
(check-expect (boss-tick END_APP_STATE ) (make-posn 700 600))

;; TEMPLATE
; (define (boss-tick-box state)
;   (cond
;     [(or (string=? (appState-movement state) "left" )
;          (string=? (appState-movement state) "up"   )) ... state ...]
;     [(or (string=? (appState-movement state) "right")
;          (string=? (appState-movement state) "down" )) ... state ...]
;     [else                                              ... state ...]))

;; CODE
(define (boss-tick-box state)
  (cond
    ; check if movement is "left" or "up" and decrements the x or y position    -> see player-move
    [(or (string=? (appState-movement state) "left"  )
         (string=? (appState-movement state) "up"    ))
     (player-move  (entities-player-pos (appState-e state)) (appState-movement state) -)]
    ; check if movement is "right" or "down" and increments the x or y position -> see player-move
    [(or (string=? (appState-movement state) "right" )
         (string=? (appState-movement state) "down"  ))
     (player-move  (entities-player-pos (appState-e state)) (appState-movement state) +)]
    [else          (entities-player-pos (appState-e state))]))

;;; ======== PLAYER-MOVE  ========

;; INPUT/OUTPUT
; signature: player-move: Posn String [Number Number -> Number] -> Posn
; purpose:   changes the position of the player by 100/FRAME pixels
;            based on the movement `m` by increasing or decreasing its position based
;            on the function `fun`
; header:    (define (player-move p m fun) (make-posn 0 0))

;; EXAMPLES
(check-expect (player-move (make-posn 500 500) "right" +) (make-posn 506 500))
(check-expect (player-move (make-posn 500 500) "left"  -) (make-posn 494 500))
(check-expect (player-move (make-posn 500 500) "up"    +) (make-posn 500 506))

;; TEMPLATE
;(define (player-move p m fun)
;  (cond
;    [(or (string=? m "right") (string=? m "left")) ... (player-position p) ...]
;    [(or (string=? m "up")    (string=? m "down")) ... (player-position p) ...]))

;; CODE
(define (player-move player-pos m fun)
  (cond
    [(or (string=? m "right") (string=? m "left"))
               (make-posn (fun (posn-x player-pos) (* BASE_SPEED FRAME))
                          (posn-y player-pos))]
    [(or (string=? m "up"   ) (string=? m "down"))
               (make-posn (posn-x player-pos)
                          (fun (posn-y player-pos) (* BASE_SPEED FRAME)))]))

;;; ======== BOSS-TICK-BORDER ========

;; INPUT/OUTPUT
; signature: boss-tick-border: appState -> Posn
; purpose:   moves the player by some pixels in the opposite direction of the border it goes into
;            when the player reaches one of the borders of the PL_BOX
; header:    (define (boss-tick-border state) (make-posn 0 0))

;; EXAMPLES
(check-expect (boss-tick-border MENU_APP_STATE) (make-posn 720 473.5))
(check-expect (boss-tick-border GAME_APP_STATE) INITIAL_PLAYER_POS)

;; TEMPLATE
; (define (boss-tick-border state)
;   (cond
;     [(<= (posn-x (player-position (appState-p state))) (+ PL_BOX_LEFT   (/ PL_WIDTH 2 )))
;           ... state ...]
;     [(>= (posn-y (player-position (appState-p state))) (- PL_BOX_BOTTOM (/ PL_HEIGHT 2)))
;           ... state ...]
;     [(>= (posn-x (player-position (appState-p state))) (- PL_BOX_RIGHT  (/ PL_WIDTH 2 )))
;           ... state ...]
;     [(<= (posn-y (player-position (appState-p state))) (+ PL_BOX_TOP    (/ PL_HEIGHT 2)))
;           ... state ...]
;     [else ... state ...]))

;; CODE
(define (boss-tick-border state)
  (cond
    ; check if the player is against the left border, moves the player x by 1 px before the left border
    [(<= (posn-x (entities-player-pos (appState-e state))) (+ PL_BOX_LEFT (/ PL_WIDTH 2)))
     (make-posn (add1 (+ PL_BOX_LEFT (/ PL_WIDTH 2))) (posn-y (entities-player-pos (appState-e state))))]
    ; check if the player is against the bottom border, moves the player y by 1 px before the bottom border
    [(>= (posn-y (entities-player-pos (appState-e state))) (- PL_BOX_BOTTOM (/ PL_HEIGHT 2)))
     (make-posn (posn-x (entities-player-pos (appState-e state))) (sub1 (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))]
    ; check if the player is against the right border, moves the player x by 1 px before the right border
    [(>= (posn-x (entities-player-pos (appState-e state))) (- PL_BOX_RIGHT (/ PL_WIDTH 2)))
     (make-posn (sub1 (- PL_BOX_RIGHT (/ PL_WIDTH 2))) (posn-y (entities-player-pos (appState-e state))))]
    ; check if the player is against the upper border, moves the player y by 1 px before the top border
    [(<= (posn-y (entities-player-pos (appState-e state))) (+ PL_BOX_TOP (/ PL_HEIGHT 2)))
     (make-posn (posn-x (entities-player-pos (appState-e state))) (add1 (+ PL_BOX_TOP (/ PL_HEIGHT 2))))]
    [else (entities-player-pos (appState-e state))]))

;;; ======== ENTITY-MOVE  ========

;; INPUT/OUTPUT
; signature: entity-move: appState -> List<Posn>
; purpose:   handles the movement of the entities accross the canvas
; header:    (define (entity-move state) (list (make-posn 0 0) (make-posn 0 0)))

;; TEMPLATE
;(define (entity-move state)
;  (cond
;    [(empty? (entities-enemies (appState-e state)))   ... ]
;    [(ormap (lambda (n) (>= 37 (distance n (entities-player-pos (appState-e state)))))
;            (entities-enemies (appState-e state)))    ... ]
;    [else                                             ... ]))

;; CODE
(define (entity-move state)
  (cond
    ; if the entities are empty build a list
    [(empty? (entities-enemies (appState-e state)))
      (build-list 7 (lambda (n) (make-posn (- (random 200) 220) (+ (random 300) 450))))]
    ; check for collisions and remove the collided entities from the list
    [(ormap (lambda (n) (>= 37 (distance n (entities-player-pos (appState-e state))))) (entities-enemies (appState-e state)))
     (filter (lambda (n) (< 37 (distance n (entities-player-pos (appState-e state))))) (entities-enemies (appState-e state)))]
    ; move the entities
    [else
     (entity-reset (entities-enemies (appState-e state)) (appState-boss state))]))

;;; ======== ENTITY-RESET ========

; signature: entity-reset: entities -> List<Posn>
; purpose:   resets the entities x positions to the opposite border when they go out of a border
; header:    (define (entity-reset en) (list (make-posn 0 0) (make-posn 0 0)))
 
;; TEMPLATE
;(define (entity-reset en)
; (cond
;    [(and (ormap (lambda (n) (<= 0 (posn-x n) 1440)) en) (<= boss 5))
;           ... (entities-positions en) ...]
;    [(and (ormap (lambda (n) (<= 0 (posn-x n) 1440)) en) ( > boss 5))
;           ... (entities-positions en) ...]
;    [else  ... (entities-positions en) ...]))

;; CODE
(define (entity-reset en boss)
  (cond
    ; make entities move at random speed if the phase is rage
    [(and (ormap (lambda (n) (<= 0 (posn-x n) 1440)) en) (<= boss 5))
      (map (lambda (n)
             (make-posn (+ (posn-x n) (* (random 500 5000) FRAME)) (+ (posn-y n) (* (random -200 300) FRAME)) ))
           en)]
    ; make entities move at regular speed if the phase is normal
    [(and (ormap (lambda (n) (<= 0 (posn-x n) 1440)) en) (> boss 5))
      (map (lambda (n)
             (make-posn (+ (posn-x n) (* ENTITY_SPEED FRAME)) (posn-y n) ) )
           en)]
    ; spawn entities to the left if their positions are not inside the screen
    [else
      (build-list 7 (lambda (n) (make-posn (random 200) (+ (random 300) 450))))]))