(in-package :test-gtk)

(defmodel test-buttons (vbox)
  ((nclics :accessor nclics :initform (c-in 0)))
  (:default-initargs
      :kids (list
	     (mk-label :text (c? (format nil "Toggled button active = ~a" 
					 (md-value (fm-other :toggled-button)))))
	     (mk-hseparator)
	     (mk-label :text (c? (format nil "Check button checked = ~a" 
					 (md-value (fm-other :check-button)))))
	     (mk-hseparator)
	     (mk-label :text (c? (format nil "Radio button selected = ~a" 
					 (md-value (fm-other :radio-group)))))
	     (mk-hseparator)
	     (mk-label :text (c? (format nil "Button clicked ~a times" 
					 (nclics (upper self test-buttons))))
		       :selectable t)
	     (mk-hseparator)
	     
	     (mk-hbox
	      :kids (list
		     (mk-button :stock :apply
				:tooltip "Click ....."
				:on-clicked (callback (widget event data)
						      (incf (nclics (upper self test-buttons)))))
		     (mk-button :label "Continuable error"
				:on-clicked (callback (widget event data)
						      (error 'gtk-continuable-error :text "Oops!")))
		     (mk-toggle-button :md-name :toggled-button
				       :markup (c? (with-markup (:foreground (if (md-value self) :red :blue))
						     "_Toggled Button")))
		     (mk-check-button :md-name :check-button				      
				      :markup (with-markup (:foreground :green)
						"_Check Button"))))
	     (mk-hbox
	      :md-name :radio-group
	      :kids (list
		     (mk-radio-button :md-name :radio-1
				      :label "Radio 1")
		     (mk-radio-button :md-name :radio-2
				      :label "Radio 2" :init t)
		     (mk-radio-button :md-name :radio-3
				      :label "Radio 3"))))))
