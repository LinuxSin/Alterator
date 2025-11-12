(define-module (ui m104 ajax)
  :use-module (alterator woo)
  :use-module (alterator ajax)
  :export (init))

; ////////////////////////////////////////////////////////////////////////////
;; Функция для получения списка профилей
(define (get-profiles-list)
  (woo-list "/m104/profiles"))

;; Функция для смены профиля
(define (ui-change-profile)
  (catch/message
   (lambda()
     (let ((selected-profile (form-value "profiles")))
       (when selected-profile
         ;; Устанавливаем выбранный профиль
         (woo "set_profile" "/m104" 'profile_name selected-profile)
         ;; Обновляем таблицу с новыми данными
         (let ((hosts-data (woo-list "/m104/hosts")))
           (form-update-enum "hosts" hosts-data)
           ;; Обновляем заголовок из первого элемента (если есть)
           (when (not (null? hosts-data))
             (let ((first-host (car hosts-data)))
               (form-update-value "title" (woo-get-option first-host 'title))))))))))

; /////////////////////////////////////////////////////////////////////////////


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


(define (init)
  (catch/message (lambda ()
    ;; Загружаем список профилей
    (let ((profiles-list (get-profiles-list)))
      (form-update-enum "profiles" profiles-list)
      
      ;; Пытаемся установить m104 как выбранный, если он есть в списке
      (if (member "m104" (map (lambda (x) (woo-get-option x 'name)) profiles-list))
          (form-update-value "profiles" "m104")
          ;; Иначе выбираем первый элемент
          (when (not (null? profiles-list))
            (form-update-value "profiles" (woo-get-option (car profiles-list) 'name))))
      
      ;; Загружаем данные хостов и обновляем заголовок
      (let ((hosts-data (woo-list "/m104/hosts")))
        (form-update-enum "hosts" hosts-data)
        ;; Устанавливаем заголовок из первого элемента (если есть)
        (when (not (null? hosts-data))
          (let ((first-host (car hosts-data)))
            (form-update-value "title" (woo-get-option first-host 'title))))))))
  
  (form-bind "profiles" "click" ui-change-profile)  
  (form-bind "datadd" "click" ui-datadd)
  (form-bind "startBtn" "click" ui-startBtn)
  (form-bind "stopBtn" "click" ui-stopBtn)
  (form-bind "restartBtn" "click" ui-restartBtn)
  (form-bind "redact_prof" "click" ui-edit-profile)  
)