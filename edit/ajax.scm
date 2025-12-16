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
         ;; Обновляем список профилей
         (let ((profiles-list (get-profiles-list)))
           (form-update-enum "profiles" profiles-list)
           (form-update-value "profiles" new-profile-name))
         ;; Обновляем таблицу
         (let ((hosts-data (woo-list "/m104/hosts")))
           (form-update-enum "hosts" hosts-data)
           (when (not (null? hosts-data))
             (let ((first-host (car hosts-data)))
               (form-update-value "title" (woo-get-option first-host 'title))))))))))

;; Функция для удаления текущего профиля
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
         ;; Передаем все выбранные процессы одним вызовом, объединяя через ";"
         (let ((processes-string (string-join (string-split selected-processes #\;) " ")))
           (woo "delete_process" "/m104" 
                'process_num processes-string)
           ;; Обновляем таблицу после удаления
           (form-update-enum "hosts"
             (woo-list "/m104/hosts"))))))))



;; Функция для показа формы "Сохранить как"
(define (ui-show-save-as)
  (form-update-visibility '("saveAsForm") #t))

;; Функция для скрытия формы "Сохранить как"
(define (ui-hide-save-as)
  (form-update-visibility '("saveAsForm") #f))
;; /////// форма для создания нового профиля ///////
(define (ui-show-profileform-as)
(form-update-visibility '("addNewProfiles") #t))

(define (ui-hide-add-as)
  (form-update-visibility '("addNewProfiles") #f))


(define (ui-show-save-as-and-hide-add-as)
  (ui-show-save-as)
  (ui-hide-add-as))

(define (ui-show-profileform-as-ui-hide-save-as)
  (ui-show-profileform-as)
  (ui-hide-save-as)
)
;;////// скрывать поле профиля после нажатия на кнопку "создать"
(define (ui-create-profile-ui-hide-add-as)
  (ui-create-profile)
  (ui-hide-add-as)
)

;;///////////////// форма для "Сохранить как"  //////////////////////////
; (define (ui-checkbox-prof)
;   (form-update-visibility '("profile_selection") #t)
; )

; (define (ui-savenewprof)
;   (form-update-visibility '("SaveNewProf") #f)
; )

; (define (ui-checkbox-prof-ui-savenewprof)
;   (ui-checkbox-prof)
;   (ui-savenewprof)
; )

;;///////////////// форма для "Сохранить как"  //////////////////////////
(define (ui-toggle-checkbox)
  (catch/message
   (lambda()
     (let ((checkbox-state (form-value "checkbox_prof")))
       (if (and checkbox-state (string=? checkbox-state "on"))
           ;; Если чекбокс отмечен - показываем выбор профиля, скрываем создание нового
           (begin
             (form-update-visibility '("profile_selection") #t)
             (form-update-visibility '("SaveNewProf") #f))
           ;; Если чекбокс не отмечен - показываем создание нового, скрываем выбор профиля
           (begin
             (form-update-visibility '("profile_selection") #f)
             (form-update-visibility '("SaveNewProf") #t)))))))

;; Функция для показа формы "Сохранить как" с начальными настройками
(define (ui-show-save-as)
  (catch/message
   (lambda()
     ;; Сбрасываем чекбокс
     (form-update-value "checkbox_prof" #f)
     ;; Показываем форму создания нового профиля
     (form-update-visibility '("SaveNewProf") #t)
     ;; Скрываем выбор существующего профиля
     (form-update-visibility '("profile_selection") #f)
     ;; Показываем основную форму
     (form-update-visibility '("saveAsForm") #t))))


;; Функция для сохранения текущего профиля как нового
(define (ui-save-as-create)
  (catch/message
   (lambda()
     (let ((new-profile-name (form-value "save_as_new_name")))
       (when (and new-profile-name (not (string-null? new-profile-name)))
         ;; Вызываем метод сохранения как
         (woo "save_profile_as" "/m104" 'new_profile_name new-profile-name)
         ;; Обновляем список профилей
         (let ((profiles-list (get-profiles-list)))
           (form-update-enum "profiles" profiles-list)
           (form-update-value "profiles" new-profile-name))
         ;; Обновляем таблицу
         (let ((hosts-data (woo-list "/m104/hosts")))
           (form-update-enum "hosts" hosts-data)
           (when (not (null? hosts-data))
             (let ((first-host (car hosts-data)))
               (form-update-value "title" (woo-get-option first-host 'title)))))
         ;; Скрываем форму после успешного сохранения
         (ui-hide-save-as))))))




(define (init)
  (catch/message (lambda ()
    ;; Загружаем список профилей
    (let ((profiles-list (get-profiles-list)))
      (display "DEBUG: Profiles list: ") (display profiles-list) (newline)
      (form-update-enum "profiles" profiles-list)
      
      ;; Загружаем данные хостов чтобы определить текущий профиль
      (let ((hosts-data (woo-list "/m104/hosts")))
        (display "DEBUG: Hosts data: ") (display hosts-data) (newline)
        (form-update-enum "hosts" hosts-data)
        
        ;; Определяем текущий профиль
        (let ((current-profile 
               (if (not (null? hosts-data))
                   (let ((first-host (car hosts-data)))
                     (let ((title (woo-get-option first-host 'title)))
                       ;; Извлекаем имя профиля из заголовка
                       (if (string-contains title "Профиль ")
                           (let ((parts (string-split title #\space)))
                             (if (> (length parts) 1)
                                 (string-join (cdr parts) " ") ; Берем все части после "Профиль"
                                 "m104"))
                           "m104")))
                   "m104")))
          
          (display "DEBUG: Current profile from title: '") (display current-profile) (display "'") (newline)
          
          ;; Устанавливаем текущий профиль в выпадающем списке
          (form-update-value "profiles" current-profile)
          
          ;; Устанавливаем заголовок
          (when (not (null? hosts-data))
            (let ((first-host (car hosts-data)))
              (form-update-value "title" (woo-get-option first-host 'title)))))))))
;; (ui-init)
(form-bind "profiles" "click" ui-change-profile)
(form-bind "return" "click" ui-return)
(form-bind "apply" "click" ui-apply)
(form-bind "applySecondary" "click" ui-applySecondary)
(form-bind "addProc" "click" ui-addProc)
(form-bind "delProc" "click" ui-delProc)
(form-bind "addNewProfile" "click" ui-addProf-NewProfile)
(form-bind "deleteProfile" "click" ui-delete-profile)
(form-bind "create_profile" "click" ui-create-profile-ui-hide-add-as)
(form-bind "save_as" "click" ui-show-save-as-and-hide-add-as)
(form-bind "cancellation_save" "click" ui-hide-save-as)

(form-bind "cancellation_newprofiles" "click" ui-hide-add-as)

(form-bind "AddNewProf" "click" ui-show-profileform-as-ui-hide-save-as)


; (form-bind "checkbox_prof" "change" ui-checkbox-prof-ui-savenewprof)
(form-bind "checkbox_prof" "change" ui-toggle-checkbox)
(form-bind "save_as_create" "click" ui-save-as-create)
)