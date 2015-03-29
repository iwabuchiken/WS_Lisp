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

(defmodel gtk-app (window)
  ((splash-screen-image :accessor splash-screen-image :initarg :splash-screen-image :initform nil)
   (tooltips :initarg :tooltips :accessor tooltips :initform (make-be 'tooltips))
   (tooltips-enable :accessor tooltips-enable :initarg :tooltips-enable :initform (c-in t))
   (tooltips-delay :accessor tooltips-delay :initarg :tooltips-delay :initform (c-in nil))
   (stock-icons :cell nil :accessor stock-icons :initarg :stock-icons :initform nil))
  (:default-initargs
   :on-delete-event (lambda (self widget event data)
		      (declare (ignore self widget event data))
		      (signal 'gtk-user-signals-quit)
		      0)))


(defmethod initialize-instance :after ((self gtk-app) &key stock-icons)
  (loop for (name pathname) in stock-icons do
       (let* ((image (gtk-image-new-from-file pathname))
              (pixbuf (gtk-image-get-pixbuf image))
              (icon-set (gtk-icon-set-new-from-pixbuf pixbuf))
              (factory (gtk-icon-factory-new)))
         (gtk-icon-factory-add factory (format nil "gtk-~A" (string-downcase (string name))) icon-set)
         (gtk-icon-factory-add-default factory))))
 
(def-c-output tooltips-enable ((self gtk-app))
  (when (tooltips self)
    (if new-value
        (gtk-tooltips-enable (id (tooltips self)))
      (gtk-tooltips-disable (id (tooltips self))))))

(def-c-output tooltips-delay ((self gtk-app))
  (when new-value
      (gtk-tooltips-set-delay (id (tooltips self)) new-value)))
      
(defmodel splash-screen (window)
  ((image-path :accessor image-path :initarg :image-path :initform nil))
  (:default-initargs
      :decorated nil
      :position :center
      :kids (c? (when (image-path self)
		  (list
		   (mk-image :filename (image-path self)))))))

(defvar *gtk-initialized* nil)


(defun start-app (app-name &key debug)
  (let ((*gtk-debug* debug))
    (when (not *gtk-initialized*)
      (when *gtk-debug*
        (trc nil "GTK INITIALIZATION") (force-output))
      (g-thread-init +c-null+)
      (gdk-threads-init)
      (assert (gtk-init-check +c-null+ +c-null+))
      (setf *gtk-initialized* t))
    
    (with-gdk-threads
        (let ((app (make-instance app-name :visible (c-in nil)))
              (splash))
          (when (splash-screen-image app)
            (setf splash (make-instance 'splash-screen :image-path (splash-screen-image app)
                           :visible (c-in nil)))
            (gtk-window-set-auto-startup-notification nil)
            (to-be splash)
            (setf (visible splash) t)
            (loop while (gtk-events-pending) do
                 (gtk-main-iteration)))

          (to-be app)

          (when splash
            (not-to-be splash)
            (gtk-window-set-auto-startup-notification t))
          (setf (visible app) t)
          (when *gtk-debug* (trc nil "STARTING GTK-MAIN") (force-output))
	  (unwind-protect
	     (loop 
	      (restart-case
	       (handler-bind 
		((gtk-user-signals-quit #'give-up-cleanly)
		 (gtk-continuable-error #'continue-from-error)
		 (error #'report-error-and-give-up))
		#-lispworks
		(gtk-main)
		#+lispworks ; give slime a chance.
		(loop ; just running your app in a process is not enough.
		 (loop while (gtk-events-pending) do 
		       (gtk-main-iteration-do nil))
		 (process-wait-with-timeout .01 "GTK event loop waiting")))
	       ;; Restart cases
	       (continue-from-error (c)
		  (show-message (format nil "Cells-GTK Error: ~a" (text c))
				:message-type :error :title "Cells-GTK Error"))
	       (give-up-cleanly () (return-from start-app))
	       (report-error-and-give-up (c) (error c))))
	    ;; clean-up forms (takes down application).
	    (not-to-be app) ; while (> (gtk-main-level) 0) do (gtk-main-quit) NG. Why?
	    (loop for i from 0 to 30 do (gtk-main-quit))
	    (loop while (gtk-events-pending) do (gtk-main-iteration-do nil)))))))

;;; Restarts
(defun continue-from-error (c)
  (invoke-restart 'continue-from-error c))

(defun report-error-and-give-up (c)
  (invoke-restart 'report-error-and-give-up c))

(defun give-up-cleanly (c)
  (declare (ignore c))
  (invoke-restart 'give-up-cleanly))

(defvar *gtk-global-callbacks* nil)
(defvar *gtk-loaded* #+clisp t #-clisp nil) ;; kt: looks like CLisp does this on its own

(defun gtk-reset ()
  (cell-reset)
  (gtk-objects-init)
  (setf *gtk-global-callbacks*
    (make-array 128 :adjustable t :fill-pointer 0)))

(defun gtk-global-callback-register (callback)
  (vector-push-extend callback *gtk-global-callbacks* 16))

(defun gtk-global-callback-funcall (n)
  (trc nil "gtk-global-callback-funcall >" n
    *gtk-global-callbacks*
    (when n (aref *gtk-global-callbacks* n)))
  (funcall (aref *gtk-global-callbacks* n)))

(defun cells-gtk-init ()
  #-cmu
  (unless *gtk-loaded*
    (gtk-ffi:load-gtk-libs)
    (setf *gtk-loaded* t))
  (gtk-reset))


