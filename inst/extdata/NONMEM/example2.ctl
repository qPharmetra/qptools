;Model Desc: Two Compartment model with Clearance and central volume modeled with covariates age and gender
;Project Name: nm7examples
;Project ID: NO PROJECT DESCRIPTION

$PROB RUN# example2 (from sampc)
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
$INPUT C SET ID JID TIME DV=CONC AMT=DOSE RATE EVID MDV CMT GNDR AGE
$DATA example2.csv IGNORE=C
$SUBROUTINES ADVAN3 TRANS4

;NTHETA=number of Thetas to be estimated
;NETA=number of Etas to be estimated (and to be described by NETAxNETA OMEGA matrix)
;NTHP=number of thetas which have a prior
;NETP=number of Omegas with prior
;Prior information is important for MCMC Bayesian analysis, not necessary for maximization
; methods
; In this example, only the OMEGAs have a prior distribution, the THETAS do not.
; For Bayesian methods, it is most important for at least the OMEGAs to have a prior,
; even an uninformative one, to stabilize the analysis. Only if the number of subjects
; exceeds the OMEGA dimension number by at least 100, then you may get away without
; priors on OMEGA for BAYES analysis.
$PRIOR NWPRI NTHETA=11, NETA=4, NTHP=0, NETP=4, NPEXP=1

$PK
; LCLM=log transformed clearance, male
LCLM=THETA(1)
;LCLF=log transformed clearance, female.
LCLF=THETA(2)
; CLAM=CL age slope, male
CLAM=THETA(3)
; CLAF=CL age slope, female
CLAF=THETA(4)
; LV1M=log transformed V1, male
LV1M=THETA(5)
; LV1F=log transformed V1, female
LV1F=THETA(6)
; V1AM=V1 age slope, male
V1AM=THETA(7)
; V1AF=V1 age slope, female
V1AF=THETA(8)
; LAGE=log transformed age
LAGE=DLOG(AGE)
;Mean of ETA1, the inter-subject deviation of Clearance, is ultimately modeled as linear function
;of THETA(1) to THETA(4).  Relating thetas to Mus by linear functions is not essential for ITS,
;IMP, or IMPMAP methods, but is very helpful for MCMC methods such as SAEM and BAYES.
MU_1=(1.0-GNDR)*(LCLM+LAGE*CLAM) + GNDR*(LCLF+LAGE*CLAF)
;Mean of ETA2, the inter-subject deviation of V1, is ultimately modeled as linear function of
; THETA(5) to THETA(8)
MU_2=(1.0-GNDR)*(LV1M+LAGE*V1AM) + GNDR*(LV1F+LAGE*V1AF)
MU_3=THETA(9)
MU_4=THETA(10)
CL=DEXP(MU_1+ETA(1))
V1=DEXP(MU_2+ETA(2))
Q=DEXP(MU_3+ETA(3))
V2=DEXP(MU_4+ETA(4))
S1=V1

STRT = 0
IF(ID.GT.200) STRT = 1

$ERROR
CALLFL=0
; Option to model the residual error coefficient in THETA(11), rather than in SIGMA.
SDSL=THETA(11)
W=F*SDSL
Y = F + W*EPS(1)
IPRED=F
IWRES=(DV-F)/W

;Initial THETAs
$THETA
( 0.7 ) ;[LCLM]
( 0.7 ) ;[LCLF]
( 2 )   ;[CLAM]
( 2.0);[CLAF]
( 0.7 ) ;[LV1M]
( 0.7 ) ;[LV1F]
( 2.0 )   ;[V1AM]
( 2.0 )   ;[V1AF]
( 0.7 ) ;[MU_3]
(  0.7 );[MU_4]
( 0.3 )     ;[SDSL]



;Initial OMEGAs
$OMEGA BLOCK(4)
0.5  ;[p]
0.001  ;[f]
0.5  ;[p]
0.001 ;[f]
0.001 ;[f]
0.5  ;[p]
0.001 ;[f]
0.001 ;[f]
0.001 ;[f]
0.5 ;[p]

; Degrees of freedom to OMEGA prior matrix:
$THETA 4 FIX
; Prior OMEGA matrix
$OMEGA BLOCK(4)
0.01 FIX 
0.0  0.01 
0.0 0.0 0.01 
0.0 0.0 0.0 0.01

;SIGMA is 1.0 fixed, serves as unscaled variance for EPS(1).  THETA(11) takes up the
; residual error scaling.
$SIGMA 
(1.0 FIXED)

; The first analysis is iterative two-stage.  Note that the GRD specification is THETA(11) is a 
; Sigma-like parameter.  This will allow NONMEM to
; make efficient gradient evaluations for THETA(11), which is useful for later IMP,IMPMAP, and
; SAEM methods, but has no impact on ITS and BAYES methods.
$EST METHOD=ITS INTERACTION FILE=psn.ext NITER=300 NSIG=2 PRINT=5 NOABORT
     SIGL=8 NOPRIOR=1 CTYPE=3 GRD=TS(11)
; Results of ITS serve as initial parameters for the IMP method.
$EST METHOD=IMP INTERACTION EONLY=0  MAPITER=0 NITER=50 ISAMPLE=300 PRINT=1 SIGL=8
; The results of IMP are used as the initial values for the SAEM method.
$EST METHOD=SAEM NBURN=3000 NITER=2000 PRINT=10 ISAMPLE=2
     ISAMPLE=1 ISAMPLE_M1=1 ISAMPLE_M2=1 ISAMPLE_M3=1
     CTYPE=3 CITER=10 CALPHA=0.05
; After the SAEM method, obtain good estimates of the marginal density (objective function),
; along with good estimates of the standard errors.
$EST METHOD=IMP INTERACTION EONLY=1 NITER=5 ISAMPLE=3000 PRINT=1 SIGL=8 SEED=123334
     CTYPE=3 CITER=10 CALPHA=0.05
; The Bayesian analysis is performed. 
$EST METHOD=BAYES INTERACTION NBURN=10000 NITER=1000 PRINT=100 NOPRIOR=0
     CTYPE=3 CITER=10 CALPHA=0.05
; Just for old-times sake, lets see what the traditional FOCE method will give us.  
; And, remember to introduce a new FILE, so its results wont append to our Bayesian FILE.
$EST  METHOD=COND INTERACTION MAXEVAL=9999 NSIG=2 SIGL=14 PRINT=5 NOABORT NOPRIOR=1
$COV MATRIX=R UNCONDITIONAL PRINT=E

$TABLE ID TIME DV IPRED PRED RES WRES CPRED CWRES EPRED ERES EWRES EVID NOAPPEND ONEHEADER 
 FILE=example2.sdtab NOPRINT
$TABLE ID CL V1 Q V2 ETA1 ETA2 ETA3 ETA4 NOAPPEND ONEHEADER NOPRINT FILE=example2.patab
$TABLE ID AGE GNDR NOAPPEND ONEHEADER NOPRINT FILE=example2.catab