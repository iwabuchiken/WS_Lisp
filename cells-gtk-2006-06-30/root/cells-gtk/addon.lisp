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

(def-widget calendar ()
  ((init :accessor init :initarg :init :initform nil)) 
  ()
  (day-selected)
  :on-day-selected (callback (widg signal data)
                     (setf (md-value self) (get-date self))))

(defmethod get-date ((self calendar))
  (uffi:with-foreign-objects ((year :int)(month :int)(day :int))
    (gtk-calendar-get-date (id self) year month day)
    (encode-universal-time 0 0 0 (uffi:deref-pointer day :int)
      (1+ (uffi:deref-pointer month :int)) (uffi:deref-pointer year :int))))

(def-c-output init ((self calendar))
  (when new-value
    (multiple-value-bind (sec min hour day month year) (decode-universal-time new-value)
      
      (declare (ignorable sec min hour))
      (gtk-calendar-select-month (id self) (1- month) year)
      (gtk-calendar-select-day (id self) day))
    (setf (md-value self) new-value)))


(def-widget arrow ()
  ((type :accessor arrow-type :initarg :type :initform nil)
   (type-id :accessor type-id 
	    :initform (c? (case (arrow-type self)
			    (:up 0)
			    (:down 1)
			    (:left 2)
			    (:right 3)
			    (t 3))))
   (shadow :accessor arrow-shadow :initarg :shadow :initform nil)
   (shadow-id :accessor shadow-id
	      :initform (c? (case (arrow-shadow self)
			      (:none 0)
			      (:in 1)
			      (:out 2)
			      (:etched-in 3)
			      (:etched-out 4)
			      (t 2)))))
  ()
  ()
  :new-args (c? (list (type-id self) (shadow-id self))))

(def-c-output type ((self arrow))
  (when new-value
    (gtk-arrow-set (id self) (type-id self) (shadow-id self))))

(def-c-output shadow ((self arrow))
  (when new-value
    (gtk-arrow-set (id self) (type-id self) (shadow-id self))))

