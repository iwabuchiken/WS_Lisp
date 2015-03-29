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


(def-widget message-dialog (window)
  ((message :accessor message :initarg :message :initform nil)
   (message-type :accessor message-type :initarg :message-type :initform :info)
   (buttons-type :accessor buttons-type :initarg :buttons-type :initform (c? (if (eql (message-type self) :question)
										 :yes-no
										 :close)))
   (content-area :accessor content-area :initarg :content-area :initform nil))
  (markup)
  ()
  :position :mouse
  :new-args (c? (list +c-null+
		      2
		      (ecase (message-type self)
			(:info 0)
			(:warning 1)
			(:question 2)
			(:error 3))
		      (ecase (buttons-type self)
			(:none 0)
			(:ok 1)
			(:close 2)
			(:cancel 3)
			(:yes-no 4)
			(:ok-cancel 5))
		      (message self))))

(defmethod md-awaken :after ((self message-dialog))
  (let ((response (gtk-dialog-run (id self))))
    (setf (md-value self)
	  (case response
	    (-5 :ok)
	    (-6 :cancel)
	    (-7 :close)
	    (-8 :yes)
	    (-9 :no))))
  (gtk-widget-destroy (id self))
  (gtk-object-forget (id self) self)
  (with-slots (content-area) self
    (when content-area 
      (setf (md-value self) (md-value content-area))
      (gtk-object-forget (id content-area) content-area))))
	   
(defun show-message (text &rest inits)
  (let ((message-widget (to-be (apply #'mk-message-dialog :message text inits))))
    (md-value message-widget)))

(def-object file-filter ()
  ((mime-types :accessor mime-types :initarg :mime-types :initform nil)
   (patterns :accessor patterns :initarg :patterns :initform nil))
  (name)
  ())

(def-c-output content-area ((self message-dialog))
  (when new-value
    (to-be new-value)
    (let ((vbox (gtk-adds-dialog-vbox (id self))))
        (gtk-box-pack-start vbox (id new-value) nil nil 5))))

(def-c-output mime-types ((self file-filter))
  (dolist (mime-type new-value)
    (gtk-file-filter-add-mime-type (id self) mime-type)))

(def-c-output patterns ((self file-filter))
  (dolist (pattern new-value)
    (gtk-file-filter-add-pattern (id self) pattern)))

(def-object file-chooser ()
  ((action :accessor action :initarg :action :initform nil)
   (action-id :accessor action-id
     :initform (c? (ecase (action self)
                     (:open 0)
                     (:save 1)
                     (:select-folder 2)
                     (:create-folder 3))))
   (filters :accessor filters :initarg :filters :initform nil)
   (filters-ids :accessor filters-ids 
     :initform (c? (loop for filter in (filters self) collect
                         (id (make-be 'file-filter :name (first filter) :patterns (rest filter)))))))
  (local-only select-multiple current-name filename
    current-folder uri current-folder-uri use-preview-label filter)
  (selection-changed)
  :on-selection-changed (callback (widget signal data)
                          (if (select-multiple self)
                              (setf (md-value self) (gtk-file-chooser-get-filenames-strs (id self)))
                            (setf (md-value self) (gtk-file-chooser-get-filename (id self))))))

(def-c-output filters-ids ((self file-chooser))
  (dolist (filter-id new-value)
    (gtk-file-chooser-add-filter (id self) filter-id)))

(def-c-output action ((self file-chooser))
  (when new-value
    (gtk-file-chooser-set-action (id self) (action-id self))))

(def-widget file-chooser-widget (file-chooser vbox)
  ()
  ()
  ()
  :new-args (c? (list (action-id self))))

(def-widget file-chooser-dialog (file-chooser window)
  ()
  ()
  ()
  :on-selection-changed nil
  :position :mouse
  :new-args (c? (list (title self) +c-null+ (action-id self)
		      "gtk-cancel" -6 ;;response-cancel
		      (format nil "gtk-~a"
			      (string-downcase 
			       (symbol-name
				(if (eql (action self) :select-folder) 
				    :open
				    (if (eql (action self) :create-folder)
					:apply
					(action self))))))
		      -5  ;;response-ok
		      +c-null+)))

(defmethod md-awaken :after ((self file-chooser-dialog))
  (let ((response (gtk-dialog-run (id self))))
    (when (eql response -5)
      (if (select-multiple self)
	  (setf (md-value self) (gtk-file-chooser-get-filenames-strs (id self)))
	  (setf (md-value self) (gtk-file-chooser-get-filename (id self)))))
    (gtk-widget-destroy (id self))
    (gtk-object-forget (id self) self)))

(defun file-chooser (&rest inits)
  (let ((dialog (to-be (apply #'mk-file-chooser-dialog inits))))
    (md-value dialog)))

