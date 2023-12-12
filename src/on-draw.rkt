;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname on-draw) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))

;; LIBRARIES
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

(require "data.rkt")
(require "on-tick.rkt")
(provide drawAppState)

;--------------------------------------------------------------------------------------


(define (display-end as for)
  (cond
    ;
    [(and (string=? for "player")
          (and (not (= (entities-player-lp (appState-e as)) 0))
               (not (= (appState-boss as) 0))))
     PL_SPRITE]
    ;
    [(and (string=? for "entities")
          (and (not (= (entities-player-lp (appState-e as)) 0))
               (not (= (appState-boss as) 0))))
     (place-images
          (build-list (length (entities-enemies (appState-e as))) (lambda (n) BALL_SPRITE))
          (entities-enemies (appState-e as))
          (rectangle 1440 900 "solid" "transparent"))]
    ;
    [(and (string=? for "game") (= (entities-player-lp (appState-e as)) 0))
     (above GAME_OVER (rectangle 20 20 "solid" "transparent") QUIT (rectangle 20 20 "solid" "transparent") RETRY)]
    [(and (string=? for "game") (= (appState-boss as) 0))
     (above WIN (rectangle 20 20 "solid" "transparent") QUIT (rectangle 20 20 "solid" "transparent") RETRY)]
    ;
    [else (rectangle 0 0 "solid" "transparent")]))

;;; ======== DRAW-ENTITIES ========

;; INPUT/OUTPUT
; signature: draw-entities: appState -> Image
; purpose:   draws the appstate on the boss' turn with entities
; header:    (define (draw-entities as) INITIAL_CANVAS)

;; TEMPLATE
; (define (draw-entities as)
;   ... (draw-lp (player-hp (appState-p as))) ...
;   ... (draw-lp (appState-boss as))          ...
;   ... (entities-sprites (appState-e as)))   ...
;   ... (entities-positions (appState-e as))) ...
;   ... PL_SPRITE                             ...
;   ... BS_SPRITE_N                           ...
;   ... BS_SPRITE_R                           ...
;   ... PL_BOX                                ...
;   ... ATK_BOX                               ...
;   ... HEAL_BOX
;   ... (player-position (appState-p as))     ...
; )

;; CODE
(define (draw-entities as)
   (place-images
    (list
     (display-end as "player")
     (if (> (appState-boss as) 5)
         BS_SPRITE_N
         BS_SPRITE_R)
     PL_BOX
     (draw-lp (entities-player-lp (appState-e as)))
     (draw-lp (appState-boss as))
     ATK_BOX_UNS
     HEAL_BOX_UNS
     ; entities
     (display-end as "entities")
     (display-end as "game")
     )
    (list
     (entities-player-pos (appState-e as))
     (if (> (appState-boss as) 5)
         BS_N_POSITION
         BS_R_POSITION)
     PL_BOX_POSITION
     LP_POSITION_PL
     LP_POSITION_BO
     ATK_BOX_POSITION
     HEAL_BOX_POSITION
     (make-posn 720 450)
     (make-posn 700 600)
     )
    BACKGROUND))

;;; ======== DRAW-LP ========

;; INPUT/OUTPUT
; signature: draw-lp: Number -> Image
; purpose:   draws a certain `n` of images to display 
; header:    (define (draw-lp n) HP_SPRITE_PL_INITIAL)

;; TEMPLATE
; (define (draw-lp n)
;   (cond
;     [(= n 1)  ...]
;     [(= n 2)  ...]
;     [(= n 3)  ...]
;     [(= n 4)  ...]
;     [(= n 5)  ...]
;     [(= n 6)  ...]
;     [(= n 7)  ...]
;     [(= n 8)  ...]
;     [(= n 9)  ...]
;     [(= n 10) ...]
;     [else     ...]))

