;; 1. Based on: 105
;; 2. Description: 
;;    LAPLACE
;; 3. Label:
;;    
;; 4. Structural model:
;; 5. Covariate model:
;; 6. Inter-individual variability:
;; 7. Inter-occasion variability:
;; 8. Residual variability:
;; 9. Estimation:

$PROBLEM PK model 1 cmt base

$INPUT ID TIME MDV EVID DV AMT  SEX WT ETN	   
$DATA acop.csv IGNORE=@
$SUBROUTINES ADVAN2 TRANS2

$PK
ET=1
IF(ETN.EQ.3) ET=1.3
KA = THETA(1)
CL = THETA(2)*((WT/70)**THETA(6))*( THETA(7)**SEX) * EXP(ETA(1))
V = THETA(3)*EXP(ETA(2))
SC=V

$THETA
2.3 ; KA ; 1/h ; LIN ; Absorption Rate Constant
80.1 ; CL ; L/h ; LIN ; Clearance 
500 ; V2 ; L ; LIN ; Volume of Distribution
0 FIX  ; RUVp ;  ; LIN ; Proportional Error
4.12    ; RUVa ; ng/mL ; LIN ; Additive Error
0.75    ; CL-WT ;  ; LIN ; Power Scalar CL-WT
0.559   ; CL-SEX ; ; LIN ; Female CL Change

$OMEGA
0.123188     ; iiv CL
0.1537040     ; iiv V2  

$SIGMA	
1 FIX

$ERROR
IPRED = F
IRES = DV-IPRED
W = IPRED*THETA(4) + THETA(5)
IF (W.EQ.0) W = 1
IWRES = IRES/W
Y= IPRED+W*ERR(1)

$EST METHOD=1 INTER MAXEVAL=9999 SIG=3 PRINT=5 NOABORT POSTHOC LAPLACE
$COV PRINT=E UNCONDITIONAL

$TABLE ID TIME DV MDV EVID IPRED IWRES CWRES ONEHEADER NOPRINT FILE=sdtab107
$TABLE ID CL V ONEHEADER NOPRINT FILE=patab107
$TABLE ID SEX ETN ONEHEADER NOPRINT FILE=catab107
$TABLE ID WT ONEHEADER NOPRINT FILE=cotab107
