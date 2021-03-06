;; -*- lisp-version: "7.0 [Windows] (Dec 28, 2004 17:34)"; cg: "1.54.2.17"; -*-

(in-package :cg-user)

(defpackage :COMMON-LISP
    (:export #:list
             #:make-instance
             #:t
             #:nil
             #:quote))

(define-project :name :utils-kt
  :modules (list (make-instance 'module :name "defpackage.lisp")
                 (make-instance 'module :name "debug.lisp")
                 (make-instance 'module :name "detritus.lisp")
                 (make-instance 'module :name "flow-control.lisp")
                 (make-instance 'module :name "strings.lisp"))
  :projects nil
  :libraries nil
  :distributed-files nil
  :internally-loaded-files nil
  :project-package-name :common-lisp
  :main-form nil
  :compilation-unit t
  :verbose nil
  :runtime-modules nil
  :splash-file-module (make-instance 'build-module :name "")
  :icon-file-module (make-instance 'build-module :name "")
  :include-flags '(:local-name-info)
  :build-flags '(:allow-debug :purify)
  :autoload-warning t
  :full-recompile-for-runtime-conditionalizations nil
  :default-command-line-arguments "+cx +t \"Initializing\""
  :additional-build-lisp-image-arguments '(:read-init-files nil)
  :old-space-size 256000
  :new-space-size 6144
  :runtime-build-option :standard
  :on-initialization 'default-init-function
  :on-restart 'do-default-restart)

;; End of Project Definition
