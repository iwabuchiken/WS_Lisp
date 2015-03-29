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

(defmacro with-tree-iters (vars &body body)
  `(let (,@(loop for var in vars collect `(,var (gtk-adds-tree-iter-new))))
     (unwind-protect 
       (progn ,@body)
       ,@(loop for var in vars collect `(gtk-tree-iter-free ,var)))))

;;; ============= Combo-box ============================
;;; User should specify exactly one of :items or :roots 
;;; If specify :roots, specify :children-fn too.
(def-widget combo-box ()
  ((items :accessor items :initarg :items :initform nil)
   (print-fn :accessor print-fn :initarg :print-fn
     :initform #'(lambda (item) (format nil "~a" item))) ; see below if :roots
   (init :accessor init :initarg :init :initform nil)
   (roots :accessor roots :initarg :roots :initform nil)
   (children-fn :accessor children-fn :initarg :children-fn :initform #'(lambda (x) (declare (ignore x)) nil))
   (tree-model :cell nil :accessor tree-model :initform nil))
  (active)
  (changed)
  :new-tail '-text
  :on-changed 
  (callback (widget event data)
    ;(trc nil "combo-box onchanged cb" widget event data (id self))
    (if (items self) 
	;; flat model (:items specified)
	(let ((pos (gtk-combo-box-get-active (id self))))
	  ;;(trc nil "combo-box pos" pos)
	  (setf (md-value self) (and (not (= pos -1))
				     (nth pos (items self)))))
      ;; non-flat tree-model (:roots specified)
      (with-tree-iters (iter)
        (when (gtk-combo-box-get-active-iter (id self) iter)
	  (setf (md-value self)
		(item-from-path
		 (children-fn self)
		 (roots self)
		 (read-from-string
		  (gtk-tree-model-get-cell (id (tree-model self)) iter 1 :string)))))))))

;;; When user specifies :roots, he is using a tree-model.
;;; POD There is probably no reason he has to use :strings for the "columns"
(def-c-output roots ((self combo-box))
  (when old-value
    (gtk-tree-store-clear (id (tree-model self))))
  (when new-value
    (unless (tree-model self)
      (let ((model (mk-tree-store :item-types '(:string :string))))
	(setf (tree-model self) model)
	(setf (of-tree model) self)
	(gtk-combo-box-set-model (id self) (id (to-be model)))))
    (let* ((user-print-fn (print-fn self)) ; because he shouldn't need to know this detail.
	   (pfunc #'(lambda (x) (list (funcall user-print-fn x)))))
      (loop for root in new-value
	    for index from 0 do
	    (gtk-tree-store-set-kids (id (tree-model self)) root +c-null+ index
				     '(:string :string) pfunc (children-fn self)))
      ;; Spec says iter must correspond to a path of depth one. But then there would be no point 
      ;; in set-active-iter.  Well, the spec seems to be wrong (or poorly worded).
      (when-bind (path (init self))
	     (cgtk-set-active-item-by-path self path)))))

(defmethod cgtk-set-active-item-by-path ((self combo-box) path)
  "Sets the value of the tree-model type combo-box to the item at the path. Path is a list of integers."
  (when-bind (tree (tree-model self))
    (with-tree-iters (it)
       (when (gtk-tree-model-get-iter-from-string (id tree) it (format nil "~{~A~^:~}" path))
	 (gtk-combo-box-set-active-iter (id self) it)
	 ;(break "in cgtk setting path = ~A" path)
	 (setf (md-value self) (item-from-path (children-fn self) (roots self) path))))))

(def-c-output items ((self combo-box))
  (when old-value
    (dotimes (i (length old-value))
      (gtk-combo-box-remove-text (id self) 0)))
  (when new-value
    (dolist (item (items self))
      (gtk-combo-box-append-text (id self) (funcall (print-fn self) item)))
    (if-bind (index (position (init self) (items self)))
	 (progn (gtk-combo-box-set-active (id self) index)
		(setf (md-value self) (init self)))
	 (progn (gtk-combo-box-set-active (id self) 0)
		(setf (md-value self) (car (items self)))))))

;;; ============= Toolbar/Toolbutton ============================	
(def-object tooltips ()
  () () ())

(def-widget toolbar ()
  ((orientation :accessor orientation :initarg :orientation :initform (c-in nil))
   (style :accessor style :initarg :style :initform (c-in nil)))
  (show-arrow tooltips)
  ()
  :padding 0)

(def-c-output .kids ((self toolbar))  
  (when new-value
    (loop for item in new-value
	  for pos from 0 do
	  (gtk-toolbar-insert (id self) (id item) pos))))

(def-c-output orientation ((self toolbar))
  (when new-value
    (gtk-toolbar-set-orientation (id self)
	  (case new-value
	    (:horizontal 0)
	    (:vertical 1)
	    (t 0)))))

(def-c-output style ((self toolbar))
  (when new-value
    (gtk-toolbar-set-style (id self)
	  (case new-value
	    (:icons 0)
	    (:text 1)
	    (:both 2)
	    (:both-horiz 3)
	    (t 0)))))

(def-widget tool-item ()
  ()
  (homogeneous expand is-important)
  ())

(def-c-output .kids ((self tool-item))
  (assert-bin self)
  (when new-value
    (dolist (kid new-value)
      (gtk-container-add (id self) (id kid))))
  #+clisp (call-next-method))

(def-widget separator-tool-item (tool-item)
  ()
  (draw)
  ())

(def-widget tool-button (tool-item)
  ((stock :accessor stock :initarg :stock :initform (c-in nil))
   (label :accessor label :initarg :label :initform (c-in nil))
   (icon-widget :accessor icon-widget :initarg :icon-widget :initform (c-in nil))
   (label-widget :accessor label-widget :initarg :label-widget :initform (c-in nil)))
  (use-underline stock-id)
  (clicked)
  :new-args (list +c-null+ +c-null+))

(def-c-output icon-widget ((self tool-button))
  (when old-value
    (not-to-be old-value))
  (when new-value
    (gtk-tool-button-set-icon-widget (id self) (id (to-be new-value)))))

(def-c-output label-widget ((self tool-button))
  (when old-value
    (not-to-be old-value))
  (when new-value
    (gtk-tool-button-set-label-widget (id self) (id (to-be new-value)))))

(def-c-output label ((self tool-button))
  (when new-value
    (gtk-tool-button-set-label (id self) new-value)))

(def-c-output stock ((self tool-button))
  (when new-value
    (setf (stock-id self) (string-downcase (format nil "gtk-~a" new-value)))))

;;; ============= Menu ============================	
(def-widget menu-shell ()
  () () ()
  :padding 0)

(def-c-output .kids ((self menu-shell))  
  (when new-value
    (dolist (kid new-value)
      (gtk-menu-shell-append (id self) (id kid))))
  #+clisp (call-next-method))

(def-widget menu-bar (menu-shell)
  () () ())

(def-widget menu (menu-shell)
  ((owner :initarg :owner :accessor owner :initform (c-in nil)))
  (title)
  ())

(def-widget menu-item ()
  ((label :accessor label :initarg :label :initform (c-in nil))
   (label-widget :accessor label-widget :initarg :label-widget :initform nil)
   (accel-label-widget :accessor accel-label-widget :initform (c? (and (label self)
							   (to-be (mk-accel-label :text (label self))))))
   (accel :accessor accel :initarg :accel :initform (c-in nil))
   (owner :initarg :owner :accessor owner :initform (c-in nil))
   (submenu :cell nil :accessor submenu :initform nil)) ; gtk-menu-item-get-submenu not doing it. POD
  (right-justified)
  (activate))

(defun accel-key-mods (accel)
  (destructuring-bind (key &rest mods-lst) accel
    (let ((mods 0))
      (when mods-lst
	(dolist (mod mods-lst)
	  (setf mods (logior mods
			     (ash 1 (ecase mod
				      (:shift 0)
				      (:control 2)
				      (:alt 3)))))))
      (values (char-int key) mods))))

(def-c-output accel ((self menu-item))
  (when new-value
    (multiple-value-bind (key mods) (accel-key-mods new-value)
      (gtk-widget-add-accelerator (id self) "activate" (accel-group (upper self window)) key mods 1))))

(def-c-output label-widget ((self menu-item))
  (when old-value 
    (not-to-be old-value))
  (when new-value
    (gtk-container-add (id self) (id (to-be new-value)))))
    
(def-c-output accel-label-widget ((self menu-item))
  (when old-value
    (not-to-be old-value))
  (when new-value
    (gtk-accel-label-set-accel-widget (id new-value) (id self))
    (gtk-container-add (id self) (id new-value))))

(def-c-output .kids ((self menu-item))
  (when old-value ; pod never occurs ?
    (gtk-menu-item-remove-submenu (id self)))
  (when new-value
    (gtk-menu-item-set-submenu (id self)
       (id (setf (submenu self) (make-be 'menu :kids new-value))))))

(def-widget check-menu-item (menu-item)
  ((init :accessor init :initarg :init :initform nil))
  (active)
  (toggled)
  :active (c-in nil)
  :on-toggled (callback (widget event data)
                (trc nil "on-toggled" self widget event data)
                (let ((state (gtk-check-menu-item-get-active widget)))
                  (setf (md-value self) state))))

(def-c-output init ((self check-menu-item))
  (setf (active self) new-value)
  (setf (md-value self) new-value))

(def-widget radio-menu-item (check-menu-item)
  () () ()
  :new-tail (c? (let ((in-group-p (upper self menu-item))
		      (not-first-p (not (eql (first (kids (fm-parent self))) self))))
		      (when (and in-group-p  not-first-p)
			'-from-widget)))
			 
  :new-args (c? (let ((in-group-p (upper self menu-item))
		      (not-first-p (not (eql (first (kids (fm-parent self))) self))))		  
		      (if (and in-group-p not-first-p)
			  (list (id (first (kids (fm-parent self)))))			  
			  (list +c-null+)))))
  
(def-c-output .md-value ((self radio-menu-item))
  (when (and new-value (upper self menu-item))
    (setf (md-value (upper self menu-item)) (md-name self)))
  #+clisp (call-next-method))

(def-widget image-menu-item (menu-item)
  ((stock :accessor stock :initarg :stock :initform nil)
   (image :accessor image :initarg :image :initform nil))
  ()
  ()
  :new-tail (c? (when (stock self)
		  '-from-stock))
  :new-args (c? (when (stock self)
		  (list (string-downcase (format nil "gtk-~a" (stock self))) +c-null+))))


(def-c-output image ((self image-menu-item))
  (when old-value
    (not-to-be old-value))
  (when new-value
    (gtk-image-menu-item-set-image (id self) (id (to-be new-value)))))

(def-widget separator-menu-item (menu-item)
  () () ())
(def-widget tearoff-menu-item (menu-item)
  () () ())

