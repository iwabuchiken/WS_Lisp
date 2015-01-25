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

(defun triangular (N)
  "Compute the factorial of N."
  (if (= N 1)
      1
;      4
      (+ N (triangular(- N 1)))
  )

;  (if (< N 1) N)
  
;  (+ N triangular(- N 1))
  
)

(defun addition (N1)

  (setq CONS 6)
  
  (+ N1 CONS)
)

(defun fibonacci (N)
  "Compute the N'th Fibonacci number."
  (if (or (zerop N) (= N 1))
      1
    (+ (fibonacci (- N 1)) (fibonacci (- N 2)))))

(defun isor(N1 N2)
  
  (or N1 N2)
  
)  

(defun bet(x n1 n2)
  
  (< x n2)
  
)  

(defun echo(x)
  
  (print x)
  
  )

(defun call_echo(F x)

  (print "start: call_echo")
  
  (funcall F x)
  
;  (funcall #'F x)	;=> undefined function F
  
;  (funcall #'echo x);=> variable ECHO has no value
;  (funcall F x)	;=> variable ECHO has no value
;  (funcall echo x)	;=> variable ECHO has no value
;  (print x)
  
  )

(defun call_binomial(n r)

  (print "start: call_binomial")
  
  (funcall (function binomial) n r)
  
;  (funcall #'F x)	;=> undefined function F
  
;  (funcall #'echo x);=> variable ECHO has no value
;  (funcall F x)	;=> variable ECHO has no value
;  (funcall echo x)	;=> variable ECHO has no value
;  (print x)
  
  )

(defun binomial (N R)
  "Compute binomial coefficient B(N, R)."
  (print "binomial => starts")
  
  (if (or (zerop R) (= N R))
      1
    (+ (binomial (- N 1) (- R 1)) 
       (binomial (- N 1) R)))
)

;(defun list_binomial (N R)
(defun list_binomial (x R)
  
  (print "start")
  (binomial (x R))
;  (print "start")
;  
;  (setq res (binomial (x R)))
;;  (setq res (binomial (N R)))
;  
;  (print "binomial => done")
;  
;;  (print (binomial (N R)))
;  (print res)
  
  
)

(defun recursive-list-length (L)

  (if (null L)
      0
    (1+ (recursive-list-length (rest L))))
  
;  (if (null L)
;    
;    0
;    
;    1
;  )
)


(defun list-intersection (L1 L2)
  "Compute the intersection of lists L1 and L2."
  (remove-if #'(lambda (X) (not (member X L2))) L1)
)

(defun list-nth (N L)
  "Return the N'th member of a list L."
  (if (null L)
      nil
    (if (zerop N) 
	(first L)
      (list-nth (1- N) (rest L)))))

(defun list-nth-2 (n L)
  "Return the n'th member of a list L."
  (cond
   ((null L)   nil)
   ((zerop n)  (first L))
   (t          (list-nth (1- n) (rest L)))))

(defun list-member (E L)
  "Test if E is a member of L."
  (cond
   ((null L)          nil)   
   ((eq E (first L))  t)     
   (t                 (list-member E (rest L))))) 

(defun list-member-2 (E L)
  t
  )