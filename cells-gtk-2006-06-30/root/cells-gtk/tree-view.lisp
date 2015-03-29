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

;;; Todo: separate tree-model/tree-store stuff into another file (used by combo box too).
;;; BTW Tree-store implements the tree-model interface, among other things.

(in-package :cgtk)

(def-object list-store ()
  ((item-types :accessor item-types :initarg :item-types :initform nil)
   (of-tree :accessor of-tree :initform (c-in nil)))
  ()
  ()
  :new-args (c? (list (item-types self))))

(def-object tree-store ()
  ((item-types :accessor item-types :initarg :item-types :initform nil)
   (of-tree :accessor of-tree :initform (c-in nil)))
  ()
  ()
  :new-args (c? (list (item-types self))))

(defun fail (&rest args) (declare (ignore args)) nil)

(def-widget tree-view ()
  ((columns-def :accessor columns-def :initarg :columns :initform nil)
   (column-types :accessor column-types :initform (c? (mapcar #'first (columns-def self))))
   (column-inits :accessor  column-inits :initform (c? (mapcar #'second (columns-def self))))
   (column-render :accessor column-render 
     :initform (c? (loop for col-def in (columns-def self)
                       for pos from 0 append
                         (when (third col-def)
                           (list pos (third col-def))))))
   (columns :accessor columns
     :initform (c? (mapcar #'(lambda (col-init)
                               (apply #'make-be 'tree-view-column
                                      :container self
                                      col-init))
                           (column-inits self))))
   (select-if :unchanged-if #'fail
     :accessor select-if :initarg :select-if :initform (c-in nil))
   (roots :accessor roots :initarg :roots :initform nil)
   (print-fn :accessor print-fn :initarg :print-fn :initform #'identity)
   (children-fn :accessor children-fn :initarg :children-fn :initform #'(lambda (x) (declare (ignore x)) nil))
   (selected-items-cache :cell nil :accessor selected-items-cache :initform nil)
   (selection-mode :accessor selection-mode :initarg :selection-mode :initform :single)
   (expand-all :accessor expand-all :initarg :expand-all :initform nil)
   (on-select :accessor on-select :initarg :on-select :initform nil)
   (tree-model :accessor tree-model :initarg :tree-model :initform nil))
  () ; gtk-slots
  () ; signal-slots
  :on-select (lambda (self widget event data)
               (declare (ignore widget event data))
               (setf (md-value self) (get-selection self))))

(def-c-output tree-model ((self tree-view))
  (when new-value
    (gtk-tree-view-set-model (id self) (id (to-be new-value)))))

(def-c-output expand-all ((self tree-view))
  (when new-value
    (gtk-tree-view-expand-all (id self))))

(defun item-from-path (child-fn roots path)
  (loop for index in path
        for node = (nth index roots) then (nth index (funcall child-fn node))
        finally (return node)))

;;; Used by combo-box also, when it is using a tree model. 
(cffi:defcallback tree-view-items-selector :void
  ((model :pointer) (path :pointer) (iter :pointer) (data :pointer))
  (let ((tree (of-tree (gtk-object-find model))))
    (push (item-from-path (children-fn tree)
            (roots tree)
	    (read-from-string 
	     (gtk-tree-model-get-cell model iter (length (column-types tree)) :string)))
          (selected-items-cache tree)))
  0)

(defmethod get-selection ((self tree-view))
  (let ((selection (gtk-tree-view-get-selection (id self)))
        (cb (cffi:get-callback 'tree-view-items-selector)))
    (setf (selected-items-cache self) nil)
    (gtk-tree-selection-selected-foreach selection cb +c-null+)
    (if (equal (gtk-tree-selection-get-mode selection) 3) ;;multiple
      (copy-list (selected-items-cache self))
    (first (selected-items-cache self)))))

(def-c-output selection-mode ((self tree-view))
  (when new-value
    (let ((sel (gtk-tree-view-get-selection (id self))))
      (gtk-tree-selection-set-mode sel 
	 (ecase (selection-mode self)
	   (:none 0)
	   (:single 1)
	   (:browse 2)
	   (:multiple 3))))))

(cffi:defcallback tree-view-select-handler :void
 ((column-widget :pointer) (event :pointer) (data :pointer))
  (if-bind (tree-view (gtk-object-find column-widget))
       (let ((cb (callback-recover tree-view :on-select)))
         (funcall cb tree-view column-widget event data))
       (trc "Clean up old widgets after runs" column-widget))
  0)

;;; The check that previously was performed here (for a clos object) caused the handler
;;; not to be registered (a problem of execution ordering?). Anyway, do we need such a check?
(def-c-output on-select ((self tree-view))
  (when  new-value    
    (let ((selected-widget (gtk-tree-view-get-selection (id self))))
      (gtk-object-store selected-widget self) ;; tie column widget to clos tree-view
      (callback-register self :on-select new-value)
      (let ((cb (cffi:get-callback 'tree-view-select-handler)))
        ;(trc nil "tree-view on-select pcb:" cb selected-widget "changed")
        (gtk-signal-connect selected-widget "changed" cb)))))

(defmodel listbox (tree-view)
  ((roots :initarg :items)) ; alternate initarg for inherited slot
  (:default-initargs 
      :tree-model (c? (make-instance 'list-store
				:item-types (append (column-types self) (list :string))))))

(defmethod items ((self listbox))
  (roots self))

(defmethod (setf items) (val (self listbox))
  (setf (roots self) val))

(defun mk-listbox (&rest inits)
  (let ((self (apply 'make-instance 'listbox inits)))
    (setf (of-tree (tree-model self)) self)
    self))

(def-c-output select-if ((self listbox))
  (when new-value
    (setf (md-value self) (remove-if-not new-value (roots self)))))

(def-c-output roots ((self listbox))
  (when old-value
    (gtk-list-store-clear (id (tree-model self))))
  (when new-value
    (gtk-list-store-set-items 
     (id (tree-model self)) 
     (append (column-types self) (list :string))
     (loop for item in new-value
	  for index from 0
         collect (let ((i (funcall (print-fn self) item)))
                   ;(ukt:trc nil "items output: old,new" item i)
                   (append i
                     (list (format nil "(~d)" index))))))))

(defmodel treebox (tree-view)
  ()
  (:default-initargs 
      :tree-model (c? (mk-tree-store
		       :item-types (append (column-types self) (list :string))))))

(defun mk-treebox (&rest inits)
  (let ((self (apply 'make-instance 'treebox inits)))
    (setf (of-tree (tree-model self)) self)
    self))

(def-c-output select-if ((self treebox))
  (when new-value
    (setf (md-value self) (mapcan (lambda (item) (fm-collect-if item new-value)) 
                            (roots self)))))

(def-c-output roots ((self treebox))
  (when old-value
    (gtk-tree-store-clear (id (tree-model self))))
  (when new-value
    (loop for root in new-value
       for index from 0 do
	 (gtk-tree-store-set-kids (id (tree-model self)) root +c-null+ index
				  (append (column-types self) (list :string)) 
				  (print-fn self) (children-fn self)))
    (when (expand-all self)
      (gtk-tree-view-expand-all (id self)))))

;;; These look like ("Trimmed Text" "(0 0 )") for example where menu structure is "Text --> Trimmed Text"
;;; Column-types is a list of :string, :float etc. used to reference g-value-set-string etc.
(defun gtk-tree-store-set-kids (model val-tree parent-iter index column-types print-fn children-fn &optional path)
  (with-tree-iter (iter)
    (gtk-tree-store-append model iter parent-iter) ; sets iter
    (gtk-tree-store-set model iter ; Not a gtk function!
      column-types
      (append
       (funcall print-fn val-tree)
       (list (format nil "(~{~d ~})" (reverse (cons index path))))))
    (loop for sub-tree in (funcall children-fn val-tree)
          for pos from 0 do
           (gtk-tree-store-set-kids model sub-tree iter
            pos column-types print-fn children-fn (cons index path)))))

(cffi:defcallback tree-view-render-cell-callback :int
  ((tree-column :pointer) (cell-renderer :pointer) (tree-model :pointer) 
   (iter :pointer) (data :pointer))
  (if-bind (self (gtk-object-find tree-column))
       (let ((cb (callback-recover self :render-cell)))
         (assert cb nil "no :render-cell callback for ~a" self)
         (funcall cb tree-column cell-renderer tree-model iter data))
       (trc nil "Clean up old widgets from prior runs." tree-column))
  1)

(def-c-output columns ((self tree-view))
  (when new-value
    (loop for col in new-value
        for pos from 0	  
        for renderer = (case (nth pos (column-types self))
                         (:boolean (gtk-cell-renderer-toggle-new))
                         (:icon (gtk-cell-renderer-pixbuf-new))
                         (t (gtk-cell-renderer-text-new))) do
          (gtk-tree-view-column-pack-start (id col) renderer t)
          (gtk-tree-view-column-set-cell-data-func (id col) renderer
            (let ((cb (cffi:get-callback 'tree-view-render-cell-callback)))
              ;(trc nil "tree-view columns pcb:" cb (id col) :render-cell)
              (callback-register col :render-cell
                (gtk-tree-view-render-cell pos 
                  (nth pos (column-types self))
                  (getf (column-render self) pos)))
              cb)
            +c-null+ +c-null+)
          (gtk-tree-view-column-set-sort-column-id (id col) pos)
          (gtk-tree-view-insert-column (id self) (id col) pos))))

(def-object tree-view-column ()
  ((title :accessor title :initarg :title :initform nil)
   (visible :accessor visible :initarg :visible :initform t))
  (spacing resizable fixed-width min-width max-width expand clickable
   sort-column-id sort-indicator reorderable)
  ()
  :resizable t
  :expand t
  :reorderable t)

(def-c-output visible ((self tree-view-column))
  (gtk-tree-view-column-set-visible (id self) new-value))

(def-c-output title ((self tree-view-column))
  (when new-value
    (gtk-tree-view-column-set-title (id self) new-value)))

(defmacro def-columns (&rest args)
  `(list ,@(loop for (type inits renderer) in args collect
		 `(list ,type ',inits ,renderer))))

