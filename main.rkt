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

;; rex-o-controller content
(define (first-page request)
  (http-response
(string-append
   "
<h1>This is the first page!</h1> \n
<p>There is some text here also</p>"
   (~r counter #:precision '(= 2))      ; Number to String
   )))
                        
;; rex-o-controlled content
(define (second-page request)
  (http-response "
<h1>This is the second page!</h1> \n
<button type=\"button\">Click Me!</button>"))

(define (the-thing request)

  ;; (set! has-happened? (not has-happened?))
  (set! counter (add1 counter))
  
  (http-response "<h1>The Thing Has Been Done!</h1>
"))

(define-values (dispatch generate-url)
  (dispatch-rules
  [("") first-page]   
  [("first")
   (if has-happened? second-page first-page)]
  [("second") second-page]
  [("the-thing") the-thing]
  [else
   (error "There is no procedure to handle the url.")
   ]))

;; Returns a HTTP response given a HTTP request.
(define (request-handler request)
  (dispatch request))

;; (define (start req)
;;   (response/xexpr
;;    `(html (head (title "Hello world!"))
;;           (body (p "Hey out there!")))))

;; Start the server.
(serve/servlet
 request-handler
 #:launch-browser? #f
 #:quit? #f
 #:listen-ip "127.0.0.1"
 #:port 8010
 #:servlet-regexp #rx"")
