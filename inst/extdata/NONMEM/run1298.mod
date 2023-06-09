;; 1. Based on: 1297
;; 2. Description:
;;    spearate BEXP for TAP F1BUP for BR
;; 3. Label:
;;    Template Model IV+NB+FB EXPAREL
;; 4. Structural model:
;;    2 Cpt elim w/ Weibull / 1st order Abs separate for EXP and bupivacaine
;; 5. Covariate model:
;;    NONE
;; 6. Inter-individual variability:
;;    KAEXP, MDTEXP, F1EXP, BEXP, RBAEXP
;; 7. Inter-occasion variability:
;;    NONE
;; 8. Residual variability:
;;    Proportional and Additive
;; 9. Estimation:
;;    FOCE
$PROBLEM    Pacira PK Model Framework
$INPUT      STUDY OID ID DV EVID CMT TIME TAFD TAD BLQ DOSE AMT RACEN
            ETHNICN COUNTRYN SEXN HT WT AGE BMI COHORTN PEDS TRT PROCN
            INJLOC MDV IRFLAG BTYPE ADMIN NDOSE EXFLAG VOLEXPAND
            TOTVOL EXPARELDOSE BUPIHCLDOSE TOTBUPIAMT RATE DFLAG
            TRTFLAG STUDYARM RECID LIPODOSE
$DATA      nm_all6.csv IGNORE=@ IGNORE=(BLQ.EQ.1) IGNORE=(EXFLAG.NE.0)
            IGNORE=(STUDY.EQ.121) IGNORE=(TRT.GT.2)
$SUBROUTINE ADVAN13 TOL=10
$ABBREVIATED COMRES=1
$MODEL      COMP (EXPWB,DEFDOSE) COMP (EXPFOA) ; WB=Weibull FOA=First Order Absorption 
            COMP (CENTRAL,DEFOBS) COMP (PERI) COMP (BUPWB)
            COMP(BUPFOA)
$PK       

IF(NEWIND.NE.2) COM(1)=0
IF(EVID.EQ.1) COM(1)=TIME

STRT=1
IF(DOSE.GT.133.AND.STRT.LT.266) STRT=2
IF(DOSE.EQ.266) STRT=3
IF(DOSE.GT.266) STRT=4

; Block Type:     1 = SubQ (SUBC), 2 = Field Block (FB), 3 = Nerve Block (NB); 4 = Intrathecal (IT), 5 = Intravenous (IV)

; Administration: 1 = Abdominal (SUBC), 2 = Flank (SUBC), 3 = Ankle (NB), 4 = Spine (NB), 5 = Spine (FB)
;                 6 = Intercostal (NB), 7 = Hernia (FB), 8 = Knee (FB),  9 = Anus (FB)
;                 10 = Ankle (FB), 11 = Knee (femoral NB), 12 = Shoulder (NB), 13 = CARDIAC (FB)
;                 14 = LUMBAR (IT), 15 = BREAST (pectoralis NB), 16 = ARMVENE (IV), 17 = TAP (NB)
; Note: for Ankle, Knee and Spine surgery, both FB and NB have been studied 

; ===== FLAGS ===== ;

SUBC                = 0
IF(BTYPE.EQ.1) SUBC = 1
FB                  = 0
IF(BTYPE.EQ.2) FB   = 1
NB                  = 0
IF(BTYPE.EQ.3) NB   = 1
IT                  = 0
IF(BTYPE.EQ.4) IT   = 1
IV                  = 0
IF(BTYPE.EQ.5) IV   = 1

; ===== NERVE BLOCK subclass ===== ;
FEM = 0
IF(STUDY.EQ.323) FEM=1
IF(STUDY.EQ.326) FEM=1

; ===== SURGERY TYPE ===== ; 
AB = 0
IF(ADMIN.EQ.1) AB = 1
FL = 0
IF(ADMIN.EQ.2) FL = 1
ANKNB = 0
IF(ADMIN.EQ.3) ANKNB = 1
SPNB = 0
IF(ADMIN.EQ.4) SPNB = 1
SPFB = 0
IF(ADMIN.EQ.5) SPFB = 1
INNB = 0
IF(ADMIN.EQ.6) INNB = 1
HERFB = 0
IF(ADMIN.EQ.7) HERFB = 1
KNFB = 0
IF(ADMIN.EQ.8) KNFB = 1
ANUS = 0
IF(ADMIN.EQ.9) ANUS = 1
ANKFB = 0
IF(ADMIN.EQ.10) ANKFB = 1
KNNB = 0
IF(ADMIN.EQ.11) KNNB = 1
SHNB = 0
IF(ADMIN.EQ.12) SHNB = 1
CAR = 0
IF(ADMIN.EQ.13) CAR = 1
LUM = 0
IF(ADMIN.EQ.14) LUM=1
BR=0
IF(ADMIN.EQ.15) BR=1
ARMV=0
IF(ADMIN.EQ.16) ARMV=1
TAP=0
IF(ADMIN.EQ.17) TAP=1

