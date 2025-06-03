;; 1. Based on: 0
;; 2. Description: 
;;    Binomial Model Example with Decay as f(DOSE)

$PROB Binomial Model Example
$DATA  binom.csv IGNORE=@
$INPUT ID TIME DOSE DV
$PRED

BASEP = EXP(THETA(1))
BASEP = BASEP/(1+BASEP) * EXP(ETA(1))

TSLP = EXP(THETA(2)+ETA(2))
DSLP = EXP(THETA(3)+ETA(3))

Y = BASEP * (1-DSLP*(DOSE/125)*(1-(EXP(-TSLP*TIME)))) * (1 + EPS(1))

$THETA
-0.25 ; BASEP ;     ; LOGIT ; Baseline 
-0.7  ; TLSP  ; 1/h ; LOG   ; Time slope  
-1.8  ; DLSP  ; 1/h ; LOG   ; Dose slope  

$OMEGA
0.09 ; IIV BASE
0.09 ; IIV TSLP
0.09 ; IIV DSLP

$SIGMA 0.1; Add RUV

$ESTIM METHOD=COND PRINT=5
$COV UNCONDITIONAL
$TABLE ID TIME DOSE DV PRED CWRES BASEP TSLP DSLP ONEHEADER NOPRINT FILE=sdtab1
