#lang racket
(require web-server/servlet)
(require web-server/servlet-env)

;; okay so running on the same web server
;; we need a rex controller and a (later multiple) rex viewer(s):
;; (control-o-rex and rex-o-controled)

;; some mutible sacrilege
(define has-happened? #f)               ; not in use anymore
(define counter 0)                      ; tracks the number times the increment page has been refreshed

;; returns an http response with some page content
(define (http-response content)
  (response/full
    200                  ; HTTP response code.
    #"OK"                ; HTTP response message.
    (current-seconds)    ; Timestamp.
    TEXT/HTML-MIME-TYPE  ; MIME type for content.
    '()                  ; Additional HTTP headers.
    (list
     (string->bytes/utf-8 content))))

;;; we need two pages - one the viewer; one the controller

;; the viewer
(define (viewer-page request)
  ;; return some http content
  (http-response
   (string-append
    "
<h1>rex-o-controlled</h1>\n
<p>the t-rex has walked...</p>"
    (~r counter #:precision '(= 2))      ; Number to String
    " meteres"
    )))

;; the controller                        
(define (controller-page request)
  (set! counter (add1 counter))         ; increment the value of counter by 1
  ;; return some http content
  (http-response "
<h1>control-o-rex!</h1> \n
<p><the t-rex 'walks' everytime this page is refreshed</p>"))

(define-values (dispatch generate-url)
  (dispatch-rules
  [("") viewer-page]   
  [("viewer") viewer-page]
  [("controller") controller-page]
  [else
   (error "There is no procedure to handle the url.")
   ]))

;; Returns a HTTP response given a HTTP request.
(define (request-handler request)
  (dispatch request))

;; start the server.
(serve/servlet
 request-handler
 #:launch-browser? #f
 #:quit? #f
 #:listen-ip "127.0.0.1"
 #:port 9010
 #:servlet-regexp #rx"")
