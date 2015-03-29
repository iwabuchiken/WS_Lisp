(in-package :cl-user)

;;; Load asdf, if necessary; set up asdf:*central-registry* 
;;; and load everything necessary to run cells-gtk. 

#-asdf(load (compile-file "asdf.lisp"))

#+clisp(setf custom:*parse-namestring-ansi* t)

(let ((default-path
       #-clisp *load-truename*
       #+clisp (make-pathname :directory '(:absolute "local" "lisp" "cells-gtk-2006-06-30")))) ; <=== CLISP users
  (setf (logical-pathname-translations "cells-gtk")
	`(("root;*.*.*"
	   ,(make-pathname
	     :name :wild :type :wild :version :wild
	     :defaults default-path))
	  ("**;*.*.*"
	   ,(merge-pathnames
	     (make-pathname
	      :directory '(:relative :wild-inferiors)
	      :name :wild :type :wild :version :wild
	      :defaults default-path)
	     default-path)))))

(let ((asdf:*central-registry* 
        (list #P"cells-gtk:"
              #P"cells-gtk:cells;"
              #P"cells-gtk:cffi;"
              #P"cells-gtk:root;pod-utils;"
              #P"cells-gtk:root;gtk-ffi;"
              #P"cells-gtk:root;cells-gtk;"
              #P"cells-gtk:root;cells-gtk;test-gtk;")))
  (asdf:oos 'asdf:load-op :cells)
  (asdf:oos 'asdf:load-op :cffi)
  (asdf:oos 'asdf:load-op :cffi-uffi-compat)
  (asdf:oos 'asdf:load-op :gtk-ffi)
  (asdf:oos 'asdf:load-op :cells-gtk)
  (asdf:oos 'asdf:load-op :test-gtk))

(format t "~3% Done! Now try (test-gtk:gtk-demo) or if problems, (test-gtk:gtk-demo t)")






