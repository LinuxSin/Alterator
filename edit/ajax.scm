(define-module (ui m104 edit ajax)
:use-module (alterator woo)
:use-module (alterator algo)
:use-module (alterator ajax)
:export (init))

; ////////////////////////////////////////////////////////////////////////////
;; Функция для получения списка профилей
(define (get-profiles-list)
  (woo-list "/m104/profiles"))

;; Новая функция для загрузки списка профилей в выпадающий список
(define (load-target-profiles-list)
  (catch/message
   (lambda()
     (let ((profiles-list (get-profiles-list)))
       ;; Загружаем список профилей в выпадающий список
       (form-update-enum "target_profiles" profiles-list)))))

;; Функция для копирования данных в выбранный профиль
(define (ui-copy-to-profile)
  (catch/message
   (lambda()
     (let ((target-profile (form-value "target_profiles")))
       (when target-profile
         ;; Вызываем метод копирования данных в выбранный профиль
         (woo "copy_to_profile" "/m104" 'target_profile target-profile)
         ;; НЕ ОБНОВЛЯЕМ СПИСОК ПРОФИЛЕЙ - они не изменились
         ;; Скрываем форму
         (ui-hide-save-as))))))

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
     (let ((new-profile-name (form-value "new_profile_name"))
           (current-profile (form-value "profiles")))  ;; Сохраняем текущий профиль
       (when (and new-profile-name (not (string-null? new-profile-name)))
         ;; Вызываем метод создания профиля
         (woo "create_profile" "/m104" 'profile_name new-profile-name)
         ;; Обновляем список профилей
         (let ((profiles-list (get-profiles-list)))
           (form-update-enum "profiles" profiles-list)
           ;; ВОЗВРАЩАЕМ ТЕКУЩИЙ ПРОФИЛЬ КАК ВЫБРАННЫЙ (не переключаемся на новый)
           (form-update-value "profiles" current-profile))
         ;; Обновляем таблицу (она должна остаться с текущим профилем)
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
(define (ui-toggle-checkbox)
  (catch/message
   (lambda()
     (let ((checkbox-state (form-value "checkbox_prof")))
       (if (and checkbox-state (string=? checkbox-state "on"))
           ;; Если чекбокс отмечен - показываем выбор профиля, скрываем создание нового
           (begin
             ;; Загружаем список профилей в выпадающий список
             (load-target-profiles-list)
             (form-update-visibility '("profile_selection") #t)
             (form-update-visibility '("SaveNewProf") #f)
             ;; Скрываем обычную кнопку и показываем кнопку (1)
             (form-update-visibility '("save_as_create") #f)
             (form-update-visibility '("save_select_data") #t))
           ;; Если чекбокс не отмечен - показываем создание нового, скрываем выбор профиля
           (begin
             (form-update-visibility '("profile_selection") #f)
             (form-update-visibility '("SaveNewProf") #t)
             ;; Показываем обычную кнопку и скрываем кнопку (1)
             (form-update-visibility '("save_as_create") #t)
             (form-update-visibility '("save_select_data") #f)))))))

;; Функция для показа формы "Сохранить как" с начальными настройками
(define (ui-show-save-as)
  (catch/message
   (lambda()
     ;; Сбрасываем чекбокс
     (form-update-value "checkbox_prof" #f)
     ;; Сбрасываем выпадающий список
     (form-update-value "target_profiles" #f)
     ;; Показываем форму создания нового профиля
     (form-update-visibility '("SaveNewProf") #t)
     ;; Скрываем выбор существующего профиля
     (form-update-visibility '("profile_selection") #f)
     ;; Скрываем кнопку копирования и показываем обычную кнопку
     (form-update-visibility '("save_select_data") #f)
     (form-update-visibility '("save_as_create") #t)
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

;; Добавьте эту привязку для новой кнопки
(form-bind "save_select_data" "click" ui-copy-to-profile)

;; Остальные привязки остаются без изменений
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
(form-bind "checkbox_prof" "change" ui-toggle-checkbox)
(form-bind "save_as_create" "click" ui-save-as-create)
)