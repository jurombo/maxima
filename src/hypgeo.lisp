;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;


;    ** (c) Copyright 1976, 1983 Massachusetts Institute of Technology **
(in-package "MAXIMA")

;These are the main routines for finding the Laplace Transform
; of special functions   --- written by Yannis Avgoustis
;                        --- modified by Edward Lafferty
;                       Latest mod by jpg 8/21/81
;
;   This program uses the programs on ELL;HYP FASL.

(macsyma-module hypgeo)

(DECLARE-top (SPECIAL VAR PAR ZEROSIGNTEST PRODUCTCASE CHECKCOEFSIGNLIST
		  $EXPONENTIALIZE $RADEXPAND))

(load-macsyma-macros rzmac)

(DEFUN BESS
       (V Z FLG)
       (LIST '(MQAPPLY)
	     (LIST (COND ((EQ FLG 'J)'($%J ARRAY))
			 (T '($%I ARRAY)))
		   V)
	     Z))

;(DEFUN CDRAS(A L)(CDR (ZL-ASSOC A L)))

(DEFUN GM(EXPR)(SIMPLIFYA (LIST '(%GAMMA) EXPR) NIL))

(DEFUN SIN%(ARG)(LIST '(%SIN) ARG))

(DEFUN NUMP
       (X)
       (COND ((ATOM X)(NUMBERP X))
	     ((NOT (ATOM X))(EQ (CAAR (SIMPLIFYA X NIL)) 'RAT))))

(DEFUN COS%(ARG)(LIST '(%COS) ARG))

(DEFUN NEGINP (A) (COND ((MAXIMA-INTEGERP A)(OR (ZERP A)(MINUSP A)))))

(DEFUN NOTNUMP(X)(NOT (NUMP X)))

(DEFUN NEGNUMP
       (X)
       (COND ((NOT (MAXIMA-INTEGERP X))
	      (MINUSP (CADR (SIMPLIFYA X NIL))))
	     (T (MINUSP X))))



(DEFUN EXPOR1P(EXP)(OR (EQUAL EXP 1)(EQ EXP '$%E)))

(DEFUN PARP(A)(EQ A PAR))



;(DEFUN HASVAR(EXP)(COND ((FREEVAR EXP) NIL)(T T)))



(DEFUN ARBPOW1
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (C NONZERP)
	      ((MEXPT)(U HASVAR)(V FREEVAR)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN U*ASINX
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT) (U NONZERP)((%ASIN)(X HASVAR)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN U*ATANX
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)((%ATAN)(X HASVAR)))
	     ((COEFFPP)(A ZERP)))
	   NIL))



(DEFUN GMINC(A B)(LIST '($GAMMAINCOMPLETE) A B))

(DEFUN LITTLESLOMMEL
       (M N Z)
       (LIST '(MQAPPLY)(LIST '($%S ARRAY) M N) Z))

(DEFUN MWHIT(A I1 I2)(LIST '(MQAPPLY)(LIST '($%M ARRAY) I1 I2) A))

(DEFUN WWHIT(A I1 I2)(LIST '(MQAPPLY)(LIST '($%W ARRAY) I1 I2) A))

(DEFUN PJAC(X N A B)(LIST '(MQAPPLY)(LIST '($%P ARRAY) N A B) X))

(DEFUN PARCYL(X N)(LIST '(MQAPPLY)(LIST '($%D ARRAY) N) X))


;...HOPEFULLY AMONG WHATEVER GARBAGE IT RECOGNIZES J[V](W).

(DEFUN ONEJ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%J ARRAY) (V TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

;...AMONG GARBAGE RECOGNIZES J[V1](W1)*J[V2](W2)


(DEFUN TWOJ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%J ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%J ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN TWOY
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%Y ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%Y ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN TWOK
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%K ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%K ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEKONEY
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%K ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%Y ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

;...AMONG GARBAGE RECOGNIZES J[V](W)^2.


(DEFUN ONEJ^2
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       ((MQAPPLY)(($%J ARRAY)(V TRUE))(W TRUE))
	       2.))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEY^2
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       ((MQAPPLY)(($%Y ARRAY)(V TRUE))(W TRUE))
	       2.))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEK^2
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       ((MQAPPLY)(($%K ARRAY)(V TRUE))(W TRUE))
	       2.))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEI
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%I ARRAY) (V TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN TWOI
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%I ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%I ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN TWOH
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%H ARRAY)(V1 TRUE)(V11 TRUE))
	       (W1 TRUE))
	      ((MQAPPLY)
	       (($%H ARRAY)(V2 TRUE)(V21 TRUE))
	       (W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEYONEJ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%Y ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%J ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEKONEJ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%K ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%J ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEYONEH
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%Y ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)
	       (($%H ARRAY)(V2 TRUE)(V21 TRUE))
	       (W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEKONEH
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%K ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)
	       (($%H ARRAY)(V2 TRUE)(V21 TRUE))
	       (W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEIONEJ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%I ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%J ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEIONEH
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%I ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)
	       (($%H ARRAY)(V2 TRUE)(V21 TRUE))
	       (W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEHONEJ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%H ARRAY)(V1 TRUE)(V11 TRUE))
	       (W1 TRUE))
	      ((MQAPPLY)(($%J ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEIONEY
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%I ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%Y ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEIONEK
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%I ARRAY)(V1 TRUE))(W1 TRUE))
	      ((MQAPPLY)(($%K ARRAY)(V2 TRUE))(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEI^2
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       ((MQAPPLY)(($%I ARRAY)(V TRUE))(W TRUE))
	       2.))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEH^2
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       ((MQAPPLY)
		(($%H ARRAY)(V1 TRUE)(V2 TRUE))
		(W TRUE))
	       2.))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONERF
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)((%ERF)(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONELOG
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)((%LOG)(W HASVAR)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONERFC
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)(($ERFC)(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEEI
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)(($%EI)(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEKELLIPTIC
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)(($KELLIPTIC)(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEE
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)(U NONZERP)(($%E)(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEGAMMAINCOMPLETE
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      (($GAMMAINCOMPLETE)(W1 FREEVARPAR)(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEGAMMAGREEK
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      (($GAMMAGREEK)(W1 FREEVARPAR)(W2 TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEHSTRUVE
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($HSTRUVE ARRAY)(V TRUE))(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONELSTRUVE
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($LSTRUVE ARRAY)(V TRUE))(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONES
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%S ARRAY)(V1 TRUE)(V2 TRUE))(W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONESLOMMEL
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($SLOMMEL ARRAY)(V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP)(A ZERP)))
	   NIL))

(DEFUN ONEY
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%Y ARRAY) (V TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEK
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%K ARRAY) (V TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONED
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%D ARRAY) (V TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEKBATEMAN
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($KBATEMAN ARRAY) (V TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEH
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%H ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEM
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%M ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEL
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%L ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEC
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%C ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONET
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%T ARRAY) (V1 TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEU
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%U ARRAY) (V1 TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEPJAC
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%P ARRAY) (V1 TRUE)(V2 TRUE)(V3 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEHE
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%HE ARRAY) (V1 TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEQ
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%Q ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEP0
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)(($%P ARRAY) (V1 TRUE)) (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN HYP-ONEP
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%P ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

(DEFUN ONEW
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MQAPPLY)
	       (($%W ARRAY) (V1 TRUE)(V2 TRUE))
	       (W TRUE)))
	     ((COEFFPP) (A ZERP)))
	   NIL))

 


 



;...RECOGNIZES L.T.E. "U*%E^(A*X+E*F(X)-P*X+C)+D".

(DEFUN LTEP
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       $%E
	       ((MPLUS)
		((COEFFPT) (A FREEVARPAR) (X VARP))
		((COEFFPT) (E FREEVARPAR) (F HASVAR))
		((MTIMES) -1. (P PARP) (X VARP))
		((COEFFPP) (C FREEVARPAR)))))
	     ((COEFFPP) (D ZERP)))
	   NIL)) 

