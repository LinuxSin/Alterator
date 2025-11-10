(define-module (ui m104 ajax)
  :use-module (alterator woo)
  :use-module (alterator ajax)
  :export (init))


(define (ui-edit-profile)
(form-replace "/m104/edit"))
;; Функция для добавления/изменения данных с выбором через чекбоксы
(define (ui-datadd)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts"))
           (new-status (form-value "newdata")))
       (when (and selected-processes new-status)
         ;; Разделяем выбранные процессы (они приходят в формате "proc1;proc2;...")
         (let ((process-list (string-split selected-processes #\;)))
           ;; Обновляем статус для каждого выбранного процесса
           (for-each
            (lambda (process-num)
              (woo "update_status" "/m104" 
                   'process_num process-num
                   'new_status new-status))
            process-list)
           ;; Обновляем таблицу после изменения
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))


(define (ui-startBtn)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts"))
           (new-status (form-value "start")))
       (when (and selected-processes new-status)
         ;; Разделяем выбранные процессы (они приходят в формате "proc1;proc2;...")
         (let ((process-list (string-split selected-processes #\;)))
           ;; Обновляем статус для каждого выбранного процесса
           (for-each
            (lambda (process-num)
              (woo "update_status" "/m104" 
                   'process_num process-num
                   'new_status new-status))
            process-list)
           ;; Обновляем таблицу после изменения
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))


(define (ui-stopBtn)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts"))
           (new-status (form-value "stop")))
       (when (and selected-processes new-status)
         ;; Разделяем выбранные процессы (они приходят в формате "proc1;proc2;...")
         (let ((process-list (string-split selected-processes #\;)))
           ;; Обновляем статус для каждого выбранного процесса
           (for-each
            (lambda (process-num)
              (woo "update_status" "/m104" 
                   'process_num process-num
                   'new_status new-status))
            process-list)
           ;; Обновляем таблицу после изменения
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))



(define (ui-restartBtn)
  (catch/message
   (lambda()
     (let ((selected-processes (form-value "hosts"))
           (new-status (form-value "restart")))
       (when (and selected-processes new-status)
         ;; Разделяем выбранные процессы (они приходят в формате "proc1;proc2;...")
         (let ((process-list (string-split selected-processes #\;)))
           ;; Обновляем статус для каждого выбранного процесса
           (for-each
            (lambda (process-num)
              (woo "update_status" "/m104" 
                   'process_num process-num
                   'new_status new-status))
            process-list)
           ;; Обновляем таблицу после изменения
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))


;; Основная функция
(define (init)
  (catch/message (lambda ()
    (form-update-enum "hosts"
      (woo-list "/m104/hosts"))))
  
  (form-bind "datadd" "click" ui-datadd)
  (form-bind "startBtn" "click" ui-startBtn)
  (form-bind "stopBtn" "click" ui-stopBtn)
  (form-bind "restartBtn" "click" ui-restartBtn)

  (form-bind "redact_prof" "click" ui-edit-profile)

  
)
