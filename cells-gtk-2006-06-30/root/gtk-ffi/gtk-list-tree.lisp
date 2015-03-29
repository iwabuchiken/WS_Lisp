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

(in-package :gtk-ffi)

(def-gtk-lib-functions :gtk
  ;;list-store
  (gtk-list-store-newv :pointer
		       ((n-columns :int)
			(col-types :pointer)))
  (gtk-list-store-set-valist :void
			     ((store :pointer)
			      (iter :pointer)
			      (data :pointer)))
  (gtk-list-store-set-value :void
			    ((store :pointer)
			     (iter :pointer)
			     (column :int)
			     (value :pointer)))
  (gtk-list-store-append :void
			 ((list-store :pointer)
			  (iter :pointer)))
  (gtk-list-store-clear :void
			((list-store :pointer)))
  ;;tre-store
  (gtk-tree-store-newv :pointer
		       ((n-columns :int)
			(col-types :pointer)))
  (gtk-tree-store-set-valist :void
			     ((store :pointer)
			      (iter :pointer)
			      (data :pointer)))
  (gtk-tree-store-set-value :void
			    ((store :pointer)
			     (iter :pointer)
			     (column :int)
			     (value :pointer)))
  (gtk-tree-store-append :void
			 ((list-store :pointer)
			  (iter :pointer)
			  (parent :pointer)))
  (gtk-tree-store-clear :void
			((list-store :pointer)))
  ;;tre-view
  (gtk-tree-view-new :pointer ())
  (gtk-tree-view-set-model :void
			   ((tree-view :pointer)
			    (model :pointer)))
  (gtk-tree-view-insert-column :int
			       ((tree-view
				 :pointer)
				(column :pointer)
				(pos :int)))
  (gtk-tree-view-get-selection :pointer
			       ((tree-view
				 :pointer)))
  (gtk-tree-view-get-path-at-pos :gtk-boolean
				 ((tree-view :pointer)
				  (x :int)
				  (y :int)
				  (path :pointer)
				  (column :pointer)
				  (cell-x :pointer)
				  (cell-y :pointer)))
  (gtk-tree-view-widget-to-tree-coords :void
				       ((tree-view :pointer)
					(wx :int)
					(wy :int)
					(tx :pointer)
					(ty :pointer)))
  (gtk-tree-view-tree-to-widget-coords :void
				       ((tree-view :pointer)
					(wx :int)
					(wy :int)
					(tx :pointer)
					(ty :pointer)))
  (gtk-tree-view-expand-all :void
			    ((tree-view :pointer)))
  ;;tree-iter
  (gtk-tree-iter-free :void ((iter :pointer)))
  (gtk-tree-model-get :void
		      ((tree-model :pointer)
		       (iter :pointer)
		       (column :int)
		       (data :pointer)
		       (eof :int)))
  ;;tree-model
  (gtk-tree-model-get-iter-from-string :gtk-boolean
				       ((tree-model :pointer)
					(iter :pointer)
					(path :gtk-string)))
  ;;tree-path
  (gtk-tree-path-new-from-string :pointer
				 ((path :gtk-string)))
  (gtk-tree-path-to-string :gtk-string
			   ((path :pointer)))
  (gtk-tree-path-free :void ((path :pointer)))
  ;;tree-selection
  (gtk-tree-selection-set-mode :void
			       ((sel :pointer)
				(mode :int)))
  (gtk-tree-selection-get-mode :int
			       ((sel :pointer)))
  (gtk-tree-selection-select-path :void
				  ((sel :pointer)
				   (path :pointer)))
  (gtk-tree-selection-get-selected :gtk-boolean
				   ((sel :pointer)
				    (model :pointer)
				    (iter :pointer)))
  (gtk-tree-selection-selected-foreach :void
				       ((sel :pointer)
					(callback-f :pointer)
					(data :pointer)))
  ;;tre-view-column
  (gtk-tree-view-column-new :pointer ())
  (gtk-tree-view-column-pack-start :void
				   ((tree-column :pointer)
				    (renderer :pointer)
				    (expand :gtk-boolean)))
  (gtk-tree-view-column-add-attribute :void
				      ((tree-column :pointer)
				       (renderer :pointer)
				       (attribute :gtk-string)
				       (column :int)))
  (gtk-tree-view-column-set-spacing :void
				    ((tree-column :pointer)
				     (spacing :int)))
  (gtk-tree-view-column-set-visible :void
				    ((tree-column :pointer)
				     (spacing :gtk-boolean)))
  (gtk-tree-view-column-set-reorderable :void
					((tree-column :pointer)
					 (resizable :gtk-boolean)))
  (gtk-tree-view-column-set-sort-column-id :void
					   ((tree-column :pointer)
					    (col-id :int)))
  (gtk-tree-view-column-set-sort-indicator :void
					   ((tree-column :pointer)
					    (resizable :gtk-boolean)))
  (gtk-tree-view-column-set-resizable :void 
				      ((tree-column :pointer)
				       (resizable :gtk-boolean)))
  (gtk-tree-view-column-set-fixed-width :void
					((tree-column :pointer)
					 (fixed-width :int)))
  (gtk-tree-view-column-set-min-width :void
				      ((tree-column :pointer)
				       (min-width :int)))
  (gtk-tree-view-column-set-max-width :void
				      ((tree-column :pointer)
				       (max-width :int)))
  (gtk-tree-view-column-set-title :void
				  ((tree-column :pointer)
				   (title :gtk-string)))
  (gtk-tree-view-column-set-expand :void
				   ((tree-column :pointer)
				    (expand :gtk-boolean)))
  (gtk-tree-view-column-set-clickable :void
				      ((tree-column
					:pointer)
				       (clickable
					:gtk-boolean)))
  (gtk-tree-view-column-set-cell-data-func :void
					   ((tree-column :pointer)
					    (cell-renderer :pointer)
					    (func :pointer)
					    (data :pointer)
					    (destroy :pointer)))
  ;;cell-renderer
  (gtk-cell-renderer-text-new :pointer ())
  (gtk-cell-renderer-toggle-new :pointer ())
  (gtk-cell-renderer-pixbuf-new :pointer ())
  (gtk-cell-renderer-set-fixed-size :void
				    ((cell
				      :pointer)
				     (width :int)
				     (height
				      :int))))

