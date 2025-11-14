(define-module (ui m104 edit ajax)
:use-module (alterator woo)
:use-module (alterator algo)
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

(define (ui-addProf-NewProfile)
(form-replace "/m104/addProf"))

(define (ui-return)
(form-replace "/m104"))

;; ////////////////////////////// Создание нового профиля ///////////////////////////////
(define (ui-create-profile)
  (catch/message
   (lambda()
     (let ((new-profile-name (form-value "new_profile_name")))
       (when (and new-profile-name (not (string-null? new-profile-name)))
         ;; Вызываем метод создания профиля
         (woo "create_profile" "/m104" 'profile_name new-profile-name)
         ;; Устанавливаем новый профиль как текущий
         (woo "set_profile" "/m104" 'profile_name new-profile-name)
         ;; Возвращаемся к странице редактирования с уже выбранным новым профилем
         (form-replace "/m104/edit"))))))

;; Функция для удаления текущего профиля
;; Функция для удаления текущего профиля (упрощенная)
(define (ui-delete-profile)
  (catch/message
   (lambda()
     ;; Просто вызываем удаление текущего профиля без параметров
     ;; Бэкенд сам определит какой профиль сейчас активен
     (woo "delete_current_profile" "/m104")
     ;; Возвращаемся на основную страницу
     (form-replace "/m104/edit"))))


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
;; (ui-init)
(form-bind "profiles" "click" ui-change-profile)
(form-bind "return" "click" ui-return)
(form-bind "apply" "click" ui-apply)
(form-bind "applySecondary" "click" ui-applySecondary)
(form-bind "addProc" "click" ui-addProc)
(form-bind "delProc" "click" ui-delProc)
(form-bind "addNewProfile" "click" ui-addProf-NewProfile)
(form-bind "deleteProfile" "click" ui-delete-profile)
(form-bind "create_profile" "click" ui-create-profile)
)