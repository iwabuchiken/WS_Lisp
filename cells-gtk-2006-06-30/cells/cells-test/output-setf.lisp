;; -*- mode: Lisp; Syntax: Common-Lisp; Package: cells; -*-
;;;
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


(in-package :cells)

(defmodel bing (model)
  ((bang :initform (c-in nil) :accessor bang)))

(def-c-output bang ()
  (trc "new bang" new-value self)
  (bwhen (p .parent)
    (with-deference
        (setf (bang p) new-value)))
  #+not (dolist (k (^kids))
    (setf (bang k) (if (numberp new-value)
                       (1+ new-value)
                     0))))

(defmodel bings (bing family)
  ()
  (:default-initargs
      :kids (c? (loop repeat 2
                      collect (make-instance 'bing
                                  :md-name (copy-symbol 'kid))))))

(defun cv-output-setf ()
  (cell-reset)
  (let ((top (make-be 'bings
               :md-name 'top
               :kids (c-in nil))))
    (push (make-instance 'bings) (kids top))
    (dolist (k (kids (car (kids top))))
      (setf (bang k) (kid-no k)))))

#+test
(cv-output-setf)
