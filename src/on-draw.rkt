;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname on-draw) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; LIBRARIES
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

(require "data.rkt")
(require "on-tick.rkt")
(provide (all-defined-out))

;--------------------------------------------------------------------------------------

;;; ======== DRAW-ENTITIES ========

;; INPUT/OUTPUT
; signature: draw-entities: appState -> Image
; purpose:   draws the appstate on the boss' turn with entities
; header:    (define (draw-entities as) INITIAL_CANVAS)

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

;; CODE
(define (draw-entities as)
   (place-images
    (list PL_SPRITE
          BS_SPRITE_N
          PL_BOX
          (draw-lp (entities-player-lp (appState-e as)))
          (draw-lp (appState-boss as))
          placeholder_rec
          placeholder_rec
          ;entities
          (place-images
           (build-list (length (entities-enemies (appState-e as))) (lambda (n) BALL_SPRITE))
           (entities-enemies (appState-e as))
           (rectangle 1440 900 "solid" "transparent"))
          ; COUNTER
          (text (number->string (appState-change-turn as)) 50 "white")
          (text (number->string (length (entities-enemies (appState-e as)))) 50 "white")
          )
    (list (entities-player-pos (appState-e as))
          BS_SPRITE_POSITION
          PL_BOX_POSITION
          LP_POSITION_PL
          LP_POSITION_BO
          ATK_BOX_POSITION
          HEAL_BOX_POSITION
          (make-posn 720 450)
          (make-posn 100 100)
          (make-posn 100 800))
    BACKGROUND))



;;; ======== DRAW-LP ========

;; INPUT/OUTPUT
; signature: draw-lp: Number -> Image
; purpose:   draws a certain `n` of images to display 
; header:    (define (draw-lp n) HP_SPRITE_PL_INITIAL)

;; TEMPLATE
; (define (draw-lp n)
;   (cond
;     [(= n 1) ...]
;     [(= n 2) ...]
;     [(= n 3) ...]
;     [(= n 4) ...]
;     [(= n 5) ...]
;     [(= n 6) ...]
;     [(= n 7) ...]
;     [(= n 8) ...]
;     [(= n 9) ...]
;     [else    ...]))

;; CODE
(define (draw-lp n)
  (cond
    ; check the number of hearts and return the image of them
    [(= n 1) HP_SPRITE_1]
    [(= n 2) HP_SPRITE_2]
    [(= n 3) HP_SPRITE_3]
    [(= n 4) HP_SPRITE_4]
    [(= n 5) HP_SPRITE_5]
    [(= n 6) HP_SPRITE_6]
    [(= n 7) HP_SPRITE_7]
    [(= n 8) HP_SPRITE_8]
    [(= n 9) HP_SPRITE_9]
    [else    HP_SPRITE_10]))

;;; ======== DRAW-TURN ========

;; INPUT/OUTPUT
; signature: draw-turn: appState -> Image
; purpose:   draws the appstate on the boss' or player's turn
; header:    (define (drawTurn as) INITIAL_CANVAS)

;; TEMPLATE
; (define (draw-turn as)
;   ... (draw-lp (player-hp (appState-p as))) ...
;   ... (draw-lp (appState-boss as))          ...
;   ... (draw-entity (appState-e as))         ...
;   ... PL_SPRITE                             ...
;   ... BS_SPRITE_N                           ...
;   ... PL_BOX                                ...
;   ... placeholder_rec                       ...
;   ... (player-position (appState-p as))     ...
; ) 

;; CODE
(define (draw-turn as)
   (place-images
    (list PL_SPRITE
          BS_SPRITE_N
          PL_BOX
          (draw-lp (entities-player-lp (appState-e as)))
          (draw-lp (appState-boss as))
          placeholder_rec
          placeholder_rec
          (text (number->string (appState-change-turn as)) 50 "white"))
    (list (entities-player-pos (appState-e as))
          BS_SPRITE_POSITION
          PL_BOX_POSITION
          LP_POSITION_PL
          LP_POSITION_BO
          ATK_BOX_POSITION
          HEAL_BOX_POSITION
          (make-posn 100 100))
    BACKGROUND))



(define (draw-menu as)
  (place-images
   (list
    (text "PLAY" 60 (if (= (distance (entities-player-pos (appState-e as)) PLAY_TEXT_POS) 0)
                           "yellow"
                           "white"))
    (text "CREDITS" 60 (if (= (distance (entities-player-pos (appState-e as)) CREDITS_TEXT_POS) 0)
                           "yellow"
                           "white"))
   )
   (list
    (make-posn 720 400)
    (make-posn 720 500)
   )
   BACKGROUND))
;;; ======== DRAW-STATE ========

;; INPUT/OUTPUT
; signature: drawAppState: appState -> Image
; purpose:   display the appState on the scene as an image
; header:    (define (drawAppState as) BACKGROUND)

;; EXAMPLES
(check-expect (drawAppState INITIAL_APP_STATE) INITIAL_CANVAS)
; (check-expect (drawAppState (make-appState BACKGROUND PL1 BALL "boss" 8 #true "still"))
;               (place-images
;               (list PL_SPRITE
;                      BS_SPRITE_N
;                      PL_BOX
;                      (draw-lp (player-hp PL1))
;                      (draw-lp 8)
;                      placeholder_rec
;                      placeholder_rec)
;                (list (player-position PL1)
;                      BS_SPRITE_POSITION
;                      PL_BOX_POSITION
;                      LP_POSITION_PL
;                      LP_POSITION_BO
;                      ATK_BOX_POSITION
;                      HEAL_BOX_POSITION)
;               BACKGROUND))

;; TEMPLATE
; ...

;; CODE 
(define (drawAppState as)
  (cond
    [(string=? (appState-s as) "menu") (draw-menu as)]
    ;[(string=? "lost") (draw-lost as)]
    ;[(string=? "win")  (draw-win as)]
    ; boss and player's turn
    [(and (empty? (entities-enemies (appState-e as)))
          (or (string=? (appState-s as) "boss")
              (string=? (appState-s as) "player")))  (draw-turn as)]
    [else (draw-entities as)]
    ;[(or (= (as-s) "player-attack") (= (as-s) "player-heal")) (draw-action as)]
    ))
