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
; (check-expect (handle-key INITIAL_APP_STATE "right")
;               (make-appState BACKGROUND INITIAL_PLAYER NONE "boss" 10 #true "right"))
; (check-expect (handle-key AP2 "left")
;               (make-appState BACKGROUND PL1 BALLS "boss" 10 #true "left"))
; (check-expect (handle-key AP3 "up")
;               (make-appState BACKGROUND PL2 BALLS "boss" 10 #true "up"))
; (check-expect (handle-key AP4 "right")
;               (make-appState BACKGROUND (make-player PL_SPRITE 5 HEAL_BOX_POSITION)
;                              NONE "player" 10 #false "still"))

;; TEMPLATE
; (define (handle-key state key)
;   (cond
;     [(string=? (appState-s state) "end")          ... state ... key ...]
;     [(or (string=? (appState-s state) "menu")
;          (string=? (appState-s state) "credits")) ... state ... key ...]
;     [(string=? (appState-s state) "boss")         ... state ... key ...]
;     [(string=? (appState-s state) "player")       ... state ... key ...]
;     [else                                         ... state ... key ...]))

;; CODE
(define (handle-key state key)
  (cond
    ; check if the game has ended -> see end? function
    [(string=? (appState-s state) "end")
     (end? key state)]
    ; check if the player is in the main menu
    [(or (string=? (appState-s state) "menu") (string=? (appState-s state) "credits"))
     (make-appState (appState-canvas state)
                    (make-entities
                     (entities-player-lp (appState-e state))
                     (menu-key key (entities-player-pos (appState-e state)))
                     (entities-enemies (appState-e state)))
                    (menu-select key (entities-player-pos (appState-e state)))
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    (appState-change-turn state))]
    ; check if it is the boss turn   -> see boss-key function
    [(string=? (appState-s state) "boss")
     (make-appState (appState-canvas state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (boss-key key)
                    (appState-change-turn state))]
    ; check if it is the player turn -> see player-act function
     [(string=? (appState-s state) "player") (player-act state key)]
    [else state]))


;;; ======== END? ========

;; INPUT/OUTPUT
; signature: end?: key appState  -> appState
; purpose:   let the player decide if to retry or to quit when the game has ended
; header:    (define (end? key state) #false)

;; TEMPLATE
; (define (end? key state)
;   (cond
;     [(string=? key "q") ... state ...]
;     [(string=? key "r") ... state ...]
;     [else               ... state ...]))

;; CODE
(define (end? key state)
  (cond
    [(string=? key "q")
     (make-appState (appState-canvas state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    #false
                    (appState-movement state)
                    (appState-change-turn state))]
    [(string=? key "r")
     GAME_APP_STATE]
    [else
     (make-appState (appState-canvas state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    (appState-change-turn state))]))

;;; ======== MENU-SELECT ========

;; INPUT/OUTPUT
; signature: menu-key: Key -> String
; purpose:   handles the key events (select) for the menu screen
; header:    (define (menu-key state key) 0)

;; TEMPLATE
; (define (menu-key key)
;   (cond
;     [(key=? key "\r") ...]
;     [(key=? key "\r") ...]
;     [else             ...]))

;; CODE
(define (menu-select key player-pos)
  (cond
    [(and (key=? key "\r") (= 0 (distance player-pos PLAY_TEXT_POS)))    "boss"]
    [(and (key=? key "\r") (= 0 (distance player-pos CREDITS_TEXT_POS))) "credits"]
    [else                                                                "menu"]))

;;; ======== MENU-KEY ========

;; INPUT/OUTPUT
; signature: menu-key: Key -> Posn
; purpose:   handles the key events (move) for the menu screen
; header:    (define (menu-key key) (make-posn 0 0))

;; TEMPLATE
; (define (menu-key key)
;   (cond
;     [(key=? key "up")   ...]
;     [(key=? key "down") ...]
;     [else               ...]))

;; CODE
(define (menu-key key player-pos)
  (cond
    [(key=? key "up")   PLAY_TEXT_POS]
    [(key=? key "down") CREDITS_TEXT_POS]
    [else               player-pos]))


;;; ======== PLAYER-ACT ========

;; INPUT/OUTPUT
; signature: player-act: appState KeyEvent -> appState
; purpose:   attacks the boss or heals the player when player presses z
; header:    (define (player-act state key) INITIAL_APP_STATE)

;; TEMPLATE
;(define (player-act state key)
;  (cond
;   [(and (= (distance (entities-player-pos (appState-e state)) (make-posn 855 800)) 0)
;         (string=? key "z")
;         (< (entities-player-lp (appState-e state)) 5))  ... state ...]
;   [(and (= (distance (entities-player-pos (appState-e state)) (make-posn 455 800)) 0)
;         (string=? key "z")
;         (= 6 (appState-boss state)))                    ... state ...]
;   [(and (= (distance (entities-player-pos (appState-e state)) (make-posn 455 800)) 0)
;         (string=? key "z"))                             ... state ...]
;   [else                                                 ... state ...]))

;; CODE
(define (player-act state key)
  (cond
    [(and (= (distance (entities-player-pos (appState-e state)) (make-posn 855 800)) 0)
          (string=? key "z")
          (< (entities-player-lp (appState-e state)) 5))
     (make-appState (appState-canvas state)
                    (make-entities
                     (add1 (entities-player-lp (appState-e state)))
                     PL_BOX_POSITION
                     (entity-move state))
                    "boss"
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    0)]
     [(and (= (distance (entities-player-pos (appState-e state)) (make-posn 455 800)) 0)
          (string=? key "z")
          (= 6 (appState-boss state)))
          (make-appState (appState-canvas state)
                    (make-entities
                     (entities-player-lp (appState-e state))
                     (player-key key (entities-player-pos (appState-e state)))
                     (entities-enemies (appState-e state)))
                    "rage"
                    (sub1 (appState-boss state))
                    (appState-running? state)
                    (appState-movement state)
                    0)]
    [(and (= (distance (entities-player-pos (appState-e state)) (make-posn 455 800)) 0)
          (string=? key "z"))
     (make-appState (appState-canvas state)
                    (make-entities
                     (entities-player-lp (appState-e state))
                     PL_BOX_POSITION
                     (entity-move state))
                    "boss"
                    (sub1 (appState-boss state))
                    (appState-running? state)
                    (appState-movement state)
                    0)]
    [else
     (make-appState (appState-canvas state)
                    (make-entities
                     (entities-player-lp (appState-e state))
                     (player-key key (entities-player-pos (appState-e state)))
                     (entities-enemies (appState-e state)))
                    (appState-s state)
                    (appState-boss state)
                    (appState-running? state)
                    (appState-movement state)
                    (appState-change-turn state))]))

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
(define (player-key key player-pos)
  (cond
    ; check if the pressed key is "left" and place the player on the attack box
    [(key=? key "left")  (make-posn 455 800)]
    ; check if the pressed key is "right" and place the player on the heal box
    [(key=? key "right") (make-posn 855 800)]
    ; if any other key is pressed, it returns the current player position
    [else                player-pos]))

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
;     [(or (key=? key "left") (key=? key "right") (key=? key "up") (key=? key "down"))
;           ... state ...]
;     [else ... state ...]))

;; CODE
(define (handle-release state key)
  (cond
  [(or (key=? key "left") (key=? key "right") (key=? key "up") (key=? key "down"))
   (make-appState
    (appState-canvas state)
    (appState-e state)
    (appState-s state)
    (appState-boss state)
    (appState-running? state)
    "still"
    (appState-change-turn state))]
  [else state]))