ST2=0
IF(STUDY.EQ.2) ST2 = 1
ST118=0
IF(STUDY.EQ.118) ST118 = 1
ST120=0
IF(STUDY.EQ.120) ST120 = 1
ST122=0
IF(STUDY.EQ.122) ST122 = 1
ST203=0
IF(STUDY.EQ.203) ST203 = 1
ST323=0
IF(STUDY.EQ.323) ST323 = 1

; bupivacaine free base disposition - 2CMT
TVV1 = THETA(1) 
TVCL = THETA(2)  
TVV2 = THETA(3) 
TVQ  = THETA(4) 

; absorption EXPAREL
TVKAEXP = THETA(5) 
TVMDTEXP= THETA(6) 
TVF1EXP = THETA(7)  
TVBEXP  = THETA(8) 
TVRBAEXP= THETA(9) 

; absorption bupivacaine
TVKABUP = THETA(10) 
TVMDTBUP= THETA(11) 
TVF1BUP = THETA(12)  
TVBBUP  = THETA(13) 
TVRBABUP= THETA(14)

; ===== ERROR ESTIMATES ===== ;

AERR = THETA(15)
PERR = THETA(16)

; ===== allometry model ===== ;

V_WT = THETA(17)
CL_WT = THETA(18)

; ===== covariates ===== ;

KAEXP_NB = THETA(19)
MDTEXP_NB = THETA(20)
F1EXP_NB = THETA(21)
BEXP_NB = THETA(22)
RBAEXP_NB = THETA(23)

KAEXP_FEM = THETA(24)
MDTEXP_FEM = THETA(25)
F1EXP_FEM = THETA(26)
BEXP_FEM = THETA(27)
RBAEXP_FEM = THETA(28)

MDTEXP_ANKNB = THETA(29)
MDTEXP_SPNB = THETA(30)
MDTEXP_SPFB = THETA(31)
MDTEXP_HERFB = THETA(32)
MDTEXP_ANUS = THETA(33)
MDTEXP_ANKFB = THETA(34)

RBAEXP_ANKNB = THETA(35)
RBAEXP_SPNB = THETA(36)
RBAEXP_KNFB = THETA(37)
RBAEXP_HERFB = THETA(38)
RBABUP_HERFB = THETA(39)
KABUP_HERFB = THETA(40)
F1EXP_ANUS = THETA(41)
F1EXP_SPFB = THETA(42)
F1EXP_ANKFB = THETA(43)
F1EXP_INNB = THETA(44)

KAEXP_ANKFB = THETA(45)
KAEXP_SPNB = THETA(46)
KAEXP_ANUS = THETA(47)

BEXP_SPNB = THETA(48)
RBAEXP_CAR = THETA(49)
MDTEXP_BR = THETA(50)

F1EXP_BR = THETA(51)
BEXP_BR = THETA(52)
RBAEXP_BR = THETA(53)

LDOSE_POW_F1=THETA(54)
LDOSE_POW_MDT=THETA(55)

KABUP_SPNB=THETA(64)
F1BUP_KNFB=THETA(56)
MDTBUP_KNFB=THETA(57)
F1BUP_SPNB=THETA(58)
F1BUP_ST2_ANKNB=THETA(59)
RBABUP_ST2_ANKNB=THETA(60)
MTDBUP_ANKNB=THETA(61)
F1BUP_SPFB=THETA(62)
MDTBUP_SPNB=THETA(63)
KABUP_SPNB=THETA(64)
MDTBUP_SPFB=THETA(65)
RBABUP_SPNB=THETA(66)

