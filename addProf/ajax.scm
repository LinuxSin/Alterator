(define-module (ui m104 addProf ajax)
  :use-module (alterator woo)
  :use-module (alterator ajax)
  :export (init))



(define (ui-return)
(form-replace "/m104/edit"))

(define (init)
  (form-bind "return" "click" ui-return)  
)