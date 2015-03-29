#|

 Gtk ffi

 Copyright (c) 2004 by Vasilis Margioulas <vasilism@sch.gr>

 You have the right to distribute and use this software as governed by 
 the terms of the Lisp Lesser GNU Public License (LLGPL):

    (http://opensource.franz.com/preamble.html)
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 Lisp Lesser GNU Public License for more details.
 
|#

(in-package :gtk-ffi)

;;; POD throw-away utility to convert hello-c/uffi to cffi
#+nil
(defun gtk-lib2cffi (body)
  "Convert hello-c to uffi to cffi types. Swap order of arguments."
  (flet ((convert-type (type)
	  (case type
	    (c-string :gtk-string)
	    (boolean :gtk-boolean)
	    (t (cffi-uffi-compat::convert-uffi-type (ffi-to-uffi-type type))))))
  (dbind (ignore module &rest funcs) body
     (pprint `(,ignore 
	       ,module
	       ,@(mapcar
		  #'(lambda (f)
		      (dbind (name args &optional return-type) f
			     ` (,name 
				    ,(if return-type
					 (convert-type return-type)
				       :void)
				    ,(mapcar #'(lambda (a)
						 (list
						  (car a)
						  (convert-type (cadr a))))
					     args))))
		      funcs))
	     *standard-output*))))

