;REF http://www.cs.sfu.ca/CourseCentral/310/pwfong/Lisp/1/tutorial1.html

;;; testing.lisp
;;; by Philip Fong
;;;
;;; Introductory comments are preceded by ";;;"
;;; Function headers are preceded by ";;"
;;; Inline comments are introduced by ";"
;;;

;;
;; Triple the value of a number
;;

(defun triple (X)
  "Compute three times X."  ; Inline comments can
  (* 3 X))                  ; be placed here.

;;
;; Negate the sign of a number
;;

(defun negate (X)
  "Negate the value of X."  ; This is a documentation string.
  (- X))     

(defun factorial (N)
  "Compute the factorial of N."
  (if (= N 1)
      1
    (* N (factorial (- N 1)))))

;; can handle '0'
(defun factorial_2 (N)
  "Compute the factorial of N."
  (cond
   ((= N 1)   1)
   ((= N 0)   1)
;;   ((= N 0) (print "is zero"))
   (t          (* N (factorial (- N 1)))))
  )
  
;;  (if (= N 1)
;;      1
;;    (= N 0) (print "is zero")
;;    (* N (factorial (- N 1)))))

(defun log_W (N list)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; disp: basic data  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (format t "list => ~A" list)
;;  (print list)
;;  (first list)
  
;;  (print (rest list))
  (print "--")
  
  (format t "list length => ~D" (list-length list))
  
;;  (print "list length")
;;  (print (list-length list))
  
;;  (print "sum")
  ;;REF http://stackoverflow.com/questions/590579/how-to-sum-a-list-of-numbers-in-emacs-lisp	answered Feb 26 '09 at 13:45
;;  (print (apply '+ list))
  
  (setq sum (apply '+ list))

  (print "--")  
  (format t "sum => ~D" sum)
  
;;  (print "N!")
;;  (print (factorial_2 sum))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; loop
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; prep
  (setq b 1)
  
  ;;REF dotimes https://www.gnu.org/software/emacs/manual/html_node/eintr/dotimes.html	
  (dotimes (num (list-length list))
    
;;    (print num)

    ;;REF subseq http://stackoverflow.com/questions/9072277/lisp-get-element-from-a-list	answered Jan 30 '12 at 23:35
    (setq elem (subseq list num (+ num 1)))
;;    (print elem)
    
    ;;REF car https://www.gnu.org/software/emacs/manual/html_node/elisp/List-Elements.html "5.3 Accessing Elements of Lists"
;;    (print (factorial_2 (car elem)))
    
    (setq b (* b (factorial_2 (car elem))))
    
;;    (print "b=")
;;    (print b)
    
;;    (factorial_2 (car elem))
    
;;    (print (car elem))
;;    (print (* (car elem) 3))
;;    (print (factorial_2 (parse-integer elem))	;;=>

    ;;REF http://stackoverflow.com/questions/16220607/converting-number-to-string-in-lisp answered Apr 25 '13 at 19:34
;;    (parse-integer (subseq list num (+ num 1)))	;;=>
;;    (parse-integer elem)	;;=> PARSE-INTEGER: argument (1) is not a string
    
;;    (factorial_2 (parse-integer elem))	;;=> PARSE-INTEGER: argument (1) is not a string
;;    (factorial_2 elem)	;;=> (1) is not a number
    
;;    (print (factorial_2 elem)	;;=> (1) is not a number
;;    (print (subseq list num (+ num 1)))
    
      );;(dotimes (num (list-length list))
  
  (print "--")  
  
  ;;REF format http://en.wikipedia.org/wiki/Format_(Common_Lisp) "Using Common Lisp, this is equivalent to:"
  (format t 
    "N0!*N1!...*Nj!=~D, sum of list=~D , N!=~D , logW=~F , list=~A , (logW / N!)=~F" 
;;    "b=~D , N!=~D , logW=~F , list=~A , (logW / N!)=~F" 
    b ;; b		
    sum
    (factorial_2 sum) ;; N!
    (/ (factorial_2 sum) b) ;; logW
    list
    (/ (/ (factorial_2 sum) b) (factorial_2 sum))	;; (logW / N!)
;;    (/ (factorial_2 sum) (factorial_2 sum))	;; (logW / N!)
    )
;;  (format t "b=~D / N!=~D / logW=%f" b (factorial_2 sum) (/ (factorial_2 sum) b))
  
;;  (print "b is now => ")
;;  (print b)
;;  ;;b
;;  
;;  (print "logW is => ")
;;  (/ (factorial_2 sum) b)
;;  (/ sum b)
;;  (print b)
  
;;  (* N (first list))
;;  (* N (log_W N (rest list)))
  
    );;(defun log_W (N list)
;  )