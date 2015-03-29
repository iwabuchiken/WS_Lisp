(in-package :test-gtk)

(defmodel test-layout (notebook)
  ()
  (:default-initargs
      :expand t :fill t
      :scrollable t				     
      :tab-labels (list "_Table" "_Panes" "_Alignment")
      :tab-pos (c? (md-value (fm-other :tab-pos)))
      :kids (list
	     (mk-table
	      :elements (cons
			 (list (mk-entry :sensitive nil :init "Row 0, Col 0-1" :x-expand t :x-fill t) nil
			       (mk-entry :sensitive nil :init "Row 0, Col 2-3" :x-expand t :x-fill t) nil)
			 (loop for row from 1 to 8 collect
			      (loop for col from 0 below 4 collect
				   (mk-entry
				    :sensitive nil
				    :x-expand (oddp col) :x-fill (oddp col)
				    :x-pad 4 :y-pad 8
				    :width 80
				    :init (format nil "Row ~d, Col ~d" row col))))))
	     (mk-hpaned 
	      :kids (list
		     (mk-expander :label "Expand"
				  :width 150
				  :kids (list
					 (mk-image :stock :home :icon-size :dialog)))
		     (mk-vpaned 
		      :kids (list
			     (mk-frame
			      :label "Notebook tab pos"
			      :kids (list
				     (mk-vbox
				      :md-name :tab-pos
				      :kids (list
					     (mk-radio-button :md-name :left :label "Left")
					     (mk-radio-button :md-name :top :label "Top" :init t)
					     (mk-radio-button :md-name :right :label "Right")
					     (mk-radio-button :md-name :bottom :label "Bottom")))))
			     (mk-label :text "VPane 2")))))
	     (mk-vbox
	      :kids (list
		     (mk-hscale :md-name :xalign
				:expand nil :fill nil
				:value-type 'single-float
				:min 0 :max 1
				:step 0.01
				:init 0.5)
		     (mk-hbox
		      :expand t :fill t
		      :kids (list
			     (mk-alignment
			      :expand t :fill t
			      :xalign (c? (or (md-value (fm^ :xalign)) 0))
			      :yalign (c? (or (md-value (fm^ :yalign)) 0))
			      :kids (list
				     (mk-label :text "Alignment test")))
			     (mk-vscale :md-name :yalign
					:expand nil :fill nil
					:value-type 'single-float
					:min 0 :max 1
					:step 0.01
					:init 0.5))))))))