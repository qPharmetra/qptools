;Model Desc: Two Compartment model with Clearance and central volume modeled with covariates age and gender
;Project Name: nm7examples
;Project ID: NO PROJECT DESCRIPTION
$PROBLEM    RUN# example2 (from sampc)
;; 1. Based on:1

;; 2. Description:

;;    Covariate Model CL and V with Gender and Age

;; 3. Label:

;;    2CMT

;; 4. Structural model:

;;    ADVAN3 TRANS4

;; 5. Covariate model:

;;    None

;; 6. Inter-individual variability:

;;    CL, V1, Q, V2

;; 7. Inter-occasion variability:

;;    None

;; 8. Residual variability:

;;    proportional

;; 9. Estimation:

;;    FOCE INTER, SAEM, BAYES, IMP
$INPUT      C SET ID JID TIME DV=CONC AMT=DOSE RATE EVID MDV CMT GNDR
            AGE
$DATA       example2.csv IGNORE=C
$SUBROUTINE ADVAN3 TRANS4
$PK

;;; V1GNDR-DEFINITION START
IF(GNDR.EQ.1) V1GNDR = 1  ; Most common
IF(GNDR.EQ.0) V1GNDR = ( 1 + THETA(9))
;;; V1GNDR-DEFINITION END


;;; V1AGE-DEFINITION START
   V1AGE = ((AGE/33.72)**THETA(8))
;;; V1AGE-DEFINITION END

;;; V1-RELATION START
V1COV=V1AGE*V1GNDR
;;; V1-RELATION END


;;; CLGNDR-DEFINITION START
IF(GNDR.EQ.1) CLGNDR = 1  ; Most common
IF(GNDR.EQ.0) CLGNDR = ( 1 + THETA(7))
;;; CLGNDR-DEFINITION END


;;; CLAGE-DEFINITION START
   CLAGE = ((AGE/33.72)**THETA(6))
;;; CLAGE-DEFINITION END

;;; CL-RELATION START
CLCOV=CLAGE*CLGNDR
;;; CL-RELATION END


TVCL=THETA(1)

TVCL = CLCOV*TVCL
TVV1=THETA(2)

TVV1 = V1COV*TVV1
TVQ=THETA(3)
TVV2=THETA(4)
CL=TVCL*DEXP(ETA(1))
V1=TVV1*DEXP(ETA(2))
Q=TVQ*DEXP(ETA(3))
V2=TVV2*DEXP(ETA(4))
S1=V1

STRT = 0
IF(ID.GT.200) STRT = 1

$ERROR 
CALLFL=0
; Option to model the residual error coefficient in THETA(11), rather than in SIGMA.
SDSL=THETA(5)
W=F*SDSL
Y = F + W*EPS(1)
IPRED=F
IWRES=(DV-F)/W

;Initial THETAs
$THETA  (0,11.9862) ; [CL]
 (0,6.23847) ; [V1]
 (0,2.00081) ; [Q]
 (0,10.0002) ; [V2]
 0.10024 ; [SDSL]
;Initial OMEGAs
$THETA  (-1000000,-0.382492,1000000) ; CLAGE1
$THETA  (-1,-0.72333,5) ; CLGNDR1
$THETA  (-1000000,0.252666,1000000) ; V1AGE1
$THETA  (-1,0.0719961,5) ; V1GNDR1
$OMEGA  BLOCK(4)
 0.0412284  ;    [varCL]
 -0.011996 0.0126616  ;    [varV1]
 0.000936897 0.00020545 0.00978679  ;     [varQ]
 -0.00273539 0.00147804 0.0018355 0.00950935  ;    [varV2]
;SIGMA is 1.0 fixed, serves as unscaled variance for EPS(1).
; residual error scaling.
$SIGMA  1.0  FIX
$ESTIMATION METHOD=COND INTERACTION MAXEVAL=9999 NSIG=2 SIGL=14
            PRINT=5 NOABORT NOPRIOR=1
$COVARIANCE MATRIX=R UNCONDITIONAL PRINT=E
$TABLE      ID TIME DV IPRED PRED RES WRES CPRED CWRES EPRED ERES
            EWRES EVID NOAPPEND ONEHEADER
            FILE=example3.sdtab
            NOPRINT
$TABLE      ID CL V1 Q V2 ETA1 ETA2 ETA3 ETA4 NOAPPEND ONEHEADER
            NOPRINT
            FILE=example3.patab
$TABLE      ID AGE GNDR NOAPPEND ONEHEADER NOPRINT
			FILE=example3.catab

