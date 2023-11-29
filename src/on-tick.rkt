;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname on-tick) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; LIBRARIES
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

(require "data.rkt")

(provide (all-defined-out))

;--------------------------------------------------------------------------------------

;;; ======== TICK ========

;; INPUT/OUTPUT
; signature: tick: appState -> appState
; purpose:   handles the movement of the player every tick so that in the boss' turn it
;            can change position in the box, while in the player's turn it can change
;            position between the two attack and heal boxes
; header:    (define (tick state) INITIAL_APP_STATE)

;; EXAMPLES
;(check-expect (tick INITIAL_APP_STATE) INITIAL_APP_STATE)
;(check-expect (tick AP2)               (make-appState
;                                        BACKGROUND
;                                        (make-player
;                                         PL_SPRITE 3
;                                         (make-posn 600 (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
 ;                                       BALLS "boss" 10 #true "still"))
;(check-expect (tick AP3)               (make-appState
 ;                                       BACKGROUND
  ;                                      (make-player
   ;                                      PL_SPRITE 3
    ;                                     (make-posn (+ PL_BOX_LEFT (/ PL_WIDTH 2)) 850))
     ;                                   BALLS "boss" 10 #true "still"))
;(check-expect (tick AP4)               AP4)

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
    [(and (< (+ PL_BOX_LEFT (/ PL_WIDTH 2))
             (posn-x (player-position (appState-p state)))
             (- PL_BOX_RIGHT (/ PL_WIDTH 2)))
          (< (+ PL_BOX_TOP (/ PL_HEIGHT 2))
             (posn-y (player-position (appState-p state)))
             (- PL_BOX_BOTTOM (/ PL_HEIGHT 2))))
          (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (player-hp (appState-p state))
                                 (boss-tick-box state))
                    (entity-move state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state))]
    ; check if the player is outside the box -> see boss-tick-border
    [else
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (player-hp (appState-p state))
                                 (boss-tick-border state))
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
;    [(and (empty? (entities-sprites   (appState-e state)))
;          (empty? (entities-positions (appState-e state))))
;          ... BALL_SPRITE  ...
;          ... (random 400) ...
;          ... (random 300) ...]
;    [else ... (entities-sprites (appState-e state))   ...
;          ... BASE_SPEED                              ...
;          ... FRAME                                   ...
;          ... (entities-positions (appState-e state)) ...]))


;; CODE
(define (entity-move state)
  (cond
    [(and (empty? (entities-sprites   (appState-e state)))
          (empty? (entities-positions (appState-e state))))
     (make-entities
      (build-list 7 (lambda (n) BALL_SPRITE))
      (build-list 7 (lambda (n) (make-posn (random 200) (+ (random 250) 51)))))]
    [else  (entity-reset (appState-e state))]))

;(define posns (list (make-posn 10 20) (make-posn 30 20) (make-posn 40 20)))

;;; ======== ENTITY-RESET ========

; signature: entity-reset: entities -> entities
; purpose:   resets the entities x positions to the opposite border when they go out of a border
; header:    (define (entity-reset en) BALLS)
 
;; TEMPLATE
;(define (entity-reset en)
; (cond
;    [(ormap (lambda (n) (<= 0 (posn-x n) 400))(entities-positions en))
;           ... (entities-sprites en)   ...
;           ... (entities-positions en) ...]
;    [else  ... (entities-sprites en)   ...
;           ... (entities-positions en) ...]))

;; CODE
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
; signature: player-move: player movement [Number Number -> Number] -> player
; purpose:   changes the position of the player by 100/FRAME pixels
;            based on the movement `m` by increasing or decreasing its position based
;            on the function `fun`
; header:    (define (player-move p m fun) INITIAL_PLAYER)

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