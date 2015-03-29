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

(in-package :cl-user)

(defpackage :cells-gtk
  (:nicknames :cgtk)
  (:use :common-lisp :pod :cells :gtk-ffi)
  (:export #:gtk-user-signals-quit
           #:gtk-continuable-error
           #:gtk-report-error
           #:cgtk-set-active-item-by-path
           #:gtk-combo-box-set-active
           #:show-message
           #:file-chooser
           #:with-markup
           #:push-message
           #:pop-message
           #:pulse
           #:gtk-drawing-set-handlers
           #:*gcontext*
           #:with-pixmap
           #:with-gc
           #:draw-line
           #:draw-text
           #:draw-rectangle
           #:insert-pixmap
           #:register-gobject
           #:gtk-app
           #:gtk-reset
           #:cells-gtk-init
           #:title
           #:icon
           #:tooltips
           #:tooltips-enable
           #:tooltips-delay
           #:start-app
           #:gtk-global-callback-register
           #:gtk-global-callback-funcall
           #:def-populate-adds
           #:populate-adds
           #:with-text-iters
           #:text-buffer-get-text
           #:text-buffer-delete-text
           #:text-buffer-insert-text
           #:text-buffer-modified-p
           #:text-view-scroll-to-position
           #:gtk-text-buffer-get-iter-at-offset
           #:gtk-text-buffer-create-mark
           #:gtk-text-view-set-wrap-mode
           #:gtk-text-view-set-editable
           #:gtk-text-buffer-move-mark
           #:gtk-text-view-scroll-mark-onscreen
           #:mk-listbox
           #:mk-treebox
           #:def-columns
           #:callback
           #:callback-if
           #:timeout-add
           #:focus
           #:widget-id))