MDTEXP_TAP = THETA(67)
RBAEXP_ST2 = THETA(68)
RBAEXP_ST118 = THETA(69)
RBAEXP_ST120 = THETA(70)
F1EXP_ST2 = THETA(71)
MDTEXP_ST118 = THETA(72)
RBABUP_TAP = THETA(73)
F1EXP_TAP = THETA(74)

IIV_RBAEXP_FB = THETA(75)
IIV_RBAEXP_NB = THETA(76)

ST203_F1BUP = THETA(77)
ST203_F1EXP = THETA(78)

F1EXP_CAR = THETA(79)
BEXP_SHNB = THETA(80)
MDTEXP_SHNB = THETA(81)

IIV_KNEE_SCALAR = THETA(82)
KNEE=0
IF(KNFB.EQ.1.OR.KNNB.EQ.1) KNEE=1

BEXP_SPFB = THETA(83)
BEXP_ANUS = THETA(84)
BEXP_CAR = THETA(85)
MDTEXP_CAR = THETA(86)

BBUP_KNFB = THETA(87)

EARLY_PERR = 0
IF(TAD.LT.5) EARLY_PERR = THETA(88)
PERR = PERR + EARLY_PERR

MDTBUP_BR = THETA(89)
ST122_MDTEXP_ANKNB = THETA(90)
KAEXP_SHNB = THETA(91)
ST122_F1EXP_ANKNB = THETA(92)
ST122_BEXP_ANKNB = THETA(93)

ST323_F1EXP_KNNB =THETA(94)
BEXP_TAP = THETA(95)
F1BUP_BR = THETA(96)

 F1_DOSE     = (LIPODOSE/266)**LDOSE_POW_F1 - 1 ; centered around zero; F1 additive effect on logit scale 
MDT_DOSE     = (LIPODOSE/266)**LDOSE_POW_MDT - 1 ; centered around zero; MDT additive on logit scale

KA_COV_EXP  = NB * KAEXP_NB +  FEM * KAEXP_FEM + KAEXP_ANKFB*ANKFB + KAEXP_SPNB*SPNB + KAEXP_ANUS*ANUS + KAEXP_SHNB*SHNB
MDT_COV_EXP = NB * MDTEXP_NB + FEM * MDTEXP_FEM + MDTEXP_ANKNB*ANKNB + MDTEXP_SPNB*SPNB + MDTEXP_SPFB*SPFB + MDTEXP_HERFB*HERFB + MDTEXP_ANUS*ANUS +MDTEXP_ANKFB*ANKFB + MDTEXP_BR*BR+MDT_DOSE + MDTEXP_TAP*TAP + ST118*MDTEXP_ST118+MDTEXP_SHNB*SHNB+MDTEXP_CAR*CAR+ST122_MDTEXP_ANKNB*ST122
F1_COV_EXP  = NB * F1EXP_NB +  FEM * F1EXP_FEM  + F1EXP_ANUS*ANUS + F1EXP_SPFB*SPFB + F1EXP_ANKFB*ANKFB + F1EXP_INNB *INNB + F1EXP_BR*BR +  F1_DOSE + ST2*F1EXP_ST2 + TAP*F1EXP_TAP + F1EXP_CAR*CAR + ST122_F1EXP_ANKNB*ST122 + ST203_F1EXP*ST203+ST323*ST323_F1EXP_KNNB
B_COV_EXP   = NB * BEXP_NB +   FEM * BEXP_FEM   + BEXP_SPNB*SPNB + BEXP_BR*BR + BEXP_SHNB*SHNB +BEXP_SPFB*SPFB+BEXP_ANUS*ANUS+BEXP_CAR*CAR+ST122_BEXP_ANKNB*ST122 + BEXP_TAP*TAP
RBA_COV_EXP = NB * RBAEXP_NB + FEM * RBAEXP_FEM + RBAEXP_ANKNB*ANKNB + RBAEXP_SPNB*SPNB + RBAEXP_KNFB*KNFB + RBAEXP_HERFB*HERFB + RBAEXP_CAR*CAR + RBAEXP_BR*BR + ST2*RBAEXP_ST2+ST118*RBAEXP_ST118+ST120*RBAEXP_ST120

