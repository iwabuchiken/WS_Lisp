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

(def-widget box ()
  ()
  (homogeneous spacing)
  ()
  :md-value (c-in nil)
  :homogeneous (c-in nil)
  :spacing (c-in 0))

(def-c-output .kids ((self box))
  (when new-value
    (dolist (kid new-value)
        (gtk-box-pack-start (id self) (id kid) 
                            (expand? kid) (fill? kid) (padding? kid)))
    #+clisp (call-next-method)))

(def-widget hbox (box)
  () () ()
  :new-args (c? (list (homogeneous self) (spacing self))))
(def-widget vbox (box)
  () () ()
  :new-args (c? (list (homogeneous self) (spacing self))))

(def-widget table ()
  ((elements :accessor elements :initarg :elements :initform (c-in nil))
   (homogeneous :accessor homogeneous :initarg :homogeneous :initform nil)
   (rows-count :accessor rows-count :initarg :rows-count :initform (c? (length (elements self))))
   (cols-count :accessor cols-count :initarg :cols-count
               :initform (c? (let ((elems (elements self)))
                               (if elems (apply #'max (mapcar #'length elems)) 0)))))
  ()
  ()
  :new-args (c? (list (rows-count self) (cols-count self) (homogeneous self)))
  :kids (c? (apply #'append (mapcar (lambda (x) (remove-if #'null x)) 
				    (elements self)))))

(defun next-row-item-not-null (row start-col)
  (or 
   (loop for item in (subseq row (1+ start-col))
      for pos from (1+ start-col) do
	(when item (return pos))
	finally (return pos))
   (1+ start-col)))

(def-c-output elements ((self table))
  (loop for row in new-value
        for row-num from 0 do
       (loop for kid in row
	     for col-num from 0 do
	    (when kid
	      (gtk-table-attach (id self) (id kid) 
				col-num (next-row-item-not-null row col-num)
				row-num (1+ row-num)
				(logior (if (x-expand kid) (ash 1 0) 0) (if (x-fill kid) (ash 1 2) 0))
				(logior (if (y-expand kid) (ash 1 0) 0) (if (y-fill kid) (ash 1 2) 0))
				(x-pad kid)
				(y-pad kid))))))

(def-widget hpaned ()
  ((divider-pos :accessor divider-pos :initarg :divider-pos :initform (c-in 0)))
  ()
  ())

(def-c-output divider-pos ((self hpaned))
  (when new-value
    (gtk-paned-set-position (id self) new-value)))

(def-c-output .kids ((self hpaned))
  (when new-value
    (gtk-paned-add1 (id self) (id (make-be 'frame 
						    :shadow 'in
						    :kids (list (first new-value)))))
    (and (cadr new-value)
	 (gtk-paned-add2 (id self) (id (make-be 'frame 
						    :shadow 'in
						    :kids (list (cadr new-value)))))))
  #+clisp (call-next-method))

(def-widget vpaned ()
  ((divider-pos :accessor divider-pos :initarg :divider-pos :initform (c-in 0)))
  ()
  ())

(def-c-output divider-pos ((self vpaned))
  (when new-value
    (gtk-paned-set-position (id self) new-value)))

(def-c-output .kids ((self vpaned))
  (when new-value
    (gtk-paned-add1 (id self) (id (make-be 'frame 
						    :shadow 'in
						    :kids (list (first new-value)))))
    (and (cadr new-value)
	 (gtk-paned-add2 (id self) (id (make-be 'frame 
						    :shadow 'in
						    :kids (list (cadr new-value)))))))
  #+clisp (call-next-method))
  

(def-widget frame ()
  ((shadow :accessor shadow? :initarg :shadow :initform nil)
   (label :accessor label :initarg :label :initform (c-in nil)))
  (label-widget label-align shadow-type)
  ()
  :shadow-type (c-in nil)
  :new-args (c? (list nil)))

(def-c-output label ((self frame))
  (when new-value
    (gtk-frame-set-label (id self) new-value)))

(def-c-output shadow ((self frame))
  (when new-value
    (setf (shadow-type self)
	  (ecase new-value
	    (none 0)
	    (in 1)
	    (out 2)
	    (etched-in 3)
	    (etched-out 4)))))

(def-c-output .kids ((self frame))
  (assert-bin self)
  (dolist (kid new-value)
    (gtk-container-add (id self) (id kid)))
  #+clisp (call-next-method))

(def-widget aspect-frame (frame)
  ((xalign :accessor xalign :initarg :xalign :initform 0.5)
   (yalign :accessor yalign :initarg :yalign :initform 0.5)
   (ratio :accessor ratio? :initarg :ratio :initform 1)
   (obey-child :accessor obey-child :initarg :obey-child :initform nil)) 
  () ()
  :new-args (c? (list 
		 nil
		 (coerce (xalign self) 'single-float)
		 (coerce (yalign self) 'single-float)
		 (coerce (ratio? self) 'single-float)
		 (obey-child self))))

(def-widget hseparator ()
  () () ())

(def-widget vseparator ()
  () () ())

(def-widget expander ()
  ((label :accessor label :initarg :label :initform (c-in nil)))
  (expanded spacing use-underline use-markup label-widget)
  ()
  :new-args (c? (list nil)))

(def-c-output label ((self expander))
  (when new-value
    (gtk-expander-set-label (id self) new-value)))

(def-c-output .kids ((self expander))
  (assert-bin self)
  (dolist (kid new-value)
    (gtk-container-add (id self) (id kid)))
  #+clisp (call-next-method))

(def-widget scrolled-window ()
  ()
  (policy placement shadow-type)
  ()
  :expand t :fill t
  :policy (list 1 1)
  :new-args (list +c-null+ +c-null+))

(def-c-output .kids ((self scrolled-window))
  (assert-bin self)
  (dolist (kid new-value)
    (if (member (class-name (class-of kid)) '(listbox treebox tree-view text-view layout) :test #'equal)
	(gtk-container-add (id self) (id kid))
	(gtk-scrolled-window-add-with-viewport (id self) (id kid))))
  #+clisp (call-next-method))

(def-widget notebook ()
  ((tab-labels :accessor tab-labels :initarg :tab-labels :initform (c-in nil))
   (tab-labels-widgets :accessor tab-labels-widgets :initform (c-in nil))
   (show-page :accessor show-page :initarg :show-page :initform (c-in 0))
   (tab-pos :accessor tab-pos :initarg :tab-pos :initform (c-in nil)))
  (current-page show-tabs show-border scrollable tab-border 
   homogeneous-tabs)
  ()
  :current-page (c-in nil)
  :show-tabs (c-in t))

(def-c-output tab-pos ((self notebook))
  (when new-value
    (gtk-notebook-set-tab-pos 
     (id self) 
     (case new-value
       (:left 0)
       (:right 1)
       (:top 2)
       (:bottom 3)
       (t 2)))))

(defun notebook-contains-page-p (notebook widget &aux (wid (cffi:pointer-address (id widget))))
  (loop for i from 1 to (gtk-notebook-get-n-pages (id notebook))
	for page = (gtk-notebook-get-nth-page (id notebook) (1- i))
	when (= wid (cffi:pointer-address page)) return t))

(def-c-output show-page ((self notebook))
  (when (and new-value (>= new-value 0) (< new-value (length (kids self))))
    (setf (current-page self) new-value)))
    
(def-c-output .kids ((self notebook))
  ;(dolist (widget (tab-labels-widgets self)) ;; This was from the original code. 
  ;      (not-to-be widget))                  ;; It causes errors. 
  (loop for kid in new-value
	for pos from 0
	for label = (nth pos (tab-labels self)) 
	unless (notebook-contains-page-p self kid) do
	(let ((lbl (and label (make-be 'label :text label))))
	  (when lbl (push lbl (tab-labels-widgets self)))
	  (gtk-notebook-append-page (id self) (id kid) (and lbl (id lbl)))))
  (loop for page from 0 to (length new-value) do
	(setf (current-page self) page)) 
  (when (and (show-page self) (>= (show-page self) 0) (< (show-page self) (length new-value)))
    (setf (current-page self) (show-page self)))
  #+clisp (call-next-method))

(def-widget alignment ()
  ((xalign :accessor xalign :initarg :xalign :initform 0.5)
   (yalign :accessor yalign :initarg :yalign :initform 0.5)
   (xscale :accessor xscale :initarg :xscale :initform 0)
   (yscale :accessor yscale :initarg :yscale :initform 0))
  ()
  ()
  :new-args (c? (list (coerce (xalign self) 'single-float)
		      (coerce (yalign self) 'single-float)
		      (coerce (xscale self) 'single-float)
		      (coerce (yscale self) 'single-float))))

(def-c-output xalign ((self alignment))
  (when new-value
    (gtk-alignment-set 
     (id self)
     (coerce (xalign self) 'single-float)
     (coerce (yalign self) 'single-float)
     (coerce (xscale self) 'single-float)
     (coerce (yscale self) 'single-float))))
(def-c-output yalign ((self alignment))
  (when new-value
    (gtk-alignment-set 
     (id self)
     (coerce (xalign self) 'single-float)
     (coerce (yalign self) 'single-float)
     (coerce (xscale self) 'single-float)
     (coerce (yscale self) 'single-float))))
(def-c-output xscale ((self alignment))
  (when new-value
    (gtk-alignment-set 
     (id self)
     (coerce (xalign self) 'single-float)
     (coerce (yalign self) 'single-float)
     (coerce (xscale self) 'single-float)
     (coerce (yscale self) 'single-float))))
(def-c-output yscale ((self alignment))
  (when new-value
    (gtk-alignment-set 
     (id self)
     (coerce (xalign self) 'single-float)
     (coerce (yalign self) 'single-float)
     (coerce (xscale self) 'single-float)
     (coerce (yscale self) 'single-float))))
				

(def-c-output .kids ((self alignment))
  (assert-bin self)
  (dolist (kid new-value)
    (gtk-container-add (id self) (id kid)))
  #+clisp (call-next-method))
