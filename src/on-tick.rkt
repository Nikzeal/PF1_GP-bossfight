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
;            can change position in the box, while in the player's turn it can change
;            position between the two attack and heal boxes
; header:    (define (tick state) INITIAL_APP_STATE)

;; EXAMPLES
; (check-expect (tick INITIAL_APP_STATE) INITIAL_APP_STATE)
; (check-expect (tick AP2)               (make-appState
;                                        BACKGROUND
;                                        (make-player
;                                        PL_SPRITE 3
;                                        (make-posn 600 (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
;                                        BALLS "boss" 10 #true "still"))
; (check-expect (tick AP3)               (make-appState
;                                         BACKGROUND
;                                          (make-player
;                                           PL_SPRITE 3
;                                           (make-posn (+ PL_BOX_LEFT (/ PL_WIDTH 2)) 850))
;                                         BALLS "boss" 10 #true "still"))
; (check-expect (tick AP4)               AP4)

;; TEMPLATE
; (define (tick state)
;   (cond
;     [(string=? (appState-s state) "boss"  ) ... state ...]
;     [(string=? (appState-s state) "player") ... state ...]))

;; CODE
(define (tick state)
  (cond
    ; check if it is the boss turn   -> see boss-tick
    [ (< (appState-change-turn state) 499)
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (collision (appState-p state) (appState-e state))
                                 (boss-tick state))
                    (entity-move state)
                    "boss"
                    (appState-boss state)
                    (end? (appState-p state))
                    (appState-movement state)
                    (add1 (appState-change-turn state)))]
    ; check if it is the player turn and display the player on the ATK button
    [(= (appState-change-turn state) 499)
      (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (player-hp (appState-p state))
                                 ATK_BOX_POSITION)
                    BALLS
                    "player"
                    (appState-boss state)
                    (appState-running? state)
                    "still"
                    (add1 (appState-change-turn state)))]
    ; let the player decide which action choose
    [else
     (make-appState (appState-canvas state)
                    (appState-p state)
                     (make-entities
                      (build-list 7 (lambda (n) BALL_SPRITE))
                      (build-list 7 (lambda (n) (make-posn (- (random 200) 210) (+ (random 300) 450))))) 
                    "player"
                    (appState-boss state)
                    (end? (appState-p state))
                    "still"
                    (appState-change-turn state))]))

;;; ======== COLLISION ========

;; INPUT/OUTPUT
; signature: collsion: player entities -> Number
; purpose:   remove a hp if the player collided with an entity
; header:    (define (collision p e) 0)

;; TEMPLATE
; (define (collision p e)
;   (cond
;     [(or (>= 79 (distance (first   (entities-positions e)) (player-position p)))
;          (>= 79 (distance (second  (entities-positions e)) (player-position p)))
;          (>= 79 (distance (third   (entities-positions e)) (player-position p)))
;          (>= 79 (distance (fourth  (entities-positions e)) (player-position p)))
;          (>= 79 (distance (fifth   (entities-positions e)) (player-position p)))
;          (>= 79 (distance (sixth   (entities-positions e)) (player-position p)))
;          (>= 79 (distance (seventh (entities-positions e)) (player-position p))))
;           ...]
;     [else ...]))

;; CODE
(define (collision p e)
  (cond
    ;[]
    ; check if the distance is lower than the sum of the radius of the two images -> see distance
    [(or (>= 37 (distance (first   (entities-positions e)) (player-position p)))
         (>= 37 (distance (second  (entities-positions e)) (player-position p)))
         (>= 37 (distance (third   (entities-positions e)) (player-position p)))
         (>= 37 (distance (fourth  (entities-positions e)) (player-position p)))
         (>= 37 (distance (fifth   (entities-positions e)) (player-position p)))
         (>= 37 (distance (sixth   (entities-positions e)) (player-position p)))
         (>= 37 (distance (seventh (entities-positions e)) (player-position p))))
     (sub1 (player-hp p)) ]
    [else (player-hp p)]))

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

;;; ======== END? ========

;; INPUT/OUTPUT
; signature: end?: player -> Boolean
; purpose:   quit the big-bang whenever the game has ended (lost or won)
; header:    (define (end? p) #false)

;; TEMPLATE
; (define (end? p)
;   (cond
;     [(= (player-hp p) 0) ...]
;     [else                ...]))

;; CODE
(define (end? p)
  (cond
    [(= (player-hp p) 0) #false]
    [else #true]))

;;; ======== BOSS-TICK ========

;; INPUT/OUTPUT
; signature: boss-tick: appState -> Posn
; purpose:   when it's the boss' turn, checks if the player is in the borders of the box,
;            in that case it handles the movement normally, otherwise it changes the position
;            to "still". If the player is against the border, some movement are limited (he
;            cannot surpass the box borders)
; header:    (define (boss-tick state) (make-posn 0 0))

;; TEMPLATE
; (define (boss-tick state)
;   (cond
;     [(and (< (+ PL_BOX_LEFT (/ PL_WIDTH 2))
;              (posn-x (player-position (appState-p state)))
;              (- PL_BOX_RIGHT (/ PL_WIDTH 2)))
;           (< (+ PL_BOX_TOP (/ PL_HEIGHT 2))
;              (posn-y (player-position (appState-p state)))
;              (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
;           ...]
;     [else ...]))

;; CODE
(define (boss-tick state)
  (cond
    ; check if the player is inside the box  -> see boss-tick-box
    [(and (< (+ PL_BOX_LEFT (/ PL_WIDTH 2))
             (posn-x (player-position (appState-p state)))
             (- PL_BOX_RIGHT (/ PL_WIDTH 2)))
          (< (+ PL_BOX_TOP (/ PL_HEIGHT 2))
             (posn-y (player-position (appState-p state)))
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
    ; check if movement is "left" or "up" and decrements the x or y position-> see player-move
    [(or (string=? (appState-movement state) "left"  )
         (string=? (appState-movement state) "up"    ))
     (player-move  (appState-p state) (appState-movement state) -)]
    ; check if movement is "right" or "down" and increments the x or y position-> see player-move
    [(or (string=? (appState-movement state) "right" )
         (string=? (appState-movement state) "down"  ))
     (player-move  (appState-p state) (appState-movement state) +)]
    [else          (player-position (appState-p state))           ]))

;;; ======== PLAYER-MOVE  ========

;; INPUT/OUTPUT
; signature: player-move: player movement [Number Number -> Number] -> Posn
; purpose:   changes the position of the player by 100/FRAME pixels
;            based on the movement `m` by increasing or decreasing its position based
;            on the function `fun`
; header:    (define (player-move p m fun) (make-posn 0 0))

;; TEMPLATE
;(define (player-move p m fun)
;  (cond
;    [(or (string=? m "right") (string=? m "left")) ... (player-position p) ...]
;    [(or (string=? m "up")    (string=? m "down")) ... (player-position p) ...]))

;; CODE
(define (player-move p m fun)
  (cond
    [(or (string=? m "right") (string=? m "left"))
               (make-posn (fun (posn-x (player-position p)) (* BASE_SPEED FRAME))
                          (posn-y (player-position p)))]
    [(or (string=? m "up"   ) (string=? m "down"))
               (make-posn (posn-x (player-position p))
                          (fun (posn-y (player-position p)) (* BASE_SPEED FRAME)))]))

;;; ======== BOSS-TICK-BORDER ========

;; INPUT/OUTPUT
; signature: boss-tick-border: appState -> Posn
; purpose:   moves the player by some pixels in the opposite direction of the border it goes into
;            when the player reaches one of the borders of the PL_BOX
; header:    (define (boss-tick-border state) (make-posn 0 0))

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

;;; ======== ENTITY-MOVE  ========

;; INPUT/OUTPUT
; signature: entity-move: appState -> List<Posn>
; purpose:   handles the movement of the entities accross the canvas
; header:    (define (entity-move state) (list (make-posn 0 0) (make-posn 0 0)))

;; TEMPLATE
;(define (entity-move state)
;  (cond
;    [(and (empty? (entities-sprites   (appState-e state)))
;          (empty? (entities-positions (appState-e state))))
;          ... (random 400)                            ...
;          ... (random 300)                            ...]
;    [else ... BASE_SPEED                              ...
;          ... FRAME                                   ...
;          ... (entities-positions (appState-e state)) ...]))


;; CODE
(define (entity-move state)
  (cond
    ; check if the player collided with an entity
    [(or (>= 35 (distance (first   (entities-positions (appState-e state)))
                          (player-position (appState-p state))))
         (>= 35 (distance (second  (entities-positions (appState-e state)))
                          (player-position (appState-p state))))
         (>= 35 (distance (third   (entities-positions (appState-e state)))
                          (player-position (appState-p state))))
         (>= 35 (distance (fourth  (entities-positions (appState-e state)))
                          (player-position (appState-p state))))
         (>= 35 (distance (fifth   (entities-positions (appState-e state)))
                          (player-position (appState-p state))))
         (>= 35 (distance (sixth   (entities-positions (appState-e state)))
                          (player-position (appState-p state))))
         (>= 35 (distance (seventh (entities-positions (appState-e state)))
                          (player-position (appState-p state)))))
     (make-entities
      (build-list 7 (lambda (n) BALL_SPRITE))
      (collided? state))]
    [(and (empty? (entities-sprites   (appState-e state)))
          (empty? (entities-positions (appState-e state))))
     (make-entities
      (build-list 7 (lambda (n) BALL_SPRITE))
      (build-list 7 (lambda (n) (make-posn (random 200) (+ (random 300) 450)))))]
    [else
     (entity-reset (appState-e state))]))

;;; ======== COLLIDED? ========

;; INPUT/OUTPUT
; signature: collided?: appState -> List<Posn>
; purpose:   return the List of the entities positions without the entity that collided
;            with the player
; header:    (define (collided? state) (list (make-posn 0 0) (make-posn 0 0)))

;; TEMPLATE
; (define (collided? state)
;   (cond
;     [(> 50 (distance (first   (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [(> 50 (distance (second  (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [(> 50 (distance (third   (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [(> 50 (distance (fourth  (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [(> 50 (distance (fifth   (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [(> 50 (distance (sixth   (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [(> 50 (distance (seventh (entities-positions (appState-e state)))
;                      (player-position (appState-p state)))) ...]
;     [else                                                   ...]))

;; CODE
(define (collided? state)
  (cond
    [(> 50 (distance (first (entities-positions (appState-e state))) (player-position (appState-p state))))
     (list (make-posn 1500 0)
           (second (entities-positions (appState-e state)))
           (third (entities-positions (appState-e state)))
           (fourth (entities-positions (appState-e state)))
           (fifth (entities-positions (appState-e state)))
           (sixth (entities-positions (appState-e state)))
           (seventh (entities-positions (appState-e state))))]
    [(> 50 (distance (second (entities-positions (appState-e state))) (player-position (appState-p state))))
     (list (first (entities-positions (appState-e state)))
           (make-posn 1500 0)
           (third (entities-positions (appState-e state)))
           (fourth (entities-positions (appState-e state)))
           (fifth (entities-positions (appState-e state)))
           (sixth (entities-positions (appState-e state)))
           (seventh (entities-positions (appState-e state))))]
    [(> 50 (distance (third (entities-positions (appState-e state))) (player-position (appState-p state))))
      (list (first (entities-positions (appState-e state)))
           (second (entities-positions (appState-e state)))
           (make-posn 1500 0)
           (fourth (entities-positions (appState-e state)))
           (fifth (entities-positions (appState-e state)))
           (sixth (entities-positions (appState-e state)))
           (seventh (entities-positions (appState-e state))))]
    [(> 50 (distance (fourth (entities-positions (appState-e state))) (player-position (appState-p state))))
      (list (first (entities-positions (appState-e state)))
           (second (entities-positions (appState-e state)))
           (third (entities-positions (appState-e state)))
           (make-posn 1500 0)
           (fifth (entities-positions (appState-e state)))
           (sixth (entities-positions (appState-e state)))
           (seventh (entities-positions (appState-e state))))]
    [(> 50 (distance (fifth (entities-positions (appState-e state))) (player-position (appState-p state))))
      (list (first (entities-positions (appState-e state)))
           (second (entities-positions (appState-e state)))
           (third (entities-positions (appState-e state)))
           (fourth (entities-positions (appState-e state)))
           (make-posn 1500 0)
           (sixth (entities-positions (appState-e state)))
           (seventh (entities-positions (appState-e state))))]
    [(> 50 (distance (sixth (entities-positions (appState-e state))) (player-position (appState-p state))))
      (list (first (entities-positions (appState-e state)))
           (second (entities-positions (appState-e state)))
           (third (entities-positions (appState-e state)))
           (fourth (entities-positions (appState-e state)))
           (fifth (entities-positions (appState-e state)))
           (make-posn 1500 0)
           (seventh (entities-positions (appState-e state))))]
    [(> 50 (distance (seventh (entities-positions (appState-e state))) (player-position (appState-p state))))
      (list (first (entities-positions (appState-e state)))
           (second (entities-positions (appState-e state)))
           (third (entities-positions (appState-e state)))
           (fourth (entities-positions (appState-e state)))
           (fifth (entities-positions (appState-e state)))
           (sixth (entities-positions (appState-e state)))
           (make-posn 1500 0))]
    [else (entities-positions (appState-e state))]))

;;; ======== ENTITY-RESET ========

; signature: entity-reset: entities -> List<Posn>
; purpose:   resets the entities x positions to the opposite border when they go out of a border
; header:    (define (entity-reset en) (list (make-posn 0 0) (make-posn 0 0)))
 
;; TEMPLATE
;(define (entity-reset en)
; (cond
;    [(ormap (lambda (n) (<= 0 (posn-x n) 400)) (entities-positions en))
;           ... (entities-positions en) ...]
;    [else  ... (entities-positions en) ...]))

;; CODE
(define (entity-reset en)
  (cond
    [(ormap (lambda (n) (<= 0 (posn-x n) 1440)) (entities-positions en))
     (make-entities
      (build-list 7 (lambda (n) BALL_SPRITE))
      (map (lambda (n)
             (make-posn (+ (posn-x n) (* ENTITY_SPEED FRAME)) (posn-y n) ))
           (entities-positions en)))]
    [else
     (make-entities
      (build-list 7 (lambda (n) BALL_SPRITE))
      (map (lambda (n)
             (make-posn (random 200) (+ 450 (random 300))))
           (entities-positions en)))]))