KA_COV_BUP  = SPNB*KABUP_SPNB + KABUP_HERFB*HERFB
F1_COV_BUP  = KNFB*F1BUP_KNFB + SPNB*F1BUP_SPNB + F1BUP_ST2_ANKNB*ST2 + F1BUP_SPFB*SPFB + ST203_F1BUP*ST203 + F1BUP_BR*BR
MDT_COV_BUP = KNFB*MDTBUP_KNFB + MTDBUP_ANKNB*ANKNB + SPNB*MDTBUP_SPNB + SPFB*MDTBUP_SPFB + MDTBUP_BR*BR
B_COV_BUP   = BBUP_KNFB*KNFB
RBA_COV_BUP = RBABUP_ST2_ANKNB*ST2 + RBABUP_SPNB*SPNB + RBABUP_TAP*TAP + RBABUP_HERFB*HERFB

; ===== PARAMETERIZATIONS ===== ;

MU1 = TVV1 ; V1
MU2 = TVCL ; CL
MU3 = TVV2 ; V2 
MU4 = TVQ  ; Q
MU5 = TVKAEXP  +  KA_COV_EXP; KAEXP 
MU6 = TVMDTEXP + MDT_COV_EXP; MDTEXP
MU7 = TVF1EXP  +  F1_COV_EXP; F1EXP 
MU8 = TVBEXP   +   B_COV_EXP; BEXP
MU9 = TVRBAEXP + RBA_COV_EXP; RBAEXP
MU10 = TVKABUP   + KA_COV_BUP ; KABUP 
MU11 = TVMDTBUP  + MDT_COV_BUP; MDTBUP
MU12 = TVF1BUP   +  F1_COV_BUP; F1BUP 
MU13 = TVBBUP    +   B_COV_BUP; BBUP
MU14 = TVRBABUP  + RBA_COV_BUP; RBABUP

V1      = EXP(MU1 + ETA(1)) * (WT/80) ** V_WT
CL      = EXP(MU2 + ETA(2)) * (WT/80) ** CL_WT
V2      = EXP(MU3 + ETA(3)) * (WT/80) ** V_WT
Q       = EXP(MU4 + ETA(4)) * (WT/80) ** CL_WT
KAEXP   = EXP(MU5 + ETA(5))
MDTEXP  = EXP(MU6 + ETA(6))
F1EXP   = EXP(MU7 + ETA(7))
BEXP    = EXP(MU8 + ETA(8)) + 1
RBAEXP  =     MU9 + ETA(9)*(IIV_RBAEXP_FB*FB+IIV_RBAEXP_NB*NB+KNEE*IIV_KNEE_SCALAR)
KABUP   = EXP(MU10 + ETA(10))
MDTBUP  = EXP(MU11 + ETA(11))
F1BUP   = EXP(MU12 + ETA(12))
BBUP    = EXP(MU13 + ETA(13)) + 1
RBABUP  =    (MU14 + ETA(14))

; ===== DOSE FRACTIONATION MODEL ===== ;

F1   = (F1EXP/(1+F1EXP)) * RBAEXP 
F2   = (1 -  F1/RBAEXP)  * RBAEXP
F5   = (F1BUP/(1+F1BUP)) * RBABUP 
F6   = (1 -  F5/RBABUP)  * RBABUP
IF(F1.LE.0) F1=1
IF(F2.LE.0) F2=1
IF(F5.LE.0) F5=1
IF(F6.LE.0) F6=1


; ===== DIFFERENTIAL EQUATIONS ===== ;

$DES 
TDUMMY = COM(1) 
TSTAR=T-COM(1)
IF(TSTAR.LT.0) TSTAR=0

KDEXP = BEXP/MDTEXP*(TSTAR/MDTEXP)**(BEXP-1) 
KDBUP = BBUP/MDTBUP*(TSTAR/MDTBUP)**(BBUP-1) 
IF(KDEXP.GT.100) KDEXP=100
IF(KDBUP.GT.100) KDBUP=100
     
C3 = A(3)/V1
C4 = A(4)/V2 

DADT(1) = -KDEXP*A(1)
DADT(2) = -KAEXP*A(2)          
DADT(3) =  KDEXP*A(1) + KAEXP*A(2) + KDBUP*A(5) + KABUP*A(6) - (CL/V1)*A(3) - Q*(C3-C4)
DADT(4) =                                                                     Q*(C3-C4)
DADT(5) = -KDBUP*A(5)
DADT(6) = -KABUP*A(6)          

; ===== ERROR MODEL =====;

$ERROR   
IPRED   = A(3)/V1
W       = sqrt(AERR**2 + PERR**2 * IPRED**2)
Y       = IPRED+W*EPS(1)
IRES    = DV - IPRED
IWRES   = IRES/W

