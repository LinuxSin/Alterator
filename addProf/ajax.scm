(define-module (ui m104 addProf ajax)
  :use-module (alterator woo)
  :use-module (alterator ajax)
  :export (init))

(define (ui-return)
(form-replace "/m104/edit"))

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

(define (init)
  (form-bind "return" "click" ui-return)
  (form-bind "create_profile" "click" ui-create-profile)  
)