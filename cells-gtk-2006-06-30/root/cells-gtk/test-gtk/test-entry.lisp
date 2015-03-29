(in-package :test-gtk)

(defmodel test-entry (vbox)
  ()
  (:default-initargs
      :kids (list	     
             (mk-vbox 
              :kids (test-entry-1))
             
             (mk-check-button :md-name :cool 
               :init t
               :label "Cool")
             (mk-frame
              :kids (test-entry-2))
             (mk-hbox
              :kids (list
                     (mk-spin-button :md-name :spin
                       :init 10)))
             (mk-hbox
              :kids (list
                     (mk-label :text "Entry completion test (press i)")
                     (mk-entry
                      :max-length 20
                      :completion (loop for i from 1 to 10 collect
                                        (format nil "Item ~d" i))))))))

(defun test-entry-1 ()
  (c? (list
       (mk-label
        :expand t :fill t
        :markup (c? (with-markup (:font-desc "24") 
                      (with-markup (:foreground :blue 
                                     :font-family "Arial" 
                                     :font-desc (if (md-value (fm-other :spin))
                                                    (truncate (md-value (fm-other :spin)))
                                                  10))
                        (md-value (fm-other :entry)))
                      (with-markup (:underline :double 
                                     :weight :bold 
                                     :foreground :red
                                     :font-desc (if (md-value (fm-other :hscale))
                                                    (truncate (md-value (fm-other :hscale)))
                                                  10))
                        "is")
                      (with-markup (:strikethrough (md-value (fm^ :cool)))
                        "boring")
                      (with-markup (:strikethrough (not (md-value (fm^ :cool))))
                        "cool!")))
        :selectable t)
       (mk-entry :md-name :entry :auto-aupdate t :init "Testing"))))

(defun test-entry-2 ()
  (c? (list
       (mk-vbox
        :kids (c? (list
                   (mk-hbox 
                    :kids (list
                           (mk-check-button :md-name :sensitive 
                             :label "Sensitive")
                           (mk-check-button :md-name :visible
                             :init t
                             :label "Visible")))
                   (mk-hscale :md-name :hscale 
                     :visible (c? (md-value (fm^ :visible)))
                     :sensitive (c? (md-value (fm^ :sensitive)))
                     :expand t :fill t
                     :min 0 :max 100
                     :init 10)))))))