;; CODE
(define (draw-lp n)
  (cond
    ; check the number of hearts and return the image of them
    [(= n 1)  PL_HP]
    [(= n 2)  (beside PL_HP PL_HP)]
    [(= n 3)  (beside PL_HP PL_HP PL_HP)]
    [(= n 4)  (beside PL_HP PL_HP PL_HP PL_HP)]
    [(= n 5)  (beside PL_HP PL_HP PL_HP PL_HP PL_HP)]
    [(= n 6)  (above (beside PL_HP PL_HP PL_HP PL_HP PL_HP) PL_HP)]
    [(= n 7)  (above (beside PL_HP PL_HP PL_HP PL_HP PL_HP) (beside PL_HP PL_HP))]
    [(= n 8)  (above (beside PL_HP PL_HP PL_HP PL_HP PL_HP) (beside PL_HP PL_HP PL_HP))]
    [(= n 9)  (above (beside PL_HP PL_HP PL_HP PL_HP PL_HP) (beside PL_HP PL_HP PL_HP PL_HP))]
    [(= n 10) (above (beside PL_HP PL_HP PL_HP PL_HP PL_HP) (beside PL_HP PL_HP PL_HP PL_HP PL_HP))]
    [else    (rectangle 0 0 "solid" "transparent")]))

;;; ======== DRAW-TURN ========

;; INPUT/OUTPUT
; signature: draw-turn: appState -> Image
; purpose:   draws the appstate on the boss' or player's turn
; header:    (define (drawTurn as) INITIAL_CANVAS)

;; TEMPLATE
; (define (draw-turn as)
;   ... (draw-lp (player-hp (appState-p as))) ...
;   ... (draw-lp (appState-boss as))          ...
;   ... (entities-sprites (appState-e as)))   ...
;   ... (entities-positions (appState-e as))) ...
;   ... PL_SPRITE                             ...
;   ... BS_SPRITE_N                           ...
;   ... BS_SPRITE_R                           ...
;   ... PL_BOX                                ...
;   ... ATK_BOX                               ...
;   ... HEAL_BOX
;   ... (player-position (appState-p as))     ...
; )

;; CODE
(define (draw-turn as)
   (place-images
    (list PL_SPRITE
          (if (> (appState-boss as) 5)
              BS_SPRITE_N
              BS_SPRITE_R)
          PL_BOX
          (draw-lp (entities-player-lp (appState-e as)))
          (draw-lp (appState-boss as))
          (if (= (distance (entities-player-pos (appState-e as)) PL_OFFSET_ATTACK) 0)
              ATK_BOX_SEL
              ATK_BOX_UNS)
          (if (= (distance (entities-player-pos (appState-e as)) PL_OFFSET_HEAL) 0)
              HEAL_BOX_SEL
              HEAL_BOX_UNS))
    (list (entities-player-pos (appState-e as))
          (if (> (appState-boss as) 5)
              BS_N_POSITION
              BS_R_POSITION)
          PL_BOX_POSITION
          LP_POSITION_PL
          LP_POSITION_BO
          ATK_BOX_POSITION
          HEAL_BOX_POSITION)
    BACKGROUND))

;;; ======== DRAW-MENU ========

;; INPUT/OUTPUT
; signature: draw-menu: appState -> Image
; purpose:   draws the appState in the game menu
; header:    (define (draw-menu as) BACKGROUND)

;; TEMPLATE
; (define (draw-menu as)
;   ... PLAY_SEL         ...
;   ... PLAY_UNS         ...
;   ... CREDITS_SEL      ...
;   ... CREDITS_UNS      ...
;   ... PLAY_TEXT_POS    ...
;   ... CREDITS_TEXT_POS ...
;   ... BACKGROUND       ...)

;; CODE
(define (draw-menu as)
  (place-images
   (list
    ; display yellow text if player is on the position of the text
    (if (= (distance (entities-player-pos (appState-e as)) PLAY_TEXT_POS) 0)
        PLAY_SEL
        PLAY_UNS)
    (if (= (distance (entities-player-pos (appState-e as)) CREDITS_TEXT_POS) 0)
        CREDITS_SEL
        CREDITS_UNS)
    ENTER
   )
   (list
    PLAY_TEXT_POS
    CREDITS_TEXT_POS
    (make-posn 720 860)
   )
   BACKGROUND))

