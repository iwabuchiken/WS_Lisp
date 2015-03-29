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

(def-widget button ()
  ((stock :accessor stock :initarg :stock :initform (c-in nil))
   (markup :accessor markup :initarg :markup :initform nil)
   (label :accessor label :initarg :label :initform (c-in nil)))
  (relief use-stock)
  (activate clicked enter leave pressed released)
  :kids (c-in nil))

(def-c-output label ((self button))
  (when new-value
    (gtk-button-set-label (id self) new-value)))

(def-c-output markup ((self button))
  (when new-value    
    (setf (kids self) (list (mk-label :markup new-value)))))

(def-c-output .kids ((self button))
  (assert-bin self)
  (dolist (kid (kids self))
    (gtk-container-add (id self) (id kid)))
  #+clisp (call-next-method))

(def-c-output stock ((self button))
  (when new-value
    (setf (label self) (string-downcase (format nil "gtk-~a" new-value)))
    (trc nil "c-outputting stock" (label self)) (force-output)
    (setf (use-stock self) t)))

(def-widget toggle-button (button)
  ((init :accessor init :initarg :init :initform nil))
  (mode active)
  (toggled)
  :active (c-in nil)
  :on-toggled (callback (widget event data)
                ;;(print (list :toggle-button :on-toggled-cb widget))
                (let ((state (gtk-toggle-button-get-active widget)))
                  ;;(print (list :toggledstate state))
                  (setf (md-value self) state))))

#+test
(DEF-GTK WIDGET TOGGLE-BUTTON (BUTTON) ((INIT :ACCESSOR INIT :INITARG :INIT :INITFORM NIL))
         (MODE ACTIVE) (TOGGLED) :ACTIVE (C-IN NIL) :ON-TOGGLED
         (CALLBACK (WIDGET EVENT DATA)
                   (LET ((STATE (GTK-TOGGLE-BUTTON-GET-ACTIVE WIDGET)))
                     (SETF (MD-VALUE SELF) STATE))))

#+test
(DEF-C-OUTPUT ACTIVE ((SELF TOGGLE-BUTTON))
                     (WHEN (OR NEW-VALUE OLD-VALUE)
                       (CONFIGURE SELF #'GTK-TOGGLE-BUTTON-SET-ACTIVE NEW-VALUE)))

(def-c-output init ((self toggle-button))
  (setf (active self) new-value)
  (setf (md-value self) new-value))

(def-widget check-button (toggle-button)
  () () ())

(def-widget radio-button (check-button)
  () () ()
  :new-tail (c? (and (upper self box)
		     (not (eql (first (kids (fm-parent self))) self))
		     '-from-widget))
			 
  :new-args (c? (and (upper self box)
		     (list
		      (if (eql (first (kids (fm-parent self))) self) 
			  +c-null+
			  (id (first (kids (fm-parent self))))))))
  :on-toggled  (callback (widget event data)
                 ;;(print (list :radio-button widget event data))
                 (let ((state (gtk-toggle-button-get-active widget)))
                   (setf (md-value self) state))))
  
(def-c-output .md-value ((self radio-button))
  (when (and new-value (upper self box))
    (setf (md-value (upper self box)) (md-name self)))
  #+clisp (call-next-method))
