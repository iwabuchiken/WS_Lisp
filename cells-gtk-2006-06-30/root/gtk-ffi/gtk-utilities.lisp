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

;;; Function with equivalents in gtklib.

(in-package :gtk-ffi)

(defun gtk-signal-connect (widget signal fun &key (after t) data destroy-data)
  #+shhtk (print (list "passing fun to gtk-signal-connect" signal fun))
  (g-signal-connect-data widget signal fun data destroy-data after))

(defun g-signal-connect-data (self detailed-signal c-handler data destroy-data after)
  (uffi:with-cstrings ((c-detailed-signal detailed-signal))
    (let ((p4 (or data +c-null+)))
      (g_signal_connect_data
       self
       c-detailed-signal
       (wrap-func c-handler)
       p4
       (or destroy-data +c-null+)
       (if after 1 0)))))

(cffi:defcfun ("g_signal_connect_data" g_signal_connect_data)
              :unsigned-long
  (instance :pointer) (detailed-signal :pointer) (c-handler :pointer) 
  (data :pointer) (destroy-data :pointer) (after :int))

(defun wrap-func (func-address) ;; vestigial. func would never be nil. i think.
  (or func-address 0))


(defun gtk-signal-connect-swap (widget signal fun &key (after t) data (destroy-data +c-null+)) ; pod 0216
  (g-signal-connect-closure widget signal
    (g-cclosure-new-swap (wrap-func fun) data destroy-data) after))

(defun gtk-object-set-property (obj property val-type val)
  (with-g-value (value)
      (g-value-init value (value-type-as-int val-type))
      (funcall (value-set-function val-type)
        value val)

      (g-object-set-property obj property value)

      (g-value-unset value)))

(defun get-gtk-string (pointer)
  (typecase pointer
    (string pointer)
    (otherwise
     (pod:trc nil "get-gtk-string sees" pointer (type-of pointer))
     #+allegro (uffi:convert-from-cstring pointer)
     #+lispworks (uffi:convert-from-foreign-string pointer
                   :null-terminated-p t)
     #-(or allegro lispworks)
     (uffi:with-foreign-object (bytes-written :int)
       (g-locale-from-utf8 pointer -1 +c-null+ bytes-written +c-null+)))))

(defun to-gtk-string (str)
  "!!!! remember to free returned str pointer"
  (uffi:with-foreign-object (bytes-written :int)
    (g-locale-to-utf8 str -1 +c-null+ bytes-written +c-null+)))