; ====== SIMULATION BLOCK ===== ;

IF(ICALL.EQ.4) THEN
 IF(Y.LE.0.1) Y = .1
ENDIF

; ===== INITIAL ESTIMATES ===== ;

$THETA  3.66782 FIX ; V1; 1; LOG ; L
$THETA  3.64869 FIX ; CL; 2; LOG ; L/h
$THETA  3.99214 FIX ; V2; 3; LOG ; L
$THETA  3.73929 FIX ; Q; 4; LOG ; L/h
$THETA  (-5,0.570332,3) ; KAEXP; 5
$THETA  (0.1,3.71972,5) ; MDTEXP; 6
$THETA  (-5,3.366,5) ; F1EXP; 7
$THETA  (-2,-0.613705,1) ; BEXP; 8
$THETA  (0,2.51872,3) ; RBAEXP; 9
$THETA  (-3,0.135314,3) ; KABUP; 10
$THETA  (-1,3.08962,6) ; MDTBUP; 11
$THETA  (-10,1.10146,8) ; F1BUP; 12
$THETA  (-5,-0.99235,1.5) ; BBUP; 13
$THETA  (-2,2.21109,3) ; RBABUP; 14
$THETA  (0,2.83483,10) ; AERR; 15
$THETA  (0,0.209509,0.5) ; PERR; 16
$THETA  1 FIX ; V allometry - weight; 17
$THETA  0 FIX ; CL allometry - weight; 18
 -0.351923 ; KA_NB; 19
 0 FIX ; MDT_NB; 20
 -0.395746 ; F1_NB; 21
 0.179487 ; B_NB; 22
 0.669855 ; RBA_NB; 23
 -3.01265 ; KA_FEM; 24
 0.760767 ; MDT_FEM; 25
 -0.674964 ; F1_FEM; 26
 0.991774 ; B_FEM; 27
 3.06571 ; RBA_FEM; 28
 0.451144 ; MDTEXP_ANKNB; 29
 0 FIX ; MDTEXP_SPNB; 30
 -0.46448 ; MDTEXP_SPFB; 31
 -0.147077 ; MDTEXP_HERFB; 32
 -0.441692 ; MDTEXP_ANUS; 33
 0.260877 ; MDTEXP_ANKFB; 34
 0 FIX ; RBAEXP_ANKNB; 35
 -1.484 FIX ; RBAEXP_SPNB; 36
 0 FIX ; RBAEXP_KNFB; 37
 -0.272803 ; RBAEXP_HERFB; 38
 -0.319896 ; RBABUP_HERFB; 39
 0.409257 ; KABUP_HERFB; 40
 -0.965742 ; F1EXP_ANUS; 41
 -0.347749 ; F1EXP_SPFB; 42
 -0.776743 ; F1EXP_ANKFB; 43
 -0.464203 ; F1EXP_INNB; 44
 -1.89813 ; KAEXP_ANKFB; 45
 -1.48836 ; KAEXP_SPNB; 46
 0.63599 ; KAEXP_ANUS; 47
 -0.232555 ; BEXP_SPNB; 48
 2.39745 ; RBAEXP_CAR; 49
 0.131069 ; MDTEXP_BR; 50
 (-2,-0.469621,3) ; F1EXP_BR; 51
 0 FIX ; BEXP_BR; 52
 0 FIX ; RBAEXP_BR; 53
 (-1,0.650806,1) ; F1EXP_DOSE; 54
 (-1,0.280833,1) ; MDTEXP_DOSE; 55
