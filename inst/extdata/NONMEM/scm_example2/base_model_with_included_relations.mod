;Model Desc: Two Compartment model with Clearance and central volume modeled with covariates age and gender
;Project Name: nm7examples
;Project ID: NO PROJECT DESCRIPTION
$PROBLEM    RUN# example2 (from sampc)
;; 1. Based on:0

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
TVCL=THETA(1)
TVV1=THETA(2)
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
$THETA  (0,1.0) ; [CL]
 (0,1.0) ; [V1]
 (0,1.0) ; [Q]
 (0,1.0) ; [V2]
 0.3 ; [SDSL]
;Initial OMEGAs
$OMEGA  BLOCK(4)
 0.5  ;    [varCL]
 0.001 0.5  ;    [varV1]
 0.001 0.001 0.5  ;     [varQ]
 0.001 0.001 0.001 0.5  ;    [varV2]
;SIGMA is 1.0 fixed, serves as unscaled variance for EPS(1).
; residual error scaling.
$SIGMA  1.0  FIX
$ESTIMATION METHOD=COND INTERACTION MAXEVAL=9999 NSIG=2 SIGL=14
            PRINT=5 NOABORT NOPRIOR=1
$COVARIANCE MATRIX=R UNCONDITIONAL PRINT=E
$TABLE      ID TIME DV IPRED PRED RES WRES CPRED CWRES EPRED ERES
            EWRES EVID NOAPPEND ONEHEADER FILE=example2.sdtab NOPRINT
$TABLE      ID CL V1 Q V2 ETA1 ETA2 ETA3 ETA4 NOAPPEND ONEHEADER
            NOPRINT FILE=example2.patab
$TABLE      ID AGE GNDR NOAPPEND ONEHEADER NOPRINT FILE=example2.catab

