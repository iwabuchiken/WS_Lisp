#|

 Cells Gtk

 Copyright (c) 2004 by Vasilis Margioulas <vasilism@sch.gr>

 You have the right to distribute and use this software as governed by 
 the terms of the Lisp Lesser GNU Public License (LLGPL):

    (http://opensource.franz.com/preamble.html)
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 Lisp Lesser GNU Public License for more details.
 
|#

(in-package :cgtk)


(defmodel gtk-object (family)
  ((container :cell nil :initarg :container :accessor container)
   (def-gtk-class-name :accessor def-gtk-class-name :initarg :def-gtk-class-name :initform nil)
   (new-function-name :accessor new-function-name :initarg :new-function-name 
     :initform (c? (intern (format nil "GTK-~a-NEW~a"
                             (def-gtk-class-name self)
                             (or (new-tail self) ""))
                     :gtk-ffi)))
   (new-args :accessor new-args :initarg :new-args :initform nil)
   (new-tail :accessor new-tail :initarg :new-tail :initform nil)
   (id :initarg :id :accessor id 
     :initform (c? (without-c-dependency 
                    (when *gtk-debug* 
                      (trc nil "NEW ID" (new-function-name self) (new-args self)) (force-output))
                    (let ((id (apply (symbol-function (new-function-name self))
                                (new-args self))))
                      (gtk-object-store id self)
                      id))))
   
   (callbacks :cell nil :accessor callbacks
     :initform nil
     :documentation "assoc of event-name, callback closures to handle widget events"))
  (:default-initargs
      :md-name nil ;; kwt: was (c-in nil), but this is not a cell
    :md-value (c-in nil)))

;; --------- provide id-to-clos lookup ------

(defvar *gtk-objects* nil)

(defun gtk-objects-init ()
  (setf *gtk-objects* (make-hash-table :size 100 :rehash-size 100)))

(defun gtk-object-store (gtk-id gtk-object &aux (hash-id (cffi:pointer-address gtk-id)))
  (unless *gtk-objects*
    (gtk-objects-init))
  (let ((known (gethash hash-id *gtk-objects*)))
    (cond
     ((not known)
      (setf (gethash hash-id *gtk-objects*) gtk-object))
     ((eql known gtk-object))
     (t
       (gtk-report-error gtk-object-id-error 
                        "gtk-object-store id ~a already known as ~a, not ~a"
                        hash-id known gtk-object)))))

(defun gtk-object-forget (gtk-id gtk-object)
  (when gtk-id
    (assert *gtk-objects*)
    (remhash (cffi:pointer-address gtk-id) *gtk-objects*)
    (mapc #'(lambda (k) (gtk-object-forget (id k) k)) (kids gtk-object))))

(defun gtk-object-find (gtk-id &optional must-find-p &aux (hash-id (cffi:pointer-address gtk-id)))
  (when *gtk-objects*
    (let ((clos-widget (gethash hash-id *gtk-objects*)))
      (when (and must-find-p (not clos-widget))
        (format t "~&gtk.object.find> ID ~a not found!!!!!!!" hash-id)
        (maphash (lambda (key value)
                   (format t "~&  known: ~a | ~a" key value))
          *gtk-objects*)
        (gtk-report-error gtk-object-id-error "gtk.object.find ID not found ~a" hash-id))         
      clos-widget)))

;; ----- fake callbackable closures ------------

(defun callback-register (self callback-key closure)
  (let ((x (assoc callback-key (callbacks self))))
    (if x (rplacd x closure)
      (push (cons callback-key closure) (callbacks self)))))

(defun callback-recover (self callback-key)
  (cdr (assoc callback-key (callbacks self))))

; ------------------------------------------

(defmethod configure ((self gtk-object) gtk-function value)
  (apply gtk-function
    (id self)
    (if (consp value)
        value
      (list value))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun gtk-function-name (class option)
    (let ((slot-access (if (atom option)
			   (list 'set option)
			   (append (and (second option) (list (second option)))
				   (list (first option))))))
      (intern (format nil "GTK-~a~{-~a~}" class slot-access) :gtk-ffi))))

;;; --- widget --------------------
;;; Define handlers that recover the callback defined on the widget

(defmacro def-gtk-event-handler (event)
  `(cffi:defcallback ,(intern (format nil "~a-HANDLER" event)) :int
     ((widget :pointer) (event :pointer) (data :pointer))
     (if-bind (self (gtk-object-find widget))
	  (let ((cb (callback-recover self ,(intern (string event) :keyword))))
	    (funcall cb self widget event data))
	  (trc nil "Unknown widget from prior run. Clean up on errors" widget))))

(def-gtk-event-handler clicked)
(def-gtk-event-handler changed)
(def-gtk-event-handler activate)
(def-gtk-event-handler value-changed)
(def-gtk-event-handler day-selected)
(def-gtk-event-handler selection-changed)
(def-gtk-event-handler toggled)
(def-gtk-event-handler delete-event)
(def-gtk-event-handler modified-changed)

(defparameter *widget-callbacks*
  (list (cons 'clicked (cffi:get-callback 'clicked-handler))
    (cons 'changed (cffi:get-callback 'changed-handler))
    (cons 'activate (cffi:get-callback 'activate-handler))
    (cons 'value-changed (cffi:get-callback 'value-changed-handler))
    (cons 'day-selected (cffi:get-callback 'day-selected-handler))
    (cons 'selection-changed (cffi:get-callback 'selection-changed-handler))
    (cons 'toggled (cffi:get-callback 'toggled-handler))
    (cons 'delete-event (cffi:get-callback 'delete-event-handler))
    (cons 'modified-changed (cffi:get-callback 'modified-changed-handler))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  
  (defmacro def-object (&rest args)
    `(def-gtk gtk-object ,@args))
  (defmacro def-widget (&rest args)
    `(def-gtk widget ,@args))  
  (defmacro def-gtk (gtk-superclass class
                      superclasses
                      (&rest std-slots)
                      (&rest gtk-slots) (&rest gtk-signals) &rest defclass-options)
    (multiple-value-bind (slots outputs)
        (loop for gtk-option-def in gtk-slots
            for slot-name = (if (atom gtk-option-def)
                                gtk-option-def (car gtk-option-def))
            collecting `(,slot-name :initform (c-in nil)
                          :initarg ,(intern (string slot-name) :keyword)
                          :accessor ,slot-name)
            into slot-defs
            collecting `(def-c-output ,slot-name ((self ,class))
                          (when (or new-value old-value)
                            #+shhh (when *gtk-debug*
                              (TRC ,(format nil "output before ~a-~a" class slot-name) new-value) (force-output))
                            (configure self #',(gtk-function-name class gtk-option-def)
                              new-value)
                            #+shhh (when *gtk-debug*
                              (TRC ,(format nil "output after ~a-~a" class slot-name) new-value) (force-output))))
            into outputs
            finally (return (values slot-defs outputs)))
      (multiple-value-bind (signals-slots signals-outputs)
          (loop for signal-slot in gtk-signals
              for slot-name = (intern (format nil "ON-~a" signal-slot))
              collecting `(,slot-name :initform nil
                            :initarg ,(intern (string slot-name) :keyword)
                            :accessor ,slot-name)
              into signals-slots-defs
              collecting `(def-c-output ,slot-name ((self ,class))
                            (when new-value
                              (callback-register self
                                ,(intern (string signal-slot) :keyword)
                                new-value)
                              (let ((cb (cdr (assoc ',signal-slot *widget-callbacks*))))
                                (assert cb () "Callback ~a not defined in *widget-callbacks*" ',signal-slot)
                                #+shhtk (trc nil "in def-c-output gtk-signal-connect pcb:"
                                  cb ',slot-name (id self))
                              (gtk-signal-connect (id self)
                                ,(string-downcase (string signal-slot)) cb))))
              into signals-outputs-defs
              finally (return (values signals-slots-defs signals-outputs-defs)))
        `(progn
           (defmodel ,class ,(or superclasses (list gtk-superclass))
             (,@(append std-slots slots signals-slots))
             (:default-initargs
                 :def-gtk-class-name ',class
               ,@defclass-options))
           (eval-when (compile load eval)
             (export ',class))
           (eval-when (compile load eval)
             (export ',(mapcar #'first (append std-slots slots signals-slots))))
           
           (defun ,(intern (format nil "MK-~a" class)) (&rest inits)
             (when *gtk-debug* (trc nil "MAKE-INSTANCE" ',class) (force-output))
             (apply 'make-instance ',class inits))
           (eval-when (compile load eval)
             (export ',(intern (format nil "MK-~a" class))))
           ,@outputs
           ,@signals-outputs)))))

(defmacro callback ((widg event data) &body body)
  `(lambda (self ,widg ,event ,data) 
     (declare (ignorable self ,widg ,event ,data))
     ;(print (list :anon-callback self ,widg ,event ,data))
     (prog1
         (progn
           ,@body
           1) ;; a boolean which indicates, IIRC, "handled"
       #+shhh (print (list :callback-finis self ,widg ,event ,data)))))

(defmacro callback-if (condition (widg event data) &body body)
  `(c? (and ,condition
         (lambda (self ,widg ,event ,data) 
                   (declare (ignorable self ,widg ,event ,data))
                   ;(print (list :anon-callback-if self ,widg ,event ,data))
                   ,@body
                   1))))

(cffi:defcallback timeout-handler-callback :int ((data :pointer))
  (let* ((id (cffi:mem-aref data :int 0))
	 (r2 (gtk-global-callback-funcall id)))
    (trc nil "timeout func really returning" r2)
    (if r2 1 0)))

(defun timeout-add (milliseconds function)
  "Call FUNCTION repeatedly, waiting MILLISECONDS between calls. 
   Stops calling when function return false."
  (let* ((id (gtk-global-callback-register
              (lambda ()
                ;;(print :timeout-add-global)
                (let ((r (with-gdk-threads
			  (funcall function))))
                  (trc nil "timeout func returning" r)
                  r))))
	 (c-id (cffi:foreign-alloc :int :initial-element id)))
    (trc nil "timeout-add > passing cb data, *data" c-id (cffi:mem-aref c-id :int 0))
    (g-timeout-add milliseconds (cffi:get-callback 'timeout-handler-callback) c-id)))

(def-object widget ()
  ((tooltip :accessor tooltip :initarg :tooltip :initform (c-in nil))
   (popup :accessor popup :initarg :popup :initform (c-in nil))
   (visible :accessor visible :initarg :visible :initform (c-in t))
   (sensitive :accessor sensitive :initarg :sensitive :initform (c-in t))
   (expand :accessor expand? :initarg :expand :initform nil)
   (x-expand :accessor x-expand :initarg :x-expand :initform (c? (expand? self)))
   (y-expand :accessor y-expand :initarg :y-expand :initform (c? (expand? self)))
   (fill :accessor fill? :initarg :fill :initform nil)
   (x-fill :accessor x-fill :initarg :x-fill :initform (c? (fill? self)))
   (y-fill :accessor y-fill :initarg :y-fill :initform (c? (fill? self)))
   (padding :accessor padding? :initarg :padding :initform 2)
   (x-pad :accessor x-pad :initarg :x-pad :initform (c? (padding? self)))
   (y-pad :accessor y-pad :initarg :y-pad :initform (c? (padding? self)))
   (width :accessor width :initarg :width :initform nil)
   (height :accessor height :initarg :height :initform nil))
  ()
  (focus show hide delete-event destroy-event))

(defmethod focus ((self widget))
  (gtk-widget-grab-focus (id self)))

(def-c-output width ((self widget))
  (when new-value
    (gtk-widget-set-size-request (id self)
				 new-value
				 (or (height self) -1))))

(def-c-output height ((self widget))
  (when new-value
    (gtk-widget-set-size-request (id self)
				 (or (width self) -1)
				 new-value)))

(def-c-output sensitive ((self widget))
  (gtk-widget-set-sensitive (id self) new-value))
  
(def-c-output popup ((self widget))
  (when old-value
    (not-to-be old-value))
  (when new-value
    (gtk-widget-set-popup (id self) (id (to-be new-value)))))
    
(def-c-output visible ((self widget))
  (if new-value 
      (gtk-widget-show (id self))
    (gtk-widget-hide (id self))))

(def-c-output tooltip ((self widget))
  (when new-value
    (gtk-tooltips-set-tip (id (tooltips (upper self gtk-app)))
      (id self) new-value "")))

(defmethod not-to-be :after ((self widget))
  (when *gtk-debug* (trc nil "WIDGET DESTROY" (md-name self)) (force-output))
  (gtk-object-forget (id self) self)
  (gtk-widget-destroy (id self)))

(defun assert-bin (container)
  (assert (null (rest (kids container))) 
	  ()
	  "~a is a bin container, must have only one kid" container))

(def-widget window ()
  ((wintype :accessor wintype :initarg wintype :initform 0)
   (title :accessor title :initarg :title
     :initform (c? (string (class-name (class-of self)))))
   (icon :initarg :icon :accessor icon :initform nil)
   (decorated :accessor decorated :initarg :decorated :initform (c-in t))
   (position :accessor set-position :initarg :position :initform (c-in nil))
   (accel-group :accessor accel-group :initform (gtk-accel-group-new)))
  (default-size resizable
   (maximize) (unmaximize) (iconify) (deiconify) (fullscreen) (unfullscreen))
  ()
;  :md-name :main-window
  :new-args (c? (list (wintype self))))

(def-c-output width ((self window))
  (when new-value
    (gtk-window-set-default-size (id self)
				 new-value
				 (or (height self) -1))))

(def-c-output height ((self window))
  (when new-value
    (gtk-window-set-default-size (id self)
				 (or (width self) -1)
				 new-value)))

(def-c-output accel-group ((self window))
  (when new-value
    (gtk-window-add-accel-group (id self) new-value)))

(def-c-output title ((self window))
  (when new-value
	(gtk-window-set-title (id self) new-value)))

(def-c-output icon ((self window))
  (when new-value
    (gtk-window-set-icon-from-file (id self) new-value +c-null+)))

(def-c-output decorated ((self window))
  (gtk-window-set-decorated (id self) new-value))

(def-c-output position ((self window))
  (when new-value
    (gtk-window-set-position (id self)
      (ecase new-value
	(:none 0)
	(:center 1)
	(:mouse 2)
	(:center-always 3)
	(:center-on-parent 4)))))

(def-c-output .kids ((self window))
  (assert-bin self)
  (dolist (kid new-value)
    (when *gtk-debug* (format t "~% window ~A has kid ~A" self kid))
    (when *gtk-debug* (trc nil "WINDOW ADD KID" (md-name self) (md-name kid)) (force-output))
    (gtk-container-add (id self) (id kid)))
  #+clisp (call-next-method))

(def-widget event-box ()
  ((visible-window :accessor visible-window :initarg :visible-window :initform nil))
  (above-child)
  ()
  :above-child t)

(def-c-output visible-window ((self event-box))
  (gtk-event-box-set-visible-window (id self) new-value))
  
(def-c-output .kids ((self event-box))
  (assert-bin self)
  (when new-value
    (gtk-container-add (id self) (id (first new-value))))
  #+clisp (call-next-method))

(declaim (inline widget-id))
(defun widget-id (widget)
  (id widget))