;(DEFUN ZERP(A)(EQUAL A 0))

;(DEFUN NONZERP(A)(NOT (ZERP A)))

(DEFMFUN $SPECINT (EXP VAR)
       (PROG ($radexpand CHECKCOEFSIGNLIST)
	    (progn (FIND-FUNCTION 'SININT))
	    (setq $radexpand '$all)
	    (RETURN (GRASP-SOME-TRIGS EXP))))

(declare-top (special asinx atanx))

(setq asinx nil atanx nil)

(DEFUN GRASP-SOME-TRIGS
       (EXP)
       (PROG(U X L )
	    (COND ((SETQ L (U*ASINX EXP))
		   (SETQ U
			 (CDRAS 'U L)
			 X
			 (CDRAS 'X L)
			 ASINX
			 'T)
		   (RETURN (DEFINTEGRATE U))))
	    (COND ((SETQ L (U*ATANX EXP))
		   (SETQ U
			 (CDRAS 'U L)
			 X
			 (CDRAS 'X L)
			 ATANX
			 'T)
		   (RETURN (DEFINTEGRATE U))))
	    (RETURN (DEFINTEGRATE EXP))))



(DEFUN DEFINTEGRATE
       (EXP)
       (PROG ($EXPONENTIALIZE)
	     (SETQ $EXPONENTIALIZE t)
	     (RETURN (DISTRDEFEXECINIT ($EXPAND (SSIMPLIFYA EXP))))))


(DEFUN DEFEXEC
       (EXP VAR)
       (PROG(L A)
	    (SETQ EXP (SIMPLIFYA EXP NIL))
	    (COND ((SETQ L (DEFLTEP EXP))
		   (SETQ A (CDRAS 'A L))
		   (RETURN (NEGTEST L A))))
	    (RETURN 'OTHER-DEFINT-TO-FOLLOW-DEFEXEC)))

(DEFUN NEGTEST
       (L A)
       (PROG(U E F C)
	    (COND ((EQ (CHECKSIGNTM ($REALPART A)) '$NEGATIVE)
		   (SETQ U
			 (CDRAS 'U L)
			 E
			 (CDRAS 'E L)
			 F
			 (CDRAS 'F L)
			 C
			 (CDRAS 'C L))
		   (COND ((ZERP E)(SETQ F 1)))
		   (RETURN (MAXIMA-SUBSTITUTE (MUL -1 A)
				       'PSEY
				       (LTSCALE U
						VAR
						'PSEY
						C
						0
						E
						F)))))
	    (RETURN 'OTHER-DEFINT-TO-FOLLOW-NEGTEST)))

(DEFUN LTSCALE
       (EXP VAR PAR C PAR0 E F)
       (MUL* (POWER '$%E C)
	    (SUBSTL (SUB PAR PAR0) PAR (LT-EXEC EXP E F))))

(DEFUN DEFLTEP
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (U NONZERP)
	      ((MEXPT)
	       $%E
	       ((MPLUS)
		((COEFFPT) (A FREEVAR) (X VARP))
		((COEFFPT) (E FREEVAR) (F HASVARNOVARP))
		((COEFFPP) (C FREEVAR)))))
	     ((COEFFPP) (D ZERP)))
	   NIL))

(DEFUN HASVARNOVARP (A) (AND (HASVAR A) (NOT (VARP A))))
;it dispatches according to the kind of transform it matches


(DEFUN HYPGEO-EXEC (EXP VAR PAR)
       (PROG (L U A C E F)
	    (SETQ EXP (SIMPLIFYA EXP NIL))
	    (COND ((SETQ L (LTEP EXP))
		   (SETQ U (CDRAS 'U L)
			 A (CDRAS 'A L)
			 C (CDRAS 'C L)
			 E (CDRAS 'E L)
			 F (CDRAS 'F L))
		   (RETURN (LTSCALE U VAR PAR C A E F))))
	    (RETURN 'OTHER-TRANS-TO-FOLLOW)))

(DEFUN SUBSTL
       (P1 P2 P3)
       (COND ((EQ P1 P2) P3)(T (MAXIMA-SUBSTITUTE P1 P2 P3)))) 

(DEFUN LT-EXEC
       (U E F)
       (PROG(L)
	    (COND ((OR ASINX ATANX)(RETURN (LT-ASINATAN U E))))
	    (COND ((ZERP E)(RETURN (LT-SF-LOG U))))
	    (COND ((AND (NOT (ZERP E))(SETQ L (C*T^V U)))
		   (RETURN (LT-EXP L E F))))
	    (RETURN (LT-SF-LOG (MUL* U (POWER '$%E (MUL E F)))))))

(DEFUN C*T^V
       (EXP)
       (M2 EXP
	   '((MTIMES)
	     ((COEFFTT)(C FREEVAR))
	     ((MEXPT)(T VARP)(V FREEVAR)))
	   NIL))

(DEFUN LT-ASINATAN (U E)
       (COND ((ZERP E)
	      (COND (ASINX (LT-LTP 'ASIN U var NIL))
		    (ATANX (LT-LTP 'ATAN U var NIL))
		    (T 'LT-ASINATAN-FAILED-1)))
	     (T 'LT-ASINATAN-FAILED-2)))

(DEFUN LT-EXP
       (L E F)
       (PROG(C V)
	    (SETQ C (CDRAS 'C L) V (CDRAS 'V L))
	    (COND ((T^2 F)
		   (SETQ E (INV (MUL -8 E)) V (ADD V 1))
		   (RETURN (F24P146TEST C V E))))
	    (COND ((SQROOTT F)
		   (SETQ E (MUL* E E (INV 4)) V (ADD V 1))
		   (RETURN (F35P147TEST C V E))))
	    (COND ((T^-1 F)
		   (SETQ E (MUL -4 E) V (ADD V 1))
		   (RETURN (F29P146TEST V E))))
	    (RETURN 'OTHER-LT-EXPONENTIAL-TO-FOLLOW)))

(DEFUN T^2(EXP)(M2 EXP '((MEXPT)(T VARP) 2) NIL))

(DEFUN SQROOTT(EXP)(M2 EXP '((MEXPT)(T VARP)((RAT) 1 2)) NIL))

(DEFUN T^-1(EXP)(M2 EXP '((MEXPT)(T VARP) -1) NIL))

(DEFUN F24P146TEST
       (C V A)
       (COND ((NOT (OR (NEGINP A)(NEGINP V)))(F24P146 C V A))
	     (T 'FAIL-ON-F24P146TEST)))

(DEFUN F35P147TEST
       (C V A)
       (COND ((NOT (NEGINP V))(F35P147 C V A))
	     (T 'FAIL-ON-F35P147TEST)))

(DEFUN F29P146TEST (V A)
       (COND ((NOT (NEGINP A))
	      (F29P146 V A))
	     (T 'FAIL-ON-F29P146TEST)))

(DEFUN F1P137TEST
       (POW)
       (COND ((NOT (NEGINP (ADD POW 1)))(F1P137 POW))
	     (T 'FAIL-IN-ARBPOW))) 

(DEFUN F1P137
       (POW)
       (MUL* (GM (ADD POW 1))(POWER PAR (SUB (MUL -1 POW) 1))))

(DEFUN F24P146
       (C V A)
       (MUL* C
	     (GM V)
	     (POWER 2 V)
	     (POWER A (DIV V 2))
	     (POWER '$%E (MUL* A PAR PAR))
	     (DTFORD (MUL* 2 PAR (POWER A (1//2)))(MUL -1 V))))

(DEFUN F35P147
       (C V A)
       (MUL* C
	     (GM (ADD V V))
	     (POWER 2 (SUB 1 V))
	     (POWER PAR (MUL -1 V))
	     (POWER '$%E (MUL* A (1//2)(INV PAR)))
	     (DTFORD (POWER (MUL* 2 A (INV PAR))(1//2))(MUL -2 V))))

(DEFUN F29P146 (V A)
       (MUL* 2
	     (POWER (MUL* A (INV 4)(INV PAR))(DIV V 2))
	     (KTFORK A V)))

(DEFUN KTFORK
       (A V)
       ((LAMBDA(Z)
	       (COND ((MAXIMA-INTEGERP V)(KMODBES Z V))
		     (T (SIMPKTF Z V))))
	(POWER (MUL* A PAR)(1//2))))

(DEFUN DTFORD
       (Z V)
       (COND (((LAMBDA(INV4)
		      (WHITTINDTEST (ADD (DIV V 2) INV4) INV4))
	       (INV 4))
	      (PARCYL Z V))
	     (T (SIMPDTF Z V))))


(DEFUN SIMPDTF
       (Z V)
       ((LAMBDA(INV2 POW)
	       (ADD (MUL* (POWER 2 (DIV (SUB V 1) 2))
			  Z
			  (GM (INV -2))
			  (INV (GM (MUL* V -1 INV2)))
			  POW
			  (HGFSIMP-EXEC (LIST (SUB INV2
						   (DIV V
							2)))
					(LIST (DIV 3 2))
					(MUL* Z Z INV2)))
		    (MUL* (POWER 2 (DIV V 2))
			  (GM INV2)
			  POW
			  (INV (GM (SUB INV2 (MUL V INV2))))
			  (HGFSIMP-EXEC (LIST (MUL* V
						   -1
						   INV2))
					(LIST INV2)
					(MUL* Z Z INV2)))))
	(1//2)
	(POWER '$%E (MUL* Z Z (INV -4)))))

(DEFUN SIMPKTF
       (Z V)
       ((LAMBDA(DZ2)
	       (MUL* '$%PI
		     (1//2)
		     (INV (sin% (MUL V '$%PI)))
		     (SUB (MUL* (POWER  DZ2 (MUL -1 V))
			       (INV (GM (SUB 1 V)))
			       (HGFSIMP-EXEC NIL
					     (LIST (SUB 1
							V))
					     (MUL* Z
						  Z
						  (INV 4))))
			  (MUL* (POWER DZ2 V)
			       (INV (GM (ADD V 1)))
			       (HGFSIMP-EXEC NIL
					     (LIST (ADD V
							1))
					     (MUL* Z
						  Z
						  (INV 4)))))))
	(DIV Z 2))) 
;dispatches according to the special functions involved in the laplace transformable expression

(DEFUN LT-SF-LOG
       (U)
       (PROG(L INDEX1 INDEX11 INDEX2 INDEX21 ARG1 ARG2 REST)
	    (COND ((SETQ L (TWOJ U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT2J REST ARG1 ARG2 INDEX1 INDEX2))))
	    (COND ((SETQ L (TWOH U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V11 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 INDEX21
			 (CDRAS 'V21 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG2
				     INDEX1
				     INDEX11
				     INDEX2
				     INDEX21
				     '2HTJORY))))
	    (COND ((SETQ L (TWOY U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG2
				     INDEX1
				     NIL
				     INDEX2
				     NIL
				     '2YTJ))))
	    (COND ((SETQ L (TWOK U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG2
				     INDEX1
				     NIL
				     INDEX2
				     NIL
				     '2KTI))))
	    (COND ((SETQ L (ONEKONEY U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG2
				     INDEX1
				     NIL
				     INDEX2
				     NIL
				     'KTIYTJ))))
	    (COND ((SETQ L (ONEIONEJ U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 INDEX21
			 (CDRAS 'V21 L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W1 L))
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (MUL* (1FACT NIL INDEX1)(CDRAS 'U L)))
		   (RETURN (LT2J REST ARG1 ARG2 INDEX1 INDEX2))))
	    (COND ((SETQ L (ONEIONEH U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 INDEX21
			 (CDRAS 'V21 L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W1 L))
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (MUL* (1FACT NIL INDEX1)(CDRAS 'U L)))
		   (RETURN (FRACTEST1 REST
				      ARG1
				      ARG2
				      INDEX1
				      INDEX2
				      INDEX21
				      'BESSHTJORY))))
	    (COND ((SETQ L (ONEYONEJ U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST1 REST
				      ARG2
				      ARG1
				      INDEX2
				      INDEX1
				      NIL
				      'BESSYTJ))))
	    (COND ((SETQ L (ONEKONEJ U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST1 REST
				      ARG2
				      ARG1
				      INDEX2
				      INDEX1
				      NIL
				      'BESSKTI))))
	    (COND ((SETQ L (ONEHONEJ U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V11 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST1 REST
				      ARG2
				      ARG1
				      INDEX2
				      INDEX1
				      INDEX11
				      'BESSHTJORY))))
	    (COND ((SETQ L (ONEYONEH U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 INDEX11
			 (CDRAS 'V21 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST1 REST
				      ARG2
				      ARG1
				      INDEX2
				      INDEX1
				      INDEX11
				      'HTJORYYTJ))))
	    (COND ((SETQ L (ONEKONEH U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 INDEX11
			 (CDRAS 'V21 L)
			 ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST1 REST
				      ARG2
				      ARG1
				      INDEX2
				      INDEX1
				      INDEX11
				      'HTJORYKTI))))
	    (COND ((SETQ L (ONEIONEY U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W1 L))
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (MUL* (1FACT NIL INDEX1)(CDRAS 'U L)))
		   (RETURN (FRACTEST1 REST
				      ARG1
				      ARG2
				      INDEX1
				      INDEX2
				      NIL
				      'BESSYTJ))))
	    (COND ((SETQ L (ONEIONEK U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W1 L))
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (MUL* (1FACT NIL INDEX1)(CDRAS 'U L)))
		   (RETURN (FRACTEST1 REST
				      ARG1
				      ARG2
				      INDEX1
				      INDEX2
				      NIL
				      'BESSKTI))))
	    (COND ((SETQ L (ONEHSTRUVE U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1HSTRUVE REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONELSTRUVE U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1LSTRUVE REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONES U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1S REST ARG1 INDEX1 INDEX2))))
	    (COND ((SETQ L (ONESLOMMEL U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST
				      ARG1
				      INDEX1
				      INDEX2
				      'SLOMMEL))))
	    (COND ((SETQ L (ONEY U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1YREF REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONEK U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST
				      ARG1
				      INDEX1
				      NIL
				      'KTI))))
	    (COND ((SETQ L (ONED U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST ARG1 INDEX1 NIL 'D))))
	    (COND ((SETQ L (ONEGAMMAINCOMPLETE U))
		   (SETQ ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST
				      ARG1
				      ARG2
				      NIL
				      'GAMMAINCOMPLETE))))
	    (COND ((SETQ L (ONEKBATEMAN U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST
				      ARG1
				      INDEX1
				      NIL
				      'KBATEMAN))))
	    (COND ((SETQ L (ONEJ U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1J REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONEGAMMAGREEK U))
		   (SETQ ARG1
			 (CDRAS 'W1 L)
			 ARG2
			 (CDRAS 'W2 L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1GAMMAGREEK REST ARG1 ARG2))))
	    (COND ((SETQ L (ONEH U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST
				      ARG1
				      INDEX1
				      INDEX11
				      'HTJORY))))
	    (COND ((SETQ L (ONEM U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1M REST ARG1 INDEX1 INDEX11))))
	    (COND ((SETQ L (ONEL U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (INTEGERTEST REST
					ARG1
					INDEX1
					INDEX11
					'L))))
	    (COND ((SETQ L (ONEC U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (INTEGERTEST REST
					ARG1
					INDEX1
					INDEX11
					'C))))
	    (COND ((SETQ L (ONET U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (INTEGERTEST REST
					ARG1
					INDEX1
					NIL
					'T))))
	    (COND ((SETQ L (ONEU U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (INTEGERTEST REST
					ARG1
					INDEX1
					NIL
					'U))))
	    (COND ((SETQ L (ONEHE U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (INTEGERTEST REST
					ARG1
					INDEX1
					NIL
					'HE))))
	    (COND ((SETQ L (HYP-ONEP U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1P REST ARG1 INDEX1 INDEX11))))
	    (COND ((SETQ L (ONEPJAC U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 INDEX21
			 (CDRAS 'V3 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (PJACTEST REST
				     ARG1
				     INDEX1
				     INDEX2
				     INDEX21))))
	    (COND ((SETQ L (ONEQ U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1Q REST ARG1 INDEX1 INDEX11))))
	    (COND ((SETQ L (ONEP0 U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 0
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1P REST ARG1 INDEX1 INDEX11))))
	    (COND ((SETQ L (ONEW U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (WHITTEST REST ARG1 INDEX1 INDEX11))))
	    (COND ((SETQ L (ONEJ^2 U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (LT1J^2 REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONEH^2 U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX11
			 (CDRAS 'V2 L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG1
				     INDEX1
				     INDEX11
				     INDEX1
				     INDEX11
				     '2HTJORY))))
	    (COND ((SETQ L (ONEY^2 U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG1
				     INDEX1
				     NIL
				     INDEX1
				     NIL
				     '2YTJ))))
	    (COND ((SETQ L (ONEK^2 U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (CDRAS 'W L)
			 REST
			 (CDRAS 'U L))
		   (RETURN (FRACTEST REST
				     ARG1
				     ARG1
				     INDEX1
				     NIL
				     INDEX1
				     NIL
				     '2KTI))))
	    (COND ((SETQ L (TWOI U))
		   (SETQ INDEX1
			 (CDRAS 'V1 L)
			 INDEX2
			 (CDRAS 'V2 L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W1 L))
			 ARG2
			 (MUL* (1FACT T T) (CDRAS 'W2 L))
			 REST
			 (MUL* (1FACT NIL INDEX1)
			      (1FACT NIL INDEX2)
			      (CDRAS 'U L)))
		   (RETURN (LT2J REST ARG1 ARG2 INDEX1 INDEX2))))
	    (COND ((SETQ L (ONEI U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W L))
			 REST
			 (MUL* (1FACT NIL INDEX1)(CDRAS 'U L)))
		   (RETURN (LT1J REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONEI^2 U))
		   (SETQ INDEX1
			 (CDRAS 'V L)
			 ARG1
			 (MUL* (1FACT T T)(CDRAS 'W L))
			 REST
			 (MUL* (1FACT NIL INDEX1)(CDRAS 'U L)))
		   (RETURN (LT1J^2 REST ARG1 INDEX1))))
	    (COND ((SETQ L (ONERF U))
		   (SETQ ARG1 (CDRAS 'W L) REST (CDRAS 'U L))
		   (RETURN (LT1ERF REST ARG1))))
	    (COND ((SETQ L (ONELOG U))
		   (SETQ ARG1 (CDRAS 'W L) REST (CDRAS 'U L))
		   (RETURN (LT1LOG REST ARG1))))
	    (COND ((SETQ L (ONERFC U))
		   (SETQ ARG1 (CDRAS 'W L) REST (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST ARG1 NIL NIL 'ERFC))))
	    (COND ((SETQ L (ONEEI U))
		   (SETQ ARG1 (CDRAS 'W L) REST (CDRAS 'U L))
		   (RETURN (FRACTEST2 REST ARG1 NIL NIL 'EI))))
	    (COND ((SETQ L (ONEKELLIPTIC U))
		   (SETQ ARG1 (CDRAS 'W L) REST (CDRAS 'U L))
		   (RETURN (LT1KELLIPTIC REST ARG1))))
	    (COND ((SETQ L (ONEE U))
		   (SETQ ARG1 (CDRAS 'W L) REST (CDRAS 'U L))
		   (RETURN (LT1E REST ARG1))))
	    (COND ((SETQ L (ARBPOW1 U))
		   (SETQ ARG1
			 (CDRAS 'U L)
			 ARG2
			 (CDRAS 'C L)
			 INDEX1
			 (CDRAS 'V L))
		   (RETURN (MUL ARG2 (LT-ARBPOW ARG1 INDEX1)))))
	    (RETURN 'OTHER-J-CASES-NEXT)))

(DEFUN LT-ARBPOW
       (EXP POW)
       (COND ((OR (EQ EXP VAR)(ZERP POW))(F1P137TEST POW))))

(DEFUN FRACTEST
       (R A1 A2 I1 I11 I2 I21 FLG)
       (COND ((OR (AND (EQUAL (CAAR I1) 'RAT)
		       (EQUAL (CAAR I2) 'RAT))
		  (EQ FLG '2HTJORY))
	      (SENDEXEC R
			(COND ((EQ FLG '2YTJ)
			       (MUL (YTJ I1 A1)(YTJ I2 A2)))
			      ((EQ FLG '2HTJORY)
			       (MUL (HTJORY I1 I11 A1)
				    (HTJORY I2 I21 A2)))
			      ((EQ FLG 'KTIYTJ)
			       (MUL (KTI I1 A1)(YTJ I2 A2)))
			      ((EQ FLG '2KTI)
			       (MUL (KTI I1 A1)(KTI I2 A2))))))
	     (T 'PRODUCT-OF-Y-WITH-NOFRACT-INDICES)))

(DEFUN FRACTEST1
       (R A1 A2 I1 I2 I FLG)
       (COND ((OR (EQUAL (CAAR I2) 'RAT)(EQ FLG 'BESSHTJORY))
	      (SENDEXEC R
			(COND ((EQ FLG 'BESSYTJ)
			       (MUL (BESS I1 A1 'J)
				    (YTJ I2 A2)))
			      ((EQ FLG 'BESSHTJORY)
			       (MUL (BESS I1 A1 'J)
				    (HTJORY I2 I A2)))
			      ((EQ FLG 'HTJORYYTJ)
			       (MUL (HTJORY I1 I A1)
				    (YTJ I2 A2)))
			      ((EQ FLG 'BESSKTI)
			       (MUL (BESS I1 A1 'J)
				    (KTI I2 A2)))
			      ((EQ FLG 'HTJORYKTI)
			       (MUL (HTJORY I1 I A1)
				    (KTI I2 A2))))))
	     (T 'PRODUCT-OF-I-Y-OF-NOFRACT-INDEX)))

(DEFUN FRACTEST2
       (R A1 I1 I11 FLG)
       (COND ((OR (EQUAL (CAAR I1) 'RAT)
		  (EQ FLG 'D)
		  (EQ FLG 'KBATEMAN)
		  (EQ FLG 'GAMMAINCOMPLETE)
		  (EQ FLG 'HTJORY)
		  (EQ FLG 'ERFC)
		  (EQ FLG 'EI)
		  (EQ FLG 'SLOMMEL))
	      (SENDEXEC R
			(COND ((EQ FLG 'YTJ)(YTJ I1 A1))
			      ((EQ FLG 'HTJORY)
			       (HTJORY I1 I11 A1))
			      ((EQ FLG 'D)(DTW I1 A1))
			      ((EQ FLG 'KBATEMAN)
			       (KBATEMANTW A1))
			      ((EQ FLG 'GAMMAINCOMPLETE)
			       (GAMMAINCOMPLETETW A1 I1))
			      ((EQ FLG 'KTI)(KTI I1 A1))
			      ((EQ FLG 'ERFC)(ERFCTD A1))
			      ((EQ FLG 'EI)
			       (EITGAMMAINCOMPLETE A1))
			      ((EQ FLG 'SLOMMEL)
			       (SLOMMELTJANDY I1 I11 A1)))))
	     (T 'Y-OF-NOFRACT-INDEX)))

(DEFUN LT1YREF
       (REST ARG1 INDEX1)
       (COND ((MAXIMA-INTEGERP INDEX1)(LT1Y REST ARG1  INDEX1))
	     (T (FRACTEST2 REST ARG1 INDEX1 NIL 'YTJ))))

(DEFUN PJACTEST
       (REST ARG INDEX1 INDEX2 INDEX3)
       (COND ((MAXIMA-INTEGERP INDEX1)
	      (LT-LTP 'ONEPJAC
		      REST
		      ARG
		      (LIST INDEX1 INDEX2 INDEX3)))
	     (T 'IND-SHOULD-BE-AN-INTEGER-IN-POLYS)))

(DEFUN EQRAT(A)(COND ((NUMBERP A) NIL)(T (EQUAL (CAAR A) 'RAT)))) 

(DEFUN INTEGERTEST
       (R ARG I1 I2 FLG)
       (COND ((MAXIMA-INTEGERP I1)(DISPATCHPOLTRANS R ARG I1 I2 FLG))
	     (T 'INDEX-SHOULD-BE-AN-INTEGER-IN-POLYS)))

(DEFUN DISPATCHPOLTRANS
       (R X I1 I2 FLG)
       (SENDEXEC R
		 (COND ((EQ FLG 'L)(LTW X I1 I2))
		       ((EQ FLG 'HE)(HETD X I1))
		       ((EQ FLG 'C)(CTPJAC X I1 I2))
		       ((EQ FLG 'T)(TTPJAC X I1))
		       ((EQ FLG 'U)(UTPJAC X I1)))))

(DEFUN SENDEXEC(R A)(DISTREXECINIT ($EXPAND (MUL (INIT R) A)))) 

(DEFUN WHITTEST
       (R A I1 I2)
       (COND ((WHITTINDTEST I1 I2) 'FORMULA-FOR-CONFL-NEEDED)
	     (T (DISTREXECINIT ($EXPAND (MUL (INIT R)
					     (WTM A I1 I2)))))))

(DEFUN WHITTINDTEST
       (I1 I2)
       (OR (MAXIMA-INTEGERP (ADD I2 I2))
	   (NEGINP (SUB (SUB (1//2) I2) I1))
	   (NEGINP (SUB (ADD (1//2) I2) I1))))

(DEFUN INIT(R)(MUL* R (POWER '$%E (MUL* -1 VAR PAR))))

(DEFUN LTW
       (X N A)
       ((LAMBDA(DIVA2)
	       (MUL* (POWER -1 N)
		     (INV (FACTORIAL N))
		     (POWER X (SUB (INV -2) DIVA2))
		     (POWER '$%E (DIV X 2))
		     (WWHIT X (ADD (1//2) DIVA2 N) DIVA2)))
	(DIV A 2)))

(DEFUN CTPJAC
       (X N V)
       ((LAMBDA(INV2)
	       (MUL* (GM (ADD V V N))
		     (INV (GM (ADD V V)))
		     (GM (ADD INV2 V))
		     (INV (GM (ADD V INV2 N)))
		     (PJAC X N (SUB V INV2)(SUB V INV2))))
	(1//2)))

(DEFUN TTPJAC
       (X N)
       ((LAMBDA(INV2)
	       (MUL* (FACTORIAL N)
		     (GM INV2)
		     (INV (GM (ADD INV2 N)))
		     (PJAC X N (MUL -1 INV2)(MUL -1 INV2))))
	(1//2)))

(DEFUN UTPJAC
       (X N)
       ((LAMBDA(INV2)
	       (MUL* (FACTORIAL (ADD N 1))
		     INV2
		     (GM INV2)
		     (INV (GM (ADD INV2 N 1)))
		     (PJAC X N INV2 INV2)))
	(1//2)))

(DEFUN HETD(X N)(MUL* (POWER '$%E (MUL* X X (INV 4)))(PARCYL X N)))

(DEFUN ERFCTD
       (X)
       ((LAMBDA(INV2)
	       (MUL* (POWER 2 INV2)
		     (POWER '$%PI (MUL* -1 INV2))
		     (POWER '$%E (MUL* -1 INV2 X X))
		     (PARCYL (MUL* (POWER 2 INV2) X) -1)))
	(1//2)))

(DEFUN EITGAMMAINCOMPLETE(X)(MUL* -1 (GMINC 0 (MUL -1 X))))

(DEFUN SLOMMELTJANDY
       (M N Z)
       ((LAMBDA(ARG)
	       (ADD (LITTLESLOMMEL M N Z)
		    (MUL* (POWER 2 (SUB M 1))
			  (GM (DIV (SUB (ADD M 1) N) 2))
			  (GM (DIV (ADD M N 1) 2))
			  (SUB (MUL* (sin% ARG)(BESS N Z 'J))
			       (MUL* (COS% ARG)(BESS N Z 'Y))))))
	(MUL* (1//2) '$%PI (SUB M N))))

(DEFUN WTM
       (A I1 I2)
       (ADD (MUL* (GM (MUL -2 I2))
		  (MWHIT A I1 I2)
		  (INV (GM (SUB (SUB (1//2) I2) I1))))
	    (MUL* (GM (ADD I2 I2))
		  (MWHIT A I1 (MUL -1 I2))
		  (INV (GM (SUB (ADD (1//2) I2) I1))))))

(DEFUN GAMMAINCOMPLETETW
       (A X)
       (MUL* (POWER X (DIV (SUB A 1) 2))
	     (POWER '$%E (DIV X -2))
	     (WWHIT X (DIV (SUB A 1) 2)(DIV A 2))))

(DEFUN DISTREXECINIT (FUN)
       (COND ((EQUAL (CAAR FUN) 'MPLUS) (DISTREXEC (CDR FUN)))
	     (T (HYPGEO-EXEC FUN VAR PAR))))

(DEFUN DISTRDEFEXECINIT (FUN)
       (COND ((EQUAL (CAAR FUN) 'MPLUS) (DISTRDEFEXEC (CDR FUN)))
	     (T (DEFEXEC FUN VAR))))

(DEFUN DISTREXEC (FUN)
       (COND ((NULL FUN) 0)
	     (T (ADD (HYPGEO-EXEC (CAR FUN) VAR PAR)
		     (DISTREXEC (CDR FUN))))))

(DEFUN DISTRDEFEXEC (FUN)
       (COND ((NULL FUN) 0)
	     (T (ADD (DEFEXEC (CAR FUN) VAR)
		     (DISTRDEFEXEC (CDR FUN))))))

(DEFUN YTJ (I A)
       (SUB (MUL* (BESS I A 'J)(LIST '(%COT) (MUL I '$%PI)))
	    (MUL* (BESS (MUL -1 I) A 'J)(INV (sin% (MUL I '$%PI))))))

(DEFUN DTW (I A)
       (MUL* (POWER 2 (ADD (DIV I 2)(INV 4)))
	     (POWER A (INV -2))
	     (WWHIT (MUL* A A (1//2))
		    (ADD (DIV I 2)(INV 4))
		    (INV 4))))

(DEFUN KBATEMANTW (A)
       ((LAMBDA(IND)
	       (DIV (WWHIT (ADD A A) IND (1//2))
		    (GM (ADD IND 1))))
	(DIV 1 2)))

(DEFUN KTI
       (I A)
       (MUL* '$%PI
	     (1//2)
	     (INV (sin% (MUL I '$%PI)))
	     (SUB (BESS (MUL -1 I) A 'I)(BESS I A 'I))))

(DEFUN 1FACT
       (FLG V)
       (POWER '$%E
	      (MUL* '$%PI
		    '$%I
		    (1//2)
		    (COND (FLG 1)(T (MUL -1 V))))))

(DEFUN BESSY(V Z)(LIST '(MQAPPLY)(LIST '($%Y ARRAY) V) Z))

(DEFUN KMODBES(Z V)(LIST '(MQAPPLY)(LIST '($%K ARRAY) V)  Z))



(DEFUN TAN%(ARG)(LIST  '(%TAN) ARG))

(DEFUN DESJY
       (V Z FLG)
       (COND ((EQ FLG 'J)(BESS V Z 'J))(T (BESSY V Z))))

(DEFUN NUMJORY
       (V SORT Z FLG)
       (COND ((EQUAL SORT 1)
	      (SUB (DESJY (MUL -1 V) Z FLG)
		   (MUL* (POWER '$%E (MUL* -1 V '$%PI '$%I))
			(DESJY V Z FLG))))
	     (T (SUB (MUL* (POWER '$%E (MUL* V '$%PI '$%I))
			  (DESMJY V Z FLG))
		     (DESMJY (MUL -1 V) Z FLG)))))

(DEFUN DESMJY
       (V Z FLG)
       (COND ((EQ FLG 'J)(BESS V Z 'J))(T (MUL -1 (BESSY V Z)))))

(DEFUN HTJORY
       (V SORT Z)
       (COND ((EQUAL (CAAR V) 'RAT)
	      (DIV (NUMJORY V SORT Z 'J)
		   (MUL* '$%I (SIN% (MUL V '$%PI)))))
	     (T (DIV (NUMJORY V SORT Z 'Y)(SIN% (MUL V '$%PI)))))) 
;expert on l.t. expressions containing one bessel function of the first kind

(DEFUN LT1J(REST ARG INDEX)(LT-LTP 'ONEJ REST ARG INDEX))

(DEFUN LT1Y(REST ARG INDEX)(LT-LTP 'ONEY REST ARG INDEX))

(DEFUN LT2J
       (REST ARG1 ARG2 INDEX1 INDEX2)
       (COND ((NOT (EQUAL ARG1 ARG2))
	      'PRODUCT-OF-BESSEL-WITH-DIFFERENT-ARGS)
	     (T (LT-LTP 'TWOJ
			REST
			ARG1
			(LIST 'LIST INDEX1 INDEX2)))))

(DEFUN LT1J^2
       (REST ARG INDEX)
       (LT-LTP 'TWOJ REST ARG (LIST 'LIST INDEX INDEX)))

(DEFUN LT1GAMMAGREEK
       (REST ARG1 ARG2)
       (LT-LTP 'GAMMAGREEK REST ARG2 ARG1))

(DEFUN LT1M(R A I1 I2)(LT-LTP 'ONEM R A (LIST I1 I2)))

(DEFUN LT1P(R A I1 I2)(LT-LTP 'HYP-ONEP R A (LIST I1 I2)))

(DEFUN LT1Q(R A I1 I2)(LT-LTP 'ONEQ R A (LIST I1 I2)))

(DEFUN LT1ERF(REST ARG)(LT-LTP 'ONERF REST ARG NIL))

(DEFUN LT1LOG(REST ARG)(LT-LTP 'ONELOG REST ARG NIL))

(DEFUN LT1KELLIPTIC(REST ARG)(LT-LTP 'ONEKELLIPTIC REST ARG NIL))

(DEFUN LT1E(REST ARG)(LT-LTP 'ONEE REST ARG NIL))

(DEFUN LT1HSTRUVE(REST ARG1 INDEX1)(LT-LTP 'HS REST ARG1 INDEX1))

(DEFUN LT1LSTRUVE(REST ARG1 INDEX1)(LT-LTP 'HL REST ARG1 INDEX1))

(DEFUN LT1S
       (REST ARG1 INDEX1 INDEX2)
       (LT-LTP 'S REST ARG1 (LIST INDEX1 INDEX2)))

(DEFUN HSTF
       (V Z)
       (PROG(D32)
	    (SETQ D32 (DIV 3 2))
	    (RETURN (LIST (MUL* (POWER (DIV Z 2)(ADD V 1))
				(INV (GM D32))
				(INV (GM (ADD V D32)))
				(INV (GM (ADD V D32))))
			  (LIST 'FPQ
				(LIST 1 2)
				(LIST 1)
				(LIST D32 (ADD V D32))
				(MUL* (INV -4) Z Z))))))

(DEFUN LSTF
       (V Z)
       (PROG(HST)
	    (RETURN (LIST (MUL* (POWER '$%E
				      (MUL* (DIV (ADD V 1)
						 -2)
					    '$%PI
					    '$%I))
			       (CAR (SETQ HST
					  (HSTF V
						(MUL* Z
						     (POWER '$%E
							    (MUL*
							     (1//2)
							     '$%I
							     '$%PI)))))))
			  (CADR HST)))))

(DEFUN STF
       (M N Z)
       (LIST (MUL* (POWER Z (ADD M 1))
		   (INV (SUB (ADD M 1) N))
		   (INV (ADD M N 1)))
	     (LIST 'FPQ
		   (LIST 1 2)
		   (LIST 1)
		   (LIST (DIV (SUB (ADD M 3) N) 2)
			 (DIV (ADD* M N 3) 2))
		   (MUL* (INV -4) Z Z))))

(DEFUN LT-LTP
       (FLG REST ARG INDEX)
       (PROG(index1 index2 ARGL CONST L L1)
	    (COND ((OR (ZERP INDEX)
		       (EQ FLG 'ONERF)
		       (EQ FLG 'ONEKELLIPTIC)
		       (EQ FLG 'ONEE)
		       (EQ FLG 'ONEPJAC)
		       (EQ FLG 'D)
		       (EQ FLG 'S)
		       (EQ FLG 'HS)
		       (EQ FLG 'LS)
		       (EQ FLG 'ONEM)
		       (EQ FLG 'ONEQ)
		       (EQ FLG 'GAMMAGREEK)
		       (EQ FLG 'ASIN)
		       (EQ FLG 'ATAN))
		   (GO LABL)))
	    (COND ((OR (EQ FLG 'HYP-ONEP)(EQ FLG 'ONELOG))
		   (GO LABL1)))
	    (cond ((not (consp index)) (go lab)))
	    (COND ((NOT (EQ (CAR INDEX) 'LIST))(GO LAB)))
	    (COND ((ZERP (SETQ INDEX1 (CADR INDEX)))(GO LA)))
	    (COND ((EQ (CHECKSIGNTM (SIMPLIFYA (INV (SETQ INDEX1
							  (CADR
							   INDEX)))
					       NIL))
		       '$NEGATIVE)
		   (SETQ INDEX1
			 (MUL -1 INDEX1)
			 REST
			 (MUL* (POWER -1 INDEX1) REST))))
	    LA
	    (COND ((ZERP (SETQ INDEX2 (CADDR INDEX)))(GO LA2)))
	    (COND ((EQ (CHECKSIGNTM (SIMPLIFYA (INV (SETQ INDEX2
							  (CADDR
							   INDEX)))
					       NIL))
		       '$NEGATIVE)
		   (SETQ INDEX2
			 (MUL -1 INDEX2)
			 REST
			 (MUL* (POWER -1 INDEX2) REST))))
	    LA2
	    (SETQ INDEX (LIST INDEX1 INDEX2))
	    (GO LABL)
	    LAB
	    (COND ((AND (EQ (CHECKSIGNTM (SIMPLIFYA (INV INDEX)
						    NIL))
			    '$NEGATIVE)
			(MAXIMA-INTEGERP INDEX))
		   (SETQ INDEX (MUL -1 INDEX))
		   (SETQ REST (MUL (POWER -1 INDEX) REST))))
	    LABL
	    (SETQ ARGL (F+C ARG))
	    (SETQ CONST (CDRAS 'C ARGL) ARG (CDRAS 'F ARGL))
	    (COND ((NULL CONST)(GO LABL1)))
	    (COND ((NOT (EQ (CHECKSIGNTM (SIMPLIFYA (POWER CONST
							   2)
						    NIL))
			    '$ZERO))
		   (RETURN 'PROP4-TO-BE-APPLIED)))
	    LABL1
	    (COND ((EQ FLG 'ONEY)(RETURN (LTY REST ARG INDEX))))
	    (COND ((SETQ L
			 (D*X^M*%E^A*X ($FACTOR (MUL* REST
						     (CAR (SETQ
							   L1
							   (REF
							    FLG
							    INDEX
							    ARG)))))))
		   (RETURN (%$ETEST L L1))))
	    (RETURN 'OTHER-CA-LATER)))

(DEFUN LTY
       (REST ARG INDEX)
       (PROG(l)
	    (COND ((SETQ L (D*X^M*%E^A*X REST))
		   (RETURN (EXECFY L ARG INDEX))))
	    (RETURN 'FAIL-IN-LTY)))

(DEFUN %$ETEST
       (L L1)
       (PROG(A Q)
	    (SETQ Q (CDRAS 'Q L))
	    (COND ((EQUAL Q 1)(SETQ A 0)(GO LOOP)))
	    (SETQ A (CDRAS 'A L))
	    LOOP
	    (RETURN (SUBSTL (SUB PAR A)
			    PAR
			    (EXECF19 L (CADR L1))))))

(DEFUN REF
       (FLG INDEX ARG)
       (COND ((EQ FLG 'ONEJ)(J1TF INDEX ARG))
	     ((EQ FLG 'TWOJ)(J2TF (CAR INDEX)(CADR INDEX) ARG))
	     ((EQ FLG 'HS)(HSTF INDEX ARG))
	     ((EQ FLG 'HL)(LSTF INDEX ARG))
	     ((EQ FLG 'S)(STF (CAR INDEX)(CADR INDEX) ARG))
	     ((EQ FLG 'ONERF)(ERFTF ARG))
	     ((EQ FLG 'ONELOG)(LOGTF ARG))
	     ((EQ FLG 'ONEKELLIPTIC)(KELLIPTICTF ARG))
	     ((EQ FLG 'ONEE)(ETF ARG))
	     ((EQ FLG 'ONEM)(MTF (CAR INDEX)(CADR INDEX) ARG))
	     ((EQ FLG 'HYP-ONEP)(PTF (CAR INDEX)(CADR INDEX) ARG))
	     ((EQ FLG 'ONEQ)(QTF (CAR INDEX)(CADR INDEX) ARG))
	     ((EQ FLG 'GAMMAGREEK)(GAMMAGREEKTF INDEX ARG))
	     ((EQ FLG 'ONEPJAC)
	      (PJACTF (CAR INDEX)(CADR INDEX)(CADDR INDEX) ARG))
	     ((EQ FLG 'ASIN)(ASINTF ARG))
	     ((EQ FLG 'ATAN)(ATANTF ARG))))

(DEFUN MTF
       (I1 I2 ARG)
       (LIST (MUL (POWER ARG (ADD I2 (1//2)))
		  (POWER '$%E (DIV ARG -2)))
	     (LIST 'FPQ
		   (LIST 1 1)
		   (LIST (ADD* (1//2) I2 (MUL -1 I1)))
		   (LIST (ADD* I2 I2 1))
		   ARG)))

(DEFUN PJACTF
       (N A B X)
       (LIST (MUL* (GM (ADD N A 1))
		   (INV (GM (ADD A 1)))
		   (INV (FACTORIAL N)))
	     (LIST 'FPQ
		   (LIST 2 1)
		   (LIST (MUL -1 N)(ADD* N A B 1))
		   (LIST (ADD A 1))
		   (SUB (1//2)(DIV X 2)))))

(DEFUN ASINTF
       (ARG)
       ((LAMBDA(INV2)
	       (LIST ARG
		     (LIST 'FPQ
			   (LIST 2 1)
			   (LIST INV2 INV2)
			   (LIST (DIV 3 2))
			   (MUL ARG ARG))))
	(1//2)))

(DEFUN ATANTF
       (ARG)
       (LIST ARG
	     (LIST 'FPQ
		   (LIST 2 1)
		   (LIST (INV 2) 1)
		   (LIST (DIV 3 2))
		   (MUL* -1 ARG ARG))))

(DEFUN PTF
       (N M Z)
       (LIST (MUL (INV (GM (SUB 1 M)))
		  (POWER (DIV (ADD Z 1)(SUB Z 1))(DIV M 2)))
	     (LIST 'FPQ
		   (LIST 2 1)
		   (LIST (MUL -1 N)(ADD N 1))
		   (LIST (SUB 1 M))
		   (SUB (1//2)(DIV Z 2)))))

(DEFUN QTF
       (N M Z)
       (LIST (MUL* (POWER '$%E (MUL* M '$%PI '$%I))
		   (POWER '$%PI (1//2))
		   (GM (ADD* M N 1))
		   (POWER 2 (SUB -1 N))
		   (INV (GM (ADD N (DIV 3 2))))
		   (POWER Z (MUL -1 (ADD* M N 1)))
		   (POWER (SUB (MUL Z Z) 1)(DIV M 2)))
	     (LIST 'FPQ
		   (LIST 2 1)
		   (LIST (DIV (ADD* M N 1) 2)
			 (DIV (ADD* M N 2) 2))
		   (LIST (ADD N (DIV 3 2)))
		   (POWER Z -2))))

(DEFUN GAMMAGREEKTF
       (A X)
       (LIST (MUL (INV A)(POWER X A))
	     (LIST 'FPQ
		   (LIST 1 1)
		   (LIST A)
		   (LIST (ADD A 1))
		   (MUL -1 X))))

(DEFUN KELLIPTICTF
       (K)
       ((LAMBDA(INV2)
	       (LIST (MUL INV2 '$%PI)
		     (LIST 'FPQ
			   (LIST  2 1)
			   (LIST INV2 INV2)
			   (LIST 1)
			   (MUL K K))))
	(1//2)))

(DEFUN ETF
       (K)
       ((LAMBDA(INV2)
	       (LIST (MUL INV2 '$%PI)
		     (LIST 'FPQ
			   (LIST  2 1)
			   (LIST (MUL -1 INV2) INV2)
			   (LIST 1)
			   (MUL K K))))
	(1//2)))

(DEFUN ERFTF
       (ARG)
       (LIST (MUL* 2 ARG (POWER '$%PI (INV -2)))
	     (LIST 'FPQ
		   (LIST 1 1)
		   (LIST (1//2))
		   (LIST (DIV 3 2))
		   (MUL* -1 ARG ARG))))

(DEFUN LOGTF
       (ARG)
       (LIST 1
	     (LIST 'FPQ (LIST 2 1)(LIST 1 1)(LIST 2)(SUB 1 ARG))))

(DEFUN J2TF
       (N M ARG)
       (LIST (MUL* (INV (GM (ADD N 1)))
		   (INV (GM (ADD M 1)))
		   (INV (POWER 2 (ADD N M)))
		   (POWER ARG (ADD N M)))
	     (LIST 'FPQ
		   (LIST 2 3)
		   (LIST (ADD* (1//2)(DIV N 2)(DIV M 2))
			 (ADD* 1 (DIV N 2)(DIV M 2)))
		   (LIST (ADD 1 N)(ADD 1 M)(ADD* 1 N M))
		   (MUL -1 (POWER ARG 2)))))

(DEFUN D*X^M*%E^A*X
       (EXP)
       (M2 EXP
	   '((MTIMES)
	     ((COEFFTT)(D FREEVARPAR))
	     ((MEXPT) (X VARP) (M FREEVARPAR))
	     ((MEXPT)
	      (Q EXPOR1P)
	      ((MTIMES)((COEFFTT)(A FREEVARPAR)) (X VARP))))
	   NIL)) 

(DEFUN EXECF19
       (L1 L2)
       (PROG(ANS)
	    (SETQ ANS (EXECARGMATCH (CAR (CDDDDR L2))))
	    (COND ((EQ (CAR ANS) 'DIONIMO)
		   (RETURN (DIONARGHYP L1 L2 (CADR ANS)))))
	    (RETURN 'NEXT-FOR-OTHER-ARGS)))

(DEFUN EXECFY
       (L ARG INDEX)
       (PROG(ANS)
	    (SETQ ANS (EXECARGMATCH ARG))
	    (COND ((EQ (CAR ANS) 'DIONIMO)
		   (RETURN (DIONARGHYP-Y L INDEX (CADR ANS)))))
	    (RETURN 'FAIL-IN-EXECFY)))
;executive  for recognizing the sort of argument

(DEFUN EXECARGMATCH
       (ARG)
       (PROG(L1)
	    (COND ((SETQ L1 (A*X^M+C ($FACTOR ARG)))
		   (RETURN (LIST 'DIONIMO L1))))
	    (COND ((SETQ L1 (A*X^M+C ($EXPAND ARG)))
		   (RETURN (LIST 'DIONIMO L1))))
	    (RETURN 'OTHER-CASE-ARGS-TO-FOLLOW)))

(DEFUN DIONARGHYP
       (L1 L2 ARG)
       (PROG(A M C)
	    (SETQ A
		  (CDRAS 'A ARG)
		  M
		  (CDRAS 'M ARG)
		  C
		  (CDRAS 'C ARG))
	    (COND ((AND (MAXIMA-INTEGERP M)(ZERP C))
		   (RETURN (F19COND A M L1 L2))))
	    (RETURN 'PROP4-AND-AOTHER-CASES-TO-FOLOW)))

 
(DEFUN F+C
       (EXP)
       (M2 EXP
	   '((MPLUS)((COEFFPT)(F HASVAR))((COEFFPP)(C FREEVAR)))
	   NIL))

(DEFUN A*X^M+C
       (EXP)
       (M2 EXP
	   '((MPLUS)
	     ((COEFFPT)
	      (A FREEVAR)
	      ((MEXPT) (X VARP) (M FREEVAR0)))
	     ((COEFFPP) (C FREEVAR)))
	   NIL))

(DEFUN FREEVAR0(M)(COND ((EQUAL M 0) NIL)(T (FREEVAR M))))

(DEFUN ADDARGLIST
       (S K)
       (PROG(K1 L)
	    (SETQ K1 (SUB K 1))
	    LOOP
	    (COND ((ZERP K1)
		   (RETURN (APPEND (LIST (DIV S K)) L))))
	    (SETQ L
		  (APPEND (LIST (DIV (ADD S K1) K)) L)
		  K1
		  (SUB K1 1))
	    (GO LOOP)))

(DEFUN F19COND
       (A M L1 L2)
       (PROG(P Q S D)
	    (SETQ P
		  (CAADR L2)
		  Q
		  (CADADR L2)
		  S
		  (CDRAS 'M L1)
		  D
		  (CDRAS 'D L1)
		  L1
		  (CADDR L2)
		  L2
		  (CADDDR L2))
	    (COND ((AND (NOT (EQ (CHECKSIGNTM (SUB (ADD* P
							 M
							 -1)
						   Q))
				 '$POSITIVE))
			(EQ (CHECKSIGNTM (ADD S 1))
			    '$POSITIVE))
		   (RETURN (MUL D
				(F19P220-SIMP (ADD S 1)
					      L1
					      L2
					      A
					      M)))))
	    (RETURN 'FAILED-ON-F19COND-MULTIPLY-THE-OTHER-CASES-WITH-D)))

(DEFUN F19P220-SIMP
       (S L1 L2 CF K)
       (MUL* (GM S)
	     (INV (POWER PAR S))
	     (HGFSIMP-EXEC (APPEND L1 (ADDARGLIST S K))
			   L2
			   (MUL* CF
				(POWER K K)
				(POWER (INV PAR) K))))) 

(DEFUN J1TF
       (V Z)
       (LIST (MUL* (INV (POWER 2 V))
		   (POWER Z V)
		   (INV (GM (ADD V 1))))
	     (LIST 'FPQ
		   (LIST 0 1)
		   NIL
		   (LIST (ADD V 1))
		   (MUL (INV -4)(POWER Z 2)))))

(DEFUN DIONARGHYP-Y (L INDEX ARG) 
       (PROG (A M C) 
	     (SETQ A (CDRAS 'A ARG) 
		   M (CDRAS 'M ARG) 
		   C (CDRAS 'C ARG))
	     (COND ((AND (ZERP C) (EQUAL M 1.))
		    (RETURN (F2P105V2COND A L INDEX))))
	     (COND ((AND (ZERP C) (EQUAL M (INV 2.)))
		    (RETURN (F50COND A L INDEX))))
	     (RETURN 'FAIL-IN-DIONARGHYP-Y))) 

(DEFUN F2P105V2COND (A L INDEX) 
       (PROG (D M) 
	     (SETQ D (CDRAS 'D L) M (CDRAS 'M L))
	     (SETQ M (ADD M 1.))
	     (COND ((EQ (CHECKSIGNTM ($REALPART (SUB M INDEX)))
			'$POSITIVE)
		    (RETURN (F2P105V2COND-SIMP M INDEX A))))
	     (RETURN 'FAIL-IN-F2P105V2COND))) 

(DEFUN F50COND (A L V) 
       (PROG (D M) 
	     (SETQ D (CDRAS 'D L) 
		   M (CDRAS 'M L) 
		   M (ADD M (INV 2.)) 
		   V (DIV V 2.))
	     (COND
	      ((AND (EQ (CHECKSIGNTM ($REALPART (ADD M V (INV 2.))))
			'$POSITIVE)
		    (EQ (CHECKSIGNTM ($REALPART (SUB (ADD M (INV 2.))
						     V)))
			'$POSITIVE)
		    (NOT (MAXIMA-INTEGERP (MUL (SUB (ADD M M) (ADD V V 1.))
					(INV 2.)))))
	       (SETQ A (MUL A A (INV 4.)))
	       (RETURN (F50P188-SIMP D M V A))))
	     (RETURN 'FAIL-IN-F50COND))) 

(DEFUN F2P105V2COND-SIMP (M V A) 
       (MUL -2.
	    (POWER '$%PI -1.)
	    (GM (ADD M V))
	    (POWER (ADD (MUL A A) (MUL PAR PAR)) (MUL -1. (INV 2.) M))
	    (LEG2FSIMP (SUB M 1.)
		       (MUL -1. V)
		       (MUL PAR
			    (POWER (ADD (MUL A A) (MUL PAR PAR))
				   (INV -2.)))))) 

(DEFUN LEG1FSIMP (M V Z) 
       (MUL (INV (GM (SUB 1. M)))
	    (POWER (DIV (ADD Z 1.) (SUB Z 1.)) (DIV M 2.))
	    (HGFSIMP-EXEC (LIST (MUL -1. V) (ADD V 1.))
			  (LIST (SUB 1. M))
			  (SUB (INV 2.) (DIV Z 2.))))) 

(DEFUN LEG2FSIMP (M V Z) 
       (MUL (POWER '$%E (MUL M '$%PI '$%I))
	    (POWER '$%PI (INV 2.))
	    (GM (ADD M V 1.))
	    (INV (POWER 2. (ADD V 1.)))
	    (INV (GM (ADD V (DIV 3. 2.))))
	    (POWER Z (SUB -1. (ADD M V)))
	    (POWER (SUB (MUL Z Z) 1.) (MUL (INV 2.) M))
	    (HGFSIMP-EXEC (LIST (DIV (ADD M V 1.) 2.)
				(DIV (ADD M V 2.) 2.))
			  (LIST (ADD V (MUL 3. (INV 2.))))
			  (INV (MUL Z Z))))) 

(declare-top (unspecial asinx atanx))
