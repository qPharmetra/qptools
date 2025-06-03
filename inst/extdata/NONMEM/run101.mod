;; 1. Based on: 100
;; 2. Description: 
;;    PK model 1 cmt - WT-CL 
;; 3. Label:
;;    
;; 4. Structural model:
;; 5. Covariate model:
;; 6. Inter-individual variability:
;; 7. Inter-occasion variability:
;; 8. Residual variability:
;; 9. Estimation:


$PROBLEM PK model 

$INPUT ID TIME MDV EVID DV AMT  SEX WT ETN	   
$DATA acop.csv IGNORE=@
$SUBROUTINES ADVAN2 TRANS2

$PK
ET=1
IF(ETN.EQ.3) ET=1.3
KA = THETA(1)
CL = THETA(2)*(WT/70)**THETA(6)* EXP(ETA(1))
V = THETA(3)*EXP(ETA(2))
SC=V


$THETA
(0, 2)  ; KA ; 1/h ; LIN ; Absorption Rate Constant
(0, 20)  ; CL ; L/h ; LIN ; Clearance 
(0, 100) ; V2 ; L ; LIN ; Volume of Distribution
(0.02)  ; RUVp ;  ; LIN ; Proportional Error
(1)     ; RUVa ; ng/mL ; LIN ; Additive Error
(0,1)   ; CL-WT ;  ; LIN ; Power Scalar CL-WT

$OMEGA
0.05    ; iiv CL
0.2     ; iiv V2  

$SIGMA	
1 FIX

$ERROR
IPRED = F
IRES = DV-IPRED
W = IPRED*THETA(4) + THETA(5)
IF (W.EQ.0) W = 1
IWRES = IRES/W
Y= IPRED+W*ERR(1)

$EST METHOD=SAEM INTER NBURN=3000 NITER=500 PRINT=100
$EST METHOD=IMP INTER EONLY=1 NITER=5 ISAMPLE=3000 PRINT=1 SIGL=8 NOPRIOR=1  
$EST METHOD=1 INTER MAXEVAL=9999 SIG=3 PRINT=5 NOABORT POSTHOC
$COV PRINT=E UNCONDITIONAL

$TABLE ID TIME DV MDV EVID IPRED IWRES CWRES ONEHEADER NOPRINT FILE=sdtab101
$TABLE ID CL V KA ETAS(1:LAST) ONEHEADER NOPRINT FILE=patab101
$TABLE ID SEX ETN ONEHEADER NOPRINT FILE=catab101
$TABLE ID WT ONEHEADER NOPRINT FILE=cotab101
