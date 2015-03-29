(defpackage :test-gtk
  (:use :common-lisp :pod :cells :gtk-ffi :cells-gtk)
  (:export gtk-demo))

(in-package :test-gtk)

(defvar *test-img-dir*
  (make-pathname :name nil :type nil :version nil
                 :defaults (merge-pathnames
                            (make-pathname :directory '(:relative :back :back "test-images"))
                            (parse-namestring *load-truename*))))
(defvar *splash-image*
  (make-pathname :name "splash" :type "png"
                 :defaults *test-img-dir*))

(defvar *small-image*
  (make-pathname :name "small" :type "png"
                 :defaults *test-img-dir*))

(defvar *stock-icon-image*
  (make-pathname :name "my-g" :type "png"
                 :defaults *test-img-dir*))

(defvar *tst-image*
  (make-pathname :name "tst" :type "gif"
                 :defaults *test-img-dir*))

(defmodel test-gtk (gtk-app)
  ()
  (:default-initargs
      :title "GTK Testing"
    ;;:tooltips nil ;;dkwt
    ;;:tooltips-enable nil ;;dkwt
    :icon (namestring *small-image*)
    :stock-icons (list (list :my-g (namestring *stock-icon-image*)))
    :position :center
    :splash-screen-image (namestring *splash-image*)
    :width 650 :height 550
    :kids (let ((tabs '("Buttons"
                        "Display" "Layout"
                        "Menus"
                        "Textview" "Dialogs" "Addon"
                        "Entry"
                        "Tree-view")))
            (list (mk-notebook 
                   :tab-labels tabs
                   :kids  (loop for test-name in tabs
                              collect (make-instance
                                          (intern (string-upcase
                                                   (format nil "test-~a" test-name))
                                            :test-gtk))))))))

(defun test-gtk-app ()
  (start-app 'test-gtk)
  #+clisp (ext:exit))


(defun gtk-demo (&optional dbg)
  (cells-gtk-init)
  (cells-gtk:start-app 'test-gtk::test-gtk :debug dbg))

;(ext:saveinitmem "test-gtk.mem" :init-function 'test-gtk::test-gtk-app)
