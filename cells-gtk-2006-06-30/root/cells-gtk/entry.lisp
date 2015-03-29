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

(def-object entry-completion ()
  ()
  (model)
  ())

#+no
(def-gtk widget entry nil
         ((auto-update :accessor auto-update :initarg :auto-aupdate :initform nil)
          (completion :accessor completion :initarg :completion :initform nil)
          (text :accessor text :initarg :text :initform (c-in nil))
          (init :accessor init :initarg :init :initform nil))
         (editable has-frame max-length) (changed activate))

(def-widget entry ()
  ((auto-update :accessor auto-update :initarg :auto-aupdate :initform nil)
   (completion :accessor completion :initarg :completion :initform nil)
   (text :accessor text :initarg :text :initform (c-in nil))
   (init :accessor init :initarg :init :initform nil))
  (editable has-frame max-length)
  (changed activate)
  :on-changed (callback-if (auto-update self)
                  (widget event data)
                (let ((txt (get-gtk-string (gtk-entry-get-text widget))))
                  (trc  nil "ENTRY (ON-CHANGED)" txt) (force-output)
                  (setf (md-value self) txt)))
  :on-activate (callback-if (not (auto-update self))
                   (widget event data)
                 (let ((txt (get-gtk-string (gtk-entry-get-text widget))))
                   (trc  nil "ENTRY (ON-ACTIVATE)" txt) (force-output)
                   (setf (md-value self) (if (equal txt "") nil txt)))))

(def-c-output text ((self entry))
  (when new-value
    (gtk-entry-set-text (id self) new-value)))

(def-c-output init ((self entry))
  (when (stringp new-value) ;; could be null or numeric for spin button
    (setf (text self) new-value)
    (setf (md-value self) new-value)))

(def-c-output completion ((self entry))
  (when new-value
    (gvi :pre-mk-store)
    (let ((store (make-be 'list-store :item-types (list :string))))
      (gvi :post-mk-store)
      (gtk-list-store-set-items (id store) (list :string) (mapcar #'list new-value))
      (gvi :post-set-items)
      (let ((completion (make-be 'entry-completion :model (id store))))
        (gtk-entry-completion-set-text-column (id completion) 0)
        (gtk-entry-set-completion (id self) (id completion))))))

;; (def-widget adjustment ()
;;   () () ())

(def-widget range ()
  ((value-type :accessor value-type :initarg :value-type :initform 'integer)
   (min :accessor minimum :initarg :min :initform 0)
   (max :accessor maximum :initarg :max :initform 100)
   (step :accessor stepping :initarg :step :initform 1)
   (page-increment :accessor page-increment :initarg :page-increment :initform 10)
   (page-size :accessor page-size :initarg :page-size :initform 0)
   (init :accessor init :initarg :init :initform nil))

  (range value inverted increments update-policy)
  (value-changed)
  :on-value-changed (callback (widget event data)
		      (let ((val (gtk-range-get-value widget)))
			  (trc nil "RANGE (ON-VALUE-CHANGED)" val) (force-output)
			    (setf (md-value self) 
				  (if (eql (value-type self) 'integer)
				      (truncate val)
				      (coerce val (value-type self)))))))

(def-c-output init ((self range))
  (when new-value
    (setf (value self) (coerce new-value 'double-float))
    (setf (md-value self) (coerce new-value (value-type self)))))

(def-widget scale (range)
  ()
  (draw-value value-pos digits)
  ()
  :expand t
  :fill t)  

(def-widget hscale (scale)
  () () ()
  :new-tail '-with-range
  :new-args (c? (list (coerce (minimum self) 'double-float)
		      (coerce (maximum self) 'double-float)
		      (coerce (stepping self) 'double-float))))

(def-widget vscale (scale)
  () () ()
  :new-tail '-with-range
  :new-args (c? (list (coerce (minimum self) 'double-float)
		      (coerce (maximum self) 'double-float)
		      (coerce (stepping self) 'double-float))))


(def-widget spin-button (entry)
  ((value-type :accessor value-type :initarg :value-type :initform 'integer)
   (min :accessor minimum :initarg :min :initform 0)
   (max :accessor maximum :initarg :max :initform 100)
   (step :accessor stepping :initarg :step :initform 1))
  (value wrap)
  (value-changed)
  :new-tail '-with-range
  :new-args (c? (list (coerce (minimum self) 'double-float)
		      (coerce (maximum self) 'double-float)
		      (coerce (stepping self) 'double-float)))
  :on-changed nil
  :on-activate nil
  :on-value-changed (callback (widget event data)
			(let ((val (gtk-spin-button-get-value widget)))
			  (trc nil "SPIN-BUTTON (ON-VALUE-CHANGED)" val) (force-output)
			  (setf (md-value self) 
				(if (eql (value-type self) 'integer)
				    (truncate val)
				    (coerce val (value-type self)))))))

(def-c-output init ((self spin-button))
  (when new-value
    (setf (value self) (coerce new-value 'double-float))
    (setf (md-value self) (coerce new-value (value-type self)))))
