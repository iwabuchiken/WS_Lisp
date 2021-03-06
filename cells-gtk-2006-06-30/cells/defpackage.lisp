;; -*- mode: Lisp; Syntax: Common-Lisp; Package: cells; -*-
;;;
;;; Copyright (c) 1995,2003 by Kenneth William Tilton.
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy 
;;; of this software and associated documentation files (the "Software"), to deal 
;;; in the Software without restriction, including without limitation the rights 
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
;;; copies of the Software, and to permit persons to whom the Software is furnished 
;;; to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in 
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
;;; IN THE SOFTWARE.

(in-package :common-lisp-user)

(defpackage :cells
    (:use #:common-lisp #:utils-kt)
    (:import-from
     ;; MOP
     #+allegro #:excl
      #+clisp #:clos
      #+cmu #:mop
      #+lispworks #:clos
      #+mcl #:ccl
      #+sbcl #:sb-mop
      #-(or allegro clisp cmu lispworks mcl sbcl)
      (cerror "Provide a package name."
	      "Don't know how to find the MOP package for this Lisp.")

       #:class-precedence-list #:class-slots #-clisp #:slot-definition-name
      )
  #+clisp (:import-from #:clos #:class-slots #:class-precedence-list)
  #+cmu (:import-from #:pcl #:class-precedence-list #:class-slots
        #:slot-definition-name #|#:true|#)
  #+cmu (:shadowing-import-from #:pcl #:true)
  #+lispworks (:import-from #:lw #:true)
  (:export #:cell #:c-input #:c-in #:c-in8
    #:c-formula #:c? #:c?8 #:c?_ #:c??
    #:with-integrity #:with-deference #:without-c-dependency #:self
    #:.cache #:c-lambda #:.cause
    #:defmodel #:c-awaken #:def-c-output #:def-c-unchanged-test
    #:new-value #:old-value #:old-value-boundp #:c...
    #:make-be
    #:mkpart #:the-kids #:nsib #:md-value #:^md-value #:.md-value #:kids #:^kids #:.kids
    #:cell-reset #:upper #:fm-max #:nearest #:fm-min-kid #:fm-max-kid #:mk-kid-slot 
    #:def-kid-slots #:find-prior #:fm-pos #:kid-no #:fm-includes #:fm-ascendant-common 
    #:fm-kid-containing #:fm-find-if #:fm-ascendant-if #:c-abs #:fm-collect-if #:psib
    #:to-be #:not-to-be #:ssibno #:md-awaken
    #:c-debug #:c-break #:c-assert #:c-stop #:c-stopped #:c-assert #:.stop    #:delta-diff
    )
  #+allegro (:shadowing-import-from #:excl #:fasl-write #:fasl-read #:gc)
  )


