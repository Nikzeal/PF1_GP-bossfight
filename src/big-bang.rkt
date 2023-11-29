;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname dtd) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

(require "data.rkt")

(require "on-key.rkt")

(require "on-draw.rkt")

(require "on-tick.rkt")

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

 
 