$THETA  (-1,2.12665,5) ; F1BUP_KNFB; 56
$THETA  (-1,0.254342,5) ; MDTBUP_KNFB; 57
$THETA  (-3,-1.48812,2) ; F1BUP_SPNB; 58
$THETA  (-4,-1.0214,1) ; ST2_ANKNB_F1BUP; 59
$THETA  (-4,-1.09386,1) ; ST2_ANKNB_RBABUP; 60
$THETA  (-1,0.191069,5) ; MDTBUP_ANKNB; 61
$THETA  0 FIX ; F1BUP_SPFB; 62
$THETA  (-5,-0.56,2) FIX ; MDTBUP_SPNB; 63
$THETA  (-5,-0.717195,2) ; KABUP_SPNB; 64
$THETA  (-5,-0.49038,2) ; MDTBUP_SPFB; 65
$THETA  -0.530133 FIX ; RBABUP_SPNB; 66
$THETA  0.563285 ; MDTEXP_TAP; 67
$THETA  -1.95144 ; RBAEXP_ST2; 68
$THETA  -1.12712 FIX ; RBAEXP_ST118; 69
$THETA  -0.636002 FIX ; RBAEXP_ST120; 70
$THETA  -0.40486 ; F1EXP_ST2; 71
$THETA  -0.167351 ; MDTEXP_ST118; 72
$THETA  -1.23802 ; RBABUP_TAP; 73
$THETA  0.694525 FIX ; F1EXP_TAP; 74
$THETA  0.954398 ; IIV_RBAEXP_FB; 75
$THETA  1.43589 ; IIV_RBAEXP_NB; 76
$THETA  0.436359 ; ST203_F1BUP; 77
$THETA  1.10639 ; ST203_F1EXP; 78
$THETA  0.475375 ; F1EXP_CAR; 79
$THETA  0.417444 ; BEXP_SHNB; 80
$THETA  0.283592 ; MDTEXP_SHNB; 81
$THETA  0.836469 ; IIV_RBA_KNEE_SCALAR; 82
$THETA  -0.224963 ; BEXP_SPFB; 83
$THETA  -0.531897 ; BEXP_ANUS; 84
$THETA  0.367499 ; BEXP_CAR; 85
$THETA  0.222756 ; MDTEXP_CAR; 86
$THETA  0.555537 ; BBUP_KNFB; 87
$THETA  (0,0.0920383,1) ; EARLY_PERR; 88
$THETA  -0.894307 ; MDTBUP_BR; 89
$THETA  0.194327 ; ST122_MDTEXP_ANKNB; 90
$THETA  -2.18697 ; KAEXP_SHNB; 91
$THETA  1.30762 ; ST122_F1EXP_ANKNB; 92
$THETA  0.217745 ; ST122_BEXP_ANKNB; 93
$THETA  1.38821 ; ST323_F1EXP_KNNB; 94
$THETA  0.45 ; BEXP_TAP; 95
$THETA  -0.3; F1BUP_BR; 96
$OMEGA  0  FIX  ;     IIV_V1
$OMEGA  0  FIX  ;     IIV_CL
$OMEGA  0  FIX  ;     IIV_V2
$OMEGA  0  FIX  ;      IIV_Q
$OMEGA  0.426897  ;  IIV_KAEXP
$OMEGA  0.051008  ; IIV_MDTEXP
$OMEGA  0.417867  ;  IIV_F1EXP
$OMEGA  0.105034  ;   IIV_BEXP
$OMEGA  1  FIX  ; IIV_RBAEXP
$OMEGA  0.191193  ;  IIV_KABUP
$OMEGA  0.0647941  ; IIV_MDTBUP
$OMEGA  0.519368  ;  IIV_F1BUP
$OMEGA  0.0724198  ;   IIV_BBUP
$OMEGA  0.76575  ; IIV_RBABUP
$SIGMA  1.0  FIX  ;  SIGMA_RES
$ESTIMATION METHOD=COND INTER NSIG=3 SIGL=9 MAXEVALS=9999 PRINT=1
            NOABORT
$COVARIANCE PRINT=E UNCONDITIONAL MATRIX=S
$TABLE      ID TIME TAD TAFD PRED IPRED RES IRES WRES IWRES CWRES DV
            EVID TSTAR TDUMMY ONEHEADER NOAPPEND NOPRINT
            FILE=sdtab1298
$TABLE      ID OID DOSE V1 CL V2 Q KAEXP MDTEXP F1EXP BEXP RBAEXP
            KAEXP MDTBUP F1BUP BBUP RBABUP SUBC FB NB IV IT KDEXP
            KDBUP AERR PERR ETAS(1:LAST) STUDY DOSE RACEN ETHNICN SEXN
            COUNTRYN HT WT BMI AGE COHORTN PROCN INJLOC BTYPE ADMIN
            MDV TRTFLAG TRT IRFLAG BLQ PEDS NDOSE EXFLAG VOLEXPAND
            TOTVOL EXPARELDOSE BUPIHCLDOSE TOTBUPIAMT LIPODOSE RATE
            DFLAG STUDYARM RECID ONEHEADER NOAPPEND NOPRINT
            FILE=patab1298

