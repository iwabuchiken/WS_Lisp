(in-package :test-gtk)

(defmodel listbox-test-item ()
  ((string :accessor string$ :initarg :string :initform nil)
   (icon :accessor icon$ :initarg :icon :initform nil)
   (int :accessor int$ :initarg :int :initform nil)
   (float :accessor float$ :initarg :float :initform nil)
   (double :accessor double$ :initarg :double :initform nil)
   (boolean :accessor boolean$ :initarg :boolean :initform nil)
   (date :accessor date$ :initarg :date :initform nil)))

(defmethod print-object ((item listbox-test-item) stream)
  (with-slots (string icon int float double boolean date) item
    (format stream "~a| ~a| ~a| ~a| ~a| ~a| ~a" string icon int float double boolean date)))

(defmodel test-tree-view (notebook)
  ((items :accessor items :initarg :items 
     :initform (c? (and (md-value (fm-other :hscale))
                     (loop for i from 1 to (md-value (fm-other :hscale)) collect
                           (make-be 'listbox-test-item
                             :string (format nil "Item ~d" i)
                             :icon (nth (random 5) (list "home" "open" "save" "ok" "cancel"))
                             :int i 
                             :float (coerce (* (+ i 1) (/ 1 (1+ (random 100)))) 'single-float) 
                             :double (coerce (* (+ i 2) (/ 1 (1+ (random 1000)))) 'double-float) 
                             :boolean (oddp i)
                             :date (- (get-universal-time) (random 10000000))))))))
  (:default-initargs
      :tab-labels (list "Listbox" "Treebox")
    :kids (list				     
           (mk-vbox 
            :homogeneous nil
            :kids (list
                   (mk-scrolled-window
                    :kids (list
                           (mk-listbox
                            :columns (def-columns
                                         (:string (:title "Selection")))
                            :items (c? (let ((sel (md-value (fm-other :listbox))))
                                         (if (listp sel) sel (list sel))))
                            :print-fn (lambda (item)
                                             (list (format nil "~a" item))))))
                   (mk-frame 
                    :label "Selection mode"
                    :kids (list
                           (mk-hbox
                            :md-name :selection-mode
                            :kids (list
                                   (mk-radio-button :md-name :none :label "None"
                                     :md-value (c-in t))
                                   (mk-radio-button :md-name :single :label "Single")
                                   (mk-radio-button :md-name :browse :label "Browse")
                                   (mk-radio-button :md-name :multiple :label "Multiple")))))
                   
                   (mk-hbox 
                    :kids (list
                           (mk-label :text "Select")
                           (mk-combo-box 
                            :md-name :selection-predicate
                            :init (c? (first (items self)))
                            :items (list
                                    #'null
                                    #'(lambda (itm)
                                        (declare (ignore itm))
                                        t)
                                    #'(lambda (itm) (not (null (boolean$ itm))))
                                    #'(lambda (itm) 
                                        (multiple-value-bind (sec min hour day month year) 
                                            (decode-universal-time (get-universal-time))
                                          (declare (ignore sec min hour day year))
                                          
                                          (multiple-value-bind (itm-sec itm-min itm-hour itm-day itm-month itm-year)
                                              (decode-universal-time (date$ itm))
                                            (declare (ignore itm-sec itm-min itm-hour itm-day itm-year))
                                            (= month itm-month))))
                                    #'(lambda (itm) (oddp (int$ itm)))
                                    #'(lambda (itm) (evenp (int$ itm))))
                            :print-fn (c?
                                            #'(lambda (item)
                                                (case (position item (items self))
                                                  (0 "None")
                                                  (1 "All")
                                                  (2 "True")
                                                  (3 "This month")
                                                  (4 "Odd")
                                                  (5 "Even")))))
                           (mk-label :text "Items in Listbox")
                           (mk-hscale 
                            :md-name :hscale
                            :expand t :fill t
                            :min 0 :max 200
                            :init 5)))
                   (mk-scrolled-window
                    :kids (list
                           (mk-listbox
                            :md-name :listbox
                            :selection-mode (c? (md-value (fm-other :selection-mode)))
                            :columns (def-columns
                                         (:string (:title "String")
                                           #'(lambda (val)
                                               (declare (ignore val))
                                               '(:font "courier")))
                                         (:icon (:title "Icon"))
                                       (:int (:title "Int") #'(lambda (val) 
                                                                (if (oddp val) 
                                                                    '(:foreground "red" :size 14)
                                                                  '(:foreground "blue" :size 6))))
                                       (:float (:title "Float" :expand nil))
                                       (:double (:title "Double") #'(lambda (val)
                                                                      (if (> val 0.5)
                                                                          '(:foreground "cyan" :strikethrough nil)
                                                                        '(:foreground "navy" :strikethrough t))))
                                       (:boolean (:title "Boolean"))
                                       (:date (:title "Date")))
                            :select-if (c? (md-value (fm^ :selection-predicate)))
                            :items (c? (items (upper self test-tree-view)))
                            :print-fn (lambda (item)
                                             (list (string$ item) (icon$ item) (int$ item) (float$ item)
                                               (double$ item) (boolean$ item) (date$ item))))))))
           (mk-vbox 
            :homogeneous nil
            :kids (list
                   (mk-scrolled-window
                    :kids (list
                           (mk-listbox
                            :columns (def-columns
                                         (:string (:title "Selection")))
                            :items (c? (let ((sel (md-value (fm-other :treebox))))
                                         (mapcar #'(lambda (item)
                                                     (list (format nil "~a" (class-name (class-of item)))))
                                           (if (listp sel) sel (list sel))))))))
                   (mk-frame 
                    :label "Selection mode"
                    :kids (list
                           (mk-hbox
                            :md-name :tree-selection-mode
                            :kids (list
                                   (mk-radio-button :md-name :none :label "None"
                                     :md-value (c-in t))
                                   (mk-radio-button :md-name :single :label "Single")
                                   (mk-radio-button :md-name :browse :label "Browse")
                                   (mk-radio-button :md-name :multiple :label "Multiple")))))
                   (mk-hbox 
                    :kids (list
                           (mk-label :text "Select")
                           (mk-combo-box 
                            :md-name :tree-selection-predicate
                            :init (c? (first (items self)))
                            :items (list
                                    #'null
                                    #'(lambda (itm) (subtypep (class-name (class-of itm)) 'vbox))
                                    #'(lambda (itm) (subtypep (class-name (class-of itm)) 'button))
                                    #'(lambda (itm) (subtypep (class-name (class-of itm)) 'notebook)))
                            :print-fn (c?
                                            #'(lambda (item)
                                                (case (position item (items self))
                                                  (0 "None")
                                                  (1 "VBoxes")
                                                  (2 "Buttons")
                                                  (3 "Notebooks")))))))
                   (mk-scrolled-window
                    :kids (list
                           (mk-treebox
                            :md-name :treebox
                            :selection-mode (c? (md-value (fm^ :tree-selection-mode)))
                            :select-if (c? (md-value (fm^ :tree-selection-predicate)))
                            :columns (def-columns				    
                                         (:string (:title "Widget class")
                                           #'(lambda (val)
                                               (declare (ignore val))
                                               '(:font "courier")))
                                         (:icon (:title "Icon"))
                                       (:int (:title "Number of kids") 
                                         #'(lambda (val)
                                             (list :foreground (if (> val 5) "red" "blue"))))
                                       (:string (:title "Gtk address")))
                            :roots (c? (list (upper self gtk-app)))
                            :children-fn #'cells:kids
                            :print-fn #'(lambda (item) 
                                               (list 
                                                (format nil "~a" (class-name (class-of item)))
                                                (case (class-name (class-of item))
                                                  (gtk-app "home")
                                                  (vbox "open")
                                                  (hbox "open")
                                                  (window "index")
                                                  (t "jump-to"))
                                                (length (kids item))
                                                (format nil "~a"
                                                  (when (subtypep (class-name (class-of item)) 'cells-gtk::gtk-object)
                                                    (cells-gtk::id item)))))))))))))