;;keep SBCL happy
(defconstant +c-null+ 
  (if (boundp '+c-null+)
      (symbol-value '+c-null+)
    (cffi:null-pointer)))

(defvar *gtk-debug* nil)

;;; ==============  Define CFFI types, and their translations.... 
(cffi:defctype :gtk-string :pointer :documentation "string type for cffi type translation")
(cffi:defctype :gtk-boolean :pointer :documentation "boolean type for cffi type translation")

(defmethod cffi:translate-to-foreign (value (type (eql :gtk-boolean)))
  (cffi:make-pointer (if value 1 0)))

(defmethod cffi:translate-from-foreign (value (type (eql :gtk-boolean)))
  #-clisp(not (zerop (cffi::pointer-address value))) ; pod strange!
  #+clisp(if (null value) ; pod something really wrong here!
	     nil
	   (not (zerop (cffi::pointer-address value)))))

(defmethod cffi:translate-to-foreign (value (type (eql :gtk-string)))
  (when (null value) (setf value "")) ; pod ??? 
  (cffi:foreign-string-alloc value))

(defmethod cffi:translate-from-foreign (value (type (eql :gtk-string)))
  (cffi:foreign-string-to-lisp value))

(defun int-slot-indexed (obj obj-type slot index)
  (declare (ignorable obj-type))
  (cffi:mem-aref (cffi:foreign-slot-value obj obj-type slot) :int  index))

(defun (setf int-slot-indexed) (new-value obj obj-type slot index)
  (declare (ignorable obj-type))
  (setf (cffi:mem-aref (cffi:foreign-slot-value obj obj-type slot) :int index)
    new-value))

(eval-when (:compile-toplevel :load-toplevel :execute)
(cffi:define-foreign-library :gobject
  (cffi-features:unix "libgobject-2.0.so")
  (cffi-features:windows "libgobject-2.0-0.dll")
  (cffi-features:darwin "libgobject-2.0-0.dylib"))

(cffi:define-foreign-library :glib
  (cffi-features:unix "libglib-2.0.so")
  (cffi-features:windows "libglib-2.0-0.dll")
  (cffi-features:darwin "libglib-2.0-0.dylib"))

(cffi:define-foreign-library :gthread
  (cffi-features:unix "libgthread-2.0.so")
  (cffi-features:windows "libgthread-2.0-0.dll")
  (cffi-features:darwin "libgthread-2.0-0.dylib"))

(cffi:define-foreign-library :gdk
  (cffi-features:unix "libgdk-x11-2.0.so")
  (cffi-features:windows "libgdk-win32-2.0-0.dll")
  (cffi-features:darwin "libgdk-win32-2.0-0.dylib")) ; pod ???

(cffi:define-foreign-library :gtk
  (cffi-features:unix "libgtk-x11-2.0.so")
  (cffi-features:windows "libgtk-win32-2.0-0.dll")
  (cffi-features:darwin "libgtk-win32-2.0-0.dylib")) ; pod ???

#+libcellsgtk
(cffi:define-foreign-library :cgtk
  (cffi-features:unix "libcellsgtk.so")
  (cffi-features:windows "libcellsgtk.dll")
  (cffi-features:darwin "libcellsgtk.dylib"))
) ;eval-when

;;; After doing this, should be able to do (g-thread-init c-null)
;;; The above define-foreigh-library appears to be useless (doesn't
;;; work through the symbols) use the names. 

;;; LW Win32 is hanging on POD's machine only:
;;; (fli:register-module "libgdk-win32-2.0-0.dll" :connection-style :immediate)
;;; (fli:register-module "c:\\Program Files\\Common Files\\GTK\\2.0\\bin\\libgdk-win32-2.0-0.dll" 
;;;                      :connection-style :immediate)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun load-gtk-libs ()
    (handler-bind ((style-warning #'muffle-warning))
      (cffi:load-foreign-library :gobject)
      (cffi:load-foreign-library :glib)
      (cffi:load-foreign-library :gthread)
      (cffi:load-foreign-library :gdk)
      (cffi:load-foreign-library :gtk)
      #+libcellsgtk
      (cffi:load-foreign-library :cgtk)))
) ; eval

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun gtk-function-name (lisp-name)
    (substitute #\_ #\- lisp-name))

  #+(or cmu clisp)(load-gtk-libs)

  (defun ffi-to-uffi-type (clisp-type)
    
    (if (consp clisp-type)
                (mapcar 'ffi-to-uffi-type clisp-type)
	      (case clisp-type
		((nil) :void)
		(uint :UNSIGNED-INT)
		(c-pointer :pointer-void)
		(c-ptr-null '*)
		(c-array-ptr '*)
		(c-ptr '*)
		(c-string :cstring)
		(sint32 :int)
		(uint32 :unsigned-int)
		(uint8 :unsigned-byte)
		(uint16 :short) ; no signed/unsigned types?
		(boolean :unsigned-int)
		(ulong :unsigned-long)
		(int :int)
		(long :long)
		(single-float :float)
		(double-float :double)
		(otherwise clisp-type))))
) ;eval

(defmacro def-gtk-function (library name return-type arguments)
  (declare (ignore library))
  (let* ((gtk-name$ (gtk-function-name (string-downcase (symbol-name name))))
         (gtk-name (intern (string-upcase gtk-name$))))
    `(progn
       (cffi:defcfun (,gtk-name$ ,gtk-name) ,return-type ,@arguments)
       (defun ,name ,(mapcar 'car arguments)
	 (when *gtk-debug*
	   ,(unless (or (string= (symbol-name name) "GTK-EVENTS-PENDING")
			(string= (symbol-name name) "GTK-MAIN-ITERATION-DO"))
	      `(format *trace-output* "~%Calling (~A ~{~A~^ ~})" 
		       ,(string-downcase (string name)) (list ,@(mapcar 'car arguments)))))
	 (let ((result (,gtk-name ,@(mapcar #'car arguments))))
	   (when *gtk-debug*
	     ,(unless (or (string= (symbol-name name) "GTK-EVENTS-PENDING")
			  (string= (symbol-name name) "GTK-MAIN-ITERATION-DO"))
	      `(format *trace-output* "~%  (~A ~{~A~^ ~}) returns ~A" 
		       ,(string-downcase (string name)) (list ,@(mapcar 'car arguments))
		       result)))
	   result))
       (eval-when (:compile-toplevel :load-toplevel :execute)
	 (export ',name)))))

(defmacro def-gtk-lib-functions (library &rest functions)
  `(progn
     ,@(loop for function in functions collect
             (destructuring-bind (name return-type (&rest args)) function
               `(def-gtk-function ,library ,name ,return-type ,args)))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro callback-function ((&rest arguments) &optional return-type)
    (declare (ignore arguments return-type))
        `'c-pointer))

(defmacro def-c-struct (struct-name &rest fields)
  (let ((slot-defs (loop for field in fields
                         collecting (destructuring-bind (name type) field
                                      (list name
                                        (intern (string-upcase
                                                 (format nil "~a-supplied-p" name)))
                                        (ffi-to-uffi-type type))))))
    `(progn
       (uffi:def-struct ,struct-name
           ,@(loop for (name nil type) in slot-defs
                   collecting (list name type)))
       ;; --- make-<struct-name> ---
       ,(let ((obj (gensym)))
          `(defun ,(intern (string-upcase (format nil "make-~a" struct-name)))
             (&key ,@(loop for (name supplied nil) in slot-defs
                         collecting (list name nil supplied)))
             (let ((,obj (uffi:allocate-foreign-object ',struct-name)))
               ,@(loop for (name supplied nil) in slot-defs
                     collecting `(when ,supplied
                                   (setf (cffi:foreign-slot-value ,obj ',struct-name ',name) ,name)))
               ,obj)))

       ;; --- accessors ---
       ,@(mapcar (lambda (slot-def &aux
                           (slot-name (car slot-def))
                           (accessor (intern (format nil "~a-~a" struct-name slot-name))))
                   `(progn
                      (defun ,accessor (self)
                        (cffi:foreign-slot-value self ',struct-name ',slot-name))
                      (defun (setf ,accessor) (new-value self)
                        (setf (cffi:foreign-slot-value self ',struct-name ',slot-name)
                          new-value))))
           slot-defs))))

(def-c-struct gdk-event-button
  (type int)
  (window c-pointer)
  (send-event uint8)
  (time uint32)
  (x double-float)
  (y double-float)
  (axes (c-ptr double-float))
  (state uint)
  (button uint)
  (device c-pointer)
  (x_root double-float)
  (y_root double-float))

(def-c-struct gdk-event-key
  (type int)
  (window c-pointer)
  (send-event uint8)
  (time uint32)
  (state uint)
  (keyval uint)
  (length int)
  (string c-pointer)
  (hardware-keycode uint16)
  (group uint8))

(def-c-struct gdk-event-expose
  (type int)
  (window c-pointer)
  (send-event uint8)
  ;; This is probably wrong. alignment issues...
  (area-x int)
  (area-y int)
  (area-width int)
  (area-height int)
  (region c-pointer)
  (count int))

(def-c-struct gdk-event-motion
  (type int)
  (window c-pointer)
  (send-event uint8)
  (time int)
  (x double-float)
  (y double-float)
  (axes c-pointer)
  (state int)
  (is-hint uint16)
  (device c-pointer)
  (x-root double-float)
  (y-root double-float))

(defun event-type (event)
  (ecase event
    (-1 :nothing)
    (0 :delete)
    (1 :destroy)
    (2 :expose)
    (3 :notify) ; that is, pointer motion notify
    (4 :button_press)
    (5 :2button_press)
    (6 :3button_press)
    (7 :button_release)
    (8 :key_press)
    (9 :key_release)
    (10 :enter_notify)
    (11 :leave_notify)
    (12 :focus_change)
    (13 :configure)
    (14 :map)
    (15 :unmap)
    (16 :property_notify)
    (17 :selection_clear)
    (18 :selection_request)
    (19 :selection_notify)
    (20 :proximity_in)
    (21 :proximity_out)
    (22 :drag_enter)
    (23 :drag_leave)
    (24 :drag_motion)
    (25 :drag_status)
    (26 :drop_start)
    (27 :drop_finished)
    (28 :client_event)
    (29 :visibility_notify)
    (30 :no_expose)
    (31 :scroll)
    (32 :window_state)
    (33 :setting)))

(uffi:def-struct list-boolean
    (value :unsigned-int)
  (end :pointer-void))

(defmacro with-gtk-string ((var string) &rest body)
  `(let ((,var ,string))
     ,@body)
  #+not
  `(let ((,var (to-gtk-string ,string)))
     (unwind-protect 
           (progn ,@body)
        (g-free ,var))))

(defun value-set-function (type)
  (ecase type
    (c-string #'g-value-set-string)
    (c-pointer #'g-value-set-string)  ;; string-pointer
    (integer #'g-value-set-int)
    (single-float #'g-value-set-float)
    (double-float #'g-value-set-double)
    (boolean #'g-value-set-boolean)))

(defun value-type-as-int (type)
  (ecase type
    (c-string (* 16 4))
    (c-pointer (* 16 4)) ;; string-pointer
    (integer (* 6 4))
    (single-float (* 14 4))
    (double-float (* 15 4))
    (boolean (* 5 4))))

(def-c-struct type-val
    (type long)
  (val double-float)
  (val2 double-float))

(def-c-struct gslist
  (data c-pointer)
  (next c-pointer))

(def-c-struct gtk-tree-iter
  (stamp int)
  (user-data c-pointer)
  (user-data2 c-pointer)
  (user-data3 c-pointer))

(defmacro with-tree-iter ((iter-var) &body body)
  `(uffi:with-foreign-object (,iter-var 'gtk-tree-iter)
     (setf (cffi:foreign-slot-value ,iter-var 'gtk-tree-iter 'stamp) 0)
     (setf (cffi:foreign-slot-value ,iter-var 'gtk-tree-iter 'user-data) +c-null+)
     (setf (cffi:foreign-slot-value ,iter-var 'gtk-tree-iter 'user-data2) +c-null+)
     (setf (cffi:foreign-slot-value ,iter-var 'gtk-tree-iter 'user-data3) +c-null+)
     ,@body))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun as-gtk-type-name (type)
    (ecase type
      (:string 'c-string)
      (:icon 'c-string)
      (:int 'int)
      (:long 'long)
      (:date 'float)
      (:float 'single-float)
      (:double 'double-float)
      (:boolean 'boolean)))
  (defun as-gtk-type (type)
    (ecase type
      (:string (* 16 4))
      (:icon (* 16 4))
      (:int (* 6 4))
      (:long (* 8 4))
      (:date (* 14 4))
      (:float (* 14 4))
      (:double (* 15 4))
      (:boolean (* 5 4)))))

(defun col-type-to-ffi-type (col-type)
  (cdr (assoc col-type '((:string . c-string) ;;2004:12:15-00:17 was c-pointer
                         (:icon . c-pointer)
                         (:boolean . boolean)
                         (:int . int)
                         (:long . long)
                         (:date . single-float)
                         (:float . single-float)
                         (:double . double-float)))))

(defmacro deref-pointer-runtime-typed (ptr type)
  "Returns a object pointed"
  (declare (ignorable type))
  `(uffi:deref-pointer ,ptr ,type))

(defun cast (ptr type)
  (deref-pointer-runtime-typed ptr (ffi-to-uffi-type type)))



