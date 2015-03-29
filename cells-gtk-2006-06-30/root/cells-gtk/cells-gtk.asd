

(asdf:defsystem :cells-gtk
  :name "cells-gtk"
  :depends-on (:cells :pod-utils :gtk-ffi)
  :serial t
  :components
  ((:file "packages")   
   (:file "conditions")
   (:file "compat")
   (:file "widgets" :depends-on ("conditions"))
   (:file "layout" :depends-on ("widgets"))
   (:file "display" :depends-on ("widgets"))
;   (:file "drawing" :depends-on ("widgets"))
   (:file "buttons" :depends-on ("widgets"))
   (:file "entry" :depends-on ("widgets"))
   (:file "tree-view" :depends-on ("widgets"))
   (:file "menus" :depends-on ("widgets"))
   (:file "dialogs" :depends-on ("widgets"))
   (:file "textview" :depends-on ("widgets"))
   (:file "addon" :depends-on ("widgets"))
   (:file "gtk-app")
   ))
