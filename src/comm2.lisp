;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")
;	** (c) Copyright 1982 Massachusetts Institute of Technology **

(macsyma-module comm2)

;;;; DIFF2

(DECLARE-TOP (SPECIAL $PROPS $DOTDISTRIB))

(DEFMFUN DIFFINT (E X)
  (LET (A)
    (COND ((NULL (CDDDR E))
	   (COND ((ALIKE1 X (CADDR E)) (CADR E))
		 ((AND (NOT (ATOM (CADDR E))) (ATOM X) (NOT (FREE (CADDR E) X)))
		  (MUL2 (CADR E) (SDIFF (CADDR E) X)))
		 ((OR ($CONSTANTP (SETQ A (SDIFF (CADR E) X)))
		      (AND (ATOM (CADDR E)) (FREE A (CADDR E))))
		  (MUL2 A (CADDR E)))
		 (T (SIMPLIFYA (LIST '(%INTEGRATE) A (CADDR E)) T))))
	  ((ALIKE1 X (CADDR E)) (ADDN (DIFFINT1 (CDR E) X X) T))
	  (T (ADDN (CONS (IF (EQUAL (SETQ A (SDIFF (CADR E) X)) 0)
			     0
			     (SIMPLIFYA (LIST '(%INTEGRATE) A (CADDR E)
					      (CADDDR E) (CAR (CDDDDR E)))
					T))
			 (DIFFINT1 (CDR E) X (CADDR E)))
		   T)))))

(DEFUN DIFFINT1 (E X Y)
  (LET ((U (SDIFF (CADDDR E) X)) (V (SDIFF (CADDR E) X)))
    (LIST (IF (pZEROP U) 0 (MUL2 U (MAXIMA-SUBSTITUTE (CADDDR E) Y (CAR E))))
	  (IF (pZEROP V) 0 (MUL3 V (MAXIMA-SUBSTITUTE (CADDR E) Y (CAR E)) -1)))))

(DEFMFUN DIFFSUMPROD (E X)
  (COND ((OR (NOT (ATOM X)) (NOT (FREE (CADDDR E) X)) (NOT (FREE (CAR (CDDDDR E)) X)))
	 (DIFF%DERIV (LIST E X 1)))
	((EQ (CADDR E) X) 0)
	(T (LET ((U (SDIFF (CADR E) X)))
	     (SETQ U (SIMPLIFYA (LIST '(%SUM)
				      (IF (EQ (CAAR E) '%SUM) U (DIV U (CADR E)))
				      (CADDR E) (CADDDR E) (CAR (CDDDDR E)))
		      T))
	(IF (EQ (CAAR E) '%SUM) U (MUL2 E U))))))

(DEFMFUN DIFFLAPLACE (E X)
  (COND ((OR (NOT (ATOM X)) (EQ (CADDDR E) X)) (DIFF%DERIV (LIST E X 1)))
	((EQ (CADDR E) X) 0)
	(T ($LAPLACE (SDIFF (CADR E) X) (CADDR E) (CADDDR E)))))

(DEFMFUN DIFF-%AT (E X)
  (COND ((FREEOF X E) 0)
	((NOT (FREEOFL X (HAND-SIDE (CADDR E) 'R))) (DIFF%DERIV (LIST E X 1)))
	(T ($AT (SDIFF (CADR E) X) (CADDR E)))))

(DEFMFUN DIFFNCEXPT (E X)
 ((LAMBDA (BASE* POW)
   (COND ((AND (MNUMP POW) (OR (NOT (EQ (ml-typep POW) 'fixnum)) (< POW 0)))  ; POW cannot be 0
	  (DIFF%DERIV (LIST E X 1)))
	 ((AND (ATOM BASE*) (EQ BASE* X) (FREE POW BASE*))
	  (MUL2* POW (LIST '(MNCEXPT) BASE* (ADD2 POW -1))))
	 ((ml-typep POW 'fixnum)
	  ((LAMBDA (DERIV ANS)
	    (DO ((I 0 (f1+ I))) ((= I POW))
		(SETQ ANS (CONS (LIST '(MNCTIMES) (LIST '(MNCEXPT) BASE* I)
				      (LIST '(MNCTIMES) DERIV
					    (LIST '(MNCEXPT) BASE* (f- POW 1 I))))
				ANS)))
	    (ADDN ANS NIL))
	   (SDIFF BASE* X) NIL))
	 ((AND (NOT (DEPENDS POW X)) (OR (ATOM POW) (AND (ATOM BASE*) (FREE POW BASE*))))
	  ((LAMBDA (DERIV INDEX)
	    (SIMPLIFYA
	     (LIST '(%SUM)
		   (LIST '(MNCTIMES) (LIST '(MNCEXPT) BASE* INDEX)
			 (LIST '(MNCTIMES) DERIV
			       (LIST '(MNCEXPT) BASE* 
				     (LIST '(MPLUS) POW -1 (LIST '(MTIMES) -1 INDEX)))))
		   INDEX 0 (LIST '(MPLUS) POW -1)) NIL))
	   (SDIFF BASE* X) (GENSUMINDEX)))
	 (T (DIFF%DERIV (LIST E X 1)))))
  (CADR E) (CADDR E)))

(DEFMFUN STOTALDIFF (E)
 (COND ((OR (MNUMP E) (CONSTANT E)) 0)
       ((OR (ATOM E) (MEMQ 'array (CDAR E)))
	(LET ((W (MGET (IF (ATOM E) E (CAAR E)) 'DEPENDS)))
	     (IF W (CONS '(MPLUS)
			 (MAPCAR #'(LAMBDA (X)
				    (LIST '(MTIMES) (CHAINRULE E X) (LIST '(%DEL) X)))
				 W))
		   (LIST '(%DEL) E))))
       ((SPECREPP E) (STOTALDIFF (SPECDISREP E)))
       ((EQ (CAAR E) 'MNCTIMES)
	(LET (($DOTDISTRIB T))
	     (ADD2 (NCMULN (CONS (STOTALDIFF (CADR E)) (CDDR E)) T)
		   (NCMUL2 (CADR E) (STOTALDIFF (NCMULN (CDDR E) T))))))
       ((EQ (CAAR E) 'MNCEXPT)
	(IF (AND (ml-typep (CADDR E) 'fixnum) (> (CADDR E) 0))
	    (STOTALDIFF (LIST '(MNCTIMES) (CADR E)
			      (NCPOWER (CADR E) (f1- (CADDR E)))))
	    (LIST '(%DERIVATIVE) E)))
       (T (ADDN (CONS 0 (MAPCAR #'(LAMBDA (X)
				   (MUL2 (SDIFF E X) (LIST '(%DEL SIMP) X)))
				(EXTRACTVARS (MARGS E))))
		T))))

(DEFUN EXTRACTVARS (E)
       (COND ((NULL E) NIL)
	     ((ATOM (CAR E))
	      (IF (NOT (MAXIMA-CONSTANTP (CAR E)))
		  (UNION* (NCONS (CAR E)) (EXTRACTVARS (CDR E)))
		  (EXTRACTVARS (CDR E))))
	     ((MEMQ 'array (CDAAR E)) (UNION* (NCONS (CAR E)) (EXTRACTVARS (CDR E))))
	     (T (UNION* (EXTRACTVARS (CDAR E)) (EXTRACTVARS (CDR E))))))

;;;; AT

;dummy-variable-operators is defined in COMM, which uses it inside of SUBST1.
(DECLARE-TOP (SPECIAL ATVARS ATEQS ATP MUNBOUND DUMMY-VARIABLE-OPERATORS))

(DEFMFUN $ATVALUE (EXP EQS VAL) 
 (LET (DL VL FUN)
      (COND ((NOTLOREQ EQS) (IMPROPER-ARG-ERR EQS '$ATVALUE))
	    ((OR (ATOM EXP) (AND (EQ (CAAR EXP) '%DERIVATIVE) (ATOM (CADR EXP))))
	     (IMPROPER-ARG-ERR EXP '$ATVALUE)))
      (COND ((NOT (EQ (CAAR EXP) '%DERIVATIVE))
	     (SETQ FUN (CAAR EXP) VL (CDR EXP) DL (LISTOF0S VL)))
	    (T (SETQ FUN (CAAADR EXP) VL (CDADR EXP))
	       (DOLIST (V VL)
		       (SETQ DL (NCONC DL (NCONS (OR (GETf (CDdR EXP) V) 0)))))))
      (IF (OR (MOPP FUN) (EQ FUN 'MQAPPLY)) (IMPROPER-ARG-ERR EXP '$ATVALUE))
      (ATVARSCHK VL)
      (DO ((VL1 VL (CDR VL1)) (L ATVARS (CDR L))) ((NULL VL1))
	  (IF (AND (SYMBOLP (CAR VL1)) (NOT (MGET (CAR VL1) '$CONSTANT)))
	      (SETQ VAL (MAXIMA-SUBSTITUTE (CAR L) (CAR VL1) VAL))
	      (IMPROPER-ARG-ERR (CONS '(MLIST) VL) '$ATVALUE)))
      (SETQ EQS (IF (EQ (CAAR EQS) 'MEQUAL) (LIST EQS) (CDR EQS)))
      (SETQ EQS (DO ((EQS EQS (CDR EQS)) (L)) ((NULL EQS) L)
		    (IF (NOT (MEMQ (CADAR EQS) VL))
			(IMPROPER-ARG-ERR (CAR EQS) '$ATVALUE))
		    (SETQ L (NCONC L (NCONS (CONS (CADAR EQS) (CADDAR EQS)))))))
      (SETQ VL (DO ((VL VL (CDR VL)) (L)) ((NULL VL) L)
		   (SETQ L (NCONC L (NCONS (CDR (OR (ASSQ (CAR VL) EQS)
						    (CONS NIL MUNBOUND))))))))
      (DO ((ATVALUES (MGET FUN 'ATVALUES) (CDR ATVALUES)))
	  ((NULL ATVALUES)
	   (MPUTPROP FUN (CONS (LIST DL VL VAL) (MGET FUN 'ATVALUES)) 'ATVALUES))
	  (WHEN (AND (EQUAL (CAAR ATVALUES) DL) (EQUAL (CADAR ATVALUES) VL))
		(RPLACA (CDDAR ATVALUES) VAL) (RETURN NIL)))
      (ADD2LNC FUN $PROPS)
      VAL))

(DEFMFUN $AT (EXP ATEQS)
 (IF (NOTLOREQ ATEQS) (IMPROPER-ARG-ERR ATEQS '$AT))
 (ATSCAN (LET ((ATP T)) ($SUBSTITUTE ATEQS EXP))))

(DEFUN ATSCAN (EXP)
 (COND ((OR (ATOM EXP) (MEMQ (CAAR EXP) '(%AT MRAT))) EXP)
       ((EQ (CAAR EXP) '%DERIVATIVE)
	(OR (AND (NOT (ATOM (CADR EXP)))
		 (LET ((VL (CDADR EXP)) DL)
		      (DOLIST (V VL)
		              (SETQ DL (NCONC DL (NCONS (OR (GETf (CdDR EXP) V)
							    0)))))
		      (ATFIND (CAAADR EXP)
			      (CDR ($SUBSTITUTE ATEQS (CONS '(MLIST) VL)))
			      DL)))
	    (LIST '(%AT) EXP ATEQS)))
       ((MEMQ (CAAR EXP) DUMMY-VARIABLE-OPERATORS) (LIST '(%AT) EXP ATEQS))
       ((AT1 EXP))
       (T (RECUR-APPLY #'ATSCAN EXP))))

(DEFUN AT1 (EXP) (ATFIND (CAAR EXP) (CDR EXP) (LISTOF0S (CDR EXP))))

(DEFUN ATFIND (FUN VL DL)
       (DO ((ATVALUES (MGET FUN 'ATVALUES) (CDR ATVALUES))) ((NULL ATVALUES))
	   (AND (EQUAL (CAAR ATVALUES) DL)
		(DO ((L (CADAR ATVALUES) (CDR L)) (VL VL (CDR VL)))
		    ((NULL L) T)
		    (IF (AND (NOT (EQUAL (CAR L) (CAR VL)))
			     (NOT (EQ (CAR L) MUNBOUND)))
			(RETURN NIL)))
		(RETURN (PROG2 (ATVARSCHK VL)
			       (SUBSTITUTEL VL ATVARS (CADDAR ATVALUES)))))))

(DEFUN LISTOF0S (LLIST)
  (DO ((LLIST LLIST (CDR LLIST)) (L NIL (CONS 0 L))) ((NULL LLIST) L)))

(declare-top (SPECIAL $RATFAC GENVAR VARLIST $KEEPFLOAT *E*))


(DEFMVAR $LOGCONCOEFFP NIL)
(DEFMVAR SUPERLOGCON T)
(defmvar $superlogcon t)

(DEFMFUN $LOGCONTRACT (E) (LGCCHECK (LOGCON E)))  ; E is assumed to be simplified.

(DEFUN LOGCON (E)
 (COND ((ATOM E) E)
       ((MEMQ (CAAR E) '(MPLUS MTIMES))
	(IF (AND $SUPERLOGCON (NOT (LGCSIMPLEP E))) (SETQ E (LGCSORT E)))
	(COND ((MPLUSP E) (LGCPLUS E)) ((MTIMESP E) (LGCTIMES E)) (T (LOGCON E))))
       (T (RECUR-APPLY #'LOGCON E))))

(DEFUN LGCPLUS (E)
 (DO ((X (CDR E) (CDR X)) (LOG) (NOTLOGS) (Y))
     ((NULL X)
      (COND ((NULL LOG) (SUBST0 (CONS '(MPLUS) (NREVERSE NOTLOGS)) E))
	    (T (SETQ LOG (SRATSIMP (MULN LOG T)))
	       (ADDN (CONS (LGCSIMP LOG) NOTLOGS) T))))
     (COND ((ATOM (CAR X)) (SETQ NOTLOGS (CONS (CAR X) NOTLOGS)))
	   ((EQ (CAAAR X) '%LOG) (SETQ LOG (CONS (LOGCON (CADAR X)) LOG)))
	   ((EQ (CAAAR X) 'MTIMES)
	    (SETQ Y (LGCTIMES (CAR X)))
	    (COND ((OR (ATOM Y) (NOT (EQ (CAAR Y) '%LOG)))
		   (SETQ NOTLOGS (CONS Y NOTLOGS)))
		  (T (SETQ LOG (CONS (CADR Y) LOG)))))
	   (T (SETQ NOTLOGS (CONS (LOGCON (CAR X)) NOTLOGS))))))

(DEFUN LGCTIMES (E)
 (SETQ E (SUBST0 (CONS '(MTIMES) (MAPCAR 'LOGCON (CDR E))) E))
 (COND ((NOT (MTIMESP E)) E)
       (T (DO ((X (CDR E) (CDR X)) (LOG) (NOTLOGS) (DECINTS))
	      ((NULL X)
	       (COND ((OR (NULL LOG) (NULL DECINTS)) E)
		     (T (MULN (CONS (LGCSIMP (POWER LOG (MULN DECINTS T)))
				    NOTLOGS)
			      T))))
	      (COND ((AND (NULL LOG) (NOT (ATOM (CAR X)))
			  (EQ (CAAAR X) '%LOG) (NOT (EQUAL (CADAR X) -1)))
		     (SETQ LOG (CADAR X)))
		    ((LOGCONCOEFFP (CAR X)) (SETQ DECINTS (CONS (CAR X) DECINTS)))
		    (T (SETQ NOTLOGS (CONS (CAR X) NOTLOGS))))))))

(DEFUN LGCSIMP (E)
 (COND ((ATOM E) (SIMPLN (LIST '(%LOG) E) 1 T)) (T (LIST '(%LOG SIMP) E))))

(DEFUN LGCSIMPLEP (E)
 (AND (EQ (CAAR E) 'MPLUS)
      (NOT (DO ((L (CDR E) (CDR L))) ((NULL L))
	       (COND ((NOT (OR (ATOM (CAR L))
			       (NOT (ISINOP (CAR L) '%LOG))
			       (EQ (CAAAR L) '%LOG)
			       (AND (EQ (CAAAR L) 'MTIMES)
				    (NULL (CDDDAR L))
				    (MNUMP (CADAR L))
				    (NOT (ATOM (CADDAR L)))
				    (EQ (CAAR (CADDAR L)) '%LOG))))
		      (RETURN T)))))))

(DEFUN LGCSORT (E)
 (LET (GENVAR VARLIST ($KEEPFLOAT T) VL E1)
      (NEWVAR E)
      (SETQ VL (DO ((VL VARLIST (CDR VL)) (LOGS) (NOTLOGS) (DECINTS))
		   ((NULL VL)
		    (SETQ LOGS (SORT LOGS #'GREAT))
		    (NRECONC DECINTS (NCONC LOGS (NREVERSE NOTLOGS))))
		   (COND ((AND (NOT (ATOM (CAR VL))) (EQ (CAAAR VL) '%LOG))
			  (SETQ LOGS (CONS (CAR VL) LOGS)))
			 ((LOGCONCOEFFP (CAR VL))
			  (SETQ DECINTS (CONS (CAR VL) DECINTS)))
			 (T (SETQ NOTLOGS (CONS (CAR VL) NOTLOGS))))))
      (SETQ E1 (RATDISREP (RATREP E VL)))
      (IF (ALIKE1 E E1) E E1)))

(DEFUN LGCCHECK (E)
 (LET (NUM DENOM)
      (COND ((ATOM E) E)
	    ((AND (EQ (CAAR E) '%LOG)
		  (SETQ NUM (zl-MEMBER ($NUM (CADR E)) '(1 -1)))
		  (NOT (EQUAL (SETQ DENOM ($DENOM (CADR E))) 1)))
	     (LIST '(MTIMES SIMP) -1
		   (LIST '(%LOG SIMP) (IF (= (CAR NUM) 1) DENOM (NEG DENOM)))))
	    (T (RECUR-APPLY #'LGCCHECK E)))))


(DEFUN LOGCONCOEFFP (E)
 (IF $LOGCONCOEFFP (LET ((*E* E)) (IS '(($LOGCONCOEFFP) *E*))) (MAXIMA-INTEGERP E)))

;;;; RTCON

(DECLARE-TOP (SPECIAL $RADEXPAND $DOMAIN RADPE))

(DEFMVAR $ROOTSCONMODE T)

(DEFUN $ROOTSCONTRACT (E)  ; E is assumed to be simplified
 ((LAMBDA (RADPE $RADEXPAND) (RTCON E))
  (AND $RADEXPAND (NOT (EQ $RADEXPAND '$ALL)) (EQ $DOMAIN '$REAL)) NIL))

(DEFUN RTCON (E)
 (COND ((ATOM E) E)
       ((EQ (CAAR E) 'MTIMES)
	(IF (AND (NOT (FREE E '$%I))
		 (LET ((NUM ($NUM E)))
		      (AND (NOT (ALIKE1 E NUM))
			   (OR (EQ NUM '$%I)
			       (AND (NOT (ATOM NUM)) (MEMQ '$%I NUM)
				    (MEMQ '$%I (RTCON NUM)))))))
	    (SETQ E (LIST* (CAR E) -1 '((MEXPT) -1 ((RAT SIMP) -1 2))
			   (DELQ '$%I (copy-top-level (CDR E)) 1))))
	(DO ((X (CDR E) (CDR X)) (ROOTS) (NOTROOTS) (Y))
	    ((NULL X)
	     (COND ((NULL ROOTS) (SUBST0 (CONS '(MTIMES) (NREVERSE NOTROOTS)) E))
		   (T (IF $ROOTSCONMODE
			  (LET (((MIN GCD LCM) (RTC-GETINFO ROOTS)))
			       (COND ((AND (= MIN GCD) (NOT (= GCD 1))
					   (NOT (= MIN LCM))
					   (NOT (EQ $ROOTSCONMODE '$ALL)))
				      (SETQ ROOTS
					    (RT-SEPAR
					     (LIST GCD
						   (RTCON
						    (RTC-FIXITUP 
						     (RTC-DIVIDE-BY-GCD ROOTS GCD)
						     NIL))
						   1)
					     NIL)))
				     ((EQ $ROOTSCONMODE '$ALL)
				      (SETQ ROOTS
					    (RT-SEPAR (SIMP-ROOTS LCM ROOTS)
						      NIL))))))
		      (RTC-FIXITUP ROOTS NOTROOTS))))
	    (COND ((ATOM (CAR X))
		   (COND ((EQ (CAR X) '$%I) (SETQ ROOTS (RT-SEPAR (LIST 2 -1) ROOTS)))
			 (T (SETQ NOTROOTS (CONS (CAR X) NOTROOTS)))))
		  ((AND (EQ (CAAAR X) 'MEXPT) (RATNUMP (SETQ Y (CADDAR X))))
		   (SETQ ROOTS (RT-SEPAR (LIST (CADDR Y)
					       (LIST '(MEXPT)
						     (RTCON (CADAR X)) (CADR Y)))
					 ROOTS)))

		  ((AND RADPE (EQ (CAAAR X) 'MABS))
		   (SETQ ROOTS (RT-SEPAR (LIST 2 `((MEXPT) ,(RTCON (CADAR X)) 2) 1)
					 ROOTS)))
		  (T (SETQ NOTROOTS (CONS (RTCON (CAR X)) NOTROOTS))))))
       ((AND RADPE (EQ (CAAR E) 'MABS))
	(POWER (POWER (RTCON (CADR E)) 2) '((RAT SIMP) 1 2)))
       (T (RECUR-APPLY #'RTCON E))))

; RT-SEPAR separates like roots into their appropriate "buckets", 
; where a bucket looks like:
; ((<denom of power> (<term to be raised> <numer of power>)
;		     (<term> <numer>)) etc)

(DEFUN RT-SEPAR (A ROOTS)
 (LET ((U (zl-ASSOC (CAR A) ROOTS)))
      (COND (U (NCONC U (CDR A))) (T (SETQ ROOTS (CONS A ROOTS)))))
 ROOTS)

(DEFUN SIMP-ROOTS (LCM ROOT-LIST)
 (LET (ROOT1)
      (DO ((X ROOT-LIST (CDR X)))
	  ((NULL X) (PUSH LCM ROOT1))
	  (PUSH (LIST '(MEXPT) (MULN (CDAR X) NIL) (QUOTIENT LCM (CAAR X)))
		ROOT1))))

(DEFUN RTC-GETINFO (LLISt)
 (LET ((M (CAAR LLIST)) (G (CAAR LLIST)) (L (CAAR LLIST)))
      (DO ((X (CDR LLIST) (CDR X)))
	  ((NULL X) (LIST M G L))
	  (SETQ M (MIN M (CAAR X)) G (GCD G (CAAR X)) L (LCM L (CAAR X))))))

(DEFUN RTC-FIXITUP (ROOTS NOTROOTS)
 (MAPCAR #'(LAMBDA (X) (RPLACD X (LIST (SRATSIMP (MULN (CDR X) (NOT $ROOTSCONMODE))))))
	 ROOTS)
 (MULN (NCONC (MAPCAR #'(LAMBDA (X) (POWER* (CADR X) `((RAT) 1 ,(CAR X))))
		      ROOTS)
	      NOTROOTS)
       (NOT $ROOTSCONMODE)))

(DEFUN RTC-DIVIDE-BY-GCD (LLIST GCD)
 (MAPCAR #'(LAMBDA (X) (RPLACA X (QUOTIENT (CAR X) GCD))) LLIST)
 LLIST)

(DEFMFUN $NTERMS (E)
 (COND ((ZEROP1 E) 0)
       ((ATOM E) 1)
       ((EQ (CAAR E) 'MTIMES)
	(IF (EQUAL -1 (CADR E)) (SETQ E (CDR E)))
	(DO ((L (CDR E) (CDR L)) (C 1 (TIMES C ($NTERMS (CAR L)))))
	    ((NULL L) C)))
       ((EQ (CAAR E) 'MPLUS)
	(DO ((L (CDR E) (CDR L)) (C 0 (PLUS C ($NTERMS (CAR L)))))
	    ((NULL L) C)))
       ((AND (EQ (CAAR E) 'MEXPT) (INTEGERP (CADDR E)) (PLUSP (CADDR E)))
	($BINOMIAL (PLUS (CADDR E) ($NTERMS (CADR E)) -1) (CADDR E)))
       ((SPECREPP E) ($NTERMS (SPECDISREP E)))
       (T 1)))

;;;; ATAN2

(DECLARE-TOP (SPECIAL $NUMER $%PIARGS $LOGARC $TRIGSIGN HALF%PI FOURTH%PI))

(DEFUN SIMPATAN2 (E VESTIGIAL Z)  ; atan2(y,x) ~ atan(y/x)
  (declare (ignore VESTIGIAL))
 (TWOARGCHECK E)
 (LET (Y X SIGNY SIGNX)
      (SETQ Y (SIMPCHECK (CADR E) Z) X (SIMPCHECK (CADDR E) Z))
      (COND ((AND (ZEROP1 Y) (ZEROP1 X))
	     (MERROR "ATAN2(0,0) has been generated."))
	    (;; float contagion
	     (and (or (numberp x) (ratnump x)) ; both numbers
		  (or (numberp y) (ratnump y)) ; ...but not bigfloats
		  (or $numer (floatp x) (floatp y))) ;at least one float
	     (atan2 ($float y) ($float x)))
	    (;; bfloat contagion
	     (and (mnump x)
		  (mnump y)
		  (or ($bfloatp x) ($bfloatp y))) ;at least one bfloat
	     (setq x ($bfloat x)
		   y ($bfloat y))
	     (if (MMINUSP* Y)
		 (NEG (*FPATAN (NEG Y) (LIST X)))
	       (*FPATAN Y (LIST X))))
	    ((AND $%PIARGS (FREE X '$%I) (FREE Y '$%I)
		  ;; Only use asksign if %piargs is on.
		  (COND ((ZEROP1 Y) (IF (ATAN2NEGP X) (SIMPLIFY '$%PI) 0))
			((ZEROP1 X) 
			 (IF (ATAN2NEGP Y) (MUL2* -1 HALF%PI) (SIMPLIFY HALF%PI)))
			((ALIKE1 Y X)
			 ;; Should we check if ($sign x) is $zero here?
			 (IF (ATAN2NEGP X) (MUL2* -3 FOURTH%PI) (SIMPLIFY FOURTH%PI)))
			((ALIKE1 Y (MUL2 -1 X))
			 (IF (ATAN2NEGP X) (MUL2* 3 FOURTH%PI) (MUL2* -1 FOURTH%PI)))
			;; Why is atan2(1,sqrt(3)) super-special-cased here?!?!
			;; It doesn't even handle atan2(1,-sqrt(3));
			;; *Atan* should handle sqrt(3) etc., so all cases will work
			((AND (EQUAL Y 1) (ALIKE1 X '((MEXPT SIMP) 3 ((RAT SIMP) 1 2))))
			 (MUL2* '((RAT SIMP) 1 6) '$%PI)))))
	    ($LOGARC (LOGARC '%ATAN (DIV Y X)))
	    ((AND $TRIGSIGN (MMINUSP* Y))
	     (NEG (SIMPLIFYA (LIST '($ATAN2) (NEG Y) X) T)))
			; atan2(y,x) = atan(y/x) + pi sign(y) (1-sign(x))/2
	    ((AND (FREE X '$%I) (EQ (SETQ SIGNX ($SIGN X)) '$POS))
	     (SIMPLIFYA (LIST '(%ATAN) (DIV Y X)) T))
	    ((AND (EQ SIGNX '$NEG) (FREE Y '$%I)
		  (MEMQ (SETQ SIGNY ($SIGN Y)) '($POS $NEG)))
	     (ADD2 (SIMPLIFYA (LIST '(%ATAN) (DIV Y X)) T)
		   (PORM (EQ SIGNY '$POS) (SIMPLIFY '$%PI))))
	    ((and (eq signx '$zero) (eq signy '$zero))
	     ;; Unfortunately, we'll rarely get here.  For example,
	     ;; assume(equal(x,0)) atan2(x,x) simplifies via the alike1 case above
	     (MERROR "ATAN2(0,0) has been generated."))
	    (T (EQTEST (LIST '($ATAN2) Y X) E)))))

(DEFUN ATAN2NEGP (E) (EQ (ASKSIGN-P-OR-N E) '$NEG))

;;;; ARITHF

(DECLARE-TOP (SPECIAL LNORECURSE))

(DEFMFUN $FIBTOPHI (E)
 (COND ((ATOM E) E)
       ((EQ (CAAR E) '$FIB)
	(SETQ E (COND (LNORECURSE (CADR E)) (T ($FIBTOPHI (CADR E)))))
	(LET ((PHI (MEVAL '$%PHI)))
	     (DIV (ADD2 (POWER PHI E) (NEG (POWER (ADD2 1 (NEG PHI)) E)))
		  (ADD2 -1 (MUL2 2 PHI)))))
       (T (RECUR-APPLY #'$FIBTOPHI E))))

(DEFMSPEC $NUMERVAL (L) (SETQ L (CDR L))
       (DO ((L L (CDDR L)) (X (NCONS '(MLIST SIMP)))) ((NULL L) X)
	   (COND ((NULL (CDR L)) (MERROR "NUMERVAL takes an even number of args"))
		 ((NOT (SYMBOLP (CAR L)))
		  (MERROR "~M must be atomic - NUMERVAL" (CAR L)))
		 ((BOUNDP (CAR L))
		  (MERROR "~M is bound - NUMERVAL" (CAR L))))
	   (MPUTPROP (CAR L) (CADR L) '$NUMER)
	   (ADD2LNC (CAR L) $PROPS)
	   (NCONC X (NCONS (CAR L)))))


(declare-top (SPECIAL POWERS VAR DEPVAR))

(DEFMFUN $DERIVDEGREE (E DEPVAR VAR)
 (LET (POWERS) (DERIVDEG1 E) (IF (NULL POWERS) 0 (MAXIMIN POWERS '$MAX))))

(DEFUN DERIVDEG1 (E)
 (COND ((OR (ATOM E) (SPECREPP E)))
       ((EQ (CAAR E) '%DERIVATIVE)
	(COND ((ALIKE1 (CADR E) DEPVAR)
	       (DO ((L (CDDR E) (CDDR L))) ((NULL L))
		   (COND ((ALIKE1 (CAR L) VAR)
			  (RETURN (SETQ POWERS (CONS (CADR L) POWERS)))))))))
       (T (MAPC 'DERIVDEG1 (CDR E)))))

(DECLARE-TOP (UNSPECIAL POWERS VAR DEPVAR))

;;;; BOX

(DEFMFUN $DPART N (MPART (LISTIFY N) NIL T NIL '$DPART))

(DEFMFUN $LPART N (MPART (CDR (LISTIFY N)) NIL (LIST (ARG 1)) NIL '$LPART))

(DEFMFUN $BOX N
 (COND ((= N 1) (LIST '(MBOX) (ARG 1)))
       ((= N 2) (LIST '(MLABOX) (ARG 1) (BOX-LABEL (ARG 2))))
       (T (WNA-ERR '$BOX))))

(DEFMFUN BOX (E LABEL) (IF (EQ LABEL T) (LIST '(MBOX) E) ($BOX E (CAR LABEL))))

(DEFUN BOX-LABEL (X) (IF (ATOM X) X (IMPLODE (CONS #\& (MSTRING X)))))

(DECLARE-TOP (SPECIAL LABEL))

(DEFMFUN $REMBOX N
 (LET ((LABEL (COND ((= N 1) '(NIL))
		    ((= N 2) (BOX-LABEL (ARG 2)))
		    (T (WNA-ERR '$REMBOX)))))
      (REMBOX1 (ARG 1))))

(DEFUN REMBOX1 (E)
 (COND ((ATOM E) E)
       ((OR (AND (EQ (CAAR E) 'MBOX)
		 (OR (EQUAL LABEL '(NIL)) (MEMQ LABEL '($UNLABELLED $UNLABELED))))
	    (AND (EQ (CAAR E) 'MLABOX)
		 (OR (EQUAL LABEL '(NIL)) (EQUAL LABEL (CADDR E)))))
	(REMBOX1 (CADR E)))
       (T (RECUR-APPLY #'REMBOX1 E))))

(DECLARE-TOP (UNSPECIAL LABEL))

;;;; MAPF


(declare-top ;#-NIL (SPLITFILE MAPF)
	 (SPECIAL SCANMAPP)
	 ;#-cl (*LEXPR SCANMAP1)
	 )

(DEFMSPEC $SCANMAP (L)
 (LET ((SCANMAPP T)) (RESIMPLIFY (APPLY #'SCANMAP1 (MMAPEV L)))))

(DEFMFUN SCANMAP1 N
 (LET ((FUNC (ARG 1)) (ARG2 (SPECREPCHECK (ARG 2))) NEWARG2)
   (COND ((EQ FUNC '$RAT) (MERROR "SCANMAP results must be in general representation."))
	 ((> N 2)
	  (COND ((EQ (ARG 3) '$BOTTOMUP)
		 (COND ((MAPATOM ARG2) (FUNCER FUNC (NCONS ARG2)))
		       (T (SUBST0 (FUNCER FUNC
					  (NCONS (MCONS-OP-ARGS
						  (MOP ARG2)
						  (MAPCAR #'(LAMBDA (U)
							     (SCANMAP1
							      FUNC U '$BOTTOMUP))
							  (MARGS ARG2)))))
				  ARG2))))
		((> N 3) (WNA-ERR '$SCANMAP))
		(T (MERROR "Only BOTTOMUP is an acceptable 3rd arg to SCANMAP."))))
	 ((MAPATOM ARG2) (FUNCER FUNC (NCONS ARG2)))
	 (T (SETQ NEWARG2 (SPECREPCHECK (FUNCER FUNC (NCONS ARG2))))
	    (COND ((MAPATOM NEWARG2) NEWARG2)
		  ((AND (ALIKE1 (CADR NEWARG2) ARG2) (NULL (CDDR NEWARG2)))
		   (SUBST0 (CONS (NCONS (CAAR NEWARG2))
				 (NCONS (SUBST0 
					 (MCONS-OP-ARGS
					  (MOP ARG2)
					  (MAPCAR #'(LAMBDA (U) (SCANMAP1 FUNC U))
						  (MARGS ARG2)))
					 ARG2)))
			   NEWARG2))
		  (T (SUBST0 (MCONS-OP-ARGS
			      (MOP NEWARG2)
			      (MAPCAR #'(LAMBDA (U) (SCANMAP1 FUNC U))
				      (MARGS NEWARG2)))
			     NEWARG2)))))))

(DEFUN SUBGEN (FORM)  ; This function does mapping of subscripts.
 (DO ((DS (IF (EQ (CAAR FORM) 'MQAPPLY) (LIST (CAR FORM) (CADR FORM))
					(NCONS (CAR FORM)))
	  (OUTERMAP1 #'DSFUNC1 (SIMPLIFY (CAR SUB)) DS))
      (SUB (REVERSE (OR (AND (EQ 'MQAPPLY (CAAR FORM)) (CDDR FORM))
			(CDR FORM))) 
	   (CDR SUB)))
     ((NULL SUB) DS)))

(DEFUN DSFUNC1 (DSN DSO)
 (COND ((OR (ATOM DSO) (ATOM (CAR DSO))) DSO)
       ((MEMQ 'array (CAR DSO))
	(COND ((EQ 'MQAPPLY (CAAR DSO))
	       (NCONC (LIST (CAR DSO) (CADR DSO) DSN) (CDDR DSO)))
	      (T (NCONC (LIST (CAR DSO) DSN) (CDR DSO)))))
       (T (MAPCAR #'(LAMBDA (D) (DSFUNC1 DSN D)) DSO))))

;;;; GENMAT

;(DECLARE-TOP #-NIL (SPLITFILE GENMAT)
;	 (FIXNUM DIM1 DIM2))

(DEFMFUN $GENMATRIX N
 (LET ((ARGS (LISTIFY N)))
      (IF (OR (< N 2) (> N 5)) (WNA-ERR '$GENMATRIX))
      (IF (NOT (OR (SYMBOLP (CAR ARGS))
		   (HASH-TABLE-P (CAR ARGS))
		   (AND (NOT (ATOM (CAR ARGS)))
			(EQ (CAAAR ARGS) 'LAMBDA))))
	  (IMPROPER-ARG-ERR (CAR ARGS) '$GENMATRIX))
      ;(MEMQ NIL (MAPCAR #'(LAMBDA (U) (EQ (TYPEP U) 'FIXNUM)) (CDR ARGS)))
      (IF (notevery #'fixnump (cdr args))
	  (MERROR "Invalid arguments to GENMATRIX:~%~M"
		  (CONS '(MLIST) (CDR ARGS))))
      (LET* ((HEADER (LIST (CAR ARGS) 'array))
	     (DIM1 (CADR ARGS))
	     (DIM2 (IF (= N 2) (CADR ARGS) (CADDR ARGS)))
	     (I (IF (> N 3) (ARG 4) 1))
	     (J (IF (= N 5) (ARG 5) I))
	     (L (NCONS '($MATRIX))))
	    (COND ((AND (OR (= DIM1 0) (= DIM2 0)) (= I 1) (= J 1)))
		  ((OR (> I DIM1) (> J DIM2))
		   (MERROR "Invalid arguments to GENMATRIX:~%~M"
			   (CONS '(MLIST) ARGS))))
	    (DO ((I I (f1+ I))) ((> I DIM1)) (NCONC L (NCONS (NCONS '(MLIST)))))
	    (DO ((I I (f1+ I)) (L (CDR L) (CDR L))) ((> I DIM1))
		(DO ((J J (f1+ J))) ((> J DIM2))
		    (NCONC (CAR L) (NCONS (MEVAL (LIST HEADER I J))))))
	    L)))

(DEFMFUN $COPYMATRIX (X)
 (IF (NOT ($MATRIXP X)) (MERROR "Argument not a matrix - COPYMATRIX:~%~M" X))
 (CONS (CAR X) (MAPCAR #'(LAMBDA (X) (copy-top-level X)) (CDR X))))

(DEFMFUN $COPYLIST (X)
 (IF (NOT ($LISTP X)) (MERROR "Argument not a list - COPYLIST:~%~M" X))
 (CONS (CAR X) (copy-top-level (CDR X))))

;;;; ADDROW

;(DECLARE-TOP #-NIL (SPLITFILE ADDROW))

(DEFMFUN $ADDROW N
 (COND ((= N 0) (WNA-ERR '$ADDROW))
       ((NOT ($MATRIXP (ARG 1))) (MERROR "First argument to ADDROW must be a matrix"))
       ((= N 1) (ARG 1))
       (T (DO ((I 2 (f1+ I)) (M (ARG 1))) ((> I N) M)
	  (SETQ M (ADDROW M (ARG I)))))))

(DEFMFUN $ADDCOL N
 (COND ((= N 0) (WNA-ERR '$ADDCOL))
       ((NOT ($MATRIXP (ARG 1))) (MERROR "First argument to ADDCOL must be a matrix"))
       ((= N 1) (ARG 1))
       (T (DO ((I 2 (f1+ I)) (M ($TRANSPOSE (ARG 1)))) ((> I N) ($TRANSPOSE M))
	  (SETQ M (ADDROW M ($TRANSPOSE (ARG I))))))))

(DEFUN ADDROW (M R)
 (COND ((NOT (MXORLISTP R)) (MERROR "Illegal argument to ADDROW or ADDCOL"))
       ((AND (CDR M)
	     (OR (AND (EQ (CAAR R) 'MLIST) (NOT (= (LENGTH (CADR M)) (LENGTH R))))
		 (AND (EQ (CAAR R) '$MATRIX)
		      (NOT (= (LENGTH (CADR M)) (LENGTH (CADR R))))
		      (PROG2 (SETQ R ($TRANSPOSE R))
			     (NOT (= (LENGTH (CADR M)) (LENGTH (CADR R))))))))
	(MERROR "Incompatible structure - ADDROW//ADDCOL")))
 (APPEND M (IF (EQ (CAAR R) '$MATRIX) (CDR R) (NCONS R))))

;;;; ARRAYF

;(DECLARE-TOP #-NIL (SPLITFILE ARRAYF))

(DEFMFUN $ARRAYMAKE (ARY SUBS)
 (COND ((OR (NOT ($LISTP SUBS)) (NULL (CDR SUBS)))
	(MERROR "Wrong type argument to ARRAYMAKE:~%~M" SUBS))
       ((EQ (ml-typep ARY) 'symbol)
	(CONS (CONS (GETOPR ARY) '(ARRAY)) (CDR SUBS)))
       (T (CONS '(MQAPPLY ARRAY) (CONS ARY (CDR SUBS))))))

;(DEFMACRO $ARRAYINFO (ARY)
;  `(arrayinfo-aux ',ary (safe-value ,ary)))

(DEFMspec $ARRAYINFO (ary) (setq ary (cdr ary)) 
  (arrayinfo-aux (car ary) (getvalue (car ary))))

(defun arrayinfo-aux (sym val)
  (prog
   (arra ary)
   (setq arra  val)(setq ary sym)
   (cond (arra
	  (cond
	    ((hash-table-p arra)
		 (let ((dim1 (gethash 'dim1 arra)))
		 (return
		  (list* '(mlist) '$hash_table (if dim1 1 t)
			 (sloop for (u v)
				in-table arra
				when (not (eq u 'dim1))
				collect
				(if (progn v dim1)  ;;ignore v
				    u (cons '(mlist simp) u)))))))
	    ((arrayp arra)
		 (return
		  (let (dims)
		    (list '(mlist)
			  '$declared
			  ;; they don't want more info (array-type arra)
			  (length (setq dims (array-dimensions arra)))
			  (cons '(mlist) (mapcar #'1- dims))))))
	    ))
	 (t
	  (LET ((GEN (MGETL  sym '(HASHAR ARRAY))) ARY1)
	       (COND ((NULL GEN) (MERROR "Not an array - ARRAYINFO:~%~M" ARY))
		     ((MFILEP (CADR GEN))
		      (I-$UNSTORE (NCONS ARY))
		      (SETQ GEN (MGETL ARY '(HASHAR ARRAY)))))
	       (SETQ ARY1 (CADR GEN))
	       (COND ((EQ (CAR GEN) 'HASHAR)
		      #+cl (setq ary1 (symbol-array ary1))
		      (return
		       (APPEND '((MLIST SIMP) $HASHED)
			       (CONS (aref ARY1 2)
				     (DO ((I 3 (f1+ I)) (L)
					  (N (CADR (ARRAYDIMS ARY1))))
					 ((= I N) (SORT L
							#'(LAMBDA (X Y) (GREAT Y X))))
					 (DO ((L1 (aref ARY1 I)
						  (CDR L1))) ((NULL L1))
						  (SETQ L (CONS
							   (CONS
							    '(MLIST SIMP)
							    (CAAR L1))
							   L))))))))
		     (T (SETQ ARY1 (ARRAYDIMS ARY1))
			(return (LIST '(MLIST SIMP)
				      (COND ((safe-GET ARY 'array)
					     (CDR (ASSQ (CAR ARY1)
							'((T . $COMPLETE) (FIXNUM . $INTEGER)
							  (FLONUM . $FLOAT)))))
					    (T '$DECLARED))
				      (LENGTH (CDR ARY1))
				      (CONS '(MLIST SIMP) (MAPCAR #'1- (CDR ARY1))))))))))))






;(DEFMSPEC $ARRAYINFO (ARY) (SETQ ARY (CDR ARY))
;  (cond ($use_fast_arrays
;	 (setq ary (symbol-value (car ary)))
;	 (cond ((arrayp ary)
;		(let (dims)(list '(mlist) (array-type ary)
;				  (length (setq dims (array-dimensions ary)))
;				  (cons '(mlist) dims))))
;	       (#-cl(ml-typep ary 'si:equal-hash-table )
;		#+cl (hash-table-p ary)
;		(list '(mlist) '$hash_table 1
;		      (cons '(mlist)
;			    (let (all-keys )
;			      (declare (special all-keys))
;			      (maphash #'(lambda (u v) 
;					   (declare (special all-keys)) v ;ignore
;					   (setq all-keys (cons u all-keys)))
;				       ary)
;			      all-keys))))
;	       (t (fsignal "Use_fast_arrays is true and the argument of arrayinfo is not a hash-table or an array"))))
;	(t
;	 (LET ((GEN (MGETL (SETQ ARY (CAR ARY)) '(HASHAR ARRAY))) ARY1)
;	   (COND ((NULL GEN) (MERROR "Not an array - ARRAYINFO:~%~M" ARY))
;		 ((MFILEP (CADR GEN))
;		  (I-$UNSTORE (NCONS ARY))
;		  (SETQ GEN (MGETL ARY '(HASHAR ARRAY)))))
;	   (SETQ ARY1 (CADR GEN))
;	   (COND ((EQ (CAR GEN) 'HASHAR)
;		  (APPEND '((MLIST SIMP) $HASHED)
;			  (CONS (FUNCALL ARY1 2)
;				(DO ((I 3 (f1+ I)) (L) (N (CADR (ARRAYDIMS ARY1))))
;				    ((= I N) (SORT L #'(LAMBDA (X Y) (GREAT Y X))))
;				  (DO L1 (FUNCALL ARY1 I) (CDR L1) (NULL L1)
;				      (SETQ L (CONS (CONS '(MLIST SIMP) (CAAR L1))
;						    L)))))))
;		 (T (SETQ ARY1 (ARRAYDIMS ARY1))
;		    (LIST '(MLIST SIMP)
;			  (COND ((safe-GET ARY 'array)
;				 (CDR (ASSQ (CAR ARY1)
;					    '((T . $COMPLETE) (FIXNUM . $INTEGER)
;					      (FLONUM . $FLOAT)))))
;				(T '$DECLARED))
;			  (LENGTH (CDR ARY1))
;			  (CONS '(MLIST SIMP) (MAPCAR #'1- (CDR ARY1))))))))))

;;;; ALIAS

(DECLARE-TOP ;#-NIL (SPLITFILE ALIAS)
	 (SPECIAL ALIASLIST ALIASCNTR GREATORDER LESSORDER)
	 ;(FIXNUM ALIASCNTR)
	 )

(DEFMSPEC $MAKEATOMIC (L) (SETQ L (CDR L))
 (DO ((L L (CDR L)) (BAS) (X)) ((NULL L) '$DONE)
     (IF (OR (ATOM (CAR L))
	     (NOT (OR (SETQ X (MEMQ (CAAAR L) '(MEXPT MNCEXPT)))
		      (MEMQ 'array (CDAAR L)))))
	 (IMPROPER-ARG-ERR (CAR L) '$MAKEATOMIC))
     (IF X (SETQ BAS (CADAR L) X (AND (ATOM (CADDAR L)) (CADDAR L)))
	   (SETQ BAS (CAAAR L) X (AND (ATOM (CADAR L)) (CADAR L))))
     (IF (NOT (ATOM BAS)) (IMPROPER-ARG-ERR (CAR L) '$MAKEATOMIC))
     (SETQ ALIASLIST
	   (CONS (CONS (CAR L)
		       (IMPLODE
			(NCONC (EXPLODEN BAS)
			       (OR (AND X (EXPLODEN X)) (NCONS '| |))
			       (CONS '$ (MEXPLODEN (SETQ ALIASCNTR (f1+ ALIASCNTR)))))))
		 ALIASLIST))))

(DEFMSPEC $ORDERGREAT (L)
  (IF GREATORDER (MERROR "Reordering is not allowed."))
  (MAKORDER (SETQ GREATORDER (REVERSE (CDR L))) '_))

(DEFMSPEC $ORDERLESS (L)
  (IF LESSORDER (MERROR "Reordering is not allowed."))
  (MAKORDER (SETQ LESSORDER (CDR L)) '|#|))

(DEFUN MAKORDER (L CHAR)
  (DO ((L L (CDR L)) (N 101 (f1+ N))) ((NULL L) '$DONE)
    (ALIAS (CAR L)
	   (IMPLODE (NCONC (NCONS CHAR) (MEXPLODEN N)
			   (EXPLODEN (STRIPDOLLAR (CAR L))))))))

(DEFMFUN $UNORDER NIL
 (LET ((L (DELQ NIL
		(CONS '(MLIST SIMP)
		      (NCONC (mapcar #'(lambda (x) (remalias (getalias x)))
				     lessorder)
			     (mapcar #'(lambda (x) (remalias (getalias x)))
				     greatorder))))))
   (SETQ LESSORDER NIL GREATORDER NIL)
   L))

;;;; CONCAT

;(DECLARE-TOP #-NIL (SPLITFILE CONCAT)
;	 (NOTYPE (ASCII-NUMBERP FIXNUM)))

(DEFMFUN $CONCAT (&REST L)
  (IF (NULL L) (MERROR "CONCAT needs at least one argument."))
  (getalias
   (IMPLODE
    (CONS (COND ((NOT (ATOM (CAR L))))
		((OR (NUMBERP (CAR L)) (char= (GETCHARN (CAR L) 1) #\&)) #\&)
		(T #\$))
	  (MAPCAN #'(LAMBDA (X)
		      (IF (NOT (ATOM X))
			  (MERROR "Argument to CONCAT not an atom: ~M" X))
		      (STRING* X))
		  L)))))

;; this function is undocumented and cryptic
;; it is obviously maldefined
;(DEFMFUN $GETCHAR (X Y)
; (LET ((N 0))
;      (COND ((NOT (SYMBOLP X))
;	     (MERROR "1st argument to GETCHAR not a symbol: ~M" X))
;	    ((OR (NOT (FIXNUMP Y)) (NOT (> Y 0)))
;	     (MERROR "Incorrect 2nd argument to GETCHAR: ~M" Y))
;;	    ((char= (SETQ N (GETCHARN (FULLSTRIP1 X) Y)) 0) NIL)
;	    ((char= (GETCHARN X 1) '#\&) (IMPLODE (LIST #\& N)))
;	    ((ASCII-NUMBERP N) (f- (char-code N) (char-code #\0)))
;	    (T (IMPLODE (LIST #\$ N))))))

;;;; ITS TTYINIT

;#+ITS
;(DECLARE-TOP (SPLITFILE TTYINI)
;	 (SPECIAL $PAGEPAUSE LINEL $LINEL SCROLLP TTYHEIGHT $PLOTHEIGHT
;		  SMART-TTY RUBOUT-TTY 12-BIT-TTY CURSORPOS PLASMA-TTY
;		  DISPLAY-FILE CHARACTER-GRAPHICS-TTY))

;#+ITS
;(DEFMFUN $TTY_INIT NIL 
;  (SETQ $PAGEPAUSE (= 0 (BOOLE  BOOLE-AND (CADDR (STATUS TTY)) #. (f* 1 (^ 2 25.)))))
;		; bit 3.8 (%TSMOR) of TTYSTS
;  (SETQ $LINEL (SETQ LINEL (LINEL T)))
;  (SETQ SCROLLP (NOT (= 0 (BOOLE  BOOLE-AND (CADDR (STATUS TTY)) #. (f* 1 (^ 2 30.))))))
;  (SETQ TTYHEIGHT (CAR (STATUS TTYSIZE))
;	$PLOTHEIGHT (IF (< TTYHEIGHT 200.) (f- TTYHEIGHT 2) 24.))
;  (LET ((TTYOPT (CAR (CDDDDR (SYSCALL 6 'CNSGET TYO)))))
;		; %TOFCI (bit 3.4) = terminal has a 12 bit keyboard.
;    (SETQ 12-BIT-TTY (NOT (= (BOOLE  BOOLE-AND #. (f* 8 (^ 2 18.)) TTYOPT) 0)))
;		; %TOMVU (bit 3.9) = terminal can do vertical cursor movement.
;		; However, we must also make sure that the screen size
;		; is within the ITS addressing limits.
;    (SETQ SMART-TTY (AND (NOT (= (BOOLE  BOOLE-AND #. (f* 256. (^ 2 18.)) TTYOPT) 0))
;			 (< TTYHEIGHT 200.)
;			 (< LINEL 128.)))
;		; %TOERS (bit 4.6) = terminal can selectively erase.
;		; %TOMVB (bit 4.4) = terminal can backspace.
;		; %TOOVR (bit 4.1) = terminal can overstrike (i.e. printing one
;		;		      character on top of another causes both 
;		;		      to appear.)
;    (SETQ RUBOUT-TTY
;	  (OR (NOT (= (BOOLE  BOOLE-AND #. (f* 32. (^ 2 27.)) TTYOPT) 0))	  ;%TOERS
;	      (AND (NOT (= (BOOLE  BOOLE-AND #. (f* 8. (^ 2 27.)) TTYOPT) 0))	  ;%TOMVB
;		   (= (BOOLE  BOOLE-AND #. (f* 1 (^ 2 27.)) TTYOPT) 0))))	  ;%TOOVR
;		; %TOCID (bit 3.1) = terminal can insert and delete characters.
;		; If the console has a 12-bit keyboard, an 85 by 50 screen, and
;		; can't ins/del characters, then it must be a Plasma console.
;    (SETQ PLASMA-TTY
;	  (AND 12-BIT-TTY (= LINEL 84.) (= TTYHEIGHT 50.)
;	       (= 0 (BOOLE  BOOLE-AND #. (f* 1 (^ 2 18.)) TTYOPT)))))
;  (SETQ CURSORPOS SMART-TTY)
;  (IF SMART-TTY (SETQ DISPLAY-FILE (OPEN '|TTY:| '(TTY OUT IMAGE BLOCK))))
;  (COND (PLASMA-TTY (LOAD '((DSK MACSYM) ARDS)))
;	((OR (= TTY 13.) (JOB-EXISTS 'H19) (JOB-EXISTS 'H19WHO))
;	 (LOAD '((DSK MACSYM) H19)))
;	((JOB-EXISTS 'VT100) (LOAD '((DSK MACSYM) VT100)))
;	(T (SETQ CHARACTER-GRAPHICS-TTY NIL)
;	   (REMPROP 'CG-D-PRODSIGN 'SUBR)
;	   (REMPROP 'CG-D-SUMSIGN 'SUBR)))
;  '$DONE)

;#+ITS
;(DEFUN JOB-EXISTS (JNAME) (PROBE-FILE (LIST '(USR *) (STATUS UNAME) JNAME)))


; Undeclarations for the file:
;#-NIL
;(DECLARE-TOP (NOTYPE N I J))
