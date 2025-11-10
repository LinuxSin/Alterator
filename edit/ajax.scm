(define-module (ui m104 edit ajax)
:use-module (alterator woo)
:use-module (alterator algo)
:use-module (alterator ajax)
:export (init))

(define (ui-return)
(form-replace "/m104"))


(define (ui-apply)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts"))
           (new-primary (form-value "addPrimary")))
       (when (and selected-processes new-primary)
         (let ((process-list (string-split selected-processes #\;)))
           (for-each
            (lambda (process-num)
              (woo "update_primary" "/m104" 
                   'process_num process-num
                   'new_primary new-primary))
            process-list)
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))



(define (ui-applySecondary)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts"))
           (new-secondary (form-value "addSecondary")))
       (when (and selected-processes new-secondary)
         (let ((process-list (string-split selected-processes #\;)))
           (for-each
            (lambda (process-num)
              (woo "update_secondary" "/m104" 
                   'process_num process-num
                   'new_secondary new-secondary))
            process-list)
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))


(define (ui-addProc)
  (catch/message
   (lambda()
     (woo "add_process" "/m104")
     ;; Обновляем таблицу после добавления
     (form-update-enum "hosts"
       (woo-list "/m104/hosts")))))


(define (ui-delProc)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts")))
       (when selected-processes
         (let ((process-list (string-split selected-processes #\;)))
           (for-each
            (lambda (process-num)
              (woo "delete_process" "/m104" 
                   'process_num process-num))
            process-list)
           ;; Обновляем таблицу после удаления
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))


(define (init)
  (catch/message (lambda ()
    (form-update-enum "hosts"
      (woo-list "/m104/hosts"))))
; (ui-init)
(form-bind "return" "click" ui-return)
(form-bind "apply" "click" ui-apply)
(form-bind "applySecondary" "click" ui-applySecondary)
(form-bind "addProc" "click" ui-addProc)
(form-bind "delProc" "click" ui-delProc)
)
