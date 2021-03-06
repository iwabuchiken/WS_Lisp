;; -*- lisp-version: "7.0 [Windows] (Dec 28, 2004 17:34)"; cg: "1.54.2.17"; -*-

(in-package :cg-user)

(defpackage :CELLS)

(define-project :name :cells
  :modules (list (make-instance 'module :name "defpackage.lisp")
                 (make-instance 'module :name "cells.lisp")
                 (make-instance 'module :name "cell-types.lisp")
                 (make-instance 'module :name "integrity.lisp")
                 (make-instance 'module :name "constructors.lisp")
                 (make-instance 'module :name "initialize.lisp")
                 (make-instance 'module :name "md-slot-value.lisp")
                 (make-instance 'module :name "slot-utilities.lisp")
                 (make-instance 'module :name "optimization.lisp")
                 (make-instance 'module :name "link.lisp")
                 (make-instance 'module :name "propagate.lisp")
                 (make-instance 'module :name "synapse.lisp")
                 (make-instance 'module :name "synapse-types.lisp")
                 (make-instance 'module :name "model-object.lisp")
                 (make-instance 'module :name "defmodel.lisp")
                 (make-instance 'module :name "md-utilities.lisp")
                 (make-instance 'module :name "family.lisp")
                 (make-instance 'module :name "fm-utilities.lisp")
                 (make-instance 'module :name "family-values.lisp")
                 (make-instance 'module :name "test.lisp"))
  :projects (list (make-instance 'project-module :name
                                 "../utils-kt/utils-kt"))
  :libraries nil
  :distributed-files nil
  :internally-loaded-files nil
  :project-package-name :cells
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
  :on-initialization 'cells::cv-test
  :on-restart 'do-default-restart)

;; End of Project Definition