(defmacro with-gdk-threads (&rest body)
  `(unwind-protect
	(progn
	  (gdk-threads-enter)
	  ,@body)
     (gdk-threads-leave)))

(cffi:defcallback button-press-event-handler :int
                  ((widget :pointer) (signal :pointer) (data :pointer))
  (let ((event (gdk-event-button-type signal)))
    (when (or (eql (event-type event) :button_press)
              (eql (event-type event) :button_release))
      (when (= (gdk-event-button-button signal) 3)
        (gtk-menu-popup widget +c-null+ +c-null+ +c-null+ +c-null+ 3
			(gdk-event-button-time signal)))))
  0)

(defun gtk-widget-set-popup (widget menu)
  (gtk-signal-connect-swap widget "button-press-event"
                           (cffi:get-callback 'button-press-event-handler)
                           :data menu)
  (gtk-signal-connect-swap widget "button-release-event"
                           (cffi:get-callback 'button-press-event-handler)
                           :data menu))

(defun gtk-list-store-new (col-types)
  (let ((c-types (cffi:foreign-alloc :int :count (length col-types))))
    (loop for type in col-types
          for n upfrom 0
          do (setf (cffi:mem-aref c-types :int n) (coerce (as-gtk-type type) 'integer)))
    (prog1
        (gtk-list-store-newv (length col-types) c-types)
      (cffi:foreign-free c-types))))


(defun gvi (&optional (key :anon))
  key)

(defun gtk-list-store-set (lstore iter types-lst data-lst)
  (with-g-value (value)
    (gvi :with-type-val)
    (loop for col from 0
        for data in data-lst
        for type in types-lst       
        for str-ptr = nil #+not (when (or (eql type :string) (eql type :icon))
                                  (gvi :pre-cstring)
                                  (convert-to-cstring data))
        do   
          (gvi :pre-truvi)
          (g-value-init value (as-gtk-type type))
          (funcall (intern (format nil "G-VALUE-SET-~a" (case type 
                                                          (:date 'float)
                                                          (:icon 'string)
                                                          (t type))) 
                     :gtk-ffi)
            value
            (or str-ptr (and (eql type :date) (coerce data 'single-float)) data))
          (gtk-list-store-set-value lstore iter col value)
          (g-value-unset value)
          (when str-ptr (uffi:free-cstring str-ptr)))))

(defun gtk-list-store-set-items (store types-lst data-lst)
  (with-tree-iter (iter)
    (dolist (item data-lst)
      (gvi :pre-append)
      (gtk-list-store-append store iter)
      (gvi :pre-set)
      (gtk-list-store-set store iter types-lst item)
      (gvi :post-set))))

(defun gtk-tree-store-new (col-types)
  (let ((gtk-types (cffi:foreign-alloc :int :count (length col-types))))
    (loop for type in col-types
          for tn upfrom 0
          do (setf (cffi:mem-aref gtk-types :int tn) (coerce (as-gtk-type type) 'integer)))
    (gtk-tree-store-newv (length col-types) gtk-types)))

(defun gtk-tree-store-set (tstore iter types-lst data-lst)
  "Sets the value of one or more cells in a row referenced by iter."
  (with-g-value (value)
    (loop for col from 0
        for data in data-lst
        for type in types-lst
        do ;; (print (list :tree-store-set value type (as-gtk-type type)))
          (g-value-init value (as-gtk-type type))
          (funcall (case type
		     ((:string :icon) #'g-value-set-string)
		     (:int #'g-value-set-int)
		     (:long #'g-value-set-long)
		     (:boolean #'g-value-set-boolean)
		     ((:float :date) #'g-value-set-float)
		     (t (error "Invalid type: ~S?" type)))
            value
            (if (eql type :date) (coerce data 'single-float) data))
          (gtk-tree-store-set-value tstore iter col value)
          (g-value-unset value))))

;;; todo: The deref-pointer-runtime-typed used by case needs work if
;;; it is going to be used for lispworks, cmu and allegro.
;;; (needs someone who knows how ffi-to-uffi-type maps types for those lisps.)
;;; Even better, eliminate it. It is ill-conceived.
(defun gtk-tree-model-get-cell (model iter column-no cell-type)
  "Returns the item at column-no if column-no [0,<num-columns-1>] or a
   a string like '(0 1 0)', which navigates to the selected item, if 
   column-no = num-columns. (See gtk-tree-store-set-kids)."
  (uffi:with-foreign-object (item :pointer-void)
    (gtk-tree-model-get model iter column-no item -1)
  (case cell-type
    (:string (uffi:convert-from-cstring (uffi:deref-pointer item :cstring)))
    (t (cast item (as-gtk-type-name cell-type))))))

(defun parse-cell-attrib (attribs)
  (loop for (attrib val) on attribs by #'cddr collect
	(ecase attrib
	  (:foreground (list "foreground" 'c-string val))
	  (:background (list "background" 'c-string val))
	  (:font (list "font" 'c-string val))
	  (:size (list "size-points" 'double-float (coerce val 'double-float)))
	  (:strikethrough (list "strikethrough" 'boolean val)))))

(progn
  (defun alloc-col-type-buffer (col-type)
    (ecase col-type
      ((:string :icon) (uffi:allocate-foreign-object '(:array :cstring) 1))
      (:boolean (uffi:allocate-foreign-object '(:array :unsigned-byte) 1)) ;;guess
      (:date (uffi:allocate-foreign-object '(:array :float) 1))
      (:int (uffi:allocate-foreign-object '(:array :int) 1))
      (:long (uffi:allocate-foreign-object '(:array :long) 1))
      (:float (uffi:allocate-foreign-object '(:array :float) 1))
      (:double (uffi:allocate-foreign-object '(:array :double) 1))))
  
  (defun deref-col-type-buffer (col-type buffer)
    (ecase col-type
      ((:string :icon)
       (get-gtk-string
        (cffi:make-pointer (cffi:mem-aref buffer :pointer 0))))
      (:boolean (not (zerop (cffi:mem-aref buffer :unsigned-char 0))))
      (:date (cffi:mem-aref buffer :FLOAT 0))
      (:int (cffi:mem-aref buffer :int 0))
      (:long (cffi:mem-aref buffer :long 0))
      (:float (cffi:mem-aref buffer :float 0))
      (:double (cffi:mem-aref buffer :double 0)))))

(defun gtk-tree-view-render-cell (col col-type cell-attrib-f) 
  (pod:trc nil "gtv-render-cell> creating callback" col col-type cell-attrib-f)
  (lambda (tree-column cell-renderer model iter data)
    (DECLARE (ignorable tree-column data))
    (pod:trc nil "gtv-render-cell (callback)> entry"
      tree-column cell-renderer model iter data)
    (let ((return-buffer (cffi:foreign-alloc :int :count 16)))
      (gtk-tree-model-get model iter col
        return-buffer -1)
      (let* ((returned-value (deref-pointer-runtime-typed return-buffer
                               (ffi-to-uffi-type
                                (col-type-to-ffi-type col-type))))
             (ret$ (when (find col-type '(:string :icon))
		     returned-value))
             (item-value (cond 
                          (ret$ (uffi:convert-from-cstring ret$))
                          ((eq col-type :boolean)
                           (not (zerop returned-value)))
                          (t returned-value))))
        (pod:trc nil "gtv-render-cell (callback)>> rendering value"
          col col-type ret$ item-value)

        (apply #'gtk-object-set-property cell-renderer 
          (case col-type 
            (:boolean (list "active" 'boolean item-value))
            (:icon (list "stock-id" 'c-string
                     (string-downcase (format nil "gtk-~a" item-value))))
            (t (list "text" 'c-string
                 (case col-type
                   (:date (multiple-value-bind (sec min hour day month year) 
                              (decode-universal-time (truncate item-value))
                            (format nil "~2,'0D/~2,'0D/~D ~2,'0D:~2,'0D:~2,'0D" 
                              day month year hour min sec)))
                   (:string (get-gtk-string item-value))
                   (otherwise (format nil "~a" item-value)))))))

        (when cell-attrib-f 
          (loop for property in (parse-cell-attrib (funcall cell-attrib-f item-value))
              do (apply #'gtk-object-set-property cell-renderer property)))
        (when ret$ (cffi:foreign-free ret$))
        (cffi:foreign-free return-buffer)))
    1))

(defun gtk-file-chooser-get-filenames-strs (file-chooser)
  (let ((glist (gtk-file-chooser-get-filenames file-chooser)))
    (loop for lst-address = glist then (cffi:foreign-slot-value lst-address 'gslist 'next)
        while (and lst-address (not (cffi:null-pointer-p lst-address)))
        collect (cffi:foreign-slot-value lst-address 'gslist 'data)
        finally (g-slist-free glist))))


