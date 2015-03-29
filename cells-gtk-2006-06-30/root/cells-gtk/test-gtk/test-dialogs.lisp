(in-package :test-gtk)

(defmodel test-message (button)
  ((message-type :accessor message-type :initarg :message-type :initform nil))
  (:default-initargs      
      :label (c? (string-downcase (symbol-name (message-type self))))
      :on-clicked (callback (widget signal data)
		     (setf (text (fm^ :message-response))
			   (format nil "Dialog response ~a"
				   (show-message (format nil "~a message" (label self)) :message-type (message-type self)))))))

(defmodel test-file-chooser-dialog (button)
  ((action :accessor action :initarg :action :initform nil))
  (:default-initargs
      :stock (c? (action self))
;      :label (c? (string-downcase (symbol-name (action self))))
      :on-clicked (callback (widget signal data)
		     (setf (text (fm^ :file-chooser-response))
			   (format nil "File chooser response ~a"
				   (file-chooser :title (format nil "~a dialog" (action self))
						 :select-multiple (md-value (fm^ :select-multiple-files))
						 :action (action self)))))))

(defmodel test-dialogs (vbox)
  ()
  (:default-initargs
      :kids (list
	     (mk-hbox
	      :kids 
              (append
               #-libcellsgtk nil
               #+libcellsgtk 
               (list 
                (mk-button :label "Query for text"
                           :on-clicked 
                           (callback (w e d) 
                             (let ((dialog
                                     (to-be
                                      (mk-message-dialog
                                       :md-name :rule-name-dialog
                                       :message "Type something:"
                                       :title "My Title"
                                       :message-type :question
                                       :buttons-type :ok-cancel
                                       :content-area (mk-entry :auto-aupdate t)))))
                               (setf (text (fm^ :message-response)) (md-value dialog))))))
               (loop for message-type in '(:info :warning :question :error) collect
                    (make-instance 'test-message :message-type message-type))))
             (mk-label :md-name :message-response)
	     (mk-hbox
	      :kids (cons
		     (mk-check-button :md-name :select-multiple-files
				      :label "Select multiple")
		     (loop for action in '(:open :save :select-folder :create-folder) collect
			   (make-instance 'test-file-chooser-dialog :action action))))
	     (mk-label :md-name :file-chooser-response)
	     (mk-notebook
	      :expand t :fill t
	      :tab-labels (list "Open" "Save" "Select folder" "Create folder")
	      :kids (loop for action in '(:open :save :select-folder :create-folder) collect
			  (mk-vbox
			   :kids (list
				  (mk-file-chooser-widget :md-name action
							  :action action 
							  :expand t :fill t
							  :filters '(("All" "*") ("Text" "*.txt" "*.doc") ("Libraries" "*.so" "*.lib")) 
							  :select-multiple (c? (md-value (fm^ :multiple))))
				  (mk-check-button :label "Select multiple" :md-name :multiple)
				  (mk-label :text (c? (format nil "~a ~a" (md-name (psib (psib)))  (md-value (psib (psib)))))))))))))
