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

;;; ======== HANDLE-KEY ========

;; INPUT/OUTPUT
; signature: handle-key: appState Key -> appState
; purpose:   checks for the turn and handles the key events based on it, if its the boss'
;            turn the player can move right, left, up or down, if its the player's turn
;            it can move in two positions, which are the heal and attack box positions and can select one of the two with `z`.
;            If it's the menu state the player can move up or down and select one out of play and credits with `enter`.
; header:    (define (handle-key state key) MENU_APP_STATE)

;; EXAMPLES
(check-expect (handle-key
               (make-appState BACKGROUND PLAYER "boss" 6 #true "still" 10) "down")
               (make-appState BACKGROUND PLAYER "boss" 6 #true "down"  10))
(check-expect (handle-key
               (make-appState BACKGROUND PLAYER_ATK "player" 6 #true "still" 0) "z")
               (make-appState BACKGROUND PLAYER_ATK "rage" 5 #true "still" 0))

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
    ; check if the player is in the menu -> see menu-key and menu-select functions
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
    ; check if it is the boss turn -> see boss-key function
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
; purpose:   let the player decide wether to retry or quit when the game has ended
; header:    (define (end? key state) GAME_APP_STATE)

;; EXAMPLES
(check-expect (end? " " (make-appState BACKGROUND NONE "end" 0  #true "still" 0))
              (make-appState BACKGROUND NONE "end" 0  #true "still" 0))
(check-expect (end? "q" (make-appState BACKGROUND NONE "end" 0  #true "still" 0))
              (make-appState BACKGROUND NONE "end" 0  #false "still" 0))
;; TEMPLATE
; (define (end? key state)
;   (cond
;     [(string=? key "q") ... state ...]
;     [(string=? key "r") ... state ...]
;     [else               ... state ...]))

;; CODE
(define (end? key state)
  (cond
    ; quit the game
    [(string=? key "q")
     (make-appState (appState-canvas state)
                    (appState-e state)
                    (appState-s state)
                    (appState-boss state)
                    #false
                    (appState-movement state)
                    (appState-change-turn state))]
    ; reset the app state to initial game state
    [(string=? key "r")
     GAME_APP_STATE]
    ; keep the state as is
    [else state]))

;;; ======== MENU-SELECT ========

;; INPUT/OUTPUT
; signature: menu-select: Key -> String
; purpose:   handles the enter key event for the menu screen and changes the app state accordingly
; header:    (define (menu-select state key) "menu")

;; EXAMPLES
(check-expect (menu-select " " PLAY_TEXT_POS) "menu")
(check-expect (menu-select "\r" PLAY_TEXT_POS) "boss")

;; TEMPLATE
; (define (menu-key key)
;   (cond
;     [(and (key=? key "\r") (= 0 (distance player-pos PLAY_TEXT_POS   )))) ...]
;     [(and (key=? key "\r") (= 0 (distance player-pos CREDITS_TEXT_POS)))) ...]
;     [else                                                                 ...]))

;; CODE
(define (menu-select key player-pos)
  (cond
    [(and (key=? key "\r") (= 0 (distance player-pos PLAY_TEXT_POS)))    "boss"]
    [(and (key=? key "\r") (= 0 (distance player-pos CREDITS_TEXT_POS))) "credits"]
    [else                                                                "menu"]))

;;; ======== MENU-KEY ========

;; INPUT/OUTPUT
; signature: menu-key: Key -> Posn
; purpose:   handles the arrow key events for the menu screen and changes the position of the player accordingly
; header:    (define (menu-key key) (make-posn 0 0))

;; EXAMPLES
(check-expect (menu-key " " PLAY_TEXT_POS) PLAY_TEXT_POS)
(check-expect (menu-key "down" PLAY_TEXT_POS) CREDITS_TEXT_POS)

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
; signature: player-act: appState Key -> appState
; purpose:   attacks the boss or heals the player when player presses z
; header:    (define (player-act state key) GAME_APP_STATE)

;; EXAMPLES
(check-expect (player-act (make-appState BACKGROUND PLAYER_ATK "player" 10 #true "still" 0) " ")
              (make-appState BACKGROUND PLAYER_ATK "player" 10 #true "still" 0))
(check-expect (player-act (make-appState BACKGROUND PLAYER_HEAL "player" 10 #true "still" 0) "left")
              (make-appState BACKGROUND PLAYER_ATK "player" 10 #true "still" 0))

;; TEMPLATE
;(define (player-act state key)
;  (cond
;   [(and (= (distance (entities-player-pos (appState-e state)) PL_OFFSET_HEAL) 0)
;          (string=? key "z")
;          (< (entities-player-lp (appState-e state)) 5))  ... state ...]
;   [(and (= (distance (entities-player-pos (appState-e state)) PL_OFFSET_ATTACK) 0)
;          (string=? key "z")
;          (= 6 (appState-boss state)))                    ... state ...]
;   [(and (= (distance (entities-player-pos (appState-e state)) PL_OFFSET_ATTACK) 0)
;          (string=? key "z"))                             ... state ...]
;   [else                                                  ... state ...]))

;; CODE
(define (player-act state key)
  (cond
    [(and (= (distance (entities-player-pos (appState-e state)) PL_OFFSET_HEAL) 0)
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
     [(and (= (distance (entities-player-pos (appState-e state)) PL_OFFSET_ATTACK) 0)
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
    [(and (= (distance (entities-player-pos (appState-e state)) PL_OFFSET_ATTACK) 0)
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
; purpose:   handles the arrow key events for the boss turn and changes the app movement accordingly
; header:    (define (boss-key state key) "still")

;; EXAMPLES
(check-expect (boss-key " ") "still")
(check-expect (boss-key "r") "still")
(check-expect (boss-key "left") "left")
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
; purpose:   handles the key events for the player turn and changes the player's position accordingly
; header:    (define (player-key key player-pos) (make-posn 0 0))

;; EXAMPLES
(check-expect (player-key " " PL_OFFSET_HEAL) PL_OFFSET_HEAL)
(check-expect (player-key "left" PL_OFFSET_HEAL) PL_OFFSET_ATTACK)

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
    [(key=? key "left")  PL_OFFSET_ATTACK]
    ; check if the pressed key is "right" and place the player on the heal box
    [(key=? key "right") PL_OFFSET_HEAL]
    ; if any other key is pressed, or no key is pressed, it returns the current player position
    [else                player-pos]))

;;; ======== HANDLE-RELEASE ========

;; INPUT/OUTPUT
; signature: handle-release: appState Key -> appState
; purpose:   if its the boss' turn the player movement stops when releasing the key,
;            if its the player's turn it does not do anything
; header:    (define (handle-release state key) GAME_APP_STATE)

;; EXAMPLES
(check-expect (handle-release (make-appState BACKGROUND PLAYER_ATK "player" 6 #true "left" 0) "left")
              (make-appState BACKGROUND PLAYER_ATK "player" 6 #true "still" 0))

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