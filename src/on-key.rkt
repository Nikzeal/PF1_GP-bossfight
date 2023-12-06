;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname on-key) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; LIBRARIES
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)
 

(require "data.rkt")
(require "on-tick.rkt")

(provide (all-defined-out))

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
                    (boss-key key)
                    (appState-change-turn state))]
    ; check if it is the player turn -> see player-key funcion
    [(and (string=? (appState-s state) "player") (= (distance (player-position (appState-p state)) ATK_BOX_POSITION) 0))
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (player-hp (appState-p state))
                                 (player-key key (appState-p state)))
                    (appState-e state)
                    (appState-s state)
                    ;(player-attack (appState-p state) key (appState-boss state))
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    (appState-change-turn state))]
     [(and (string=? (appState-s state) "player") (= (distance (player-position (appState-p state)) HEAL_BOX_POSITION) 0)) (player-heal state key)]
    [else state]))

;;; ======== PLAYER-HEAL ========
;; INPUT/OUTPUT
; signature: player-heal: appState KeyEvent -> Number
; purpose:   heals the player when player presses z
; header:    (define (player-heal state key) 5)

;; TEMPLATE
;(define (player-attack state key)
;  (cond
;   [(and (= key "z") (< (player-hp player) 5)) ... (player-hp player) ...]
;    [else ... (player-hp) ...]))

;; CODE
(define (player-heal state key)
  (cond
    [(and (string=? key "z") (< (player-hp (appState-p state)) 5))
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (add1 (player-hp (appState-p state)))
                                 (player-position (appState-p state)))
                    (entity-move state)
                    "boss"
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    0)]
    [else
     (make-appState (appState-canvas state)
                    (make-player PL_SPRITE
                                 (player-hp (appState-p state))
                                 (player-key key (appState-p state)))
                    (entity-move state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    (appState-change-turn state))]))

;;; ======== PLAYER-HEAL ========
;; INPUT/OUTPUT
; signature: player-attack: player KeyEvent -> Number
; purpose:   attacks the boss when player presses z
; header:    (define (player-attack player key) 5)

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
(define (player-key key player)
  (cond
    ; check if the pressed key is "left" and place the player on the attack box
    [(key=? key "left")  ATK_BOX_POSITION        ]
    ; check if the pressed key is "right" and place the player on the heal box
    [(key=? key "right") HEAL_BOX_POSITION       ]
    ; if any other key is pressed, it returns the current player position
    [else                (player-position player)]))

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
  [(or (key=? key "left") (key=? key "right") (key=? key "up") (key=? key "down"))
   (make-appState (appState-canvas state)
                 (appState-p state)
                 (appState-e state)
                 (appState-s state)
                 (appState-boss state)
                 (appState-running? state)
                 "still"
                 (appState-change-turn state))]
  [else state]))