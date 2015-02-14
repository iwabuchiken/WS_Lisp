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

(defun list-append (L1 L2)
  "Append L1 by L2."
  (if (null L1)
      L2
    (cons (first L1) (list-append (rest L1) L2))))

(defun list-intersection-2 (L1 L2)
  "Return a list containing elements belonging to both L1 and L2."
  (cond
   ((null L1) nil)
   ((member (first L1) L2) 
    (cons (first L1) (list-intersection (rest L1) L2)))
   (t (list-intersection (rest L1) L2))))

(defun addup (char num)
  
  "Add char up for 'num' number of times"
  
  (setq count 0)
  (setq tmp nil)
  
  (loop

    (setq tmp (cons char tmp))
    (setq count (+ count 1))
    (when (> count (- num 1))
;    (when (> count num)
      (print tmp)
      (return tmp)
      );when
  
  );loop
  
);defun addup

(defun list-diff (L1 L2)
  
  (setq Lu (union L1 L2))
  (setq Li (intersection L1 L2))

  ;Report
  (print "L1 is")
  (print L1)
  (print "L2 is")
  (print L2)
  
  (print "union is")
  (print Lu)
  
  (print "intersec is")
  (print Li)
    
  ;; get: length of the union
  (print "len of union is")
  (setq len_union (list-length Lu))
  (print len_union)

  ;-------------------------------
  ;	validate: union
  ;-------------------------------
  (cond
    ((> 1 len_union)
      (print "len_union => < 1")
      (return)
      )
    ((> len_union 1)  (print "len_union => > 1"))
;    (t                 (list-member E (rest L)))
    );cond
        
  ;-------------------------------
  ;	validate: intersection
  ;-------------------------------
  (setq len_intersec (list-length Li))
  
  (cond
    ((> 1 len_intersec)
      (print "len_intersec => < 1")
      (return)
      )
    ((> len_intersec 1)  (print "len_intersec => > 1"))
;    (t                 (list-member E (rest L)))
    );cond
        
  );;defun list-diff



  ;-------------------------------
  ;	
  ;-------------------------------

(defun return_from (x)
  (return-from return_from x)
;  (return-from return_from 3)
  
  )

(defun sqrt-complex (x)
;(defun sqrt-complex (a b x)
  
  (setq counter 0)
;  (setq c1 #C(a b))
  (setq c1 #C(1 1))
  
  (loop
    (setq counter (+ counter 1))
 
    (print counter)
    (print c1)
       
    (when (>= counter x)
      (print "done")
      (return c1)
      ;(return counter)
      );when
  
    (setq c1 (sqrt c1))
    
  )
)

(defun logs (x n)

  (setq counter 0)
;  (setq res (log x))
  (print x)
  
  (loop
    
    (when (>= counter n)
      (print "done")
      (return)
      ;(return counter)
      );when
  
;    (setq res (log res))
    (setq x (log x))
    
    (print counter)
    (print x)

    (setq counter (+ counter 1))
    
  )
  
)