;;; ======== DRAW-CREDITS ========

;; INPUT/OUTPUT
; signature: draw-credits: appState -> Image
; purpose:   adds the credits to the game main menu
; header:    (define (draw-credits as) BACKGROUND)

;; TEMPLATE
; (define (draw-credits as)
;   ... PLAY_SEL         ...
;   ... PLAY_UNS         ...
;   ... CREDITS_SEL      ...
;   ... CREDITS_UNS      ...
;   ... NAMES            ...
;   ... PLAY_TEXT_POS    ...
;   ... CREDITS_TEXT_POS ...
;   ... BACKGROUND       ...)

;; CODE
(define (draw-credits as)
  (place-images
   (list
    (if (= (distance (entities-player-pos (appState-e as)) PLAY_TEXT_POS) 0)
        PLAY_SEL
        PLAY_UNS)
   (if (= (distance (entities-player-pos (appState-e as)) CREDITS_TEXT_POS) 0)
       CREDITS_SEL
       CREDITS_UNS)
   NAMES
   )
   (list
    PLAY_TEXT_POS
    CREDITS_TEXT_POS
    (make-posn 720 700)
   )
   BACKGROUND))

;;; ======== DRAW-RAGE ========

;; INPUT/OUTPUT
; signature: draw-rage: appState -> Image
; purpose:   create a transition gif for the rage mode
; header:    (define (draw-rage as) BACKGROUND)

;; TEMPLATE
; (define (draw-rage as)
;   (cond
;     [(<= 0   (appState-change-turn as) 8  ) ...]
;     [(<= 9   (appState-change-turn as) 17 ) ...]
;     [(<= 18  (appState-change-turn as) 26 ) ...]
;     [(<= 27  (appState-change-turn as) 35 ) ...]
;     [(<= 36  (appState-change-turn as) 44 ) ...]
;     [(<= 45  (appState-change-turn as) 53 ) ...]
;     [(<= 54  (appState-change-turn as) 62 ) ...]
;     [(<= 63  (appState-change-turn as) 71 ) ...]
;     [(<= 72  (appState-change-turn as) 80 ) ...]
;     [(<= 81  (appState-change-turn as) 89 ) ...]
;     [(<= 90  (appState-change-turn as) 98 ) ...]
;     [(<= 99  (appState-change-turn as) 107) ...]
;     [(<= 108 (appState-change-turn as) 117) ...]
;     [else                                   ...]))

;; CODE
(define (draw-rage as)
  (cond
    [(<=   (appState-change-turn as) 8  ) (place-image RG1  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 17 ) (place-image RG2  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 26 ) (place-image RG3  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 35 ) (place-image RG4  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 44 ) (place-image RG5  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 53 ) (place-image RG6  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 62 ) (place-image RG7  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 71 ) (place-image RG8  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 80 ) (place-image RG9  720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 89 ) (place-image RG10 720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 98 ) (place-image RG11 720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 107) (place-image RG12 720 450 BACKGROUND)]
    [(<=   (appState-change-turn as) 117) (place-image RG13 720 450 BACKGROUND)]
    [else (rectangle 0 0 "solid" "transparent")]))

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
; (define (drawAppState as)
;   (cond
;     [(string=? (appState-s as) "menu")               ...]
;     [(string=? (appState-s as) "credits")            ...]
;     [(string=? (appState-s as) "rage")               ...]
;     [(and (empty? (entities-enemies (appState-e as)))
;           (or (string=? (appState-s as) "boss")
;               (string=? (appState-s as) "player")))  ...]
;     [else (draw-entities as)]))

;; CODE 
(define (drawAppState as)
  (cond
    [(string=? (appState-s as) "menu")    (draw-menu as)]
    [(string=? (appState-s as) "credits") (draw-credits as)]
    [(string=? (appState-s as) "rage")    (draw-rage as)]
    ; boss and player's turn
    [(and (empty? (entities-enemies (appState-e as)))
          (or (string=? (appState-s as) "boss")
              (string=? (appState-s as) "player")))  (draw-turn as)]
    [else (draw-entities as)]
    ))
