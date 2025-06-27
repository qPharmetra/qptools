---
title: "Introduction to qptools"
author: "Klaas Prins & Tim Bergsma"
output: 
  html_document:
    toc: true
    toc_float: true
    code_folding: show
    keep_md : TRUE
    fig.width: 8
    fig.height: 6
    theme: united
    highlight: tango
vignette: >
  %\VignetteIndexEntry{An Introduction to qptools}
  %\VignetteEncoding{UTF-8}
  %\VignetteEngine{knitr::rmarkdown}
editor_options: 
  chunk_output_type: console
---



# Set things up


``` r
library(qptools) 
library(nonmemica)
library(pmxTools)
```

```
## Loading required package: patchwork
```

```
## 
## Attaching package: 'pmxTools'
```

```
## The following object is masked from 'package:qptools':
## 
##     get_est_table
```

``` r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

``` r
library(magrittr)
library(yamlet)
```

```
## 
## Attaching package: 'yamlet'
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

``` r
library(wrangle)
```

```
## 
## Attaching package: 'wrangle'
```

```
## The following object is masked from 'package:nonmemica':
## 
##     safe_join
```

```
## The following object is masked from 'package:qptools':
## 
##     safe_join
```

``` r
options(qpExampleDir = system.file(package="qptools") %>% file.path(., "extdata/NONMEM")) 

getOption("qpExampleDir")
```

```
## [1] "C:/project/devel/qptools/inst/extdata/NONMEM"
```

``` r
getOption("qpExampleDir") %>% dir
```

```
##  [1] "acop.csv"        "binom.csv"       "bootstrap"       "example1"       
##  [5] "example1.csv"    "example1.ctl"    "example1.lst"    "example2"       
##  [9] "example2.csv"    "example2.ctl"    "example2.lst"    "example3"       
## [13] "example3.csv"    "example3.ctl"    "example3.lst"    "run1"           
## [17] "run1.lst"        "run1.mod"        "run100"          "run100.lst"     
## [21] "run100.mod"      "run101"          "run101.lst"      "run101.mod"     
## [25] "run102"          "run102.lst"      "run102.mod"      "run103"         
## [29] "run103.lst"      "run103.mod"      "run105"          "run105.lst"     
## [33] "run105.mod"      "run105bs.mod"    "run106"          "run106.lst"     
## [37] "run106.mod"      "run107"          "run107.lst"      "run107.mod"     
## [41] "run108"          "run108.lst"      "run108.mod"      "scm_config2.scm"
## [45] "scm_example2"
```

# Show LIBRARY functions

Forces library calls to be based on declared version or higher, or R will stop.


``` r
LIBRARY("qptools")
```

# Show 'base' functions

Non-exhaustive. Check others in the INDEX.


``` r
example(fxs)
```

```
## Warning in example(fxs): no help found for 'fxs'
```

``` r
example(aadp)
```

```
## Warning in example(aadp): no help found for 'aadp'
```

``` r
example(repeat_nth)
```

```
## Warning in example(repeat_nth): no help found for 'repeat_nth'
```

``` r
example("asNumeric")
```

```
## Warning in example("asNumeric"): no help found for 'asNumeric'
```

``` r
example("isNumeric")
```

```
## Warning in example("isNumeric"): no help found for 'isNumeric'
```

# NONMEM post-processing tools

Arguments in the nm_xxx function base has changed. Previously we had 'run' and 'path', this is now replaced by 'x' and 'directory'. This was chosen as this is largely in sync with packages 'nonmemica' and 'pmsTools' with which 'qptools' collaborates or that it draws from or refers to.

We simply state the run as a character and let the 'nm_xxx' tool do its work on it. Tool is able to figure out of it's character text (e.g. "run1"), or if it's already pre-processed by another 'qptools' function.


## Example Directory

Let's first check out the example directory that comes with 'qptools'.


``` r
getOption("qpExampleDir") %>% file.path(., "run105") %>% dir() ## no xml file, only zipped file
```

```
##  [1] "_run105.xml"   "catab105"      "cotab105"      "patab105"     
##  [5] "run105.coi.7z" "run105.cor.7z" "run105.cov.7z" "run105.ext"   
##  [9] "run105.xml"    "run105.xml.7z" "sdtab105"
```

``` r
getOption("qpExampleDir") %>% file.path(.) %>% nm_unzip("run105", rundir=., extension = "xml")
getOption("qpExampleDir") %>% file.path(., "run105") %>% dir() ## there it is
```

```
##  [1] "_run105.xml"   "catab105"      "cotab105"      "patab105"     
##  [5] "run105.coi.7z" "run105.cor.7z" "run105.cov.7z" "run105.ext"   
##  [9] "run105.xml"    "run105.xml.7z" "sdtab105"
```

## Set default NONMEM directory


``` r
options(nmDir = getOption("qpExampleDir"))
```

Now we do not have to specify directory anymore -it's automatically used throughout `nm_xxx`.

## The read_xxx function base

The NONMEM tools `nm_xxx` also feature `read_xxx` base and call these under the hood for parameter tables for example. See for yourself what this does.


``` r
"run105" %>% read_lst()
```

```
## [1] "14/09/2023 \n12:29\n;; 1. Based on: 102\n;; 2. Description: \n;;    PK model 1 cmt - WT-CL allom SEX-CL\n;; 3. Label:\n;;    \n;; 4. Structural model:\n;; 5. Covariate model:\n;; 6. Inter-individual variability:\n;; 7. Inter-occasion variability:\n;; 8. Residual variability:\n;; 9. Estimation:\n$PROBLEM    PK model 1 cmt base\n$INPUT      ID TIME MDV EVID DV AMT SEX WT ETN\n$DATA      acop.csv IGNORE=@\n$SUBROUTINE ADVAN2 TRANS2\n$PK\nET=1\nIF(ETN.EQ.3) ET=1.3\nKA = THETA(1)\nCL = THETA(2)*((WT/70)**THETA(6))*( THETA(7)**SEX) * EXP(ETA(1))\nV = THETA(3)*EXP(ETA(2))\nSC=V\n$THETA  (0,2) ; KA; 1/h; LIN ;Absorption Rate Constant\n (0,20) ; CL; L/h; LIN ;Clearance\n (0,100) ; V2; L; LIN ;Volume of Distribution\n 0.02 ; RUVp; ; LIN ;Proportional Error\n 1 ; RUVa; ng/mL; LIN ;Additive Error\n 0.75 FIX ; CL-WT; ; LIN ;Power Scalar CL-WT\n (0,1) ; CL-SEX; ; LIN ;Female CL Change\n$OMEGA  0.05  ;     iiv CL\n 0.2  ;     iiv V2\n$SIGMA  1  FIX\n$ERROR\nIPRED = F\nIRES = DV-IPRED\nW = IPRED*THETA(4) + THETA(5)\nIF (W.EQ.0) W = 1\nIWRES = IRES/W\nY= IPRED+W*ERR(1)\n$ESTIMATION METHOD=SAEM INTER NBURN=3000 NITER=500 PRINT=100\n$ESTIMATION METHOD=IMP INTER EONLY=1 NITER=5 ISAMPLE=3000 PRINT=1\n            SIGL=8 NOPRIOR=1\n$ESTIMATION METHOD=1 INTER MAXEVAL=9999 SIG=3 PRINT=5 NOABORT POSTHOC\n$COVARIANCE PRINT=E UNCONDITIONAL\n$TABLE      ID TIME DV MDV EVID IPRED IWRES CWRES ONEHEADER NOPRINT\n            FILE=sdtab105\n$TABLE      ID CL V KA ETAS(1:LAST) ONEHEADER NOPRINT FILE=patab105\n$TABLE      ID SEX ETN ONEHEADER NOPRINT FILE=catab105\n$TABLE      ID WT ONEHEADER NOPRINT FILE=cotab105\n  \nNM-TRAN MESSAGES \n  \n WARNINGS AND ERRORS (IF ANY) FOR PROBLEM    1\n             \n (WARNING  2) NM-TRAN INFERS THAT THE DATA ARE POPULATION.\n  \nLicense Registered to: qPharmetra\nExpiration Date:    14 JUL 2024\nCurrent Date:       14 SEP 2023\nDays until program expires : 305\n1NONLINEAR MIXED EFFECTS MODEL PROGRAM (NONMEM) VERSION 7.4.3\n ORIGINALLY DEVELOPED BY STUART BEAL, LEWIS SHEINER, AND ALISON BOECKMANN\n CURRENT DEVELOPERS ARE ROBERT BAUER, ICON DEVELOPMENT SOLUTIONS,\n AND ALISON BOECKMANN. IMPLEMENTATION, EFFICIENCY, AND STANDARDIZATION\n PERFORMED BY NOUS INFOSYSTEMS.\n PROBLEM NO.:         1\n PK model 1 cmt base\n0DATA CHECKOUT RUN:              NO\n DATA SET LOCATED ON UNIT NO.:    2\n THIS UNIT TO BE REWOUND:        NO\n NO. OF DATA RECS IN DATA SET:      800\n NO. OF DATA ITEMS IN DATA SET:   9\n ID DATA ITEM IS DATA ITEM NO.:   1\n DEP VARIABLE IS DATA ITEM NO.:   5\n MDV DATA ITEM IS DATA ITEM NO.:  3\n0INDICES PASSED TO SUBROUTINE PRED:\n   4   2   6   0   0   0   0   0   0   0   0\n0LABELS FOR DATA ITEMS:\n ID TIME MDV EVID DV AMT SEX WT ETN\n0(NONBLANK) LABELS FOR PRED-DEFINED ITEMS:\n KA CL V IPRED IWRES\n0FORMAT FOR DATA:\n (E3.0,E5.0,2E2.0,E10.0,E6.0,E2.0,E5.0,E2.0)\n TOT. NO. OF OBS RECS:      760\n TOT. NO. OF INDIVIDUALS:       40\n0LENGTH OF THETA:   7\n0DEFAULT THETA BOUNDARY TEST OMITTED:    NO\n0OMEGA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   2\n0DEFAULT OMEGA BOUNDARY TEST OMITTED:    NO\n0SIGMA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   1\n0DEFAULT SIGMA BOUNDARY TEST OMITTED:    NO\n0INITIAL ESTIMATE OF THETA:\n LOWER BOUND    INITIAL EST    UPPER BOUND\n  0.0000E+00     0.2000E+01     0.1000E+07\n  0.0000E+00     0.2000E+02     0.1000E+07\n  0.0000E+00     0.1000E+03     0.1000E+07\n -0.1000E+07     0.2000E-01     0.1000E+07\n -0.1000E+07     0.1000E+01     0.1000E+07\n  0.7500E+00     0.7500E+00     0.7500E+00\n  0.0000E+00     0.1000E+01     0.1000E+07\n0INITIAL ESTIMATE OF OMEGA:\n 0.5000E-01\n 0.0000E+00   0.2000E+00\n0INITIAL ESTIMATE OF SIGMA:\n 0.1000E+01\n0SIGMA CONSTRAINED TO BE THIS INITIAL ESTIMATE\n0COVARIANCE STEP OMITTED:        NO\n EIGENVLS. PRINTED:             YES\n SPECIAL COMPUTATION:            NO\n COMPRESSED FORMAT:              NO\n GRADIENT METHOD USED:     NOSLOW\n SIGDIGITS ETAHAT (SIGLO):                  -1\n SIGDIGITS GRADIENTS (SIGL):                -1\n EXCLUDE COV FOR FOCE (NOFCOV):              NO\n TURN OFF Cholesky Transposition of R Matrix (CHOLROFF): NO\n KNUTHSUMOFF:                                -1\n RESUME COV ANALYSIS (RESUME):               NO\n SIR SAMPLE SIZE (SIRSAMPLE):              -1\n NON-LINEARLY TRANSFORM THETAS DURING COV (THBND): 1\n PRECONDTIONING CYCLES (PRECOND):        0\n PRECONDTIONING TYPES (PRECONDS):        TOS\n FORCED PRECONDTIONING CYCLES (PFCOND):0\n PRECONDTIONING TYPE (PRETYPE):        0\n FORCED POS. DEFINITE SETTING: (FPOSDEF):0\n0TABLES STEP OMITTED:    NO\n NO. OF TABLES:           4\n SEED NUMBER (SEED):    11456\n RANMETHOD:             3U\n MC SAMPLES (ESAMPLE):    300\n WRES SQUARE ROOT TYPE (WRESCHOL): EIGENVALUE\n0-- TABLE   1 --\n0RECORDS ONLY:    ALL\n04 COLUMNS APPENDED:    YES\n PRINTED:                NO\n HEADER:                YES\n FILE TO BE FORWARDED:   NO\n FORMAT:                S1PE11.4\n LFORMAT:\n RFORMAT:\n FIXED_EFFECT_ETAS:\n0USER-CHOSEN ITEMS:\n ID TIME DV MDV EVID IPRED IWRES CWRES\n0-- TABLE   2 --\n0RECORDS ONLY:    ALL\n04 COLUMNS APPENDED:    YES\n PRINTED:                NO\n HEADER:                YES\n FILE TO BE FORWARDED:   NO\n FORMAT:                S1PE11.4\n LFORMAT:\n RFORMAT:\n FIXED_EFFECT_ETAS:\n0USER-CHOSEN ITEMS:\n ID CL V KA ETA1 ETA2\n0-- TABLE   3 --\n0RECORDS ONLY:    ALL\n04 COLUMNS APPENDED:    YES\n PRINTED:                NO\n HEADER:                YES\n FILE TO BE FORWARDED:   NO\n FORMAT:                S1PE11.4\n LFORMAT:\n RFORMAT:\n FIXED_EFFECT_ETAS:\n0USER-CHOSEN ITEMS:\n ID SEX ETN\n0-- TABLE   4 --\n0RECORDS ONLY:    ALL\n04 COLUMNS APPENDED:    YES\n PRINTED:                NO\n HEADER:                YES\n FILE TO BE FORWARDED:   NO\n FORMAT:                S1PE11.4\n LFORMAT:\n RFORMAT:\n FIXED_EFFECT_ETAS:\n0USER-CHOSEN ITEMS:\n ID WT\n1DOUBLE PRECISION PREDPP VERSION 7.4.3\n ONE COMPARTMENT MODEL WITH FIRST-ORDER ABSORPTION (ADVAN2)\n0MAXIMUM NO. OF BASIC PK PARAMETERS:   3\n0BASIC PK PARAMETERS (AFTER TRANSLATION):\n   ELIMINATION RATE (K) IS BASIC PK PARAMETER NO.:  1\n   ABSORPTION RATE (KA) IS BASIC PK PARAMETER NO.:  3\n TRANSLATOR WILL CONVERT PARAMETERS\n CLEARANCE (CL) AND VOLUME (V) TO K (TRANS2)\n0COMPARTMENT ATTRIBUTES\n COMPT. NO.   FUNCTION   INITIAL    ON/OFF      DOSE      DEFAULT    DEFAULT\n                         STATUS     ALLOWED    ALLOWED    FOR DOSE   FOR OBS.\n    1         DEPOT        OFF        YES        YES        YES        NO\n    2         CENTRAL      ON         NO         YES        NO         YES\n    3         OUTPUT       OFF        YES        NO         NO         NO\n1\n ADDITIONAL PK PARAMETERS - ASSIGNMENT OF ROWS IN GG\n COMPT. NO.                             INDICES\n              SCALE      BIOAVAIL.   ZERO-ORDER  ZERO-ORDER  ABSORB\n                         FRACTION    RATE        DURATION    LAG\n    1            *           *           *           *           *\n    2            4           *           *           *           *\n    3            *           -           -           -           -\n             - PARAMETER IS NOT ALLOWED FOR THIS MODEL\n             * PARAMETER IS NOT SUPPLIED BY PK SUBROUTINE;\n               WILL DEFAULT TO ONE IF APPLICABLE\n0DATA ITEM INDICES USED BY PRED ARE:\n   EVENT ID DATA ITEM IS DATA ITEM NO.:      4\n   TIME DATA ITEM IS DATA ITEM NO.:          2\n   DOSE AMOUNT DATA ITEM IS DATA ITEM NO.:   6\n0PK SUBROUTINE CALLED WITH EVERY EVENT RECORD.\n PK SUBROUTINE NOT CALLED AT NONEVENT (ADDITIONAL OR LAGGED) DOSE TIMES.\n0ERROR SUBROUTINE CALLED WITH EVERY EVENT RECORD.\n1\n #TBLN:      1\n #METH: Stochastic Approximation Expectation-Maximization\n ESTIMATION STEP OMITTED:                 NO\n ANALYSIS TYPE:                           POPULATION\n NUMBER OF SADDLE POINT RESET ITERATIONS:      0\n GRADIENT METHOD USED:               NOSLOW\n CONDITIONAL ESTIMATES USED:              YES\n CENTERED ETA:                            NO\n EPS-ETA INTERACTION:                     YES\n LAPLACIAN OBJ. FUNC.:                    NO\n NO. OF FUNCT. EVALS. ALLOWED:            624\n NO. OF SIG. FIGURES REQUIRED:            3\n INTERMEDIATE PRINTOUT:                   YES\n ESTIMATE OUTPUT TO MSF:                  NO\n IND. OBJ. FUNC. VALUES SORTED:           NO\n NUMERICAL DERIVATIVE\n       FILE REQUEST (NUMDER):               NONE\n MAP (ETAHAT) ESTIMATION METHOD (OPTMAP):   0\n ETA HESSIAN EVALUATION METHOD (ETADER):    0\n INITIAL ETA FOR MAP ESTIMATION (MCETA):    0\n SIGDIGITS FOR MAP ESTIMATION (SIGLO):      100\n GRADIENT SIGDIGITS OF\n       FIXED EFFECTS PARAMETERS (SIGL):     100\n NOPRIOR SETTING (NOPRIOR):                 OFF\n NOCOV SETTING (NOCOV):                     OFF\n DERCONT SETTING (DERCONT):                 OFF\n FINAL ETA RE-EVALUATION (FNLETA):          ON\n EXCLUDE NON-INFLUENTIAL (NON-INFL.) ETAS\n       IN SHRINKAGE (ETASTYPE):             NO\n NON-INFL. ETA CORRECTION (NONINFETA):      OFF\n RAW OUTPUT FILE (FILE): psn.ext\n EXCLUDE TITLE (NOTITLE):                   NO\n EXCLUDE COLUMN LABELS (NOLABEL):           NO\n FORMAT FOR ADDITIONAL FILES (FORMAT):      S1PE12.5\n PARAMETER ORDER FOR OUTPUTS (ORDER):       TSOL\n WISHART PRIOR DF INTERPRETATION (WISHTYPE):0\n KNUTHSUMOFF:                               0\n INCLUDE LNTWOPI:                           NO\n INCLUDE CONSTANT TERM TO PRIOR (PRIORC):   NO\n INCLUDE CONSTANT TERM TO OMEGA (ETA) (OLNTWOPI):NO\n EM OR BAYESIAN METHOD USED:                STOCHASTIC APPROXIMATION EXPECTATION MAXIMIZATION (SAEM)\n MU MODELING PATTERN (MUM):\n GRADIENT/GIBBS PATTERN (GRD):\n AUTOMATIC SETTING FEATURE (AUTO):          OFF\n CONVERGENCE TYPE (CTYPE):                  0\n BURN-IN ITERATIONS (NBURN):                3000\n ITERATIONS (NITER):                        500\n ANEAL SETTING (CONSTRAIN):                 1\n STARTING SEED FOR MC METHODS (SEED):       11456\n MC SAMPLES PER SUBJECT (ISAMPLE):          2\n RANDOM SAMPLING METHOD (RANMETHOD):        3U\n EXPECTATION ONLY (EONLY):                  0\n PROPOSAL DENSITY SCALING RANGE\n              (ISCALE_MIN, ISCALE_MAX):     1.000000000000000E-06   ,1000000.00000000\n SAMPLE ACCEPTANCE RATE (IACCEPT):          0.400000000000000\n METROPOLIS HASTINGS SAMPLING FOR INDIVIDUAL ETAS:\n SAMPLES FOR GLOBAL SEARCH KERNEL (ISAMPLE_M1):          2\n SAMPLES FOR NEIGHBOR SEARCH KERNEL (ISAMPLE_M1A):       0\n SAMPLES FOR MASS/IMP/POST. MATRIX SEARCH (ISAMPLE_M1B): 2\n SAMPLES FOR LOCAL SEARCH KERNEL (ISAMPLE_M2):           2\n SAMPLES FOR LOCAL UNIVARIATE KERNEL (ISAMPLE_M3):       2\n PWR. WT. MASS/IMP/POST MATRIX ACCUM. FOR ETAS (IKAPPA): 1.00000000000000\n MASS/IMP./POST. MATRIX REFRESH SETTING (MASSREST):      -1\n THE FOLLOWING LABELS ARE EQUIVALENT\n PRED=PREDI\n RES=RESI\n WRES=WRESI\n IWRS=IWRESI\n IPRD=IPREDI\n IRS=IRESI\n EM/BAYES SETUP:\n THETAS THAT ARE MU MODELED:\n \n THETAS THAT ARE SIGMA-LIKE:\n \n MONITORING OF SEARCH:\n Stochastic/Burn-in Mode\n iteration        -3000  SAEMOBJ=   37880.578399081634\n iteration        -2900  SAEMOBJ=   1819.9797813209129\n iteration        -2800  SAEMOBJ=   1775.7623169685935\n iteration        -2700  SAEMOBJ=   1762.6348116922927\n iteration        -2600  SAEMOBJ=   1756.5962068838376\n iteration        -2500  SAEMOBJ=   1738.7137277621491\n iteration        -2400  SAEMOBJ=   1738.8232940947819\n iteration        -2300  SAEMOBJ=   1748.4815457049922\n iteration        -2200  SAEMOBJ=   1710.3493739249757\n iteration        -2100  SAEMOBJ=   1678.3150276961987\n iteration        -2000  SAEMOBJ=   1660.7697562928051\n iteration        -1900  SAEMOBJ=   1670.6905203533120\n iteration        -1800  SAEMOBJ=   1676.5422115195090\n iteration        -1700  SAEMOBJ=   1679.9175463929050\n iteration        -1600  SAEMOBJ=   1666.1447026518115\n iteration        -1500  SAEMOBJ=   1678.2053340635484\n iteration        -1400  SAEMOBJ=   1684.4738496434206\n iteration        -1300  SAEMOBJ=   1666.7514702127837\n iteration        -1200  SAEMOBJ=   1665.1358146630539\n iteration        -1100  SAEMOBJ=   1663.2056797589910\n iteration        -1000  SAEMOBJ=   1676.0512289498085\n iteration         -900  SAEMOBJ=   1656.5899185787312\n iteration         -800  SAEMOBJ=   1660.9547108389204\n iteration         -700  SAEMOBJ=   1664.7104693758502\n iteration         -600  SAEMOBJ=   1670.7599984097280\n iteration         -500  SAEMOBJ=   1664.0882947137266\n iteration         -400  SAEMOBJ=   1669.3760024849835\n iteration         -300  SAEMOBJ=   1665.6498136784967\n iteration         -200  SAEMOBJ=   1668.4572104514200\n iteration         -100  SAEMOBJ=   1661.0589433728653\n Reduced Stochastic/Accumulation Mode\n iteration            0  SAEMOBJ=   1667.0797458880336\n iteration          100  SAEMOBJ=   1654.0501788529286\n iteration          200  SAEMOBJ=   1654.1064511390723\n iteration          300  SAEMOBJ=   1653.9436158865042\n iteration          400  SAEMOBJ=   1653.9493430311197\n iteration          500  SAEMOBJ=   1653.7461440391669\n #TERM:\n STOCHASTIC PORTION WAS NOT TESTED FOR CONVERGENCE\n REDUCED STOCHASTIC PORTION WAS COMPLETED\n ETABAR IS THE ARITHMETIC MEAN OF THE ETA-ESTIMATES,\n AND THE P-VALUE IS GIVEN FOR THE NULL HYPOTHESIS THAT THE TRUE MEAN IS 0.\n ETABAR:         5.1052E-03 -2.6889E-02\n SE:             2.6115E-02  5.9862E-02\n N:                      40          40\n P VAL.:         8.4501E-01  6.5330E-01\n ETASHRINKSD(%)  1.3076E+01  9.7483E-01\n ETASHRINKVR(%)  2.4443E+01  1.9401E+00\n EBVSHRINKSD(%)  1.3034E+01  7.2605E-01\n EBVSHRINKVR(%)  2.4369E+01  1.4468E+00\n EPSSHRINKSD(%)  4.5935E+00\n EPSSHRINKVR(%)  8.9760E+00\n  \n TOTAL DATA POINTS NORMALLY DISTRIBUTED (N):          760\n N*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    1396.7865704711026     \n OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    1653.7461440391669     \n OBJECTIVE FUNCTION VALUE WITH CONSTANT:       3050.5327145102692     \n REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT\n  \n TOTAL EFFECTIVE ETAS (NIND*NETA):                            80\n NIND*NETA*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    147.03016531274761     \n OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    1653.7461440391669     \n OBJECTIVE FUNCTION VALUE WITH CONSTANT:       1800.7763093519145     \n REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT\n  \n #TERE:\n Elapsed estimation  time in seconds:   126.02\n Elapsed covariance  time in seconds:     0.02\n1\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n #OBJT:**************                        FINAL VALUE OF LIKELIHOOD FUNCTION                      ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n #OBJV:********************************************     1653.746       **************************************************\n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n ********************                             FINAL PARAMETER ESTIMATE                           ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********\n         TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     \n \n         2.26E+00  7.26E+01  4.80E+02  7.17E-02  1.09E+00  7.50E-01  6.00E-01\n \n OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********\n         ETA1      ETA2     \n \n ETA1\n+        3.70E-02\n \n ETA2\n+        0.00E+00  1.50E-01\n \n SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****\n         EPS1     \n \n EPS1\n+        1.00E+00\n \n1\n OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******\n         ETA1      ETA2     \n \n ETA1\n+        1.92E-01\n \n ETA2\n+        0.00E+00  3.87E-01\n \n SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***\n         EPS1     \n \n EPS1\n+        1.00E+00\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n ********************                          STANDARD ERROR OF ESTIMATE (S)                        ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********\n         TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     \n \n         6.48E-02  5.36E+00  3.23E+01  7.65E-03  1.00E-01  0.00E+00  5.10E-02\n \n OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********\n         ETA1      ETA2     \n \n ETA1\n+        1.32E-02\n \n ETA2\n+        0.00E+00  5.00E-02\n \n SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****\n         EPS1     \n \n EPS1\n+        0.00E+00\n \n1\n OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******\n         ETA1      ETA2     \n \n ETA1\n+        3.42E-02\n \n ETA2\n+       .........  6.46E-02\n \n SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***\n         EPS1     \n \n EPS1\n+       .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n ********************                        COVARIANCE MATRIX OF ESTIMATE (S)                       ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        4.20E-03\n \n TH 2\n+       -1.40E-04  2.88E+01\n \n TH 3\n+        4.53E-01  3.39E+01  1.04E+03\n \n TH 4\n+        4.63E-05  1.32E-04 -5.65E-02  5.86E-05\n \n TH 5\n+       -8.45E-04  5.09E-02  4.07E-01 -6.15E-04  1.00E-02\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+       -4.00E-04 -2.35E-01 -4.32E-01  4.33E-05 -4.56E-04  0.00E+00  2.60E-03\n \n OM11\n+        1.91E-04 -1.17E-03  2.04E-04 -2.60E-05  2.71E-04  0.00E+00 -9.50E-05  1.74E-04\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+       -3.40E-04 -2.60E-02  1.16E-01 -1.32E-05  1.79E-04  0.00E+00  2.88E-05  1.14E-04  0.00E+00  2.50E-03\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n ********************                        CORRELATION MATRIX OF ESTIMATE (S)                      ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        6.48E-02\n \n TH 2\n+       -4.02E-04  5.36E+00\n \n TH 3\n+        2.17E-01  1.96E-01  3.23E+01\n \n TH 4\n+        9.34E-02  3.22E-03 -2.29E-01  7.65E-03\n \n TH 5\n+       -1.30E-01  9.47E-02  1.26E-01 -8.02E-01  1.00E-01\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+       -1.21E-01 -8.58E-01 -2.63E-01  1.11E-01 -8.92E-02  0.00E+00  5.10E-02\n \n OM11\n+        2.24E-01 -1.66E-02  4.80E-04 -2.58E-01  2.06E-01  0.00E+00 -1.41E-01  1.32E-02\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+       -1.05E-01 -9.71E-02  7.20E-02 -3.45E-02  3.58E-02  0.00E+00  1.13E-02  1.73E-01  0.00E+00  5.00E-02\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n ********************                    INVERSE COVARIANCE MATRIX OF ESTIMATE (S)                   ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        3.00E+02\n \n TH 2\n+        1.41E+00  1.73E-01\n \n TH 3\n+       -1.61E-01 -7.80E-04  1.20E-03\n \n TH 4\n+       -6.57E+02 -3.68E+01  2.02E+00  5.99E+04\n \n TH 5\n+        1.85E-01 -2.43E+00  5.83E-02  3.50E+03  3.17E+02\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+        1.42E+02  1.61E+01  1.00E-01 -3.37E+03 -2.15E+02  0.00E+00  1.92E+03\n \n OM11\n+       -3.92E+02  5.68E+00  5.05E-01  2.50E+03 -8.86E+01  0.00E+00  7.53E+02  7.38E+03\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+        7.57E+01  1.56E+00 -1.03E-01 -5.76E+02 -2.57E+01  0.00E+00  1.23E+02 -3.43E+02  0.00E+00  4.44E+02\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************\n ********************                    EIGENVALUES OF COR MATRIX OF ESTIMATE (S)                   ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n             1         2         3         4         5         6         7         8\n \n         9.15E-02  2.12E-01  4.85E-01  9.43E-01  1.05E+00  1.24E+00  1.78E+00  2.20E+00\n \n1\n #TBLN:      2\n #METH: Objective Function Evaluation by Importance Sampling (No Prior)\n ESTIMATION STEP OMITTED:                 NO\n ANALYSIS TYPE:                           POPULATION\n NUMBER OF SADDLE POINT RESET ITERATIONS:      0\n GRADIENT METHOD USED:               NOSLOW\n CONDITIONAL ESTIMATES USED:              YES\n CENTERED ETA:                            NO\n EPS-ETA INTERACTION:                     YES\n LAPLACIAN OBJ. FUNC.:                    NO\n NO. OF FUNCT. EVALS. ALLOWED:            624\n NO. OF SIG. FIGURES REQUIRED:            3\n INTERMEDIATE PRINTOUT:                   YES\n ESTIMATE OUTPUT TO MSF:                  NO\n IND. OBJ. FUNC. VALUES SORTED:           NO\n NUMERICAL DERIVATIVE\n       FILE REQUEST (NUMDER):               NONE\n MAP (ETAHAT) ESTIMATION METHOD (OPTMAP):   0\n ETA HESSIAN EVALUATION METHOD (ETADER):    0\n INITIAL ETA FOR MAP ESTIMATION (MCETA):    0\n SIGDIGITS FOR MAP ESTIMATION (SIGLO):      8\n GRADIENT SIGDIGITS OF\n       FIXED EFFECTS PARAMETERS (SIGL):     8\n NOPRIOR SETTING (NOPRIOR):                 ON\n NOCOV SETTING (NOCOV):                     OFF\n DERCONT SETTING (DERCONT):                 OFF\n FINAL ETA RE-EVALUATION (FNLETA):          ON\n EXCLUDE NON-INFLUENTIAL (NON-INFL.) ETAS\n       IN SHRINKAGE (ETASTYPE):             NO\n NON-INFL. ETA CORRECTION (NONINFETA):      OFF\n RAW OUTPUT FILE (FILE): psn.ext\n EXCLUDE TITLE (NOTITLE):                   NO\n EXCLUDE COLUMN LABELS (NOLABEL):           NO\n FORMAT FOR ADDITIONAL FILES (FORMAT):      S1PE12.5\n PARAMETER ORDER FOR OUTPUTS (ORDER):       TSOL\n WISHART PRIOR DF INTERPRETATION (WISHTYPE):0\n KNUTHSUMOFF:                               0\n INCLUDE LNTWOPI:                           NO\n INCLUDE CONSTANT TERM TO PRIOR (PRIORC):   NO\n INCLUDE CONSTANT TERM TO OMEGA (ETA) (OLNTWOPI):NO\n EM OR BAYESIAN METHOD USED:                IMPORTANCE SAMPLING (IMP)\n MU MODELING PATTERN (MUM):\n GRADIENT/GIBBS PATTERN (GRD):\n AUTOMATIC SETTING FEATURE (AUTO):          OFF\n CONVERGENCE TYPE (CTYPE):                  0\n ITERATIONS (NITER):                        5\n ANEAL SETTING (CONSTRAIN):                 1\n STARTING SEED FOR MC METHODS (SEED):       11456\n MC SAMPLES PER SUBJECT (ISAMPLE):          3000\n RANDOM SAMPLING METHOD (RANMETHOD):        3U\n EXPECTATION ONLY (EONLY):                  1\n PROPOSAL DENSITY SCALING RANGE\n              (ISCALE_MIN, ISCALE_MAX):     0.100000000000000       ,10.0000000000000\n SAMPLE ACCEPTANCE RATE (IACCEPT):          0.400000000000000\n LONG TAIL SAMPLE ACCEPT. RATE (IACCEPTL):   0.00000000000000\n T-DIST. PROPOSAL DENSITY (DF):             0\n NO. ITERATIONS FOR MAP (MAPITER):          1\n INTERVAL ITER. FOR MAP (MAPINTER):         0\n MAP COVARIANCE/MODE SETTING (MAPCOV):      1\n Gradient Quick Value (GRDQ):               0.00000000000000\n THE FOLLOWING LABELS ARE EQUIVALENT\n PRED=PREDI\n RES=RESI\n WRES=WRESI\n IWRS=IWRESI\n IPRD=IPREDI\n IRS=IRESI\n EM/BAYES SETUP:\n THETAS THAT ARE MU MODELED:\n \n THETAS THAT ARE SIGMA-LIKE:\n \n MONITORING OF SEARCH:\n iteration            0  OBJ=   2042.2787689427023 eff.=    3002. Smpl.=    3000. Fit.= 0.98929\n iteration            1  OBJ=   2042.1984488958581 eff.=    1202. Smpl.=    3000. Fit.= 0.78696\n iteration            2  OBJ=   2042.3797207602163 eff.=    1193. Smpl.=    3000. Fit.= 0.78587\n iteration            3  OBJ=   2042.3247305602517 eff.=    1195. Smpl.=    3000. Fit.= 0.78567\n iteration            4  OBJ=   2042.1527399552278 eff.=    1198. Smpl.=    3000. Fit.= 0.78582\n iteration            5  OBJ=   2042.4148330855062 eff.=    1196. Smpl.=    3000. Fit.= 0.78648\n #TERM:\n EXPECTATION ONLY PROCESS COMPLETED\n ETABAR IS THE ARITHMETIC MEAN OF THE ETA-ESTIMATES,\n AND THE P-VALUE IS GIVEN FOR THE NULL HYPOTHESIS THAT THE TRUE MEAN IS 0.\n ETABAR:         3.7682E-03 -2.6665E-02\n SE:             2.6396E-02  5.9870E-02\n N:                      40          40\n P VAL.:         8.8648E-01  6.5605E-01\n ETASHRINKSD(%)  1.2142E+01  9.6263E-01\n ETASHRINKVR(%)  2.2809E+01  1.9160E+00\n EBVSHRINKSD(%)  1.3093E+01  7.2078E-01\n EBVSHRINKVR(%)  2.4471E+01  1.4364E+00\n EPSSHRINKSD(%)  4.6618E+00\n EPSSHRINKVR(%)  9.1063E+00\n  \n TOTAL DATA POINTS NORMALLY DISTRIBUTED (N):          760\n N*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    1396.7865704711026     \n OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    2042.4148330855062     \n OBJECTIVE FUNCTION VALUE WITH CONSTANT:       3439.2014035566090     \n REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT\n  \n TOTAL EFFECTIVE ETAS (NIND*NETA):                            80\n  \n #TERE:\n Elapsed estimation  time in seconds:    13.97\n Elapsed covariance  time in seconds:   222.13\n1\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n #OBJT:**************                        FINAL VALUE OF OBJECTIVE FUNCTION                       ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n #OBJV:********************************************     2042.415       **************************************************\n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n ********************                             FINAL PARAMETER ESTIMATE                           ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********\n         TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     \n \n         2.26E+00  7.26E+01  4.80E+02  7.17E-02  1.09E+00  7.50E-01  6.00E-01\n \n OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********\n         ETA1      ETA2     \n \n ETA1\n+        3.70E-02\n \n ETA2\n+        0.00E+00  1.50E-01\n \n SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****\n         EPS1     \n \n EPS1\n+        1.00E+00\n \n1\n OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******\n         ETA1      ETA2     \n \n ETA1\n+        1.92E-01\n \n ETA2\n+        0.00E+00  3.87E-01\n \n SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***\n         EPS1     \n \n EPS1\n+        1.00E+00\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n ********************                         STANDARD ERROR OF ESTIMATE (RSR)                       ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********\n         TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     \n \n         7.94E-02  3.06E+00  2.52E+01  8.20E-03  8.51E-02  0.00E+00  4.09E-02\n \n OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********\n         ETA1      ETA2     \n \n ETA1\n+        1.20E-02\n \n ETA2\n+        0.00E+00  2.36E-02\n \n SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****\n         EPS1     \n \n EPS1\n+        0.00E+00\n \n1\n OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******\n         ETA1      ETA2     \n \n ETA1\n+        3.12E-02\n \n ETA2\n+       .........  3.05E-02\n \n SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***\n         EPS1     \n \n EPS1\n+       .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n ********************                       COVARIANCE MATRIX OF ESTIMATE (RSR)                      ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        6.31E-03\n \n TH 2\n+       -2.09E-02  9.39E+00\n \n TH 3\n+       -1.00E-01 -1.75E+01  6.36E+02\n \n TH 4\n+       -1.24E-04 -2.80E-03  5.29E-02  6.72E-05\n \n TH 5\n+        1.34E-03  1.39E-02 -3.55E-01 -5.97E-04  7.25E-03\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+        2.04E-04 -8.11E-02  1.52E-01 -2.66E-05  6.48E-05  0.00E+00  1.68E-03\n \n OM11\n+       -1.98E-04 -6.64E-03 -1.78E-02  2.75E-05 -3.54E-04  0.00E+00  1.12E-04  1.44E-04\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+        2.58E-04  1.16E-02 -2.00E-02 -2.33E-05  1.91E-04  0.00E+00 -4.11E-05 -4.59E-05  0.00E+00  5.56E-04\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n ********************                       CORRELATION MATRIX OF ESTIMATE (RSR)                     ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        7.94E-02\n \n TH 2\n+       -8.57E-02  3.06E+00\n \n TH 3\n+       -4.99E-02 -2.26E-01  2.52E+01\n \n TH 4\n+       -1.90E-01 -1.11E-01  2.56E-01  8.20E-03\n \n TH 5\n+        1.98E-01  5.32E-02 -1.65E-01 -8.55E-01  8.51E-02\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+        6.28E-02 -6.47E-01  1.47E-01 -7.93E-02  1.86E-02  0.00E+00  4.09E-02\n \n OM11\n+       -2.08E-01 -1.80E-01 -5.87E-02  2.79E-01 -3.46E-01  0.00E+00  2.27E-01  1.20E-02\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+        1.38E-01  1.61E-01 -3.36E-02 -1.20E-01  9.50E-02  0.00E+00 -4.25E-02 -1.62E-01  0.00E+00  2.36E-02\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n ********************                   INVERSE COVARIANCE MATRIX OF ESTIMATE (RSR)                  ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        1.76E+02\n \n TH 2\n+        7.18E-01  2.09E-01\n \n TH 3\n+        3.57E-02  2.19E-03  1.85E-03\n \n TH 4\n+        1.37E+02  2.74E+01 -2.30E+00  6.38E+04\n \n TH 5\n+       -8.59E+00  1.90E+00 -7.14E-02  5.01E+03  5.63E+02\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+       -3.21E+00  1.00E+01 -1.50E-01  2.37E+03  1.31E+02  0.00E+00  1.17E+03\n \n OM11\n+        2.12E+02  1.53E+00  7.51E-01 -3.94E+02  4.00E+02  0.00E+00 -6.37E+02  9.09E+03\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+       -6.93E+01 -3.27E+00 -1.67E-02  3.70E+02  2.08E+01  0.00E+00 -1.26E+02  4.46E+02  0.00E+00  1.93E+03\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************\n ********************                   EIGENVALUES OF COR MATRIX OF ESTIMATE (RSR)                  ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n             1         2         3         4         5         6         7         8\n \n         1.25E-01  3.31E-01  5.59E-01  8.45E-01  9.56E-01  1.14E+00  1.73E+00  2.31E+00\n \n1\n #TBLN:      3\n #METH: First Order Conditional Estimation with Interaction (No Prior)\n ESTIMATION STEP OMITTED:                 NO\n ANALYSIS TYPE:                           POPULATION\n NUMBER OF SADDLE POINT RESET ITERATIONS:      0\n GRADIENT METHOD USED:               NOSLOW\n CONDITIONAL ESTIMATES USED:              YES\n CENTERED ETA:                            NO\n EPS-ETA INTERACTION:                     YES\n LAPLACIAN OBJ. FUNC.:                    NO\n NO. OF FUNCT. EVALS. ALLOWED:            9999\n NO. OF SIG. FIGURES REQUIRED:            3\n INTERMEDIATE PRINTOUT:                   YES\n ESTIMATE OUTPUT TO MSF:                  NO\n ABORT WITH PRED EXIT CODE 1:             NO\n IND. OBJ. FUNC. VALUES SORTED:           NO\n NUMERICAL DERIVATIVE\n       FILE REQUEST (NUMDER):               NONE\n MAP (ETAHAT) ESTIMATION METHOD (OPTMAP):   0\n ETA HESSIAN EVALUATION METHOD (ETADER):    0\n INITIAL ETA FOR MAP ESTIMATION (MCETA):    0\n SIGDIGITS FOR MAP ESTIMATION (SIGLO):      8\n GRADIENT SIGDIGITS OF\n       FIXED EFFECTS PARAMETERS (SIGL):     8\n NOPRIOR SETTING (NOPRIOR):                 ON\n NOCOV SETTING (NOCOV):                     OFF\n DERCONT SETTING (DERCONT):                 OFF\n FINAL ETA RE-EVALUATION (FNLETA):          ON\n EXCLUDE NON-INFLUENTIAL (NON-INFL.) ETAS\n       IN SHRINKAGE (ETASTYPE):             NO\n NON-INFL. ETA CORRECTION (NONINFETA):      OFF\n RAW OUTPUT FILE (FILE): psn.ext\n EXCLUDE TITLE (NOTITLE):                   NO\n EXCLUDE COLUMN LABELS (NOLABEL):           NO\n FORMAT FOR ADDITIONAL FILES (FORMAT):      S1PE12.5\n PARAMETER ORDER FOR OUTPUTS (ORDER):       TSOL\n WISHART PRIOR DF INTERPRETATION (WISHTYPE):0\n KNUTHSUMOFF:                               0\n INCLUDE LNTWOPI:                           NO\n INCLUDE CONSTANT TERM TO PRIOR (PRIORC):   NO\n INCLUDE CONSTANT TERM TO OMEGA (ETA) (OLNTWOPI):NO\n ADDITIONAL CONVERGENCE TEST (CTYPE=4)?:    NO\n EM OR BAYESIAN METHOD USED:                 NONE\n THE FOLLOWING LABELS ARE EQUIVALENT\n PRED=PREDI\n RES=RESI\n WRES=WRESI\n IWRS=IWRESI\n IPRD=IPREDI\n IRS=IRESI\n MONITORING OF SEARCH:\n0ITERATION NO.:    0    OBJECTIVE VALUE:   2042.27086961333        NO. OF FUNC. EVALS.:   8\n CUMULATIVE NO. OF FUNC. EVALS.:        8\n NPARAMETR:  2.2644E+00  7.2636E+01  4.8036E+02  7.1713E-02  1.0873E+00  6.0036E-01  3.7030E-02  1.4992E-01\n PARAMETER:  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01\n GRADIENT:  -1.0512E+01 -1.7829E+01  1.5705E+01 -2.7421E+00 -1.2923E+01 -1.2880E+00  8.7096E-01  1.9875E+00\n0ITERATION NO.:    5    OBJECTIVE VALUE:   2041.94796099031        NO. OF FUNC. EVALS.:  59\n CUMULATIVE NO. OF FUNC. EVALS.:       67\n NPARAMETR:  2.2752E+00  7.4348E+01  4.6198E+02  7.1424E-02  1.0892E+00  5.9173E-01  3.6790E-02  1.4799E-01\n PARAMETER:  1.0473E-01  1.2330E-01  6.0978E-02  9.9598E-02  1.0017E-01  8.5518E-02  9.6750E-02  9.3518E-02\n GRADIENT:   6.8361E+00  7.5075E+00 -5.0826E+00 -1.6685E+01 -2.6389E+01  7.0805E+00  1.1345E+00  1.4235E+00\n0ITERATION NO.:   10    OBJECTIVE VALUE:   2041.85479582408        NO. OF FUNC. EVALS.:  52\n CUMULATIVE NO. OF FUNC. EVALS.:      119\n NPARAMETR:  2.2709E+00  7.4490E+01  4.6625E+02  7.1410E-02  1.0921E+00  5.8663E-01  3.5633E-02  1.4500E-01\n PARAMETER:  1.0284E-01  1.2520E-01  7.0175E-02  9.9578E-02  1.0044E-01  7.6870E-02  8.0763E-02  8.3299E-02\n GRADIENT:   1.0988E+00  1.9777E+00 -9.3637E-02 -2.9956E+00 -4.6340E+00  4.8188E-01 -1.9506E-01 -1.0332E-01\n0ITERATION NO.:   15    OBJECTIVE VALUE:   2041.84864317025        NO. OF FUNC. EVALS.:  82\n CUMULATIVE NO. OF FUNC. EVALS.:      201\n NPARAMETR:  2.2705E+00  7.4377E+01  4.6815E+02  7.1415E-02  1.0932E+00  5.8738E-01  3.5788E-02  1.4520E-01\n PARAMETER:  1.0268E-01  1.2368E-01  7.4240E-02  9.9585E-02  1.0054E-01  7.8144E-02  8.2932E-02  8.3981E-02\n GRADIENT:   1.9863E-04 -5.6821E-05 -7.7600E-05 -1.5445E-03 -1.7496E-03  8.2343E-05  3.7358E-05 -1.9489E-03\n #TERM:\n0MINIMIZATION SUCCESSFUL\n NO. OF FUNCTION EVALUATIONS USED:      201\n NO. OF SIG. DIGITS IN FINAL EST.:  3.9\n ETABAR IS THE ARITHMETIC MEAN OF THE ETA-ESTIMATES,\n AND THE P-VALUE IS GIVEN FOR THE NULL HYPOTHESIS THAT THE TRUE MEAN IS 0.\n ETABAR:         1.6346E-03 -2.1190E-03\n SE:             2.5837E-02  5.9657E-02\n N:                      40          40\n P VAL.:         9.4955E-01  9.7167E-01\n ETASHRINKSD(%)  1.2521E+01  1.0000E-10\n ETASHRINKVR(%)  2.3475E+01  1.0000E-10\n EBVSHRINKSD(%)  1.3193E+01  7.4530E-01\n EBVSHRINKVR(%)  2.4646E+01  1.4851E+00\n EPSSHRINKSD(%)  4.6580E+00\n EPSSHRINKVR(%)  9.0991E+00\n  \n TOTAL DATA POINTS NORMALLY DISTRIBUTED (N):          760\n N*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    1396.7865704711026     \n OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    2041.8486431702499     \n OBJECTIVE FUNCTION VALUE WITH CONSTANT:       3438.6352136413525     \n REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT\n  \n TOTAL EFFECTIVE ETAS (NIND*NETA):                            80\n  \n #TERE:\n Elapsed estimation  time in seconds:     1.12\n Elapsed covariance  time in seconds:     0.95\n Elapsed postprocess time in seconds:     0.02\n1\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n #OBJT:**************                       MINIMUM VALUE OF OBJECTIVE FUNCTION                      ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n #OBJV:********************************************     2041.849       **************************************************\n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n ********************                             FINAL PARAMETER ESTIMATE                           ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********\n         TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     \n \n         2.27E+00  7.44E+01  4.68E+02  7.14E-02  1.09E+00  7.50E-01  5.87E-01\n \n OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********\n         ETA1      ETA2     \n \n ETA1\n+        3.58E-02\n \n ETA2\n+        0.00E+00  1.45E-01\n \n SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****\n         EPS1     \n \n EPS1\n+        1.00E+00\n \n1\n OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******\n         ETA1      ETA2     \n \n ETA1\n+        1.89E-01\n \n ETA2\n+        0.00E+00  3.81E-01\n \n SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***\n         EPS1     \n \n EPS1\n+        1.00E+00\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n ********************                            STANDARD ERROR OF ESTIMATE                          ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********\n         TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     \n \n         8.05E-02  2.85E+00  2.83E+01  8.25E-03  8.60E-02 .........  3.87E-02\n \n OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********\n         ETA1      ETA2     \n \n ETA1\n+        1.09E-02\n \n ETA2\n+       .........  2.34E-02\n \n SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****\n         EPS1     \n \n EPS1\n+       .........\n \n1\n OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******\n         ETA1      ETA2     \n \n ETA1\n+        2.89E-02\n \n ETA2\n+       .........  3.07E-02\n \n SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***\n         EPS1     \n \n EPS1\n+       .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n ********************                          COVARIANCE MATRIX OF ESTIMATE                         ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        6.49E-03\n \n TH 2\n+       -2.58E-02  8.10E+00\n \n TH 3\n+       -1.46E-01 -2.39E+01  7.99E+02\n \n TH 4\n+       -1.30E-04 -1.37E-03  6.43E-02  6.80E-05\n \n TH 5\n+        1.45E-03  1.76E-03 -4.69E-01 -6.07E-04  7.40E-03\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+        2.24E-04 -6.50E-02  1.63E-01 -3.52E-05  1.02E-04 .........  1.50E-03\n \n OM11\n+       -2.25E-04 -4.06E-03  4.18E-02  2.88E-05 -3.64E-04 .........  1.02E-04  1.19E-04\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+        2.35E-04  2.66E-03  9.22E-04 -1.85E-05  1.46E-04 .........  5.39E-05 -4.49E-05 .........  5.47E-04\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n ********************                          CORRELATION MATRIX OF ESTIMATE                        ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        8.05E-02\n \n TH 2\n+       -1.13E-01  2.85E+00\n \n TH 3\n+       -6.39E-02 -2.97E-01  2.83E+01\n \n TH 4\n+       -1.96E-01 -5.83E-02  2.76E-01  8.25E-03\n \n TH 5\n+        2.09E-01  7.21E-03 -1.93E-01 -8.56E-01  8.60E-02\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+        7.18E-02 -5.91E-01  1.49E-01 -1.10E-01  3.08E-02 .........  3.87E-02\n \n OM11\n+       -2.55E-01 -1.31E-01  1.35E-01  3.19E-01 -3.88E-01 .........  2.41E-01  1.09E-02\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+        1.25E-01  4.00E-02  1.39E-03 -9.57E-02  7.25E-02 .........  5.96E-02 -1.76E-01 .........  2.34E-02\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n ********************                      INVERSE COVARIANCE MATRIX OF ESTIMATE                     ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n            TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  \n \n TH 1\n+        1.74E+02\n \n TH 2\n+        7.09E-01  2.17E-01\n \n TH 3\n+        2.71E-02  3.99E-03  1.50E-03\n \n TH 4\n+        1.04E+02  2.26E+01 -1.91E+00  6.29E+04\n \n TH 5\n+       -8.84E+00  1.74E+00 -7.13E-02  4.97E+03  5.62E+02\n \n TH 6\n+       ......... ......... ......... ......... ......... .........\n \n TH 7\n+       -1.25E+01  9.50E+00 -2.38E-02  2.32E+03  1.29E+02 .........  1.20E+03\n \n OM11\n+        2.82E+02 -1.72E+00 -1.07E-01 -1.90E+02  4.89E+02 ......... -9.57E+02  1.15E+04\n \n OM12\n+       ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n OM22\n+       -4.79E+01 -2.15E+00 -8.55E-02  4.04E+02  4.10E+01 ......... -1.94E+02  7.92E+02 .........  1.95E+03\n \n SG11\n+       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........\n \n1\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ************************************************************************************************************************\n ********************                                                                                ********************\n ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************\n ********************                      EIGENVALUES OF COR MATRIX OF ESTIMATE                     ********************\n ********************                                                                                ********************\n ************************************************************************************************************************\n \n             1         2         3         4         5         6         7         8\n \n         1.25E-01  3.52E-01  5.92E-01  8.38E-01  8.84E-01  1.10E+00  1.75E+00  2.36E+00\n \n Elapsed finaloutput time in seconds:     0.30\n #CPUT: Total CPU Time in Seconds,      359.688\nStop Time: \n14/09/2023 \n12:36"
## attr(,"class")
## [1] "lst"
```

``` r
"run105" %>% read_lst() %>% writeLines()
```

```
## 14/09/2023 
## 12:29
## ;; 1. Based on: 102
## ;; 2. Description: 
## ;;    PK model 1 cmt - WT-CL allom SEX-CL
## ;; 3. Label:
## ;;    
## ;; 4. Structural model:
## ;; 5. Covariate model:
## ;; 6. Inter-individual variability:
## ;; 7. Inter-occasion variability:
## ;; 8. Residual variability:
## ;; 9. Estimation:
## $PROBLEM    PK model 1 cmt base
## $INPUT      ID TIME MDV EVID DV AMT SEX WT ETN
## $DATA      acop.csv IGNORE=@
## $SUBROUTINE ADVAN2 TRANS2
## $PK
## ET=1
## IF(ETN.EQ.3) ET=1.3
## KA = THETA(1)
## CL = THETA(2)*((WT/70)**THETA(6))*( THETA(7)**SEX) * EXP(ETA(1))
## V = THETA(3)*EXP(ETA(2))
## SC=V
## $THETA  (0,2) ; KA; 1/h; LIN ;Absorption Rate Constant
##  (0,20) ; CL; L/h; LIN ;Clearance
##  (0,100) ; V2; L; LIN ;Volume of Distribution
##  0.02 ; RUVp; ; LIN ;Proportional Error
##  1 ; RUVa; ng/mL; LIN ;Additive Error
##  0.75 FIX ; CL-WT; ; LIN ;Power Scalar CL-WT
##  (0,1) ; CL-SEX; ; LIN ;Female CL Change
## $OMEGA  0.05  ;     iiv CL
##  0.2  ;     iiv V2
## $SIGMA  1  FIX
## $ERROR
## IPRED = F
## IRES = DV-IPRED
## W = IPRED*THETA(4) + THETA(5)
## IF (W.EQ.0) W = 1
## IWRES = IRES/W
## Y= IPRED+W*ERR(1)
## $ESTIMATION METHOD=SAEM INTER NBURN=3000 NITER=500 PRINT=100
## $ESTIMATION METHOD=IMP INTER EONLY=1 NITER=5 ISAMPLE=3000 PRINT=1
##             SIGL=8 NOPRIOR=1
## $ESTIMATION METHOD=1 INTER MAXEVAL=9999 SIG=3 PRINT=5 NOABORT POSTHOC
## $COVARIANCE PRINT=E UNCONDITIONAL
## $TABLE      ID TIME DV MDV EVID IPRED IWRES CWRES ONEHEADER NOPRINT
##             FILE=sdtab105
## $TABLE      ID CL V KA ETAS(1:LAST) ONEHEADER NOPRINT FILE=patab105
## $TABLE      ID SEX ETN ONEHEADER NOPRINT FILE=catab105
## $TABLE      ID WT ONEHEADER NOPRINT FILE=cotab105
##   
## NM-TRAN MESSAGES 
##   
##  WARNINGS AND ERRORS (IF ANY) FOR PROBLEM    1
##              
##  (WARNING  2) NM-TRAN INFERS THAT THE DATA ARE POPULATION.
##   
## License Registered to: qPharmetra
## Expiration Date:    14 JUL 2024
## Current Date:       14 SEP 2023
## Days until program expires : 305
## 1NONLINEAR MIXED EFFECTS MODEL PROGRAM (NONMEM) VERSION 7.4.3
##  ORIGINALLY DEVELOPED BY STUART BEAL, LEWIS SHEINER, AND ALISON BOECKMANN
##  CURRENT DEVELOPERS ARE ROBERT BAUER, ICON DEVELOPMENT SOLUTIONS,
##  AND ALISON BOECKMANN. IMPLEMENTATION, EFFICIENCY, AND STANDARDIZATION
##  PERFORMED BY NOUS INFOSYSTEMS.
##  PROBLEM NO.:         1
##  PK model 1 cmt base
## 0DATA CHECKOUT RUN:              NO
##  DATA SET LOCATED ON UNIT NO.:    2
##  THIS UNIT TO BE REWOUND:        NO
##  NO. OF DATA RECS IN DATA SET:      800
##  NO. OF DATA ITEMS IN DATA SET:   9
##  ID DATA ITEM IS DATA ITEM NO.:   1
##  DEP VARIABLE IS DATA ITEM NO.:   5
##  MDV DATA ITEM IS DATA ITEM NO.:  3
## 0INDICES PASSED TO SUBROUTINE PRED:
##    4   2   6   0   0   0   0   0   0   0   0
## 0LABELS FOR DATA ITEMS:
##  ID TIME MDV EVID DV AMT SEX WT ETN
## 0(NONBLANK) LABELS FOR PRED-DEFINED ITEMS:
##  KA CL V IPRED IWRES
## 0FORMAT FOR DATA:
##  (E3.0,E5.0,2E2.0,E10.0,E6.0,E2.0,E5.0,E2.0)
##  TOT. NO. OF OBS RECS:      760
##  TOT. NO. OF INDIVIDUALS:       40
## 0LENGTH OF THETA:   7
## 0DEFAULT THETA BOUNDARY TEST OMITTED:    NO
## 0OMEGA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   2
## 0DEFAULT OMEGA BOUNDARY TEST OMITTED:    NO
## 0SIGMA HAS SIMPLE DIAGONAL FORM WITH DIMENSION:   1
## 0DEFAULT SIGMA BOUNDARY TEST OMITTED:    NO
## 0INITIAL ESTIMATE OF THETA:
##  LOWER BOUND    INITIAL EST    UPPER BOUND
##   0.0000E+00     0.2000E+01     0.1000E+07
##   0.0000E+00     0.2000E+02     0.1000E+07
##   0.0000E+00     0.1000E+03     0.1000E+07
##  -0.1000E+07     0.2000E-01     0.1000E+07
##  -0.1000E+07     0.1000E+01     0.1000E+07
##   0.7500E+00     0.7500E+00     0.7500E+00
##   0.0000E+00     0.1000E+01     0.1000E+07
## 0INITIAL ESTIMATE OF OMEGA:
##  0.5000E-01
##  0.0000E+00   0.2000E+00
## 0INITIAL ESTIMATE OF SIGMA:
##  0.1000E+01
## 0SIGMA CONSTRAINED TO BE THIS INITIAL ESTIMATE
## 0COVARIANCE STEP OMITTED:        NO
##  EIGENVLS. PRINTED:             YES
##  SPECIAL COMPUTATION:            NO
##  COMPRESSED FORMAT:              NO
##  GRADIENT METHOD USED:     NOSLOW
##  SIGDIGITS ETAHAT (SIGLO):                  -1
##  SIGDIGITS GRADIENTS (SIGL):                -1
##  EXCLUDE COV FOR FOCE (NOFCOV):              NO
##  TURN OFF Cholesky Transposition of R Matrix (CHOLROFF): NO
##  KNUTHSUMOFF:                                -1
##  RESUME COV ANALYSIS (RESUME):               NO
##  SIR SAMPLE SIZE (SIRSAMPLE):              -1
##  NON-LINEARLY TRANSFORM THETAS DURING COV (THBND): 1
##  PRECONDTIONING CYCLES (PRECOND):        0
##  PRECONDTIONING TYPES (PRECONDS):        TOS
##  FORCED PRECONDTIONING CYCLES (PFCOND):0
##  PRECONDTIONING TYPE (PRETYPE):        0
##  FORCED POS. DEFINITE SETTING: (FPOSDEF):0
## 0TABLES STEP OMITTED:    NO
##  NO. OF TABLES:           4
##  SEED NUMBER (SEED):    11456
##  RANMETHOD:             3U
##  MC SAMPLES (ESAMPLE):    300
##  WRES SQUARE ROOT TYPE (WRESCHOL): EIGENVALUE
## 0-- TABLE   1 --
## 0RECORDS ONLY:    ALL
## 04 COLUMNS APPENDED:    YES
##  PRINTED:                NO
##  HEADER:                YES
##  FILE TO BE FORWARDED:   NO
##  FORMAT:                S1PE11.4
##  LFORMAT:
##  RFORMAT:
##  FIXED_EFFECT_ETAS:
## 0USER-CHOSEN ITEMS:
##  ID TIME DV MDV EVID IPRED IWRES CWRES
## 0-- TABLE   2 --
## 0RECORDS ONLY:    ALL
## 04 COLUMNS APPENDED:    YES
##  PRINTED:                NO
##  HEADER:                YES
##  FILE TO BE FORWARDED:   NO
##  FORMAT:                S1PE11.4
##  LFORMAT:
##  RFORMAT:
##  FIXED_EFFECT_ETAS:
## 0USER-CHOSEN ITEMS:
##  ID CL V KA ETA1 ETA2
## 0-- TABLE   3 --
## 0RECORDS ONLY:    ALL
## 04 COLUMNS APPENDED:    YES
##  PRINTED:                NO
##  HEADER:                YES
##  FILE TO BE FORWARDED:   NO
##  FORMAT:                S1PE11.4
##  LFORMAT:
##  RFORMAT:
##  FIXED_EFFECT_ETAS:
## 0USER-CHOSEN ITEMS:
##  ID SEX ETN
## 0-- TABLE   4 --
## 0RECORDS ONLY:    ALL
## 04 COLUMNS APPENDED:    YES
##  PRINTED:                NO
##  HEADER:                YES
##  FILE TO BE FORWARDED:   NO
##  FORMAT:                S1PE11.4
##  LFORMAT:
##  RFORMAT:
##  FIXED_EFFECT_ETAS:
## 0USER-CHOSEN ITEMS:
##  ID WT
## 1DOUBLE PRECISION PREDPP VERSION 7.4.3
##  ONE COMPARTMENT MODEL WITH FIRST-ORDER ABSORPTION (ADVAN2)
## 0MAXIMUM NO. OF BASIC PK PARAMETERS:   3
## 0BASIC PK PARAMETERS (AFTER TRANSLATION):
##    ELIMINATION RATE (K) IS BASIC PK PARAMETER NO.:  1
##    ABSORPTION RATE (KA) IS BASIC PK PARAMETER NO.:  3
##  TRANSLATOR WILL CONVERT PARAMETERS
##  CLEARANCE (CL) AND VOLUME (V) TO K (TRANS2)
## 0COMPARTMENT ATTRIBUTES
##  COMPT. NO.   FUNCTION   INITIAL    ON/OFF      DOSE      DEFAULT    DEFAULT
##                          STATUS     ALLOWED    ALLOWED    FOR DOSE   FOR OBS.
##     1         DEPOT        OFF        YES        YES        YES        NO
##     2         CENTRAL      ON         NO         YES        NO         YES
##     3         OUTPUT       OFF        YES        NO         NO         NO
## 1
##  ADDITIONAL PK PARAMETERS - ASSIGNMENT OF ROWS IN GG
##  COMPT. NO.                             INDICES
##               SCALE      BIOAVAIL.   ZERO-ORDER  ZERO-ORDER  ABSORB
##                          FRACTION    RATE        DURATION    LAG
##     1            *           *           *           *           *
##     2            4           *           *           *           *
##     3            *           -           -           -           -
##              - PARAMETER IS NOT ALLOWED FOR THIS MODEL
##              * PARAMETER IS NOT SUPPLIED BY PK SUBROUTINE;
##                WILL DEFAULT TO ONE IF APPLICABLE
## 0DATA ITEM INDICES USED BY PRED ARE:
##    EVENT ID DATA ITEM IS DATA ITEM NO.:      4
##    TIME DATA ITEM IS DATA ITEM NO.:          2
##    DOSE AMOUNT DATA ITEM IS DATA ITEM NO.:   6
## 0PK SUBROUTINE CALLED WITH EVERY EVENT RECORD.
##  PK SUBROUTINE NOT CALLED AT NONEVENT (ADDITIONAL OR LAGGED) DOSE TIMES.
## 0ERROR SUBROUTINE CALLED WITH EVERY EVENT RECORD.
## 1
##  #TBLN:      1
##  #METH: Stochastic Approximation Expectation-Maximization
##  ESTIMATION STEP OMITTED:                 NO
##  ANALYSIS TYPE:                           POPULATION
##  NUMBER OF SADDLE POINT RESET ITERATIONS:      0
##  GRADIENT METHOD USED:               NOSLOW
##  CONDITIONAL ESTIMATES USED:              YES
##  CENTERED ETA:                            NO
##  EPS-ETA INTERACTION:                     YES
##  LAPLACIAN OBJ. FUNC.:                    NO
##  NO. OF FUNCT. EVALS. ALLOWED:            624
##  NO. OF SIG. FIGURES REQUIRED:            3
##  INTERMEDIATE PRINTOUT:                   YES
##  ESTIMATE OUTPUT TO MSF:                  NO
##  IND. OBJ. FUNC. VALUES SORTED:           NO
##  NUMERICAL DERIVATIVE
##        FILE REQUEST (NUMDER):               NONE
##  MAP (ETAHAT) ESTIMATION METHOD (OPTMAP):   0
##  ETA HESSIAN EVALUATION METHOD (ETADER):    0
##  INITIAL ETA FOR MAP ESTIMATION (MCETA):    0
##  SIGDIGITS FOR MAP ESTIMATION (SIGLO):      100
##  GRADIENT SIGDIGITS OF
##        FIXED EFFECTS PARAMETERS (SIGL):     100
##  NOPRIOR SETTING (NOPRIOR):                 OFF
##  NOCOV SETTING (NOCOV):                     OFF
##  DERCONT SETTING (DERCONT):                 OFF
##  FINAL ETA RE-EVALUATION (FNLETA):          ON
##  EXCLUDE NON-INFLUENTIAL (NON-INFL.) ETAS
##        IN SHRINKAGE (ETASTYPE):             NO
##  NON-INFL. ETA CORRECTION (NONINFETA):      OFF
##  RAW OUTPUT FILE (FILE): psn.ext
##  EXCLUDE TITLE (NOTITLE):                   NO
##  EXCLUDE COLUMN LABELS (NOLABEL):           NO
##  FORMAT FOR ADDITIONAL FILES (FORMAT):      S1PE12.5
##  PARAMETER ORDER FOR OUTPUTS (ORDER):       TSOL
##  WISHART PRIOR DF INTERPRETATION (WISHTYPE):0
##  KNUTHSUMOFF:                               0
##  INCLUDE LNTWOPI:                           NO
##  INCLUDE CONSTANT TERM TO PRIOR (PRIORC):   NO
##  INCLUDE CONSTANT TERM TO OMEGA (ETA) (OLNTWOPI):NO
##  EM OR BAYESIAN METHOD USED:                STOCHASTIC APPROXIMATION EXPECTATION MAXIMIZATION (SAEM)
##  MU MODELING PATTERN (MUM):
##  GRADIENT/GIBBS PATTERN (GRD):
##  AUTOMATIC SETTING FEATURE (AUTO):          OFF
##  CONVERGENCE TYPE (CTYPE):                  0
##  BURN-IN ITERATIONS (NBURN):                3000
##  ITERATIONS (NITER):                        500
##  ANEAL SETTING (CONSTRAIN):                 1
##  STARTING SEED FOR MC METHODS (SEED):       11456
##  MC SAMPLES PER SUBJECT (ISAMPLE):          2
##  RANDOM SAMPLING METHOD (RANMETHOD):        3U
##  EXPECTATION ONLY (EONLY):                  0
##  PROPOSAL DENSITY SCALING RANGE
##               (ISCALE_MIN, ISCALE_MAX):     1.000000000000000E-06   ,1000000.00000000
##  SAMPLE ACCEPTANCE RATE (IACCEPT):          0.400000000000000
##  METROPOLIS HASTINGS SAMPLING FOR INDIVIDUAL ETAS:
##  SAMPLES FOR GLOBAL SEARCH KERNEL (ISAMPLE_M1):          2
##  SAMPLES FOR NEIGHBOR SEARCH KERNEL (ISAMPLE_M1A):       0
##  SAMPLES FOR MASS/IMP/POST. MATRIX SEARCH (ISAMPLE_M1B): 2
##  SAMPLES FOR LOCAL SEARCH KERNEL (ISAMPLE_M2):           2
##  SAMPLES FOR LOCAL UNIVARIATE KERNEL (ISAMPLE_M3):       2
##  PWR. WT. MASS/IMP/POST MATRIX ACCUM. FOR ETAS (IKAPPA): 1.00000000000000
##  MASS/IMP./POST. MATRIX REFRESH SETTING (MASSREST):      -1
##  THE FOLLOWING LABELS ARE EQUIVALENT
##  PRED=PREDI
##  RES=RESI
##  WRES=WRESI
##  IWRS=IWRESI
##  IPRD=IPREDI
##  IRS=IRESI
##  EM/BAYES SETUP:
##  THETAS THAT ARE MU MODELED:
##  
##  THETAS THAT ARE SIGMA-LIKE:
##  
##  MONITORING OF SEARCH:
##  Stochastic/Burn-in Mode
##  iteration        -3000  SAEMOBJ=   37880.578399081634
##  iteration        -2900  SAEMOBJ=   1819.9797813209129
##  iteration        -2800  SAEMOBJ=   1775.7623169685935
##  iteration        -2700  SAEMOBJ=   1762.6348116922927
##  iteration        -2600  SAEMOBJ=   1756.5962068838376
##  iteration        -2500  SAEMOBJ=   1738.7137277621491
##  iteration        -2400  SAEMOBJ=   1738.8232940947819
##  iteration        -2300  SAEMOBJ=   1748.4815457049922
##  iteration        -2200  SAEMOBJ=   1710.3493739249757
##  iteration        -2100  SAEMOBJ=   1678.3150276961987
##  iteration        -2000  SAEMOBJ=   1660.7697562928051
##  iteration        -1900  SAEMOBJ=   1670.6905203533120
##  iteration        -1800  SAEMOBJ=   1676.5422115195090
##  iteration        -1700  SAEMOBJ=   1679.9175463929050
##  iteration        -1600  SAEMOBJ=   1666.1447026518115
##  iteration        -1500  SAEMOBJ=   1678.2053340635484
##  iteration        -1400  SAEMOBJ=   1684.4738496434206
##  iteration        -1300  SAEMOBJ=   1666.7514702127837
##  iteration        -1200  SAEMOBJ=   1665.1358146630539
##  iteration        -1100  SAEMOBJ=   1663.2056797589910
##  iteration        -1000  SAEMOBJ=   1676.0512289498085
##  iteration         -900  SAEMOBJ=   1656.5899185787312
##  iteration         -800  SAEMOBJ=   1660.9547108389204
##  iteration         -700  SAEMOBJ=   1664.7104693758502
##  iteration         -600  SAEMOBJ=   1670.7599984097280
##  iteration         -500  SAEMOBJ=   1664.0882947137266
##  iteration         -400  SAEMOBJ=   1669.3760024849835
##  iteration         -300  SAEMOBJ=   1665.6498136784967
##  iteration         -200  SAEMOBJ=   1668.4572104514200
##  iteration         -100  SAEMOBJ=   1661.0589433728653
##  Reduced Stochastic/Accumulation Mode
##  iteration            0  SAEMOBJ=   1667.0797458880336
##  iteration          100  SAEMOBJ=   1654.0501788529286
##  iteration          200  SAEMOBJ=   1654.1064511390723
##  iteration          300  SAEMOBJ=   1653.9436158865042
##  iteration          400  SAEMOBJ=   1653.9493430311197
##  iteration          500  SAEMOBJ=   1653.7461440391669
##  #TERM:
##  STOCHASTIC PORTION WAS NOT TESTED FOR CONVERGENCE
##  REDUCED STOCHASTIC PORTION WAS COMPLETED
##  ETABAR IS THE ARITHMETIC MEAN OF THE ETA-ESTIMATES,
##  AND THE P-VALUE IS GIVEN FOR THE NULL HYPOTHESIS THAT THE TRUE MEAN IS 0.
##  ETABAR:         5.1052E-03 -2.6889E-02
##  SE:             2.6115E-02  5.9862E-02
##  N:                      40          40
##  P VAL.:         8.4501E-01  6.5330E-01
##  ETASHRINKSD(%)  1.3076E+01  9.7483E-01
##  ETASHRINKVR(%)  2.4443E+01  1.9401E+00
##  EBVSHRINKSD(%)  1.3034E+01  7.2605E-01
##  EBVSHRINKVR(%)  2.4369E+01  1.4468E+00
##  EPSSHRINKSD(%)  4.5935E+00
##  EPSSHRINKVR(%)  8.9760E+00
##   
##  TOTAL DATA POINTS NORMALLY DISTRIBUTED (N):          760
##  N*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    1396.7865704711026     
##  OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    1653.7461440391669     
##  OBJECTIVE FUNCTION VALUE WITH CONSTANT:       3050.5327145102692     
##  REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT
##   
##  TOTAL EFFECTIVE ETAS (NIND*NETA):                            80
##  NIND*NETA*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    147.03016531274761     
##  OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    1653.7461440391669     
##  OBJECTIVE FUNCTION VALUE WITH CONSTANT:       1800.7763093519145     
##  REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT
##   
##  #TERE:
##  Elapsed estimation  time in seconds:   126.02
##  Elapsed covariance  time in seconds:     0.02
## 1
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  #OBJT:**************                        FINAL VALUE OF LIKELIHOOD FUNCTION                      ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  #OBJV:********************************************     1653.746       **************************************************
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  ********************                             FINAL PARAMETER ESTIMATE                           ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********
##          TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     
##  
##          2.26E+00  7.26E+01  4.80E+02  7.17E-02  1.09E+00  7.50E-01  6.00E-01
##  
##  OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********
##          ETA1      ETA2     
##  
##  ETA1
## +        3.70E-02
##  
##  ETA2
## +        0.00E+00  1.50E-01
##  
##  SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****
##          EPS1     
##  
##  EPS1
## +        1.00E+00
##  
## 1
##  OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******
##          ETA1      ETA2     
##  
##  ETA1
## +        1.92E-01
##  
##  ETA2
## +        0.00E+00  3.87E-01
##  
##  SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***
##          EPS1     
##  
##  EPS1
## +        1.00E+00
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  ********************                          STANDARD ERROR OF ESTIMATE (S)                        ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********
##          TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     
##  
##          6.48E-02  5.36E+00  3.23E+01  7.65E-03  1.00E-01  0.00E+00  5.10E-02
##  
##  OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********
##          ETA1      ETA2     
##  
##  ETA1
## +        1.32E-02
##  
##  ETA2
## +        0.00E+00  5.00E-02
##  
##  SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****
##          EPS1     
##  
##  EPS1
## +        0.00E+00
##  
## 1
##  OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******
##          ETA1      ETA2     
##  
##  ETA1
## +        3.42E-02
##  
##  ETA2
## +       .........  6.46E-02
##  
##  SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***
##          EPS1     
##  
##  EPS1
## +       .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  ********************                        COVARIANCE MATRIX OF ESTIMATE (S)                       ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        4.20E-03
##  
##  TH 2
## +       -1.40E-04  2.88E+01
##  
##  TH 3
## +        4.53E-01  3.39E+01  1.04E+03
##  
##  TH 4
## +        4.63E-05  1.32E-04 -5.65E-02  5.86E-05
##  
##  TH 5
## +       -8.45E-04  5.09E-02  4.07E-01 -6.15E-04  1.00E-02
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +       -4.00E-04 -2.35E-01 -4.32E-01  4.33E-05 -4.56E-04  0.00E+00  2.60E-03
##  
##  OM11
## +        1.91E-04 -1.17E-03  2.04E-04 -2.60E-05  2.71E-04  0.00E+00 -9.50E-05  1.74E-04
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +       -3.40E-04 -2.60E-02  1.16E-01 -1.32E-05  1.79E-04  0.00E+00  2.88E-05  1.14E-04  0.00E+00  2.50E-03
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  ********************                        CORRELATION MATRIX OF ESTIMATE (S)                      ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        6.48E-02
##  
##  TH 2
## +       -4.02E-04  5.36E+00
##  
##  TH 3
## +        2.17E-01  1.96E-01  3.23E+01
##  
##  TH 4
## +        9.34E-02  3.22E-03 -2.29E-01  7.65E-03
##  
##  TH 5
## +       -1.30E-01  9.47E-02  1.26E-01 -8.02E-01  1.00E-01
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +       -1.21E-01 -8.58E-01 -2.63E-01  1.11E-01 -8.92E-02  0.00E+00  5.10E-02
##  
##  OM11
## +        2.24E-01 -1.66E-02  4.80E-04 -2.58E-01  2.06E-01  0.00E+00 -1.41E-01  1.32E-02
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +       -1.05E-01 -9.71E-02  7.20E-02 -3.45E-02  3.58E-02  0.00E+00  1.13E-02  1.73E-01  0.00E+00  5.00E-02
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  ********************                    INVERSE COVARIANCE MATRIX OF ESTIMATE (S)                   ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        3.00E+02
##  
##  TH 2
## +        1.41E+00  1.73E-01
##  
##  TH 3
## +       -1.61E-01 -7.80E-04  1.20E-03
##  
##  TH 4
## +       -6.57E+02 -3.68E+01  2.02E+00  5.99E+04
##  
##  TH 5
## +        1.85E-01 -2.43E+00  5.83E-02  3.50E+03  3.17E+02
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +        1.42E+02  1.61E+01  1.00E-01 -3.37E+03 -2.15E+02  0.00E+00  1.92E+03
##  
##  OM11
## +       -3.92E+02  5.68E+00  5.05E-01  2.50E+03 -8.86E+01  0.00E+00  7.53E+02  7.38E+03
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +        7.57E+01  1.56E+00 -1.03E-01 -5.76E+02 -2.57E+01  0.00E+00  1.23E+02 -3.43E+02  0.00E+00  4.44E+02
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************                STOCHASTIC APPROXIMATION EXPECTATION-MAXIMIZATION               ********************
##  ********************                    EIGENVALUES OF COR MATRIX OF ESTIMATE (S)                   ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##              1         2         3         4         5         6         7         8
##  
##          9.15E-02  2.12E-01  4.85E-01  9.43E-01  1.05E+00  1.24E+00  1.78E+00  2.20E+00
##  
## 1
##  #TBLN:      2
##  #METH: Objective Function Evaluation by Importance Sampling (No Prior)
##  ESTIMATION STEP OMITTED:                 NO
##  ANALYSIS TYPE:                           POPULATION
##  NUMBER OF SADDLE POINT RESET ITERATIONS:      0
##  GRADIENT METHOD USED:               NOSLOW
##  CONDITIONAL ESTIMATES USED:              YES
##  CENTERED ETA:                            NO
##  EPS-ETA INTERACTION:                     YES
##  LAPLACIAN OBJ. FUNC.:                    NO
##  NO. OF FUNCT. EVALS. ALLOWED:            624
##  NO. OF SIG. FIGURES REQUIRED:            3
##  INTERMEDIATE PRINTOUT:                   YES
##  ESTIMATE OUTPUT TO MSF:                  NO
##  IND. OBJ. FUNC. VALUES SORTED:           NO
##  NUMERICAL DERIVATIVE
##        FILE REQUEST (NUMDER):               NONE
##  MAP (ETAHAT) ESTIMATION METHOD (OPTMAP):   0
##  ETA HESSIAN EVALUATION METHOD (ETADER):    0
##  INITIAL ETA FOR MAP ESTIMATION (MCETA):    0
##  SIGDIGITS FOR MAP ESTIMATION (SIGLO):      8
##  GRADIENT SIGDIGITS OF
##        FIXED EFFECTS PARAMETERS (SIGL):     8
##  NOPRIOR SETTING (NOPRIOR):                 ON
##  NOCOV SETTING (NOCOV):                     OFF
##  DERCONT SETTING (DERCONT):                 OFF
##  FINAL ETA RE-EVALUATION (FNLETA):          ON
##  EXCLUDE NON-INFLUENTIAL (NON-INFL.) ETAS
##        IN SHRINKAGE (ETASTYPE):             NO
##  NON-INFL. ETA CORRECTION (NONINFETA):      OFF
##  RAW OUTPUT FILE (FILE): psn.ext
##  EXCLUDE TITLE (NOTITLE):                   NO
##  EXCLUDE COLUMN LABELS (NOLABEL):           NO
##  FORMAT FOR ADDITIONAL FILES (FORMAT):      S1PE12.5
##  PARAMETER ORDER FOR OUTPUTS (ORDER):       TSOL
##  WISHART PRIOR DF INTERPRETATION (WISHTYPE):0
##  KNUTHSUMOFF:                               0
##  INCLUDE LNTWOPI:                           NO
##  INCLUDE CONSTANT TERM TO PRIOR (PRIORC):   NO
##  INCLUDE CONSTANT TERM TO OMEGA (ETA) (OLNTWOPI):NO
##  EM OR BAYESIAN METHOD USED:                IMPORTANCE SAMPLING (IMP)
##  MU MODELING PATTERN (MUM):
##  GRADIENT/GIBBS PATTERN (GRD):
##  AUTOMATIC SETTING FEATURE (AUTO):          OFF
##  CONVERGENCE TYPE (CTYPE):                  0
##  ITERATIONS (NITER):                        5
##  ANEAL SETTING (CONSTRAIN):                 1
##  STARTING SEED FOR MC METHODS (SEED):       11456
##  MC SAMPLES PER SUBJECT (ISAMPLE):          3000
##  RANDOM SAMPLING METHOD (RANMETHOD):        3U
##  EXPECTATION ONLY (EONLY):                  1
##  PROPOSAL DENSITY SCALING RANGE
##               (ISCALE_MIN, ISCALE_MAX):     0.100000000000000       ,10.0000000000000
##  SAMPLE ACCEPTANCE RATE (IACCEPT):          0.400000000000000
##  LONG TAIL SAMPLE ACCEPT. RATE (IACCEPTL):   0.00000000000000
##  T-DIST. PROPOSAL DENSITY (DF):             0
##  NO. ITERATIONS FOR MAP (MAPITER):          1
##  INTERVAL ITER. FOR MAP (MAPINTER):         0
##  MAP COVARIANCE/MODE SETTING (MAPCOV):      1
##  Gradient Quick Value (GRDQ):               0.00000000000000
##  THE FOLLOWING LABELS ARE EQUIVALENT
##  PRED=PREDI
##  RES=RESI
##  WRES=WRESI
##  IWRS=IWRESI
##  IPRD=IPREDI
##  IRS=IRESI
##  EM/BAYES SETUP:
##  THETAS THAT ARE MU MODELED:
##  
##  THETAS THAT ARE SIGMA-LIKE:
##  
##  MONITORING OF SEARCH:
##  iteration            0  OBJ=   2042.2787689427023 eff.=    3002. Smpl.=    3000. Fit.= 0.98929
##  iteration            1  OBJ=   2042.1984488958581 eff.=    1202. Smpl.=    3000. Fit.= 0.78696
##  iteration            2  OBJ=   2042.3797207602163 eff.=    1193. Smpl.=    3000. Fit.= 0.78587
##  iteration            3  OBJ=   2042.3247305602517 eff.=    1195. Smpl.=    3000. Fit.= 0.78567
##  iteration            4  OBJ=   2042.1527399552278 eff.=    1198. Smpl.=    3000. Fit.= 0.78582
##  iteration            5  OBJ=   2042.4148330855062 eff.=    1196. Smpl.=    3000. Fit.= 0.78648
##  #TERM:
##  EXPECTATION ONLY PROCESS COMPLETED
##  ETABAR IS THE ARITHMETIC MEAN OF THE ETA-ESTIMATES,
##  AND THE P-VALUE IS GIVEN FOR THE NULL HYPOTHESIS THAT THE TRUE MEAN IS 0.
##  ETABAR:         3.7682E-03 -2.6665E-02
##  SE:             2.6396E-02  5.9870E-02
##  N:                      40          40
##  P VAL.:         8.8648E-01  6.5605E-01
##  ETASHRINKSD(%)  1.2142E+01  9.6263E-01
##  ETASHRINKVR(%)  2.2809E+01  1.9160E+00
##  EBVSHRINKSD(%)  1.3093E+01  7.2078E-01
##  EBVSHRINKVR(%)  2.4471E+01  1.4364E+00
##  EPSSHRINKSD(%)  4.6618E+00
##  EPSSHRINKVR(%)  9.1063E+00
##   
##  TOTAL DATA POINTS NORMALLY DISTRIBUTED (N):          760
##  N*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    1396.7865704711026     
##  OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    2042.4148330855062     
##  OBJECTIVE FUNCTION VALUE WITH CONSTANT:       3439.2014035566090     
##  REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT
##   
##  TOTAL EFFECTIVE ETAS (NIND*NETA):                            80
##   
##  #TERE:
##  Elapsed estimation  time in seconds:    13.97
##  Elapsed covariance  time in seconds:   222.13
## 1
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  #OBJT:**************                        FINAL VALUE OF OBJECTIVE FUNCTION                       ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  #OBJV:********************************************     2042.415       **************************************************
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  ********************                             FINAL PARAMETER ESTIMATE                           ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********
##          TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     
##  
##          2.26E+00  7.26E+01  4.80E+02  7.17E-02  1.09E+00  7.50E-01  6.00E-01
##  
##  OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********
##          ETA1      ETA2     
##  
##  ETA1
## +        3.70E-02
##  
##  ETA2
## +        0.00E+00  1.50E-01
##  
##  SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****
##          EPS1     
##  
##  EPS1
## +        1.00E+00
##  
## 1
##  OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******
##          ETA1      ETA2     
##  
##  ETA1
## +        1.92E-01
##  
##  ETA2
## +        0.00E+00  3.87E-01
##  
##  SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***
##          EPS1     
##  
##  EPS1
## +        1.00E+00
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  ********************                         STANDARD ERROR OF ESTIMATE (RSR)                       ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********
##          TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     
##  
##          7.94E-02  3.06E+00  2.52E+01  8.20E-03  8.51E-02  0.00E+00  4.09E-02
##  
##  OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********
##          ETA1      ETA2     
##  
##  ETA1
## +        1.20E-02
##  
##  ETA2
## +        0.00E+00  2.36E-02
##  
##  SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****
##          EPS1     
##  
##  EPS1
## +        0.00E+00
##  
## 1
##  OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******
##          ETA1      ETA2     
##  
##  ETA1
## +        3.12E-02
##  
##  ETA2
## +       .........  3.05E-02
##  
##  SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***
##          EPS1     
##  
##  EPS1
## +       .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  ********************                       COVARIANCE MATRIX OF ESTIMATE (RSR)                      ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        6.31E-03
##  
##  TH 2
## +       -2.09E-02  9.39E+00
##  
##  TH 3
## +       -1.00E-01 -1.75E+01  6.36E+02
##  
##  TH 4
## +       -1.24E-04 -2.80E-03  5.29E-02  6.72E-05
##  
##  TH 5
## +        1.34E-03  1.39E-02 -3.55E-01 -5.97E-04  7.25E-03
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +        2.04E-04 -8.11E-02  1.52E-01 -2.66E-05  6.48E-05  0.00E+00  1.68E-03
##  
##  OM11
## +       -1.98E-04 -6.64E-03 -1.78E-02  2.75E-05 -3.54E-04  0.00E+00  1.12E-04  1.44E-04
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +        2.58E-04  1.16E-02 -2.00E-02 -2.33E-05  1.91E-04  0.00E+00 -4.11E-05 -4.59E-05  0.00E+00  5.56E-04
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  ********************                       CORRELATION MATRIX OF ESTIMATE (RSR)                     ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        7.94E-02
##  
##  TH 2
## +       -8.57E-02  3.06E+00
##  
##  TH 3
## +       -4.99E-02 -2.26E-01  2.52E+01
##  
##  TH 4
## +       -1.90E-01 -1.11E-01  2.56E-01  8.20E-03
##  
##  TH 5
## +        1.98E-01  5.32E-02 -1.65E-01 -8.55E-01  8.51E-02
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +        6.28E-02 -6.47E-01  1.47E-01 -7.93E-02  1.86E-02  0.00E+00  4.09E-02
##  
##  OM11
## +       -2.08E-01 -1.80E-01 -5.87E-02  2.79E-01 -3.46E-01  0.00E+00  2.27E-01  1.20E-02
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +        1.38E-01  1.61E-01 -3.36E-02 -1.20E-01  9.50E-02  0.00E+00 -4.25E-02 -1.62E-01  0.00E+00  2.36E-02
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  ********************                   INVERSE COVARIANCE MATRIX OF ESTIMATE (RSR)                  ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        1.76E+02
##  
##  TH 2
## +        7.18E-01  2.09E-01
##  
##  TH 3
## +        3.57E-02  2.19E-03  1.85E-03
##  
##  TH 4
## +        1.37E+02  2.74E+01 -2.30E+00  6.38E+04
##  
##  TH 5
## +       -8.59E+00  1.90E+00 -7.14E-02  5.01E+03  5.63E+02
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +       -3.21E+00  1.00E+01 -1.50E-01  2.37E+03  1.31E+02  0.00E+00  1.17E+03
##  
##  OM11
## +        2.12E+02  1.53E+00  7.51E-01 -3.94E+02  4.00E+02  0.00E+00 -6.37E+02  9.09E+03
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +       -6.93E+01 -3.27E+00 -1.67E-02  3.70E+02  2.08E+01  0.00E+00 -1.26E+02  4.46E+02  0.00E+00  1.93E+03
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************         OBJECTIVE FUNCTION EVALUATION BY IMPORTANCE SAMPLING (NO PRIOR)        ********************
##  ********************                   EIGENVALUES OF COR MATRIX OF ESTIMATE (RSR)                  ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##              1         2         3         4         5         6         7         8
##  
##          1.25E-01  3.31E-01  5.59E-01  8.45E-01  9.56E-01  1.14E+00  1.73E+00  2.31E+00
##  
## 1
##  #TBLN:      3
##  #METH: First Order Conditional Estimation with Interaction (No Prior)
##  ESTIMATION STEP OMITTED:                 NO
##  ANALYSIS TYPE:                           POPULATION
##  NUMBER OF SADDLE POINT RESET ITERATIONS:      0
##  GRADIENT METHOD USED:               NOSLOW
##  CONDITIONAL ESTIMATES USED:              YES
##  CENTERED ETA:                            NO
##  EPS-ETA INTERACTION:                     YES
##  LAPLACIAN OBJ. FUNC.:                    NO
##  NO. OF FUNCT. EVALS. ALLOWED:            9999
##  NO. OF SIG. FIGURES REQUIRED:            3
##  INTERMEDIATE PRINTOUT:                   YES
##  ESTIMATE OUTPUT TO MSF:                  NO
##  ABORT WITH PRED EXIT CODE 1:             NO
##  IND. OBJ. FUNC. VALUES SORTED:           NO
##  NUMERICAL DERIVATIVE
##        FILE REQUEST (NUMDER):               NONE
##  MAP (ETAHAT) ESTIMATION METHOD (OPTMAP):   0
##  ETA HESSIAN EVALUATION METHOD (ETADER):    0
##  INITIAL ETA FOR MAP ESTIMATION (MCETA):    0
##  SIGDIGITS FOR MAP ESTIMATION (SIGLO):      8
##  GRADIENT SIGDIGITS OF
##        FIXED EFFECTS PARAMETERS (SIGL):     8
##  NOPRIOR SETTING (NOPRIOR):                 ON
##  NOCOV SETTING (NOCOV):                     OFF
##  DERCONT SETTING (DERCONT):                 OFF
##  FINAL ETA RE-EVALUATION (FNLETA):          ON
##  EXCLUDE NON-INFLUENTIAL (NON-INFL.) ETAS
##        IN SHRINKAGE (ETASTYPE):             NO
##  NON-INFL. ETA CORRECTION (NONINFETA):      OFF
##  RAW OUTPUT FILE (FILE): psn.ext
##  EXCLUDE TITLE (NOTITLE):                   NO
##  EXCLUDE COLUMN LABELS (NOLABEL):           NO
##  FORMAT FOR ADDITIONAL FILES (FORMAT):      S1PE12.5
##  PARAMETER ORDER FOR OUTPUTS (ORDER):       TSOL
##  WISHART PRIOR DF INTERPRETATION (WISHTYPE):0
##  KNUTHSUMOFF:                               0
##  INCLUDE LNTWOPI:                           NO
##  INCLUDE CONSTANT TERM TO PRIOR (PRIORC):   NO
##  INCLUDE CONSTANT TERM TO OMEGA (ETA) (OLNTWOPI):NO
##  ADDITIONAL CONVERGENCE TEST (CTYPE=4)?:    NO
##  EM OR BAYESIAN METHOD USED:                 NONE
##  THE FOLLOWING LABELS ARE EQUIVALENT
##  PRED=PREDI
##  RES=RESI
##  WRES=WRESI
##  IWRS=IWRESI
##  IPRD=IPREDI
##  IRS=IRESI
##  MONITORING OF SEARCH:
## 0ITERATION NO.:    0    OBJECTIVE VALUE:   2042.27086961333        NO. OF FUNC. EVALS.:   8
##  CUMULATIVE NO. OF FUNC. EVALS.:        8
##  NPARAMETR:  2.2644E+00  7.2636E+01  4.8036E+02  7.1713E-02  1.0873E+00  6.0036E-01  3.7030E-02  1.4992E-01
##  PARAMETER:  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01  1.0000E-01
##  GRADIENT:  -1.0512E+01 -1.7829E+01  1.5705E+01 -2.7421E+00 -1.2923E+01 -1.2880E+00  8.7096E-01  1.9875E+00
## 0ITERATION NO.:    5    OBJECTIVE VALUE:   2041.94796099031        NO. OF FUNC. EVALS.:  59
##  CUMULATIVE NO. OF FUNC. EVALS.:       67
##  NPARAMETR:  2.2752E+00  7.4348E+01  4.6198E+02  7.1424E-02  1.0892E+00  5.9173E-01  3.6790E-02  1.4799E-01
##  PARAMETER:  1.0473E-01  1.2330E-01  6.0978E-02  9.9598E-02  1.0017E-01  8.5518E-02  9.6750E-02  9.3518E-02
##  GRADIENT:   6.8361E+00  7.5075E+00 -5.0826E+00 -1.6685E+01 -2.6389E+01  7.0805E+00  1.1345E+00  1.4235E+00
## 0ITERATION NO.:   10    OBJECTIVE VALUE:   2041.85479582408        NO. OF FUNC. EVALS.:  52
##  CUMULATIVE NO. OF FUNC. EVALS.:      119
##  NPARAMETR:  2.2709E+00  7.4490E+01  4.6625E+02  7.1410E-02  1.0921E+00  5.8663E-01  3.5633E-02  1.4500E-01
##  PARAMETER:  1.0284E-01  1.2520E-01  7.0175E-02  9.9578E-02  1.0044E-01  7.6870E-02  8.0763E-02  8.3299E-02
##  GRADIENT:   1.0988E+00  1.9777E+00 -9.3637E-02 -2.9956E+00 -4.6340E+00  4.8188E-01 -1.9506E-01 -1.0332E-01
## 0ITERATION NO.:   15    OBJECTIVE VALUE:   2041.84864317025        NO. OF FUNC. EVALS.:  82
##  CUMULATIVE NO. OF FUNC. EVALS.:      201
##  NPARAMETR:  2.2705E+00  7.4377E+01  4.6815E+02  7.1415E-02  1.0932E+00  5.8738E-01  3.5788E-02  1.4520E-01
##  PARAMETER:  1.0268E-01  1.2368E-01  7.4240E-02  9.9585E-02  1.0054E-01  7.8144E-02  8.2932E-02  8.3981E-02
##  GRADIENT:   1.9863E-04 -5.6821E-05 -7.7600E-05 -1.5445E-03 -1.7496E-03  8.2343E-05  3.7358E-05 -1.9489E-03
##  #TERM:
## 0MINIMIZATION SUCCESSFUL
##  NO. OF FUNCTION EVALUATIONS USED:      201
##  NO. OF SIG. DIGITS IN FINAL EST.:  3.9
##  ETABAR IS THE ARITHMETIC MEAN OF THE ETA-ESTIMATES,
##  AND THE P-VALUE IS GIVEN FOR THE NULL HYPOTHESIS THAT THE TRUE MEAN IS 0.
##  ETABAR:         1.6346E-03 -2.1190E-03
##  SE:             2.5837E-02  5.9657E-02
##  N:                      40          40
##  P VAL.:         9.4955E-01  9.7167E-01
##  ETASHRINKSD(%)  1.2521E+01  1.0000E-10
##  ETASHRINKVR(%)  2.3475E+01  1.0000E-10
##  EBVSHRINKSD(%)  1.3193E+01  7.4530E-01
##  EBVSHRINKVR(%)  2.4646E+01  1.4851E+00
##  EPSSHRINKSD(%)  4.6580E+00
##  EPSSHRINKVR(%)  9.0991E+00
##   
##  TOTAL DATA POINTS NORMALLY DISTRIBUTED (N):          760
##  N*LOG(2PI) CONSTANT TO OBJECTIVE FUNCTION:    1396.7865704711026     
##  OBJECTIVE FUNCTION VALUE WITHOUT CONSTANT:    2041.8486431702499     
##  OBJECTIVE FUNCTION VALUE WITH CONSTANT:       3438.6352136413525     
##  REPORTED OBJECTIVE FUNCTION DOES NOT CONTAIN CONSTANT
##   
##  TOTAL EFFECTIVE ETAS (NIND*NETA):                            80
##   
##  #TERE:
##  Elapsed estimation  time in seconds:     1.12
##  Elapsed covariance  time in seconds:     0.95
##  Elapsed postprocess time in seconds:     0.02
## 1
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  #OBJT:**************                       MINIMUM VALUE OF OBJECTIVE FUNCTION                      ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  #OBJV:********************************************     2041.849       **************************************************
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  ********************                             FINAL PARAMETER ESTIMATE                           ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********
##          TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     
##  
##          2.27E+00  7.44E+01  4.68E+02  7.14E-02  1.09E+00  7.50E-01  5.87E-01
##  
##  OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********
##          ETA1      ETA2     
##  
##  ETA1
## +        3.58E-02
##  
##  ETA2
## +        0.00E+00  1.45E-01
##  
##  SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****
##          EPS1     
##  
##  EPS1
## +        1.00E+00
##  
## 1
##  OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******
##          ETA1      ETA2     
##  
##  ETA1
## +        1.89E-01
##  
##  ETA2
## +        0.00E+00  3.81E-01
##  
##  SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***
##          EPS1     
##  
##  EPS1
## +        1.00E+00
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  ********************                            STANDARD ERROR OF ESTIMATE                          ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##  THETA - VECTOR OF FIXED EFFECTS PARAMETERS   *********
##          TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7     
##  
##          8.05E-02  2.85E+00  2.83E+01  8.25E-03  8.60E-02 .........  3.87E-02
##  
##  OMEGA - COV MATRIX FOR RANDOM EFFECTS - ETAS  ********
##          ETA1      ETA2     
##  
##  ETA1
## +        1.09E-02
##  
##  ETA2
## +       .........  2.34E-02
##  
##  SIGMA - COV MATRIX FOR RANDOM EFFECTS - EPSILONS  ****
##          EPS1     
##  
##  EPS1
## +       .........
##  
## 1
##  OMEGA - CORR MATRIX FOR RANDOM EFFECTS - ETAS  *******
##          ETA1      ETA2     
##  
##  ETA1
## +        2.89E-02
##  
##  ETA2
## +       .........  3.07E-02
##  
##  SIGMA - CORR MATRIX FOR RANDOM EFFECTS - EPSILONS  ***
##          EPS1     
##  
##  EPS1
## +       .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  ********************                          COVARIANCE MATRIX OF ESTIMATE                         ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        6.49E-03
##  
##  TH 2
## +       -2.58E-02  8.10E+00
##  
##  TH 3
## +       -1.46E-01 -2.39E+01  7.99E+02
##  
##  TH 4
## +       -1.30E-04 -1.37E-03  6.43E-02  6.80E-05
##  
##  TH 5
## +        1.45E-03  1.76E-03 -4.69E-01 -6.07E-04  7.40E-03
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +        2.24E-04 -6.50E-02  1.63E-01 -3.52E-05  1.02E-04 .........  1.50E-03
##  
##  OM11
## +       -2.25E-04 -4.06E-03  4.18E-02  2.88E-05 -3.64E-04 .........  1.02E-04  1.19E-04
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +        2.35E-04  2.66E-03  9.22E-04 -1.85E-05  1.46E-04 .........  5.39E-05 -4.49E-05 .........  5.47E-04
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  ********************                          CORRELATION MATRIX OF ESTIMATE                        ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        8.05E-02
##  
##  TH 2
## +       -1.13E-01  2.85E+00
##  
##  TH 3
## +       -6.39E-02 -2.97E-01  2.83E+01
##  
##  TH 4
## +       -1.96E-01 -5.83E-02  2.76E-01  8.25E-03
##  
##  TH 5
## +        2.09E-01  7.21E-03 -1.93E-01 -8.56E-01  8.60E-02
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +        7.18E-02 -5.91E-01  1.49E-01 -1.10E-01  3.08E-02 .........  3.87E-02
##  
##  OM11
## +       -2.55E-01 -1.31E-01  1.35E-01  3.19E-01 -3.88E-01 .........  2.41E-01  1.09E-02
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +        1.25E-01  4.00E-02  1.39E-03 -9.57E-02  7.25E-02 .........  5.96E-02 -1.76E-01 .........  2.34E-02
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  ********************                      INVERSE COVARIANCE MATRIX OF ESTIMATE                     ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##             TH 1      TH 2      TH 3      TH 4      TH 5      TH 6      TH 7      OM11      OM12      OM22      SG11  
##  
##  TH 1
## +        1.74E+02
##  
##  TH 2
## +        7.09E-01  2.17E-01
##  
##  TH 3
## +        2.71E-02  3.99E-03  1.50E-03
##  
##  TH 4
## +        1.04E+02  2.26E+01 -1.91E+00  6.29E+04
##  
##  TH 5
## +       -8.84E+00  1.74E+00 -7.13E-02  4.97E+03  5.62E+02
##  
##  TH 6
## +       ......... ......... ......... ......... ......... .........
##  
##  TH 7
## +       -1.25E+01  9.50E+00 -2.38E-02  2.32E+03  1.29E+02 .........  1.20E+03
##  
##  OM11
## +        2.82E+02 -1.72E+00 -1.07E-01 -1.90E+02  4.89E+02 ......... -9.57E+02  1.15E+04
##  
##  OM12
## +       ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
##  OM22
## +       -4.79E+01 -2.15E+00 -8.55E-02  4.04E+02  4.10E+01 ......... -1.94E+02  7.92E+02 .........  1.95E+03
##  
##  SG11
## +       ......... ......... ......... ......... ......... ......... ......... ......... ......... ......... .........
##  
## 1
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  
##  ************************************************************************************************************************
##  ********************                                                                                ********************
##  ********************          FIRST ORDER CONDITIONAL ESTIMATION WITH INTERACTION (NO PRIOR)        ********************
##  ********************                      EIGENVALUES OF COR MATRIX OF ESTIMATE                     ********************
##  ********************                                                                                ********************
##  ************************************************************************************************************************
##  
##              1         2         3         4         5         6         7         8
##  
##          1.25E-01  3.52E-01  5.92E-01  8.38E-01  8.84E-01  1.10E+00  1.75E+00  2.36E+00
##  
##  Elapsed finaloutput time in seconds:     0.30
##  #CPUT: Total CPU Time in Seconds,      359.688
## Stop Time: 
## 14/09/2023 
## 12:36
```

``` r
"run105" %>% read_mod()
```

```
## [1] ";; 1. Based on: 102\n;; 2. Description: \n;;    PK model 1 cmt - WT-CL allom SEX-CL\n;; 3. Label:\n;;    \n;; 4. Structural model:\n;; 5. Covariate model:\n;; 6. Inter-individual variability:\n;; 7. Inter-occasion variability:\n;; 8. Residual variability:\n;; 9. Estimation:\n$PROBLEM PK model 1 cmt base\n$INPUT ID TIME MDV EVID DV AMT  SEX WT ETN\t   \n$DATA acop.csv IGNORE=@\n$SUBROUTINES ADVAN2 TRANS2\n$PK\nET=1\nIF(ETN.EQ.3) ET=1.3\nKA = THETA(1)\nCL = THETA(2)*((WT/70)**THETA(6))*( THETA(7)**SEX) * EXP(ETA(1))\nV = THETA(3)*EXP(ETA(2))\nSC=V\n$THETA\n(0, 2)  ; KA ; 1/h ; LIN ; Absorption Rate Constant\n(0, 20)  ; CL ; L/h ; LIN ; Clearance \n(0, 100) ; V2 ; L ; LIN ; Volume of Distribution\n(0.02)  ; RUVp ;  ; LIN ; Proportional Error\n(1)     ; RUVa ; ng/mL ; LIN ; Additive Error\n0.75  FIX  ; CL-WT ;  ; LIN ; Power Scalar CL-WT\n(0,1)   ; CL-SEX ; ; LIN ; Female CL Change\n$OMEGA\n0.05    ; iiv CL\n0.2     ; iiv V2  \n$SIGMA\t\n1 FIX\n$ERROR\nIPRED = F\nIRES = DV-IPRED\nW = IPRED*THETA(4) + THETA(5)\nIF (W.EQ.0) W = 1\nIWRES = IRES/W\nY= IPRED+W*ERR(1)\n$EST METHOD=SAEM INTER NBURN=3000 NITER=500 PRINT=100\n$EST METHOD=IMP INTER EONLY=1 NITER=5 ISAMPLE=3000 PRINT=1 SIGL=8 NOPRIOR=1  \n$EST METHOD=1 INTER MAXEVAL=9999 SIG=3 PRINT=5 NOABORT POSTHOC \n$COV PRINT=E UNCONDITIONAL\n$TABLE ID TIME DV MDV EVID IPRED IWRES CWRES ONEHEADER NOPRINT FILE=sdtab105\n$TABLE ID CL V KA ETAS(1:LAST) ONEHEADER NOPRINT FILE=patab105\n$TABLE ID SEX ETN ONEHEADER NOPRINT FILE=catab105\n$TABLE ID WT ONEHEADER NOPRINT FILE=cotab105"
## attr(,"class")
## [1] "mod"
```

``` r
"run105" %>% read_mod() %>% writeLines()
```

```
## ;; 1. Based on: 102
## ;; 2. Description: 
## ;;    PK model 1 cmt - WT-CL allom SEX-CL
## ;; 3. Label:
## ;;    
## ;; 4. Structural model:
## ;; 5. Covariate model:
## ;; 6. Inter-individual variability:
## ;; 7. Inter-occasion variability:
## ;; 8. Residual variability:
## ;; 9. Estimation:
## $PROBLEM PK model 1 cmt base
## $INPUT ID TIME MDV EVID DV AMT  SEX WT ETN	   
## $DATA acop.csv IGNORE=@
## $SUBROUTINES ADVAN2 TRANS2
## $PK
## ET=1
## IF(ETN.EQ.3) ET=1.3
## KA = THETA(1)
## CL = THETA(2)*((WT/70)**THETA(6))*( THETA(7)**SEX) * EXP(ETA(1))
## V = THETA(3)*EXP(ETA(2))
## SC=V
## $THETA
## (0, 2)  ; KA ; 1/h ; LIN ; Absorption Rate Constant
## (0, 20)  ; CL ; L/h ; LIN ; Clearance 
## (0, 100) ; V2 ; L ; LIN ; Volume of Distribution
## (0.02)  ; RUVp ;  ; LIN ; Proportional Error
## (1)     ; RUVa ; ng/mL ; LIN ; Additive Error
## 0.75  FIX  ; CL-WT ;  ; LIN ; Power Scalar CL-WT
## (0,1)   ; CL-SEX ; ; LIN ; Female CL Change
## $OMEGA
## 0.05    ; iiv CL
## 0.2     ; iiv V2  
## $SIGMA	
## 1 FIX
## $ERROR
## IPRED = F
## IRES = DV-IPRED
## W = IPRED*THETA(4) + THETA(5)
## IF (W.EQ.0) W = 1
## IWRES = IRES/W
## Y= IPRED+W*ERR(1)
## $EST METHOD=SAEM INTER NBURN=3000 NITER=500 PRINT=100
## $EST METHOD=IMP INTER EONLY=1 NITER=5 ISAMPLE=3000 PRINT=1 SIGL=8 NOPRIOR=1  
## $EST METHOD=1 INTER MAXEVAL=9999 SIG=3 PRINT=5 NOABORT POSTHOC 
## $COV PRINT=E UNCONDITIONAL
## $TABLE ID TIME DV MDV EVID IPRED IWRES CWRES ONEHEADER NOPRINT FILE=sdtab105
## $TABLE ID CL V KA ETAS(1:LAST) ONEHEADER NOPRINT FILE=patab105
## $TABLE ID SEX ETN ONEHEADER NOPRINT FILE=catab105
## $TABLE ID WT ONEHEADER NOPRINT FILE=cotab105
```

``` r
"run105" %>% read_ext() 
```

```
## [1] "TABLE NO.     1: Stochastic Approximation Expectation-Maximization: Goal Function=FINAL VALUE OF LIKELIHOOD FUNCTION: Problem=1 Subproblem=0 Superproblem1=0 Iteration1=0 Superproblem2=0 Iteration2=0\n ITERATION    THETA1       THETA2       THETA3       THETA4       THETA5       THETA6       THETA7       SIGMA(1,1)   OMEGA(1,1)   OMEGA(2,1)   OMEGA(2,2)   SAEMOBJ\n        -3000  2.00000E+00  2.00000E+01  1.00000E+02  2.00000E-02  1.00000E+00  7.50000E-01  1.00000E+00  1.00000E+00  7.50000E-02  0.00000E+00  3.00000E-01    37880.578399081634\n        -2900  2.26219E+00  5.06175E+01  1.17808E+02  7.29750E-02  1.05423E+00  7.50000E-01  6.51247E-01  1.00000E+00  1.55534E-01  0.00000E+00  2.12129E+00    1819.9797813209129\n        -2800  2.24985E+00  6.54076E+01  1.23374E+02  7.51517E-02  1.04799E+00  7.50000E-01  6.47060E-01  1.00000E+00  4.61305E-02  0.00000E+00  1.97668E+00    1775.7623169685935\n        -2700  2.25377E+00  7.43762E+01  1.31510E+02  7.13489E-02  1.07487E+00  7.50000E-01  5.66634E-01  1.00000E+00  3.98529E-02  0.00000E+00  1.79308E+00    1762.6348116922927\n        -2600  2.30198E+00  7.27393E+01  1.41257E+02  7.67862E-02  1.03629E+00  7.50000E-01  5.69837E-01  1.00000E+00  4.10185E-02  0.00000E+00  1.60492E+00    1756.5962068838376\n        -2500  2.26391E+00  7.44803E+01  1.76128E+02  6.99548E-02  1.08713E+00  7.50000E-01  5.96563E-01  1.00000E+00  3.57216E-02  0.00000E+00  1.11326E+00    1738.7137277621491\n        -2400  2.27308E+00  7.49226E+01  1.97619E+02  6.88084E-02  1.13616E+00  7.50000E-01  5.67575E-01  1.00000E+00  3.67248E-02  0.00000E+00  9.13672E-01    1738.8232940947819\n        -2300  2.35219E+00  6.64574E+01  2.36863E+02  8.09510E-02  9.81739E-01  7.50000E-01  6.30681E-01  1.00000E+00  4.22095E-02  0.00000E+00  6.55839E-01    1748.4815457049922\n        -2200  2.23456E+00  7.51669E+01  2.83716E+02  6.99352E-02  1.03390E+00  7.50000E-01  5.42726E-01  1.00000E+00  4.07044E-02  0.00000E+00  3.88266E-01    1710.3493739249757\n        -2100  2.26244E+00  7.26690E+01  3.57461E+02  7.05286E-02  1.06238E+00  7.50000E-01  5.70080E-01  1.00000E+00  3.80839E-02  0.00000E+00  2.25544E-01    1678.3150276961987\n        -2000  2.29471E+00  7.88326E+01  4.34984E+02  7.44532E-02  1.09797E+00  7.50000E-01  5.50298E-01  1.00000E+00  4.15186E-02  0.00000E+00  1.53121E-01    1660.7697562928051\n        -1900  2.25577E+00  7.44557E+01  4.97621E+02  7.29154E-02  1.10292E+00  7.50000E-01  5.69433E-01  1.00000E+00  3.15091E-02  0.00000E+00  1.56486E-01    1670.6905203533120\n        -1800  2.27635E+00  7.03770E+01  5.01559E+02  7.94631E-02  1.01779E+00  7.50000E-01  5.95151E-01  1.00000E+00  3.86228E-02  0.00000E+00  1.58006E-01    1676.5422115195090\n        -1700  2.27284E+00  7.35321E+01  4.74556E+02  7.55750E-02  1.08123E+00  7.50000E-01  6.09731E-01  1.00000E+00  4.18199E-02  0.00000E+00  1.52028E-01    1679.9175463929050\n        -1600  2.26223E+00  8.00857E+01  4.97042E+02  7.34281E-02  1.06417E+00  7.50000E-01  5.52950E-01  1.00000E+00  4.61639E-02  0.00000E+00  1.50096E-01    1666.1447026518115\n        -1500  2.25131E+00  7.45324E+01  4.69146E+02  7.28480E-02  1.12424E+00  7.50000E-01  5.77215E-01  1.00000E+00  3.46252E-02  0.00000E+00  1.52908E-01    1678.2053340635484\n        -1400  2.24106E+00  6.78455E+01  4.79708E+02  6.98973E-02  1.12867E+00  7.50000E-01  6.15438E-01  1.00000E+00  4.21262E-02  0.00000E+00  1.55466E-01    1684.4738496434206\n        -1300  2.24527E+00  6.67459E+01  4.84894E+02  6.82437E-02  1.13522E+00  7.50000E-01  6.46379E-01  1.00000E+00  4.09829E-02  0.00000E+00  1.50764E-01    1666.7514702127837\n        -1200  2.24877E+00  7.33003E+01  4.56242E+02  6.91187E-02  1.12847E+00  7.50000E-01  6.00148E-01  1.00000E+00  3.47292E-02  0.00000E+00  1.56116E-01    1665.1358146630539\n        -1100  2.26462E+00  7.30287E+01  4.92945E+02  7.32362E-02  1.05012E+00  7.50000E-01  6.04190E-01  1.00000E+00  3.45829E-02  0.00000E+00  1.52886E-01    1663.2056797589910\n        -1000  2.25590E+00  7.49987E+01  4.62989E+02  7.12967E-02  1.06852E+00  7.50000E-01  5.41566E-01  1.00000E+00  3.70151E-02  0.00000E+00  1.50143E-01    1676.0512289498085\n         -900  2.27548E+00  7.28357E+01  5.06149E+02  7.83879E-02  1.02337E+00  7.50000E-01  5.73392E-01  1.00000E+00  3.68944E-02  0.00000E+00  1.44466E-01    1656.5899185787312\n         -800  2.25260E+00  7.60084E+01  4.93443E+02  6.80798E-02  1.14882E+00  7.50000E-01  5.55841E-01  1.00000E+00  3.54225E-02  0.00000E+00  1.49788E-01    1660.9547108389204\n         -700  2.25387E+00  7.33801E+01  4.64630E+02  6.85284E-02  1.12962E+00  7.50000E-01  5.82067E-01  1.00000E+00  3.14252E-02  0.00000E+00  1.50915E-01    1664.7104693758502\n         -600  2.23921E+00  7.58133E+01  4.75884E+02  7.73336E-02  1.07097E+00  7.50000E-01  5.65563E-01  1.00000E+00  4.59280E-02  0.00000E+00  1.48129E-01    1670.7599984097280\n         -500  2.24063E+00  7.40977E+01  4.47268E+02  7.32570E-02  1.07831E+00  7.50000E-01  5.92659E-01  1.00000E+00  3.89064E-02  0.00000E+00  1.40963E-01    1664.0882947137266\n         -400  2.26882E+00  6.99290E+01  4.66580E+02  7.54985E-02  1.07283E+00  7.50000E-01  5.95420E-01  1.00000E+00  4.75989E-02  0.00000E+00  1.41905E-01    1669.3760024849835\n         -300  2.25787E+00  7.34269E+01  5.01876E+02  7.07321E-02  1.12274E+00  7.50000E-01  5.95068E-01  1.00000E+00  3.62820E-02  0.00000E+00  1.57528E-01    1665.6498136784967\n         -200  2.24225E+00  7.78154E+01  4.43857E+02  7.67127E-02  1.07332E+00  7.50000E-01  5.62574E-01  1.00000E+00  4.05358E-02  0.00000E+00  1.49404E-01    1668.4572104514200\n         -100  2.25957E+00  7.50761E+01  4.93225E+02  6.95438E-02  1.12615E+00  7.50000E-01  5.80226E-01  1.00000E+00  3.71847E-02  0.00000E+00  1.46377E-01    1661.0589433728653\n            0  2.30614E+00  7.50727E+01  4.82144E+02  7.30899E-02  1.03613E+00  7.50000E-01  5.76697E-01  1.00000E+00  3.72926E-02  0.00000E+00  1.53033E-01    1667.0797458880336\n          100  2.26285E+00  7.18621E+01  4.80067E+02  7.21099E-02  1.08477E+00  7.50000E-01  6.10409E-01  1.00000E+00  3.66807E-02  0.00000E+00  1.49628E-01    1654.0501788529286\n          200  2.26372E+00  7.21823E+01  4.80243E+02  7.15939E-02  1.08961E+00  7.50000E-01  6.05262E-01  1.00000E+00  3.71298E-02  0.00000E+00  1.49738E-01    1654.1064511390723\n          300  2.26398E+00  7.23304E+01  4.80310E+02  7.16203E-02  1.08779E+00  7.50000E-01  6.02954E-01  1.00000E+00  3.71716E-02  0.00000E+00  1.49936E-01    1653.9436158865042\n          400  2.26435E+00  7.25356E+01  4.80331E+02  7.16726E-02  1.08772E+00  7.50000E-01  6.01232E-01  1.00000E+00  3.71225E-02  0.00000E+00  1.49931E-01    1653.9493430311197\n          500  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    1653.7461440391669\n  -1000000000  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    1653.7461440391669\n  -1000000001  6.47988E-02  5.36376E+00  3.22530E+01  7.65275E-03  1.00186E-01  0.00000E+00  5.09554E-02  0.00000E+00  1.31737E-02  0.00000E+00  5.00113E-02    0.0000000000000000\n  -1000000002  9.15105E-02  2.11830E-01  4.84855E-01  9.42733E-01  1.05046E+00  1.24309E+00  1.77790E+00  2.19762E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000003  2.40150E+01  9.15105E-02  2.19762E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000004  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+00  1.92433E-01  0.00000E+00  3.87200E-01    0.0000000000000000\n  -1000000005  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+10  3.42293E-02  1.00000E+10  6.45808E-02    0.0000000000000000\n  -1000000006  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000007  2.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000008  1.44418E+00  7.16468E-02 -3.37735E-03  2.78362E+00  1.15115E+00  0.00000E+00 -4.14448E+00  0.00000E+00 -1.14510E-02  0.00000E+00  1.74146E-03    0.0000000000000000\nTABLE NO.     2: Objective Function Evaluation by Importance Sampling (No Prior): Goal Function=FINAL VALUE OF OBJECTIVE FUNCTION: Problem=1 Subproblem=0 Superproblem1=0 Iteration1=0 Superproblem2=0 Iteration2=0\n ITERATION    THETA1       THETA2       THETA3       THETA4       THETA5       THETA6       THETA7       SIGMA(1,1)   OMEGA(1,1)   OMEGA(2,1)   OMEGA(2,2)   OBJ\n            0  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.2787689427023\n            1  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.1984488958581\n            2  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.3797207602163\n            3  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.3247305602517\n            4  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.1527399552278\n            5  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.4148330855062\n  -1000000000  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.4148330855062\n  -1000000001  7.94444E-02  3.06478E+00  2.52242E+01  8.19953E-03  8.51449E-02  0.00000E+00  4.09449E-02  0.00000E+00  1.20055E-02  0.00000E+00  2.35869E-02    0.0000000000000000\n  -1000000002  1.24565E-01  3.30898E-01  5.59113E-01  8.44712E-01  9.56458E-01  1.14255E+00  1.73423E+00  2.30747E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000003  1.85242E+01  1.24565E-01  2.30747E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000004  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+00  1.92433E-01  0.00000E+00  3.87200E-01    0.0000000000000000\n  -1000000005  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+10  3.11940E-02  1.00000E+10  3.04583E-02    0.0000000000000000\n  -1000000006  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000007  2.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000008  1.85752E+00  3.90883E-02 -1.77468E-02  2.05010E+00  8.72793E-01  0.00000E+00 -5.80339E+00  0.00000E+00  9.19019E+00  0.00000E+00  9.02989E-03    0.0000000000000000\nTABLE NO.     3: First Order Conditional Estimation with Interaction (No Prior): Goal Function=MINIMUM VALUE OF OBJECTIVE FUNCTION: Problem=1 Subproblem=0 Superproblem1=0 Iteration1=0 Superproblem2=0 Iteration2=0\n ITERATION    THETA1       THETA2       THETA3       THETA4       THETA5       THETA6       THETA7       SIGMA(1,1)   OMEGA(1,1)   OMEGA(2,1)   OMEGA(2,2)   OBJ\n            0  2.26442E+00  7.26364E+01  4.80363E+02  7.17127E-02  1.08733E+00  7.50000E-01  6.00359E-01  1.00000E+00  3.70303E-02  0.00000E+00  1.49923E-01    2042.2708696133293\n            5  2.27516E+00  7.43484E+01  4.61979E+02  7.14242E-02  1.08919E+00  7.50000E-01  5.91728E-01  1.00000E+00  3.67904E-02  0.00000E+00  1.47993E-01    2041.9479609903128\n           10  2.27086E+00  7.44900E+01  4.66248E+02  7.14104E-02  1.09215E+00  7.50000E-01  5.86632E-01  1.00000E+00  3.56327E-02  0.00000E+00  1.44998E-01    2041.8547958240829\n           15  2.27050E+00  7.43772E+01  4.68147E+02  7.14153E-02  1.09317E+00  7.50000E-01  5.87380E-01  1.00000E+00  3.57876E-02  0.00000E+00  1.45196E-01    2041.8486431702499\n  -1000000000  2.27050E+00  7.43772E+01  4.68147E+02  7.14153E-02  1.09317E+00  7.50000E-01  5.87380E-01  1.00000E+00  3.57876E-02  0.00000E+00  1.45196E-01    2041.8486431702499\n  -1000000001  8.05415E-02  2.84600E+00  2.82706E+01  8.24789E-03  8.60124E-02  1.00000E+10  3.86722E-02  1.00000E+10  1.09275E-02  1.00000E+10  2.33912E-02    0.0000000000000000\n  -1000000002  1.25021E-01  3.51726E-01  5.91659E-01  8.38148E-01  8.84206E-01  1.10089E+00  1.75241E+00  2.35594E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000003  1.88444E+01  1.25021E-01  2.35594E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000004  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+00  1.89176E-01  0.00000E+00  3.81047E-01    0.0000000000000000\n  -1000000005  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+10  2.88819E-02  1.00000E+10  3.06934E-02    0.0000000000000000\n  -1000000006  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00  1.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000007  0.00000E+00  3.70000E+01  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00  0.00000E+00    0.0000000000000000\n  -1000000008 -2.64681E-05  6.04246E-07  1.35185E-07  4.19103E-02  5.73174E-03  0.00000E+00 -6.68260E-05  0.00000E+00 -2.60968E-04  0.00000E+00  3.35568E-03    0.0000000000000000"
## attr(,"class")
## [1] "ext"
```

``` r
"run105" %>% read_ext() %>% as.list
```

```
## $`Stochastic Approximation Expectation-Maximization`
##      ITERATION      THETA1      THETA2       THETA3      THETA4      THETA5
## 1        -3000 2.00000E+00 2.00000E+01  1.00000E+02 2.00000E-02 1.00000E+00
## 2        -2900 2.26219E+00 5.06175E+01  1.17808E+02 7.29750E-02 1.05423E+00
## 3        -2800 2.24985E+00 6.54076E+01  1.23374E+02 7.51517E-02 1.04799E+00
## 4        -2700 2.25377E+00 7.43762E+01  1.31510E+02 7.13489E-02 1.07487E+00
## 5        -2600 2.30198E+00 7.27393E+01  1.41257E+02 7.67862E-02 1.03629E+00
## 6        -2500 2.26391E+00 7.44803E+01  1.76128E+02 6.99548E-02 1.08713E+00
## 7        -2400 2.27308E+00 7.49226E+01  1.97619E+02 6.88084E-02 1.13616E+00
## 8        -2300 2.35219E+00 6.64574E+01  2.36863E+02 8.09510E-02 9.81739E-01
## 9        -2200 2.23456E+00 7.51669E+01  2.83716E+02 6.99352E-02 1.03390E+00
## 10       -2100 2.26244E+00 7.26690E+01  3.57461E+02 7.05286E-02 1.06238E+00
## 11       -2000 2.29471E+00 7.88326E+01  4.34984E+02 7.44532E-02 1.09797E+00
## 12       -1900 2.25577E+00 7.44557E+01  4.97621E+02 7.29154E-02 1.10292E+00
## 13       -1800 2.27635E+00 7.03770E+01  5.01559E+02 7.94631E-02 1.01779E+00
## 14       -1700 2.27284E+00 7.35321E+01  4.74556E+02 7.55750E-02 1.08123E+00
## 15       -1600 2.26223E+00 8.00857E+01  4.97042E+02 7.34281E-02 1.06417E+00
## 16       -1500 2.25131E+00 7.45324E+01  4.69146E+02 7.28480E-02 1.12424E+00
## 17       -1400 2.24106E+00 6.78455E+01  4.79708E+02 6.98973E-02 1.12867E+00
## 18       -1300 2.24527E+00 6.67459E+01  4.84894E+02 6.82437E-02 1.13522E+00
## 19       -1200 2.24877E+00 7.33003E+01  4.56242E+02 6.91187E-02 1.12847E+00
## 20       -1100 2.26462E+00 7.30287E+01  4.92945E+02 7.32362E-02 1.05012E+00
## 21       -1000 2.25590E+00 7.49987E+01  4.62989E+02 7.12967E-02 1.06852E+00
## 22        -900 2.27548E+00 7.28357E+01  5.06149E+02 7.83879E-02 1.02337E+00
## 23        -800 2.25260E+00 7.60084E+01  4.93443E+02 6.80798E-02 1.14882E+00
## 24        -700 2.25387E+00 7.33801E+01  4.64630E+02 6.85284E-02 1.12962E+00
## 25        -600 2.23921E+00 7.58133E+01  4.75884E+02 7.73336E-02 1.07097E+00
## 26        -500 2.24063E+00 7.40977E+01  4.47268E+02 7.32570E-02 1.07831E+00
## 27        -400 2.26882E+00 6.99290E+01  4.66580E+02 7.54985E-02 1.07283E+00
## 28        -300 2.25787E+00 7.34269E+01  5.01876E+02 7.07321E-02 1.12274E+00
## 29        -200 2.24225E+00 7.78154E+01  4.43857E+02 7.67127E-02 1.07332E+00
## 30        -100 2.25957E+00 7.50761E+01  4.93225E+02 6.95438E-02 1.12615E+00
## 31           0 2.30614E+00 7.50727E+01  4.82144E+02 7.30899E-02 1.03613E+00
## 32         100 2.26285E+00 7.18621E+01  4.80067E+02 7.21099E-02 1.08477E+00
## 33         200 2.26372E+00 7.21823E+01  4.80243E+02 7.15939E-02 1.08961E+00
## 34         300 2.26398E+00 7.23304E+01  4.80310E+02 7.16203E-02 1.08779E+00
## 35         400 2.26435E+00 7.25356E+01  4.80331E+02 7.16726E-02 1.08772E+00
## 36         500 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 37 -1000000000 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 38 -1000000001 6.47988E-02 5.36376E+00  3.22530E+01 7.65275E-03 1.00186E-01
## 39 -1000000002 9.15105E-02 2.11830E-01  4.84855E-01 9.42733E-01 1.05046E+00
## 40 -1000000003 2.40150E+01 9.15105E-02  2.19762E+00 0.00000E+00 0.00000E+00
## 41 -1000000004 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 42 -1000000005 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 43 -1000000006 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 44 -1000000007 2.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 45 -1000000008 1.44418E+00 7.16468E-02 -3.37735E-03 2.78362E+00 1.15115E+00
##         THETA6       THETA7  SIGMA(1,1)   OMEGA(1,1)  OMEGA(2,1)  OMEGA(2,2)
## 1  7.50000E-01  1.00000E+00 1.00000E+00  7.50000E-02 0.00000E+00 3.00000E-01
## 2  7.50000E-01  6.51247E-01 1.00000E+00  1.55534E-01 0.00000E+00 2.12129E+00
## 3  7.50000E-01  6.47060E-01 1.00000E+00  4.61305E-02 0.00000E+00 1.97668E+00
## 4  7.50000E-01  5.66634E-01 1.00000E+00  3.98529E-02 0.00000E+00 1.79308E+00
## 5  7.50000E-01  5.69837E-01 1.00000E+00  4.10185E-02 0.00000E+00 1.60492E+00
## 6  7.50000E-01  5.96563E-01 1.00000E+00  3.57216E-02 0.00000E+00 1.11326E+00
## 7  7.50000E-01  5.67575E-01 1.00000E+00  3.67248E-02 0.00000E+00 9.13672E-01
## 8  7.50000E-01  6.30681E-01 1.00000E+00  4.22095E-02 0.00000E+00 6.55839E-01
## 9  7.50000E-01  5.42726E-01 1.00000E+00  4.07044E-02 0.00000E+00 3.88266E-01
## 10 7.50000E-01  5.70080E-01 1.00000E+00  3.80839E-02 0.00000E+00 2.25544E-01
## 11 7.50000E-01  5.50298E-01 1.00000E+00  4.15186E-02 0.00000E+00 1.53121E-01
## 12 7.50000E-01  5.69433E-01 1.00000E+00  3.15091E-02 0.00000E+00 1.56486E-01
## 13 7.50000E-01  5.95151E-01 1.00000E+00  3.86228E-02 0.00000E+00 1.58006E-01
## 14 7.50000E-01  6.09731E-01 1.00000E+00  4.18199E-02 0.00000E+00 1.52028E-01
## 15 7.50000E-01  5.52950E-01 1.00000E+00  4.61639E-02 0.00000E+00 1.50096E-01
## 16 7.50000E-01  5.77215E-01 1.00000E+00  3.46252E-02 0.00000E+00 1.52908E-01
## 17 7.50000E-01  6.15438E-01 1.00000E+00  4.21262E-02 0.00000E+00 1.55466E-01
## 18 7.50000E-01  6.46379E-01 1.00000E+00  4.09829E-02 0.00000E+00 1.50764E-01
## 19 7.50000E-01  6.00148E-01 1.00000E+00  3.47292E-02 0.00000E+00 1.56116E-01
## 20 7.50000E-01  6.04190E-01 1.00000E+00  3.45829E-02 0.00000E+00 1.52886E-01
## 21 7.50000E-01  5.41566E-01 1.00000E+00  3.70151E-02 0.00000E+00 1.50143E-01
## 22 7.50000E-01  5.73392E-01 1.00000E+00  3.68944E-02 0.00000E+00 1.44466E-01
## 23 7.50000E-01  5.55841E-01 1.00000E+00  3.54225E-02 0.00000E+00 1.49788E-01
## 24 7.50000E-01  5.82067E-01 1.00000E+00  3.14252E-02 0.00000E+00 1.50915E-01
## 25 7.50000E-01  5.65563E-01 1.00000E+00  4.59280E-02 0.00000E+00 1.48129E-01
## 26 7.50000E-01  5.92659E-01 1.00000E+00  3.89064E-02 0.00000E+00 1.40963E-01
## 27 7.50000E-01  5.95420E-01 1.00000E+00  4.75989E-02 0.00000E+00 1.41905E-01
## 28 7.50000E-01  5.95068E-01 1.00000E+00  3.62820E-02 0.00000E+00 1.57528E-01
## 29 7.50000E-01  5.62574E-01 1.00000E+00  4.05358E-02 0.00000E+00 1.49404E-01
## 30 7.50000E-01  5.80226E-01 1.00000E+00  3.71847E-02 0.00000E+00 1.46377E-01
## 31 7.50000E-01  5.76697E-01 1.00000E+00  3.72926E-02 0.00000E+00 1.53033E-01
## 32 7.50000E-01  6.10409E-01 1.00000E+00  3.66807E-02 0.00000E+00 1.49628E-01
## 33 7.50000E-01  6.05262E-01 1.00000E+00  3.71298E-02 0.00000E+00 1.49738E-01
## 34 7.50000E-01  6.02954E-01 1.00000E+00  3.71716E-02 0.00000E+00 1.49936E-01
## 35 7.50000E-01  6.01232E-01 1.00000E+00  3.71225E-02 0.00000E+00 1.49931E-01
## 36 7.50000E-01  6.00359E-01 1.00000E+00  3.70303E-02 0.00000E+00 1.49923E-01
## 37 7.50000E-01  6.00359E-01 1.00000E+00  3.70303E-02 0.00000E+00 1.49923E-01
## 38 0.00000E+00  5.09554E-02 0.00000E+00  1.31737E-02 0.00000E+00 5.00113E-02
## 39 1.24309E+00  1.77790E+00 2.19762E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 40 0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 41 0.00000E+00  0.00000E+00 1.00000E+00  1.92433E-01 0.00000E+00 3.87200E-01
## 42 0.00000E+00  0.00000E+00 1.00000E+10  3.42293E-02 1.00000E+10 6.45808E-02
## 43 1.00000E+00  0.00000E+00 1.00000E+00  0.00000E+00 1.00000E+00 0.00000E+00
## 44 0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 45 0.00000E+00 -4.14448E+00 0.00000E+00 -1.14510E-02 0.00000E+00 1.74146E-03
##               SAEMOBJ
## 1  37880.578399081634
## 2  1819.9797813209129
## 3  1775.7623169685935
## 4  1762.6348116922927
## 5  1756.5962068838376
## 6  1738.7137277621491
## 7  1738.8232940947819
## 8  1748.4815457049922
## 9  1710.3493739249757
## 10 1678.3150276961987
## 11 1660.7697562928051
## 12 1670.6905203533120
## 13 1676.5422115195090
## 14 1679.9175463929050
## 15 1666.1447026518115
## 16 1678.2053340635484
## 17 1684.4738496434206
## 18 1666.7514702127837
## 19 1665.1358146630539
## 20 1663.2056797589910
## 21 1676.0512289498085
## 22 1656.5899185787312
## 23 1660.9547108389204
## 24 1664.7104693758502
## 25 1670.7599984097280
## 26 1664.0882947137266
## 27 1669.3760024849835
## 28 1665.6498136784967
## 29 1668.4572104514200
## 30 1661.0589433728653
## 31 1667.0797458880336
## 32 1654.0501788529286
## 33 1654.1064511390723
## 34 1653.9436158865042
## 35 1653.9493430311197
## 36 1653.7461440391669
## 37 1653.7461440391669
## 38 0.0000000000000000
## 39 0.0000000000000000
## 40 0.0000000000000000
## 41 0.0000000000000000
## 42 0.0000000000000000
## 43 0.0000000000000000
## 44 0.0000000000000000
## 45 0.0000000000000000
## 
## $`Objective Function Evaluation by Importance Sampling (No Prior)`
##      ITERATION      THETA1      THETA2       THETA3      THETA4      THETA5
## 1            0 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 2            1 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 3            2 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 4            3 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 5            4 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 6            5 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 7  -1000000000 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 8  -1000000001 7.94444E-02 3.06478E+00  2.52242E+01 8.19953E-03 8.51449E-02
## 9  -1000000002 1.24565E-01 3.30898E-01  5.59113E-01 8.44712E-01 9.56458E-01
## 10 -1000000003 1.85242E+01 1.24565E-01  2.30747E+00 0.00000E+00 0.00000E+00
## 11 -1000000004 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 12 -1000000005 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 13 -1000000006 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 14 -1000000007 2.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 15 -1000000008 1.85752E+00 3.90883E-02 -1.77468E-02 2.05010E+00 8.72793E-01
##         THETA6       THETA7  SIGMA(1,1)  OMEGA(1,1)  OMEGA(2,1)  OMEGA(2,2)
## 1  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 2  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 3  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 4  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 5  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 6  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 7  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 8  0.00000E+00  4.09449E-02 0.00000E+00 1.20055E-02 0.00000E+00 2.35869E-02
## 9  1.14255E+00  1.73423E+00 2.30747E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 10 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 11 0.00000E+00  0.00000E+00 1.00000E+00 1.92433E-01 0.00000E+00 3.87200E-01
## 12 0.00000E+00  0.00000E+00 1.00000E+10 3.11940E-02 1.00000E+10 3.04583E-02
## 13 1.00000E+00  0.00000E+00 1.00000E+00 0.00000E+00 1.00000E+00 0.00000E+00
## 14 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 15 0.00000E+00 -5.80339E+00 0.00000E+00 9.19019E+00 0.00000E+00 9.02989E-03
##                   OBJ
## 1  2042.2787689427023
## 2  2042.1984488958581
## 3  2042.3797207602163
## 4  2042.3247305602517
## 5  2042.1527399552278
## 6  2042.4148330855062
## 7  2042.4148330855062
## 8  0.0000000000000000
## 9  0.0000000000000000
## 10 0.0000000000000000
## 11 0.0000000000000000
## 12 0.0000000000000000
## 13 0.0000000000000000
## 14 0.0000000000000000
## 15 0.0000000000000000
## 
## $`First Order Conditional Estimation with Interaction (No Prior)`
##      ITERATION       THETA1      THETA2      THETA3      THETA4      THETA5
## 1            0  2.26442E+00 7.26364E+01 4.80363E+02 7.17127E-02 1.08733E+00
## 2            5  2.27516E+00 7.43484E+01 4.61979E+02 7.14242E-02 1.08919E+00
## 3           10  2.27086E+00 7.44900E+01 4.66248E+02 7.14104E-02 1.09215E+00
## 4           15  2.27050E+00 7.43772E+01 4.68147E+02 7.14153E-02 1.09317E+00
## 5  -1000000000  2.27050E+00 7.43772E+01 4.68147E+02 7.14153E-02 1.09317E+00
## 6  -1000000001  8.05415E-02 2.84600E+00 2.82706E+01 8.24789E-03 8.60124E-02
## 7  -1000000002  1.25021E-01 3.51726E-01 5.91659E-01 8.38148E-01 8.84206E-01
## 8  -1000000003  1.88444E+01 1.25021E-01 2.35594E+00 0.00000E+00 0.00000E+00
## 9  -1000000004  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 10 -1000000005  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 11 -1000000006  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 12 -1000000007  0.00000E+00 3.70000E+01 0.00000E+00 0.00000E+00 0.00000E+00
## 13 -1000000008 -2.64681E-05 6.04246E-07 1.35185E-07 4.19103E-02 5.73174E-03
##         THETA6       THETA7  SIGMA(1,1)   OMEGA(1,1)  OMEGA(2,1)  OMEGA(2,2)
## 1  7.50000E-01  6.00359E-01 1.00000E+00  3.70303E-02 0.00000E+00 1.49923E-01
## 2  7.50000E-01  5.91728E-01 1.00000E+00  3.67904E-02 0.00000E+00 1.47993E-01
## 3  7.50000E-01  5.86632E-01 1.00000E+00  3.56327E-02 0.00000E+00 1.44998E-01
## 4  7.50000E-01  5.87380E-01 1.00000E+00  3.57876E-02 0.00000E+00 1.45196E-01
## 5  7.50000E-01  5.87380E-01 1.00000E+00  3.57876E-02 0.00000E+00 1.45196E-01
## 6  1.00000E+10  3.86722E-02 1.00000E+10  1.09275E-02 1.00000E+10 2.33912E-02
## 7  1.10089E+00  1.75241E+00 2.35594E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 8  0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 9  0.00000E+00  0.00000E+00 1.00000E+00  1.89176E-01 0.00000E+00 3.81047E-01
## 10 0.00000E+00  0.00000E+00 1.00000E+10  2.88819E-02 1.00000E+10 3.06934E-02
## 11 1.00000E+00  0.00000E+00 1.00000E+00  0.00000E+00 1.00000E+00 0.00000E+00
## 12 0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 13 0.00000E+00 -6.68260E-05 0.00000E+00 -2.60968E-04 0.00000E+00 3.35568E-03
##                   OBJ
## 1  2042.2708696133293
## 2  2041.9479609903128
## 3  2041.8547958240829
## 4  2041.8486431702499
## 5  2041.8486431702499
## 6  0.0000000000000000
## 7  0.0000000000000000
## 8  0.0000000000000000
## 9  0.0000000000000000
## 10 0.0000000000000000
## 11 0.0000000000000000
## 12 0.0000000000000000
## 13 0.0000000000000000
## 
## attr(,"class")
## [1] "extList"
```

``` r
"run105" %>% read_ext() %>% as.list %>% names
```

```
## [1] "Stochastic Approximation Expectation-Maximization"              
## [2] "Objective Function Evaluation by Importance Sampling (No Prior)"
## [3] "First Order Conditional Estimation with Interaction (No Prior)"
```

``` r
"run105" %>% read_ext() %>% as.matrix
```

```
## $`Stochastic Approximation Expectation-Maximization`
##      ITERATION      THETA1      THETA2       THETA3      THETA4      THETA5
## 1        -3000 2.00000E+00 2.00000E+01  1.00000E+02 2.00000E-02 1.00000E+00
## 2        -2900 2.26219E+00 5.06175E+01  1.17808E+02 7.29750E-02 1.05423E+00
## 3        -2800 2.24985E+00 6.54076E+01  1.23374E+02 7.51517E-02 1.04799E+00
## 4        -2700 2.25377E+00 7.43762E+01  1.31510E+02 7.13489E-02 1.07487E+00
## 5        -2600 2.30198E+00 7.27393E+01  1.41257E+02 7.67862E-02 1.03629E+00
## 6        -2500 2.26391E+00 7.44803E+01  1.76128E+02 6.99548E-02 1.08713E+00
## 7        -2400 2.27308E+00 7.49226E+01  1.97619E+02 6.88084E-02 1.13616E+00
## 8        -2300 2.35219E+00 6.64574E+01  2.36863E+02 8.09510E-02 9.81739E-01
## 9        -2200 2.23456E+00 7.51669E+01  2.83716E+02 6.99352E-02 1.03390E+00
## 10       -2100 2.26244E+00 7.26690E+01  3.57461E+02 7.05286E-02 1.06238E+00
## 11       -2000 2.29471E+00 7.88326E+01  4.34984E+02 7.44532E-02 1.09797E+00
## 12       -1900 2.25577E+00 7.44557E+01  4.97621E+02 7.29154E-02 1.10292E+00
## 13       -1800 2.27635E+00 7.03770E+01  5.01559E+02 7.94631E-02 1.01779E+00
## 14       -1700 2.27284E+00 7.35321E+01  4.74556E+02 7.55750E-02 1.08123E+00
## 15       -1600 2.26223E+00 8.00857E+01  4.97042E+02 7.34281E-02 1.06417E+00
## 16       -1500 2.25131E+00 7.45324E+01  4.69146E+02 7.28480E-02 1.12424E+00
## 17       -1400 2.24106E+00 6.78455E+01  4.79708E+02 6.98973E-02 1.12867E+00
## 18       -1300 2.24527E+00 6.67459E+01  4.84894E+02 6.82437E-02 1.13522E+00
## 19       -1200 2.24877E+00 7.33003E+01  4.56242E+02 6.91187E-02 1.12847E+00
## 20       -1100 2.26462E+00 7.30287E+01  4.92945E+02 7.32362E-02 1.05012E+00
## 21       -1000 2.25590E+00 7.49987E+01  4.62989E+02 7.12967E-02 1.06852E+00
## 22        -900 2.27548E+00 7.28357E+01  5.06149E+02 7.83879E-02 1.02337E+00
## 23        -800 2.25260E+00 7.60084E+01  4.93443E+02 6.80798E-02 1.14882E+00
## 24        -700 2.25387E+00 7.33801E+01  4.64630E+02 6.85284E-02 1.12962E+00
## 25        -600 2.23921E+00 7.58133E+01  4.75884E+02 7.73336E-02 1.07097E+00
## 26        -500 2.24063E+00 7.40977E+01  4.47268E+02 7.32570E-02 1.07831E+00
## 27        -400 2.26882E+00 6.99290E+01  4.66580E+02 7.54985E-02 1.07283E+00
## 28        -300 2.25787E+00 7.34269E+01  5.01876E+02 7.07321E-02 1.12274E+00
## 29        -200 2.24225E+00 7.78154E+01  4.43857E+02 7.67127E-02 1.07332E+00
## 30        -100 2.25957E+00 7.50761E+01  4.93225E+02 6.95438E-02 1.12615E+00
## 31           0 2.30614E+00 7.50727E+01  4.82144E+02 7.30899E-02 1.03613E+00
## 32         100 2.26285E+00 7.18621E+01  4.80067E+02 7.21099E-02 1.08477E+00
## 33         200 2.26372E+00 7.21823E+01  4.80243E+02 7.15939E-02 1.08961E+00
## 34         300 2.26398E+00 7.23304E+01  4.80310E+02 7.16203E-02 1.08779E+00
## 35         400 2.26435E+00 7.25356E+01  4.80331E+02 7.16726E-02 1.08772E+00
## 36         500 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 37 -1000000000 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 38 -1000000001 6.47988E-02 5.36376E+00  3.22530E+01 7.65275E-03 1.00186E-01
## 39 -1000000002 9.15105E-02 2.11830E-01  4.84855E-01 9.42733E-01 1.05046E+00
## 40 -1000000003 2.40150E+01 9.15105E-02  2.19762E+00 0.00000E+00 0.00000E+00
## 41 -1000000004 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 42 -1000000005 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 43 -1000000006 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 44 -1000000007 2.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 45 -1000000008 1.44418E+00 7.16468E-02 -3.37735E-03 2.78362E+00 1.15115E+00
##         THETA6       THETA7  SIGMA(1,1)   OMEGA(1,1)  OMEGA(2,1)  OMEGA(2,2)
## 1  7.50000E-01  1.00000E+00 1.00000E+00  7.50000E-02 0.00000E+00 3.00000E-01
## 2  7.50000E-01  6.51247E-01 1.00000E+00  1.55534E-01 0.00000E+00 2.12129E+00
## 3  7.50000E-01  6.47060E-01 1.00000E+00  4.61305E-02 0.00000E+00 1.97668E+00
## 4  7.50000E-01  5.66634E-01 1.00000E+00  3.98529E-02 0.00000E+00 1.79308E+00
## 5  7.50000E-01  5.69837E-01 1.00000E+00  4.10185E-02 0.00000E+00 1.60492E+00
## 6  7.50000E-01  5.96563E-01 1.00000E+00  3.57216E-02 0.00000E+00 1.11326E+00
## 7  7.50000E-01  5.67575E-01 1.00000E+00  3.67248E-02 0.00000E+00 9.13672E-01
## 8  7.50000E-01  6.30681E-01 1.00000E+00  4.22095E-02 0.00000E+00 6.55839E-01
## 9  7.50000E-01  5.42726E-01 1.00000E+00  4.07044E-02 0.00000E+00 3.88266E-01
## 10 7.50000E-01  5.70080E-01 1.00000E+00  3.80839E-02 0.00000E+00 2.25544E-01
## 11 7.50000E-01  5.50298E-01 1.00000E+00  4.15186E-02 0.00000E+00 1.53121E-01
## 12 7.50000E-01  5.69433E-01 1.00000E+00  3.15091E-02 0.00000E+00 1.56486E-01
## 13 7.50000E-01  5.95151E-01 1.00000E+00  3.86228E-02 0.00000E+00 1.58006E-01
## 14 7.50000E-01  6.09731E-01 1.00000E+00  4.18199E-02 0.00000E+00 1.52028E-01
## 15 7.50000E-01  5.52950E-01 1.00000E+00  4.61639E-02 0.00000E+00 1.50096E-01
## 16 7.50000E-01  5.77215E-01 1.00000E+00  3.46252E-02 0.00000E+00 1.52908E-01
## 17 7.50000E-01  6.15438E-01 1.00000E+00  4.21262E-02 0.00000E+00 1.55466E-01
## 18 7.50000E-01  6.46379E-01 1.00000E+00  4.09829E-02 0.00000E+00 1.50764E-01
## 19 7.50000E-01  6.00148E-01 1.00000E+00  3.47292E-02 0.00000E+00 1.56116E-01
## 20 7.50000E-01  6.04190E-01 1.00000E+00  3.45829E-02 0.00000E+00 1.52886E-01
## 21 7.50000E-01  5.41566E-01 1.00000E+00  3.70151E-02 0.00000E+00 1.50143E-01
## 22 7.50000E-01  5.73392E-01 1.00000E+00  3.68944E-02 0.00000E+00 1.44466E-01
## 23 7.50000E-01  5.55841E-01 1.00000E+00  3.54225E-02 0.00000E+00 1.49788E-01
## 24 7.50000E-01  5.82067E-01 1.00000E+00  3.14252E-02 0.00000E+00 1.50915E-01
## 25 7.50000E-01  5.65563E-01 1.00000E+00  4.59280E-02 0.00000E+00 1.48129E-01
## 26 7.50000E-01  5.92659E-01 1.00000E+00  3.89064E-02 0.00000E+00 1.40963E-01
## 27 7.50000E-01  5.95420E-01 1.00000E+00  4.75989E-02 0.00000E+00 1.41905E-01
## 28 7.50000E-01  5.95068E-01 1.00000E+00  3.62820E-02 0.00000E+00 1.57528E-01
## 29 7.50000E-01  5.62574E-01 1.00000E+00  4.05358E-02 0.00000E+00 1.49404E-01
## 30 7.50000E-01  5.80226E-01 1.00000E+00  3.71847E-02 0.00000E+00 1.46377E-01
## 31 7.50000E-01  5.76697E-01 1.00000E+00  3.72926E-02 0.00000E+00 1.53033E-01
## 32 7.50000E-01  6.10409E-01 1.00000E+00  3.66807E-02 0.00000E+00 1.49628E-01
## 33 7.50000E-01  6.05262E-01 1.00000E+00  3.71298E-02 0.00000E+00 1.49738E-01
## 34 7.50000E-01  6.02954E-01 1.00000E+00  3.71716E-02 0.00000E+00 1.49936E-01
## 35 7.50000E-01  6.01232E-01 1.00000E+00  3.71225E-02 0.00000E+00 1.49931E-01
## 36 7.50000E-01  6.00359E-01 1.00000E+00  3.70303E-02 0.00000E+00 1.49923E-01
## 37 7.50000E-01  6.00359E-01 1.00000E+00  3.70303E-02 0.00000E+00 1.49923E-01
## 38 0.00000E+00  5.09554E-02 0.00000E+00  1.31737E-02 0.00000E+00 5.00113E-02
## 39 1.24309E+00  1.77790E+00 2.19762E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 40 0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 41 0.00000E+00  0.00000E+00 1.00000E+00  1.92433E-01 0.00000E+00 3.87200E-01
## 42 0.00000E+00  0.00000E+00 1.00000E+10  3.42293E-02 1.00000E+10 6.45808E-02
## 43 1.00000E+00  0.00000E+00 1.00000E+00  0.00000E+00 1.00000E+00 0.00000E+00
## 44 0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 45 0.00000E+00 -4.14448E+00 0.00000E+00 -1.14510E-02 0.00000E+00 1.74146E-03
##               SAEMOBJ
## 1  37880.578399081634
## 2  1819.9797813209129
## 3  1775.7623169685935
## 4  1762.6348116922927
## 5  1756.5962068838376
## 6  1738.7137277621491
## 7  1738.8232940947819
## 8  1748.4815457049922
## 9  1710.3493739249757
## 10 1678.3150276961987
## 11 1660.7697562928051
## 12 1670.6905203533120
## 13 1676.5422115195090
## 14 1679.9175463929050
## 15 1666.1447026518115
## 16 1678.2053340635484
## 17 1684.4738496434206
## 18 1666.7514702127837
## 19 1665.1358146630539
## 20 1663.2056797589910
## 21 1676.0512289498085
## 22 1656.5899185787312
## 23 1660.9547108389204
## 24 1664.7104693758502
## 25 1670.7599984097280
## 26 1664.0882947137266
## 27 1669.3760024849835
## 28 1665.6498136784967
## 29 1668.4572104514200
## 30 1661.0589433728653
## 31 1667.0797458880336
## 32 1654.0501788529286
## 33 1654.1064511390723
## 34 1653.9436158865042
## 35 1653.9493430311197
## 36 1653.7461440391669
## 37 1653.7461440391669
## 38 0.0000000000000000
## 39 0.0000000000000000
## 40 0.0000000000000000
## 41 0.0000000000000000
## 42 0.0000000000000000
## 43 0.0000000000000000
## 44 0.0000000000000000
## 45 0.0000000000000000
## 
## $`Objective Function Evaluation by Importance Sampling (No Prior)`
##      ITERATION      THETA1      THETA2       THETA3      THETA4      THETA5
## 1            0 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 2            1 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 3            2 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 4            3 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 5            4 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 6            5 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 7  -1000000000 2.26442E+00 7.26364E+01  4.80363E+02 7.17127E-02 1.08733E+00
## 8  -1000000001 7.94444E-02 3.06478E+00  2.52242E+01 8.19953E-03 8.51449E-02
## 9  -1000000002 1.24565E-01 3.30898E-01  5.59113E-01 8.44712E-01 9.56458E-01
## 10 -1000000003 1.85242E+01 1.24565E-01  2.30747E+00 0.00000E+00 0.00000E+00
## 11 -1000000004 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 12 -1000000005 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 13 -1000000006 0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 14 -1000000007 2.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 15 -1000000008 1.85752E+00 3.90883E-02 -1.77468E-02 2.05010E+00 8.72793E-01
##         THETA6       THETA7  SIGMA(1,1)  OMEGA(1,1)  OMEGA(2,1)  OMEGA(2,2)
## 1  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 2  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 3  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 4  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 5  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 6  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 7  7.50000E-01  6.00359E-01 1.00000E+00 3.70303E-02 0.00000E+00 1.49923E-01
## 8  0.00000E+00  4.09449E-02 0.00000E+00 1.20055E-02 0.00000E+00 2.35869E-02
## 9  1.14255E+00  1.73423E+00 2.30747E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 10 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 11 0.00000E+00  0.00000E+00 1.00000E+00 1.92433E-01 0.00000E+00 3.87200E-01
## 12 0.00000E+00  0.00000E+00 1.00000E+10 3.11940E-02 1.00000E+10 3.04583E-02
## 13 1.00000E+00  0.00000E+00 1.00000E+00 0.00000E+00 1.00000E+00 0.00000E+00
## 14 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 15 0.00000E+00 -5.80339E+00 0.00000E+00 9.19019E+00 0.00000E+00 9.02989E-03
##                   OBJ
## 1  2042.2787689427023
## 2  2042.1984488958581
## 3  2042.3797207602163
## 4  2042.3247305602517
## 5  2042.1527399552278
## 6  2042.4148330855062
## 7  2042.4148330855062
## 8  0.0000000000000000
## 9  0.0000000000000000
## 10 0.0000000000000000
## 11 0.0000000000000000
## 12 0.0000000000000000
## 13 0.0000000000000000
## 14 0.0000000000000000
## 15 0.0000000000000000
## 
## $`First Order Conditional Estimation with Interaction (No Prior)`
##      ITERATION       THETA1      THETA2      THETA3      THETA4      THETA5
## 1            0  2.26442E+00 7.26364E+01 4.80363E+02 7.17127E-02 1.08733E+00
## 2            5  2.27516E+00 7.43484E+01 4.61979E+02 7.14242E-02 1.08919E+00
## 3           10  2.27086E+00 7.44900E+01 4.66248E+02 7.14104E-02 1.09215E+00
## 4           15  2.27050E+00 7.43772E+01 4.68147E+02 7.14153E-02 1.09317E+00
## 5  -1000000000  2.27050E+00 7.43772E+01 4.68147E+02 7.14153E-02 1.09317E+00
## 6  -1000000001  8.05415E-02 2.84600E+00 2.82706E+01 8.24789E-03 8.60124E-02
## 7  -1000000002  1.25021E-01 3.51726E-01 5.91659E-01 8.38148E-01 8.84206E-01
## 8  -1000000003  1.88444E+01 1.25021E-01 2.35594E+00 0.00000E+00 0.00000E+00
## 9  -1000000004  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 10 -1000000005  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 11 -1000000006  0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00 0.00000E+00
## 12 -1000000007  0.00000E+00 3.70000E+01 0.00000E+00 0.00000E+00 0.00000E+00
## 13 -1000000008 -2.64681E-05 6.04246E-07 1.35185E-07 4.19103E-02 5.73174E-03
##         THETA6       THETA7  SIGMA(1,1)   OMEGA(1,1)  OMEGA(2,1)  OMEGA(2,2)
## 1  7.50000E-01  6.00359E-01 1.00000E+00  3.70303E-02 0.00000E+00 1.49923E-01
## 2  7.50000E-01  5.91728E-01 1.00000E+00  3.67904E-02 0.00000E+00 1.47993E-01
## 3  7.50000E-01  5.86632E-01 1.00000E+00  3.56327E-02 0.00000E+00 1.44998E-01
## 4  7.50000E-01  5.87380E-01 1.00000E+00  3.57876E-02 0.00000E+00 1.45196E-01
## 5  7.50000E-01  5.87380E-01 1.00000E+00  3.57876E-02 0.00000E+00 1.45196E-01
## 6  1.00000E+10  3.86722E-02 1.00000E+10  1.09275E-02 1.00000E+10 2.33912E-02
## 7  1.10089E+00  1.75241E+00 2.35594E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 8  0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 9  0.00000E+00  0.00000E+00 1.00000E+00  1.89176E-01 0.00000E+00 3.81047E-01
## 10 0.00000E+00  0.00000E+00 1.00000E+10  2.88819E-02 1.00000E+10 3.06934E-02
## 11 1.00000E+00  0.00000E+00 1.00000E+00  0.00000E+00 1.00000E+00 0.00000E+00
## 12 0.00000E+00  0.00000E+00 0.00000E+00  0.00000E+00 0.00000E+00 0.00000E+00
## 13 0.00000E+00 -6.68260E-05 0.00000E+00 -2.60968E-04 0.00000E+00 3.35568E-03
##                   OBJ
## 1  2042.2708696133293
## 2  2041.9479609903128
## 3  2041.8547958240829
## 4  2041.8486431702499
## 5  2041.8486431702499
## 6  0.0000000000000000
## 7  0.0000000000000000
## 8  0.0000000000000000
## 9  0.0000000000000000
## 10 0.0000000000000000
## 11 0.0000000000000000
## 12 0.0000000000000000
## 13 0.0000000000000000
## 
## attr(,"class")
## [1] "extList"
```

``` r
"run105" %>% get_ext() 
```

```
## [[1]]
##                estimate       se_est    eigen_cor         cond        om_sg
## THETA1        2.2644200    0.0647988    0.0915105   24.0150000    0.0000000
## THETA2       72.6364000    5.3637600    0.2118300    0.0915105    0.0000000
## THETA3     480.36300000  32.25300000   0.48485500   2.19762000   0.00000000
## THETA4       0.07171270   0.00765275   0.94273300   0.00000000   0.00000000
## THETA5         1.087330     0.100186     1.050460     0.000000     0.000000
## THETA6          0.75000      0.00000      1.24309      0.00000      0.00000
## THETA7        0.6003590    0.0509554    1.7779000    0.0000000    0.0000000
## SIGMA(1,1)  1.00000e+00  0.00000e+00  2.19762e+00  0.00000e+00  1.00000e+00
## OMEGA(1,1)    0.0370303    0.0131737    0.0000000    0.0000000    0.1924330
## OMEGA(2,1)        0e+00        0e+00        0e+00        0e+00        0e+00
## OMEGA(2,2)   0.14992300   0.05001130   0.00000000   0.00000000   0.38720000
##                se_om_sg          fix         term part_deriv_LL
## THETA1        0.0000000    0.0000000    2.0000000     1.4441800
## THETA2        0.0000000    0.0000000    0.0000000     0.0716468
## THETA3       0.00000000   0.00000000   0.00000000   -0.00337735
## THETA4       0.00000000   0.00000000   0.00000000    2.78362000
## THETA5         0.000000     0.000000     0.000000      1.151150
## THETA6          0.00000      1.00000      0.00000       0.00000
## THETA7        0.0000000    0.0000000    0.0000000    -4.1444800
## SIGMA(1,1)  1.00000e+10  1.00000e+00  0.00000e+00   0.00000e+00
## OMEGA(1,1)    0.0342293    0.0000000    0.0000000    -0.0114510
## OMEGA(2,1)        1e+10        1e+00        0e+00         0e+00
## OMEGA(2,2)   0.06458080   0.00000000   0.00000000    0.00174146
## 
## [[2]]
##               estimate      se_est   eigen_cor        cond       om_sg
## THETA1       2.2644200   0.0794444   0.1245650  18.5242000   0.0000000
## THETA2      72.6364000   3.0647800   0.3308980   0.1245650   0.0000000
## THETA3     480.3630000  25.2242000   0.5591130   2.3074700   0.0000000
## THETA4      0.07171270  0.00819953  0.84471200  0.00000000  0.00000000
## THETA5       1.0873300   0.0851449   0.9564580   0.0000000   0.0000000
## THETA6         0.75000     0.00000     1.14255     0.00000     0.00000
## THETA7       0.6003590   0.0409449   1.7342300   0.0000000   0.0000000
## SIGMA(1,1) 1.00000e+00 0.00000e+00 2.30747e+00 0.00000e+00 1.00000e+00
## OMEGA(1,1)   0.0370303   0.0120055   0.0000000   0.0000000   0.1924330
## OMEGA(2,1)       0e+00       0e+00       0e+00       0e+00       0e+00
## OMEGA(2,2)  0.14992300  0.02358690  0.00000000  0.00000000  0.38720000
##               se_om_sg         fix        term part_deriv_LL
## THETA1       0.0000000   0.0000000   2.0000000     1.8575200
## THETA2       0.0000000   0.0000000   0.0000000     0.0390883
## THETA3       0.0000000   0.0000000   0.0000000    -0.0177468
## THETA4      0.00000000  0.00000000  0.00000000    2.05010000
## THETA5       0.0000000   0.0000000   0.0000000     0.8727930
## THETA6         0.00000     1.00000     0.00000       0.00000
## THETA7       0.0000000   0.0000000   0.0000000    -5.8033900
## SIGMA(1,1) 1.00000e+10 1.00000e+00 0.00000e+00   0.00000e+00
## OMEGA(1,1)   0.0311940   0.0000000   0.0000000     9.1901900
## OMEGA(2,1)       1e+10       1e+00       0e+00         0e+00
## OMEGA(2,2)  0.03045830  0.00000000  0.00000000    0.00902989
## 
## [[3]]
##                estimate       se_est    eigen_cor         cond        om_sg
## THETA1      2.27050e+00  8.05415e-02  1.25021e-01  1.88444e+01  0.00000e+00
## THETA2      7.43772e+01  2.84600e+00  3.51726e-01  1.25021e-01  0.00000e+00
## THETA3      4.68147e+02  2.82706e+01  5.91659e-01  2.35594e+00  0.00000e+00
## THETA4       0.07141530   0.00824789   0.83814800   0.00000000   0.00000000
## THETA5       1.09317000   0.08601240   0.88420600   0.00000000   0.00000000
## THETA6      7.50000e-01  1.00000e+10  1.10089e+00  0.00000e+00  0.00000e+00
## THETA7      0.587380000  0.038672200  1.752410000  0.000000000  0.000000000
## SIGMA(1,1)  1.00000e+00  1.00000e+10  2.35594e+00  0.00000e+00  1.00000e+00
## OMEGA(1,1)  0.035787600  0.010927500  0.000000000  0.000000000  0.189176000
## OMEGA(2,1)        0e+00        1e+10        0e+00        0e+00        0e+00
## OMEGA(2,2)   0.14519600   0.02339120   0.00000000   0.00000000   0.38104700
##                se_om_sg          fix         term part_deriv_LL
## THETA1      0.00000e+00  0.00000e+00  0.00000e+00  -2.64681e-05
## THETA2      0.00000e+00  0.00000e+00  3.70000e+01   6.04246e-07
## THETA3      0.00000e+00  0.00000e+00  0.00000e+00   1.35185e-07
## THETA4       0.00000000   0.00000000   0.00000000    0.04191030
## THETA5       0.00000000   0.00000000   0.00000000    0.00573174
## THETA6      0.00000e+00  1.00000e+00  0.00000e+00   0.00000e+00
## THETA7      0.000000000  0.000000000  0.000000000  -0.000066826
## SIGMA(1,1)  1.00000e+10  1.00000e+00  0.00000e+00   0.00000e+00
## OMEGA(1,1)  0.028881900  0.000000000  0.000000000  -0.000260968
## OMEGA(2,1)        1e+10        1e+00        0e+00         0e+00
## OMEGA(2,2)   0.03069340   0.00000000   0.00000000    0.00335568
```

Function `get_ext` reads ext file, strips iterations, then creates backbone par table.

When you read the ext file and turn it into `as.list` or `as matrix  it turns the 1 line character input ext file into a understandable matrix.

## lol - last-of-list

Everything that is based on output from a NONMEM run is a list of length equal to the number of iterations you did. One iteration? Still a list. Use `lol` to get the last (or nth) of that list returned (as a data.frame in case of `nm_xxx`)..


``` r
"run105" %>% get_ext() %>% lol
```

```
##                estimate       se_est    eigen_cor         cond        om_sg
## THETA1      2.27050e+00  8.05415e-02  1.25021e-01  1.88444e+01  0.00000e+00
## THETA2      7.43772e+01  2.84600e+00  3.51726e-01  1.25021e-01  0.00000e+00
## THETA3      4.68147e+02  2.82706e+01  5.91659e-01  2.35594e+00  0.00000e+00
## THETA4       0.07141530   0.00824789   0.83814800   0.00000000   0.00000000
## THETA5       1.09317000   0.08601240   0.88420600   0.00000000   0.00000000
## THETA6      7.50000e-01  1.00000e+10  1.10089e+00  0.00000e+00  0.00000e+00
## THETA7      0.587380000  0.038672200  1.752410000  0.000000000  0.000000000
## SIGMA(1,1)  1.00000e+00  1.00000e+10  2.35594e+00  0.00000e+00  1.00000e+00
## OMEGA(1,1)  0.035787600  0.010927500  0.000000000  0.000000000  0.189176000
## OMEGA(2,1)        0e+00        1e+10        0e+00        0e+00        0e+00
## OMEGA(2,2)   0.14519600   0.02339120   0.00000000   0.00000000   0.38104700
##                se_om_sg          fix         term part_deriv_LL
## THETA1      0.00000e+00  0.00000e+00  0.00000e+00  -2.64681e-05
## THETA2      0.00000e+00  0.00000e+00  3.70000e+01   6.04246e-07
## THETA3      0.00000e+00  0.00000e+00  0.00000e+00   1.35185e-07
## THETA4       0.00000000   0.00000000   0.00000000    0.04191030
## THETA5       0.00000000   0.00000000   0.00000000    0.00573174
## THETA6      0.00000e+00  1.00000e+00  0.00000e+00   0.00000e+00
## THETA7      0.000000000  0.000000000  0.000000000  -0.000066826
## SIGMA(1,1)  1.00000e+10  1.00000e+00  0.00000e+00   0.00000e+00
## OMEGA(1,1)  0.028881900  0.000000000  0.000000000  -0.000260968
## OMEGA(2,1)        1e+10        1e+00        0e+00         0e+00
## OMEGA(2,2)   0.03069340   0.00000000   0.00000000    0.00335568
```

``` r
"run105" %>% get_ext() %>% lol(n=2)
```

```
##               estimate      se_est   eigen_cor        cond       om_sg
## THETA1       2.2644200   0.0794444   0.1245650  18.5242000   0.0000000
## THETA2      72.6364000   3.0647800   0.3308980   0.1245650   0.0000000
## THETA3     480.3630000  25.2242000   0.5591130   2.3074700   0.0000000
## THETA4      0.07171270  0.00819953  0.84471200  0.00000000  0.00000000
## THETA5       1.0873300   0.0851449   0.9564580   0.0000000   0.0000000
## THETA6         0.75000     0.00000     1.14255     0.00000     0.00000
## THETA7       0.6003590   0.0409449   1.7342300   0.0000000   0.0000000
## SIGMA(1,1) 1.00000e+00 0.00000e+00 2.30747e+00 0.00000e+00 1.00000e+00
## OMEGA(1,1)   0.0370303   0.0120055   0.0000000   0.0000000   0.1924330
## OMEGA(2,1)       0e+00       0e+00       0e+00       0e+00       0e+00
## OMEGA(2,2)  0.14992300  0.02358690  0.00000000  0.00000000  0.38720000
##               se_om_sg         fix        term part_deriv_LL
## THETA1       0.0000000   0.0000000   2.0000000     1.8575200
## THETA2       0.0000000   0.0000000   0.0000000     0.0390883
## THETA3       0.0000000   0.0000000   0.0000000    -0.0177468
## THETA4      0.00000000  0.00000000  0.00000000    2.05010000
## THETA5       0.0000000   0.0000000   0.0000000     0.8727930
## THETA6         0.00000     1.00000     0.00000       0.00000
## THETA7       0.0000000   0.0000000   0.0000000    -5.8033900
## SIGMA(1,1) 1.00000e+10 1.00000e+00 0.00000e+00   0.00000e+00
## OMEGA(1,1)   0.0311940   0.0000000   0.0000000     9.1901900
## OMEGA(2,1)       1e+10       1e+00       0e+00         0e+00
## OMEGA(2,2)  0.03045830  0.00000000  0.00000000    0.00902989
```

## Parameter Tables

Extensive post-processing for easy-to-include parameter tables using the function `nm_params_table`.

### PsN naming recap

name; unit; transformation

Alternatives that OK: 

$THETA 1 ; Absorption Rate Constant ; 1/h ; LIN 

$THETA 1 ; KA                       ; 1/h ; LIN ; Absorption Rate Constant

$THETA 1 ; Absorption Rate Constant ; 1/h ; LIN ; KA

Will all work.

$THETA 1 ; KA  

$THETA 1 ; KA                       ; 1/h ; LIN ; 

$THETA 1 ; KA                       ; 1/h ; LIN ; Absorption Rate Constant

Note that PsN will paste together whatever comes after the 2nd semi-colon, so the transformation may become the paste of position 3 and whatever comes after. This will make PsN's sumo -trans option fail, so you know. `nm_params_table()` will work just fine.

### Functions supporting nm_params_tables()

Shrinkage (`nm_shrinkage` and (off-)diagonals (`find_diag`).


``` r
## functions underneath that may be of interest
"run103" %>% nm_shrinkage()
```

```
## $`Stochastic Approximation Expectation-Maximization`
##   fr sr  parameter pclass   on type shrinksd
## 1  1  1 SIGMA(1,1)  SIGMA TRUE  EPS   4.5195
## 2  1  1 OMEGA(1,1)  OMEGA TRUE  ETA   1.3018
## 3  2  2 OMEGA(2,2)  OMEGA TRUE  ETA   1.3341
## 
## $`Objective Function Evaluation by Importance Sampling (No Prior)`
##   fr sr  parameter pclass   on type shrinksd
## 1  1  1 SIGMA(1,1)  SIGMA TRUE  EPS   4.6529
## 2  1  1 OMEGA(1,1)  OMEGA TRUE  ETA   1.2131
## 3  2  2 OMEGA(2,2)  OMEGA TRUE  ETA   1.2890
## 
## $`First Order Conditional Estimation with Interaction (No Prior)`
##   fr sr  parameter pclass   on type shrinksd
## 1  1  1 SIGMA(1,1)  SIGMA TRUE  EPS   4.6579
## 2  1  1 OMEGA(1,1)  OMEGA TRUE  ETA   1.2523
## 3  2  2 OMEGA(2,2)  OMEGA TRUE  ETA   1.0000
```

``` r
   "run103" %>% nm_shrinkage(eta.shrinkage.clue = "ETASHRINKVR") # check eps.shrinkage.clue = "EPSSHRINKVR"
```

```
## $`Stochastic Approximation Expectation-Maximization`
##   fr sr  parameter pclass   on type shrinksd
## 1  1  1 SIGMA(1,1)  SIGMA TRUE  EPS   4.5195
## 2  1  1 OMEGA(1,1)  OMEGA TRUE  ETA   1.3018
## 3  2  2 OMEGA(2,2)  OMEGA TRUE  ETA   1.3341
## 
## $`Objective Function Evaluation by Importance Sampling (No Prior)`
##   fr sr  parameter pclass   on type shrinksd
## 1  1  1 SIGMA(1,1)  SIGMA TRUE  EPS   4.6529
## 2  1  1 OMEGA(1,1)  OMEGA TRUE  ETA   1.2131
## 3  2  2 OMEGA(2,2)  OMEGA TRUE  ETA   1.2890
## 
## $`First Order Conditional Estimation with Interaction (No Prior)`
##   fr sr  parameter pclass   on type shrinksd
## 1  1  1 SIGMA(1,1)  SIGMA TRUE  EPS   4.6579
## 2  1  1 OMEGA(1,1)  OMEGA TRUE  ETA   1.2523
## 3  2  2 OMEGA(2,2)  OMEGA TRUE  ETA   1.0000
```

``` r
"run105" %>% find_diag()
```

```
## [[1]]
##     parameter pclass on
## 1      THETA1  THETA  0
## 2      THETA2  THETA  0
## 3      THETA3  THETA  0
## 4      THETA4  THETA  0
## 5      THETA5  THETA  0
## 6      THETA6  THETA  0
## 7      THETA7  THETA  0
## 8  SIGMA(1,1)  SIGMA  1
## 9  OMEGA(1,1)  OMEGA  1
## 10 OMEGA(2,1)  OMEGA  0
## 11 OMEGA(2,2)  OMEGA  1
## 
## [[2]]
##     parameter pclass on
## 1      THETA1  THETA  0
## 2      THETA2  THETA  0
## 3      THETA3  THETA  0
## 4      THETA4  THETA  0
## 5      THETA5  THETA  0
## 6      THETA6  THETA  0
## 7      THETA7  THETA  0
## 8  SIGMA(1,1)  SIGMA  1
## 9  OMEGA(1,1)  OMEGA  1
## 10 OMEGA(2,1)  OMEGA  0
## 11 OMEGA(2,2)  OMEGA  1
## 
## [[3]]
##     parameter pclass on
## 1      THETA1  THETA  0
## 2      THETA2  THETA  0
## 3      THETA3  THETA  0
## 4      THETA4  THETA  0
## 5      THETA5  THETA  0
## 6      THETA6  THETA  0
## 7      THETA7  THETA  0
## 8  SIGMA(1,1)  SIGMA  1
## 9  OMEGA(1,1)  OMEGA  1
## 10 OMEGA(2,1)  OMEGA  0
## 11 OMEGA(2,2)  OMEGA  1
```

### Simple parameter tables 

Explore the examples.


``` r
"run103" %>% nm_params_table()
```

```
## [[1]]
##     parameter pclass on    estimate      se_est eigen_cor       cond    om_sg
## 1      THETA1  THETA  0   2.2598500  0.06434490 0.0271756 85.2782000 0.000000
## 2      THETA2  THETA  0  72.5917000 10.59310000 0.1633420  0.0271756 0.000000
## 3      THETA3  THETA  0 448.5460000 30.74240000 0.4862410  2.3174800 0.000000
## 4      THETA4  THETA  0   0.0720032  0.00815036 0.6783080  0.0000000 0.000000
## 5      THETA5  THETA  0   1.0833100  0.09797250 0.8478870  0.0000000 0.000000
## 6      THETA6  THETA  0   0.7395590  0.36384100 1.1534300  0.0000000 0.000000
## 7      THETA7  THETA  0   0.5946970  0.05058200 1.5473700  0.0000000 0.000000
## 8  SIGMA(1,1)  SIGMA  1   1.0000000  0.00000000 1.7787700  0.0000000 1.000000
## 9  OMEGA(1,1)  OMEGA  1   0.0369896  0.01334860 2.3174800  0.0000000 0.192327
## 10 OMEGA(2,1)  OMEGA  0   0.0000000  0.00000000 0.0000000  0.0000000 0.000000
## 11 OMEGA(2,2)  OMEGA  1   0.1508320  0.05159710 0.0000000  0.0000000 0.388371
##       se_om_sg fix term part_deriv_LL fr sr type shrinksd       RSE
## 1  0.00000e+00   0    2    1.53102000 NA NA        0.0000  2.847308
## 2  0.00000e+00   0    0    0.13829700 NA NA        0.0000 14.592715
## 3  0.00000e+00   0    0    0.04954420 NA NA        0.0000  6.853790
## 4  0.00000e+00   0    0   -1.43472000 NA NA        0.0000 11.319441
## 5  0.00000e+00   0    0    1.39039000 NA NA        0.0000  9.043810
## 6  0.00000e+00   0    0   -3.03716000 NA NA        0.0000 49.197021
## 7  0.00000e+00   0    0    6.69407000 NA NA        0.0000  8.505508
## 8  1.00000e+10   1    0    0.00000000  1  1  EPS   4.5195  0.000000
## 9  3.47030e-02   0    0   -0.16907500  1  1  ETA   1.3018 36.087441
## 10 1.00000e+10   1    0    0.00000000 NA NA        0.0000  0.000000
## 11 6.64276e-02   0    0    0.00650042  2  2  ETA   1.3341 34.208324
##               CI95        item     symbol  unit transform
## 1      2.13 - 2.39    theta_01         KA   1/h       LIN
## 2      51.8 - 93.4    theta_02         CL   L/h       LIN
## 3        388 - 509    theta_03         V2     L       LIN
## 4    0.056 - 0.088    theta_04       RUVp  <NA>       LIN
## 5     0.891 - 1.28    theta_05       RUVa ng/mL       LIN
## 6    0.0264 - 1.45    theta_06      CL-WT  <NA>       LIN
## 7    0.496 - 0.694    theta_07     CL-SEX  <NA>       LIN
## 8                - sigma_01_01       EPS1  <NA>      <NA>
## 9  0.0108 - 0.0632 omega_01_01     iiv CL  <NA>      <NA>
## 10               - omega_02_01 OMEGA(2,1)  <NA>      <NA>
## 11  0.0497 - 0.252 omega_02_02     iiv V2  <NA>      <NA>
##                       label
## 1  Absorption Rate Constant
## 2                 Clearance
## 3    Volume of Distribution
## 4        Proportional Error
## 5            Additive Error
## 6        Power Scalar CL-WT
## 7          Female CL Change
## 8                       RUV
## 9                   IIV(CL)
## 10               OMEGA(2,1)
## 11                  IIV(V2)
## 
## [[2]]
##     parameter pclass on    estimate      se_est eigen_cor       cond    om_sg
## 1      THETA1  THETA  0   2.2598500  0.07954000 0.0973847 25.5667000 0.000000
## 2      THETA2  THETA  0  72.5917000  3.87839000 0.1542600  0.0973847 0.000000
## 3      THETA3  THETA  0 448.5460000 22.68500000 0.6112300  2.4898000 0.000000
## 4      THETA4  THETA  0   0.0720032  0.00811598 0.7310460  0.0000000 0.000000
## 5      THETA5  THETA  0   1.0833100  0.08445940 0.8697180  0.0000000 0.000000
## 6      THETA6  THETA  0   0.7395590  0.12324600 1.0470100  0.0000000 0.000000
## 7      THETA7  THETA  0   0.5946970  0.04052430 1.4154900  0.0000000 0.000000
## 8  SIGMA(1,1)  SIGMA  1   1.0000000  0.00000000 1.5840600  0.0000000 1.000000
## 9  OMEGA(1,1)  OMEGA  1   0.0369896  0.01233160 2.4898000  0.0000000 0.192327
## 10 OMEGA(2,1)  OMEGA  0   0.0000000  0.00000000 0.0000000  0.0000000 0.000000
## 11 OMEGA(2,2)  OMEGA  1   0.1508320  0.02428140 0.0000000  0.0000000 0.388371
##       se_om_sg fix term part_deriv_LL fr sr type shrinksd       RSE
## 1  0.00000e+00   0    2     1.5027400 NA NA        0.0000  3.519703
## 2  0.00000e+00   0    0     0.0770840 NA NA        0.0000  5.342746
## 3  0.00000e+00   0    0     0.0208706 NA NA        0.0000  5.057452
## 4  0.00000e+00   0    0    -1.4271200 NA NA        0.0000 11.271693
## 5  0.00000e+00   0    0     1.2411700 NA NA        0.0000  7.796420
## 6  0.00000e+00   0    0    -1.3443000 NA NA        0.0000 16.664796
## 7  0.00000e+00   0    0    -0.2305750 NA NA        0.0000  6.814277
## 8  1.00000e+10   1    0     0.0000000  1  1  EPS   4.6529  0.000000
## 9  3.20591e-02   0    0     9.5243200  1  1  ETA   1.2131 33.338019
## 10 1.00000e+10   1    0     0.0000000 NA NA        0.0000  0.000000
## 11 3.12607e-02   0    0    -0.0144470  2  2  ETA   1.2890 16.098308
##               CI95        item     symbol  unit transform
## 1       2.1 - 2.42    theta_01         KA   1/h       LIN
## 2        65 - 80.2    theta_02         CL   L/h       LIN
## 3        404 - 493    theta_03         V2     L       LIN
## 4  0.0561 - 0.0879    theta_04       RUVp  <NA>       LIN
## 5     0.918 - 1.25    theta_05       RUVa ng/mL       LIN
## 6    0.498 - 0.981    theta_06      CL-WT  <NA>       LIN
## 7    0.515 - 0.674    theta_07     CL-SEX  <NA>       LIN
## 8                - sigma_01_01       EPS1  <NA>      <NA>
## 9  0.0128 - 0.0612 omega_01_01     iiv CL  <NA>      <NA>
## 10               - omega_02_01 OMEGA(2,1)  <NA>      <NA>
## 11   0.103 - 0.198 omega_02_02     iiv V2  <NA>      <NA>
##                       label
## 1  Absorption Rate Constant
## 2                 Clearance
## 3    Volume of Distribution
## 4        Proportional Error
## 5            Additive Error
## 6        Power Scalar CL-WT
## 7          Female CL Change
## 8                       RUV
## 9                   IIV(CL)
## 10               OMEGA(2,1)
## 11                  IIV(V2)
## 
## [[3]]
##     parameter pclass on    estimate      se_est eigen_cor       cond    om_sg
## 1      THETA1  THETA  0   2.2705000 8.05467e-02 0.0964827 25.9927000 0.000000
## 2      THETA2  THETA  0  74.2674000 3.76134e+00 0.1516630  0.0964827 0.000000
## 3      THETA3  THETA  0 468.1450000 2.82716e+01 0.5382020  2.5078500 0.000000
## 4      THETA4  THETA  0   0.0714092 8.19589e-03 0.8350520  0.0000000 0.000000
## 5      THETA5  THETA  0   1.0932500 8.58609e-02 0.8630220  0.0000000 0.000000
## 6      THETA6  THETA  0   0.7451050 1.27530e-01 1.0370800  0.0000000 0.000000
## 7      THETA7  THETA  0   0.5872060 4.00082e-02 1.3480700  0.0000000 0.000000
## 8  SIGMA(1,1)  SIGMA  1   1.0000000 1.00000e+10 1.6225800  0.0000000 1.000000
## 9  OMEGA(1,1)  OMEGA  1   0.0357831 1.09243e-02 2.5078500  0.0000000 0.189164
## 10 OMEGA(2,1)  OMEGA  0   0.0000000 1.00000e+10 0.0000000  0.0000000 0.000000
## 11 OMEGA(2,2)  OMEGA  1   0.1451950 2.33885e-02 0.0000000  0.0000000 0.381044
##       se_om_sg fix term part_deriv_LL fr sr type shrinksd          RSE
## 1  0.00000e+00   0    0   5.48200e-06 NA NA        0.0000 3.547531e+00
## 2  0.00000e+00   0   37   9.29421e-06 NA NA        0.0000 5.064591e+00
## 3  0.00000e+00   0    0   1.49913e-06 NA NA        0.0000 6.039069e+00
## 4  0.00000e+00   0    0   4.28314e-02 NA NA        0.0000 1.147736e+01
## 5  0.00000e+00   0    0   5.83685e-03 NA NA        0.0000 7.853730e+00
## 6  0.00000e+00   0    0  -1.71198e-03 NA NA        0.0000 1.711571e+01
## 7  0.00000e+00   0    0   1.51473e-03 NA NA        0.0000 6.813316e+00
## 8  1.00000e+10   1    0   0.00000e+00  1  1  EPS   4.6579 1.000000e+12
## 9  2.88751e-02   0    0   5.77672e-03  1  1  ETA   1.2523 3.052922e+01
## 10 1.00000e+10   1    0   0.00000e+00 NA NA        0.0000          Inf
## 11 3.06900e-02   0    0   3.64906e-03  2  2  ETA   1.0000 1.610834e+01
##               CI95        item     symbol  unit transform
## 1      2.11 - 2.43    theta_01         KA   1/h       LIN
## 2      66.9 - 81.6    theta_02         CL   L/h       LIN
## 3        413 - 524    theta_03         V2     L       LIN
## 4  0.0553 - 0.0875    theta_04       RUVp  <NA>       LIN
## 5     0.925 - 1.26    theta_05       RUVa ng/mL       LIN
## 6    0.495 - 0.995    theta_06      CL-WT  <NA>       LIN
## 7    0.509 - 0.666    theta_07     CL-SEX  <NA>       LIN
## 8                - sigma_01_01       EPS1  <NA>      <NA>
## 9  0.0144 - 0.0572 omega_01_01     iiv CL  <NA>      <NA>
## 10               - omega_02_01 OMEGA(2,1)  <NA>      <NA>
## 11  0.0994 - 0.191 omega_02_02     iiv V2  <NA>      <NA>
##                       label
## 1  Absorption Rate Constant
## 2                 Clearance
## 3    Volume of Distribution
## 4        Proportional Error
## 5            Additive Error
## 6        Power Scalar CL-WT
## 7          Female CL Change
## 8                       RUV
## 9                   IIV(CL)
## 10               OMEGA(2,1)
## 11                  IIV(V2)
## 
## attr(,"class")
## [1] "nmpartab" "list"
```

``` r
"run103" %>% nm_params_table() %>% names
```

```
## NULL
```

``` r
"run103" %>% nm_params_table() %>% lol
```

```
##     parameter pclass on    estimate      se_est eigen_cor       cond    om_sg
## 1      THETA1  THETA  0   2.2705000 8.05467e-02 0.0964827 25.9927000 0.000000
## 2      THETA2  THETA  0  74.2674000 3.76134e+00 0.1516630  0.0964827 0.000000
## 3      THETA3  THETA  0 468.1450000 2.82716e+01 0.5382020  2.5078500 0.000000
## 4      THETA4  THETA  0   0.0714092 8.19589e-03 0.8350520  0.0000000 0.000000
## 5      THETA5  THETA  0   1.0932500 8.58609e-02 0.8630220  0.0000000 0.000000
## 6      THETA6  THETA  0   0.7451050 1.27530e-01 1.0370800  0.0000000 0.000000
## 7      THETA7  THETA  0   0.5872060 4.00082e-02 1.3480700  0.0000000 0.000000
## 8  SIGMA(1,1)  SIGMA  1   1.0000000 1.00000e+10 1.6225800  0.0000000 1.000000
## 9  OMEGA(1,1)  OMEGA  1   0.0357831 1.09243e-02 2.5078500  0.0000000 0.189164
## 10 OMEGA(2,1)  OMEGA  0   0.0000000 1.00000e+10 0.0000000  0.0000000 0.000000
## 11 OMEGA(2,2)  OMEGA  1   0.1451950 2.33885e-02 0.0000000  0.0000000 0.381044
##       se_om_sg fix term part_deriv_LL fr sr type shrinksd          RSE
## 1  0.00000e+00   0    0   5.48200e-06 NA NA        0.0000 3.547531e+00
## 2  0.00000e+00   0   37   9.29421e-06 NA NA        0.0000 5.064591e+00
## 3  0.00000e+00   0    0   1.49913e-06 NA NA        0.0000 6.039069e+00
## 4  0.00000e+00   0    0   4.28314e-02 NA NA        0.0000 1.147736e+01
## 5  0.00000e+00   0    0   5.83685e-03 NA NA        0.0000 7.853730e+00
## 6  0.00000e+00   0    0  -1.71198e-03 NA NA        0.0000 1.711571e+01
## 7  0.00000e+00   0    0   1.51473e-03 NA NA        0.0000 6.813316e+00
## 8  1.00000e+10   1    0   0.00000e+00  1  1  EPS   4.6579 1.000000e+12
## 9  2.88751e-02   0    0   5.77672e-03  1  1  ETA   1.2523 3.052922e+01
## 10 1.00000e+10   1    0   0.00000e+00 NA NA        0.0000          Inf
## 11 3.06900e-02   0    0   3.64906e-03  2  2  ETA   1.0000 1.610834e+01
##               CI95        item     symbol  unit transform
## 1      2.11 - 2.43    theta_01         KA   1/h       LIN
## 2      66.9 - 81.6    theta_02         CL   L/h       LIN
## 3        413 - 524    theta_03         V2     L       LIN
## 4  0.0553 - 0.0875    theta_04       RUVp  <NA>       LIN
## 5     0.925 - 1.26    theta_05       RUVa ng/mL       LIN
## 6    0.495 - 0.995    theta_06      CL-WT  <NA>       LIN
## 7    0.509 - 0.666    theta_07     CL-SEX  <NA>       LIN
## 8                - sigma_01_01       EPS1  <NA>      <NA>
## 9  0.0144 - 0.0572 omega_01_01     iiv CL  <NA>      <NA>
## 10               - omega_02_01 OMEGA(2,1)  <NA>      <NA>
## 11  0.0994 - 0.191 omega_02_02     iiv V2  <NA>      <NA>
##                       label
## 1  Absorption Rate Constant
## 2                 Clearance
## 3    Volume of Distribution
## 4        Proportional Error
## 5            Additive Error
## 6        Power Scalar CL-WT
## 7          Female CL Change
## 8                       RUV
## 9                   IIV(CL)
## 10               OMEGA(2,1)
## 11                  IIV(V2)
```

``` r
"run103" %>% nm_params_table_short() %>% lol
```

```
##     parameter    estimate          RSE            CI95 fix shrinksd     symbol
## 1      THETA1   2.2705000 3.547531e+00     2.11 - 2.43   0   0.0000         KA
## 2      THETA2  74.2674000 5.064591e+00     66.9 - 81.6   0   0.0000         CL
## 3      THETA3 468.1450000 6.039069e+00       413 - 524   0   0.0000         V2
## 4      THETA4   0.0714092 1.147736e+01 0.0553 - 0.0875   0   0.0000       RUVp
## 5      THETA5   1.0932500 7.853730e+00    0.925 - 1.26   0   0.0000       RUVa
## 6      THETA6   0.7451050 1.711571e+01   0.495 - 0.995   0   0.0000      CL-WT
## 7      THETA7   0.5872060 6.813316e+00   0.509 - 0.666   0   0.0000     CL-SEX
## 8  SIGMA(1,1)   1.0000000 1.000000e+12               -   1   4.6579       EPS1
## 9  OMEGA(1,1)   0.0357831 3.052922e+01 0.0144 - 0.0572   0   1.2523     iiv CL
## 10 OMEGA(2,1)   0.0000000          Inf               -   1   0.0000 OMEGA(2,1)
## 11 OMEGA(2,2)   0.1451950 1.610834e+01  0.0994 - 0.191   0   1.0000     iiv V2
##     unit transform                    label      se_est
## 1    1/h       LIN Absorption Rate Constant 8.05467e-02
## 2    L/h       LIN                Clearance 3.76134e+00
## 3      L       LIN   Volume of Distribution 2.82716e+01
## 4   <NA>       LIN       Proportional Error 8.19589e-03
## 5  ng/mL       LIN           Additive Error 8.58609e-02
## 6   <NA>       LIN       Power Scalar CL-WT 1.27530e-01
## 7   <NA>       LIN         Female CL Change 4.00082e-02
## 8   <NA>      <NA>                      RUV 1.00000e+10
## 9   <NA>      <NA>                  IIV(CL) 1.09243e-02
## 10  <NA>      <NA>               OMEGA(2,1) 1.00000e+10
## 11  <NA>      <NA>                  IIV(V2) 2.33885e-02
```

``` r
"run103" %>% nm_params_table() %>% format 
```

```
## [[1]]
##     Parameter              Description       Name     Estimate  RSE
## 1          KA Absorption Rate Constant     THETA1         2.26 2.85
## 2          CL                Clearance     THETA2         72.6 14.6
## 3          V2   Volume of Distribution     THETA3          449 6.85
## 4        RUVp       Proportional Error     THETA4       0.0720 11.3
## 5        RUVa           Additive Error     THETA5         1.08 9.04
## 6       CL-WT       Power Scalar CL-WT     THETA6        0.740 49.2
## 7      CL-SEX         Female CL Change     THETA7        0.595 8.51
## 8        EPS1                      RUV SIGMA(1,1) 1.00 (fixed)    -
## 9      iiv CL                  IIV(CL) OMEGA(1,1)       0.0370 36.1
## 10 OMEGA(2,1)               OMEGA(2,1) OMEGA(2,1) 0.00 (fixed)    -
## 11     iiv V2                  IIV(V2) OMEGA(2,2)        0.151 34.2
##           95\\% CI Shrinkage  unit transform trnsfd fix
## 1      2.13 - 2.39      0.00   1/h       LIN      0   0
## 2      51.8 - 93.4      0.00   L/h       LIN      0   0
## 3        388 - 509      0.00     L       LIN      0   0
## 4    0.056 - 0.088      0.00     -       LIN      0   0
## 5     0.891 - 1.28      0.00 ng/mL       LIN      0   0
## 6    0.0264 - 1.45      0.00     -       LIN      0   0
## 7    0.496 - 0.694      0.00     -       LIN      0   0
## 8                -      4.52     -         -      0   1
## 9  0.0108 - 0.0632      1.30     -         -      0   0
## 10               -      0.00     -         -      0   1
## 11  0.0497 - 0.252      1.33     -         -      0   0
## 
## [[2]]
##     Parameter              Description       Name     Estimate  RSE
## 1          KA Absorption Rate Constant     THETA1         2.26 3.52
## 2          CL                Clearance     THETA2         72.6 5.34
## 3          V2   Volume of Distribution     THETA3          449 5.06
## 4        RUVp       Proportional Error     THETA4       0.0720 11.3
## 5        RUVa           Additive Error     THETA5         1.08 7.80
## 6       CL-WT       Power Scalar CL-WT     THETA6        0.740 16.7
## 7      CL-SEX         Female CL Change     THETA7        0.595 6.81
## 8        EPS1                      RUV SIGMA(1,1) 1.00 (fixed)    -
## 9      iiv CL                  IIV(CL) OMEGA(1,1)       0.0370 33.3
## 10 OMEGA(2,1)               OMEGA(2,1) OMEGA(2,1) 0.00 (fixed)    -
## 11     iiv V2                  IIV(V2) OMEGA(2,2)        0.151 16.1
##           95\\% CI Shrinkage  unit transform trnsfd fix
## 1       2.1 - 2.42      0.00   1/h       LIN      0   0
## 2        65 - 80.2      0.00   L/h       LIN      0   0
## 3        404 - 493      0.00     L       LIN      0   0
## 4  0.0561 - 0.0879      0.00     -       LIN      0   0
## 5     0.918 - 1.25      0.00 ng/mL       LIN      0   0
## 6    0.498 - 0.981      0.00     -       LIN      0   0
## 7    0.515 - 0.674      0.00     -       LIN      0   0
## 8                -      4.65     -         -      0   1
## 9  0.0128 - 0.0612      1.21     -         -      0   0
## 10               -      0.00     -         -      0   1
## 11   0.103 - 0.198      1.29     -         -      0   0
## 
## [[3]]
##     Parameter              Description       Name     Estimate  RSE
## 1          KA Absorption Rate Constant     THETA1         2.27 3.55
## 2          CL                Clearance     THETA2         74.3 5.06
## 3          V2   Volume of Distribution     THETA3          468 6.04
## 4        RUVp       Proportional Error     THETA4       0.0714 11.5
## 5        RUVa           Additive Error     THETA5         1.09 7.85
## 6       CL-WT       Power Scalar CL-WT     THETA6        0.745 17.1
## 7      CL-SEX         Female CL Change     THETA7        0.587 6.81
## 8        EPS1                      RUV SIGMA(1,1) 1.00 (fixed)    -
## 9      iiv CL                  IIV(CL) OMEGA(1,1)       0.0358 30.5
## 10 OMEGA(2,1)               OMEGA(2,1) OMEGA(2,1) 0.00 (fixed)    -
## 11     iiv V2                  IIV(V2) OMEGA(2,2)        0.145 16.1
##           95\\% CI Shrinkage  unit transform trnsfd fix
## 1      2.11 - 2.43      0.00   1/h       LIN      0   0
## 2      66.9 - 81.6      0.00   L/h       LIN      0   0
## 3        413 - 524      0.00     L       LIN      0   0
## 4  0.0553 - 0.0875      0.00     -       LIN      0   0
## 5     0.925 - 1.26      0.00 ng/mL       LIN      0   0
## 6    0.495 - 0.995      0.00     -       LIN      0   0
## 7    0.509 - 0.666      0.00     -       LIN      0   0
## 8                -      4.66     -         -      0   1
## 9  0.0144 - 0.0572      1.25     -         -      0   0
## 10               -      0.00     -         -      0   1
## 11  0.0994 - 0.191      1.00     -         -      0   0
```

``` r
"run103" %>% nm_params_table() %>% lol %>% format(digits = 2)
```

```
##     Parameter              Description       Name    Estimate RSE
## 1          KA Absorption Rate Constant     THETA1         2.3 3.5
## 2          CL                Clearance     THETA2          74 5.1
## 3          V2   Volume of Distribution     THETA3     4.7e+02 6.0
## 4        RUVp       Proportional Error     THETA4       0.071  11
## 5        RUVa           Additive Error     THETA5         1.1 7.9
## 6       CL-WT       Power Scalar CL-WT     THETA6        0.75  17
## 7      CL-SEX         Female CL Change     THETA7        0.59 6.8
## 8        EPS1                      RUV SIGMA(1,1) 1.0 (fixed)   -
## 9      iiv CL                  IIV(CL) OMEGA(1,1)       0.036  31
## 10 OMEGA(2,1)               OMEGA(2,1) OMEGA(2,1) 0.0 (fixed)   -
## 11     iiv V2                  IIV(V2) OMEGA(2,2)        0.15  16
##           95\\% CI Shrinkage  unit transform trnsfd fix
## 1      2.11 - 2.43       0.0   1/h       LIN      0   0
## 2      66.9 - 81.6       0.0   L/h       LIN      0   0
## 3        413 - 524       0.0     L       LIN      0   0
## 4  0.0553 - 0.0875       0.0     -       LIN      0   0
## 5     0.925 - 1.26       0.0 ng/mL       LIN      0   0
## 6    0.495 - 0.995       0.0     -       LIN      0   0
## 7    0.509 - 0.666       0.0     -       LIN      0   0
## 8                -       4.7     -         -      0   1
## 9  0.0144 - 0.0572       1.3     -         -      0   0
## 10               -       0.0     -         -      0   1
## 11  0.0994 - 0.191       1.0     -         -      0   0
```

You're getting a parameter table for each estimation method. So the output is a list!

Function `lol`  - see explanation above. All 'qptools' functions are methods able to work with list of data frames or data frames themselves. No worries.

### Formatting parameter tables


``` r
"run103" %>% nm_params_table %>% 
  lol %>% 
  format(paste_label_unit='label')
```

```
##     Parameter                    Description       Name     Estimate  RSE
## 1          KA Absorption Rate Constant (1/h)     THETA1         2.27 3.55
## 2          CL                Clearance (L/h)     THETA2         74.3 5.06
## 3          V2     Volume of Distribution (L)     THETA3          468 6.04
## 4        RUVp         Proportional Error (-)     THETA4       0.0714 11.5
## 5        RUVa         Additive Error (ng/mL)     THETA5         1.09 7.85
## 6       CL-WT         Power Scalar CL-WT (-)     THETA6        0.745 17.1
## 7      CL-SEX           Female CL Change (-)     THETA7        0.587 6.81
## 8        EPS1                        RUV (-) SIGMA(1,1) 1.00 (fixed)    -
## 9      iiv CL                    IIV(CL) (-) OMEGA(1,1)       0.0358 30.5
## 10 OMEGA(2,1)                 OMEGA(2,1) (-) OMEGA(2,1) 0.00 (fixed)    -
## 11     iiv V2                    IIV(V2) (-) OMEGA(2,2)        0.145 16.1
##           95\\% CI Shrinkage  unit transform trnsfd fix
## 1      2.11 - 2.43      0.00   1/h       LIN      0   0
## 2      66.9 - 81.6      0.00   L/h       LIN      0   0
## 3        413 - 524      0.00     L       LIN      0   0
## 4  0.0553 - 0.0875      0.00     -       LIN      0   0
## 5     0.925 - 1.26      0.00 ng/mL       LIN      0   0
## 6    0.495 - 0.995      0.00     -       LIN      0   0
## 7    0.509 - 0.666      0.00     -       LIN      0   0
## 8                -      4.66     -         -      0   1
## 9  0.0144 - 0.0572      1.25     -         -      0   0
## 10               -      0.00     -         -      0   1
## 11  0.0994 - 0.191      1.00     -         -      0   0
```

``` r
## doing lol either before or after works
"run103" %>% nm_params_table %>% 
  format(paste_label_unit='label') %>% 
  lol
```

```
##     Parameter                    Description       Name     Estimate  RSE
## 1          KA Absorption Rate Constant (1/h)     THETA1         2.27 3.55
## 2          CL                Clearance (L/h)     THETA2         74.3 5.06
## 3          V2     Volume of Distribution (L)     THETA3          468 6.04
## 4        RUVp         Proportional Error (-)     THETA4       0.0714 11.5
## 5        RUVa         Additive Error (ng/mL)     THETA5         1.09 7.85
## 6       CL-WT         Power Scalar CL-WT (-)     THETA6        0.745 17.1
## 7      CL-SEX           Female CL Change (-)     THETA7        0.587 6.81
## 8        EPS1                        RUV (-) SIGMA(1,1) 1.00 (fixed)    -
## 9      iiv CL                    IIV(CL) (-) OMEGA(1,1)       0.0358 30.5
## 10 OMEGA(2,1)                 OMEGA(2,1) (-) OMEGA(2,1) 0.00 (fixed)    -
## 11     iiv V2                    IIV(V2) (-) OMEGA(2,2)        0.145 16.1
##           95\\% CI Shrinkage  unit transform trnsfd fix
## 1      2.11 - 2.43      0.00   1/h       LIN      0   0
## 2      66.9 - 81.6      0.00   L/h       LIN      0   0
## 3        413 - 524      0.00     L       LIN      0   0
## 4  0.0553 - 0.0875      0.00     -       LIN      0   0
## 5     0.925 - 1.26      0.00 ng/mL       LIN      0   0
## 6    0.495 - 0.995      0.00     -       LIN      0   0
## 7    0.509 - 0.666      0.00     -       LIN      0   0
## 8                -      4.66     -         -      0   1
## 9  0.0144 - 0.0572      1.25     -         -      0   0
## 10               -      0.00     -         -      0   1
## 11  0.0994 - 0.191      1.00     -         -      0   0
```

``` r
## rename columns as you desire - super-easy
"run103" %>% nm_params_table %>% 
   lol %>% 
   format(paste_label_unit='symbol') %>%
  select(-Parameter) %>%
  rename(Parameter = Description)
```

```
##         Parameter       Name     Estimate  RSE        95\\% CI Shrinkage  unit
## 1        KA (1/h)     THETA1         2.27 3.55     2.11 - 2.43      0.00   1/h
## 2        CL (L/h)     THETA2         74.3 5.06     66.9 - 81.6      0.00   L/h
## 3          V2 (L)     THETA3          468 6.04       413 - 524      0.00     L
## 4        RUVp (-)     THETA4       0.0714 11.5 0.0553 - 0.0875      0.00     -
## 5    RUVa (ng/mL)     THETA5         1.09 7.85    0.925 - 1.26      0.00 ng/mL
## 6       CL-WT (-)     THETA6        0.745 17.1   0.495 - 0.995      0.00     -
## 7      CL-SEX (-)     THETA7        0.587 6.81   0.509 - 0.666      0.00     -
## 8        EPS1 (-) SIGMA(1,1) 1.00 (fixed)    -               -      4.66     -
## 9      iiv CL (-) OMEGA(1,1)       0.0358 30.5 0.0144 - 0.0572      1.25     -
## 10 OMEGA(2,1) (-) OMEGA(2,1) 0.00 (fixed)    -               -      0.00     -
## 11     iiv V2 (-) OMEGA(2,2)        0.145 16.1  0.0994 - 0.191      1.00     -
##    transform trnsfd fix
## 1        LIN      0   0
## 2        LIN      0   0
## 3        LIN      0   0
## 4        LIN      0   0
## 5        LIN      0   0
## 6        LIN      0   0
## 7        LIN      0   0
## 8          -      0   1
## 9          -      0   0
## 10         -      0   1
## 11         -      0   0
```

``` r
## formatting, AND preserve all intermediate material created using argument 'pretty=FALSE'
"run103" %>% nm_params_table %>% 
   lol %>% 
   format(paste_label_unit='label', pretty = FALSE)
```

```
##          Name pclass on     Estimate se_est eigen_cor       cond    om_sg
## 1      THETA1  THETA  0         2.27    --- 0.0964827 25.9927000 0.000000
## 2      THETA2  THETA  0         74.3    --- 0.1516630  0.0964827 0.000000
## 3      THETA3  THETA  0          468    --- 0.5382020  2.5078500 0.000000
## 4      THETA4  THETA  0       0.0714    --- 0.8350520  0.0000000 0.000000
## 5      THETA5  THETA  0         1.09    --- 0.8630220  0.0000000 0.000000
## 6      THETA6  THETA  0        0.745    --- 1.0370800  0.0000000 0.000000
## 7      THETA7  THETA  0        0.587    --- 1.3480700  0.0000000 0.000000
## 8  SIGMA(1,1)  SIGMA  1 1.00 (fixed)      - 1.6225800  0.0000000 1.000000
## 9  OMEGA(1,1)  OMEGA  1       0.0358    --- 2.5078500  0.0000000 0.189164
## 10 OMEGA(2,1)  OMEGA  0 0.00 (fixed)      - 0.0000000  0.0000000 0.000000
## 11 OMEGA(2,2)  OMEGA  1        0.145    --- 0.0000000  0.0000000 0.381044
##       se_om_sg fix term part_deriv_LL fr sr type Shrinkage  RSE        95\\% CI
## 1  0.00000e+00   0    0   5.48200e-06 NA NA           0.00 3.55     2.11 - 2.43
## 2  0.00000e+00   0   37   9.29421e-06 NA NA           0.00 5.06     66.9 - 81.6
## 3  0.00000e+00   0    0   1.49913e-06 NA NA           0.00 6.04       413 - 524
## 4  0.00000e+00   0    0   4.28314e-02 NA NA           0.00 11.5 0.0553 - 0.0875
## 5  0.00000e+00   0    0   5.83685e-03 NA NA           0.00 7.85    0.925 - 1.26
## 6  0.00000e+00   0    0  -1.71198e-03 NA NA           0.00 17.1   0.495 - 0.995
## 7  0.00000e+00   0    0   1.51473e-03 NA NA           0.00 6.81   0.509 - 0.666
## 8  1.00000e+10   1    0   0.00000e+00  1  1  EPS      4.66    -               -
## 9  2.88751e-02   0    0   5.77672e-03  1  1  ETA      1.25 30.5 0.0144 - 0.0572
## 10 1.00000e+10   1    0   0.00000e+00 NA NA           0.00    -               -
## 11 3.06900e-02   0    0   3.64906e-03  2  2  ETA      1.00 16.1  0.0994 - 0.191
##           item  Parameter  unit transform                    Description
## 1     theta_01         KA   1/h       LIN Absorption Rate Constant (1/h)
## 2     theta_02         CL   L/h       LIN                Clearance (L/h)
## 3     theta_03         V2     L       LIN     Volume of Distribution (L)
## 4     theta_04       RUVp     -       LIN         Proportional Error (-)
## 5     theta_05       RUVa ng/mL       LIN         Additive Error (ng/mL)
## 6     theta_06      CL-WT     -       LIN         Power Scalar CL-WT (-)
## 7     theta_07     CL-SEX     -       LIN           Female CL Change (-)
## 8  sigma_01_01       EPS1     -         -                        RUV (-)
## 9  omega_01_01     iiv CL     -         -                    IIV(CL) (-)
## 10 omega_02_01 OMEGA(2,1)     -         -                 OMEGA(2,1) (-)
## 11 omega_02_02     iiv V2     -         -                    IIV(V2) (-)
##    estimate_untransf se_est_untransf RSE_untransf   CI95_untransf equation
## 1          2.2705000     8.05467e-02 3.547531e+00     2.11 - 2.43        -
## 2         74.2674000     3.76134e+00 5.064591e+00     66.9 - 81.6        -
## 3        468.1450000     2.82716e+01 6.039069e+00       413 - 524        -
## 4          0.0714092     8.19589e-03 1.147736e+01 0.0553 - 0.0875        -
## 5          1.0932500     8.58609e-02 7.853730e+00    0.925 - 1.26        -
## 6          0.7451050     1.27530e-01 1.711571e+01   0.495 - 0.995        -
## 7          0.5872060     4.00082e-02 6.813316e+00   0.509 - 0.666        -
## 8          1.0000000     1.00000e+10 1.000000e+12               -        -
## 9          0.0357831     1.09243e-02 3.052922e+01 0.0144 - 0.0572        -
## 10         0.0000000     1.00000e+10          Inf               -        -
## 11         0.1451950     2.33885e-02 1.610834e+01  0.0994 - 0.191        -
##    trnsfd
## 1       0
## 2       0
## 3       0
## 4       0
## 5       0
## 6       0
## 7       0
## 8       0
## 9       0
## 10      0
## 11      0
```

``` r
## use the 4th labeling element instead of the 1st 
"run103" %>% nm_params_table %>% 
   format(paste_label_unit='symbol') %>%
  lol # does not matter when you select the estimation method. Before, after none (defaulting to last). all good
```

```
##     Parameter    Description       Name     Estimate  RSE        95\\% CI
## 1          KA       KA (1/h)     THETA1         2.27 3.55     2.11 - 2.43
## 2          CL       CL (L/h)     THETA2         74.3 5.06     66.9 - 81.6
## 3          V2         V2 (L)     THETA3          468 6.04       413 - 524
## 4        RUVp       RUVp (-)     THETA4       0.0714 11.5 0.0553 - 0.0875
## 5        RUVa   RUVa (ng/mL)     THETA5         1.09 7.85    0.925 - 1.26
## 6       CL-WT      CL-WT (-)     THETA6        0.745 17.1   0.495 - 0.995
## 7      CL-SEX     CL-SEX (-)     THETA7        0.587 6.81   0.509 - 0.666
## 8        EPS1       EPS1 (-) SIGMA(1,1) 1.00 (fixed)    -               -
## 9      iiv CL     iiv CL (-) OMEGA(1,1)       0.0358 30.5 0.0144 - 0.0572
## 10 OMEGA(2,1) OMEGA(2,1) (-) OMEGA(2,1) 0.00 (fixed)    -               -
## 11     iiv V2     iiv V2 (-) OMEGA(2,2)        0.145 16.1  0.0994 - 0.191
##    Shrinkage  unit transform trnsfd fix
## 1       0.00   1/h       LIN      0   0
## 2       0.00   L/h       LIN      0   0
## 3       0.00     L       LIN      0   0
## 4       0.00     -       LIN      0   0
## 5       0.00 ng/mL       LIN      0   0
## 6       0.00     -       LIN      0   0
## 7       0.00     -       LIN      0   0
## 8       4.66     -         -      0   1
## 9       1.25     -         -      0   0
## 10      0.00     -         -      0   1
## 11      1.00     -         -      0   0
```

Check the results and understand the differences.

### parameter tables - extra


``` r
"run103" %>% nm_params_table %>% 
  lol %>% 
  format(paste_label_unit='symbol', pretty=FALSE) %>%
  filter(on==0)
```

```
##         Name pclass on     Estimate se_est eigen_cor       cond om_sg se_om_sg
## 1     THETA1  THETA  0         2.27    --- 0.0964827 25.9927000     0    0e+00
## 2     THETA2  THETA  0         74.3    --- 0.1516630  0.0964827     0    0e+00
## 3     THETA3  THETA  0          468    --- 0.5382020  2.5078500     0    0e+00
## 4     THETA4  THETA  0       0.0714    --- 0.8350520  0.0000000     0    0e+00
## 5     THETA5  THETA  0         1.09    --- 0.8630220  0.0000000     0    0e+00
## 6     THETA6  THETA  0        0.745    --- 1.0370800  0.0000000     0    0e+00
## 7     THETA7  THETA  0        0.587    --- 1.3480700  0.0000000     0    0e+00
## 8 OMEGA(2,1)  OMEGA  0 0.00 (fixed)      - 0.0000000  0.0000000     0    1e+10
##   fix term part_deriv_LL fr sr type Shrinkage  RSE        95\\% CI        item
## 1   0    0   5.48200e-06 NA NA           0.00 3.55     2.11 - 2.43    theta_01
## 2   0   37   9.29421e-06 NA NA           0.00 5.06     66.9 - 81.6    theta_02
## 3   0    0   1.49913e-06 NA NA           0.00 6.04       413 - 524    theta_03
## 4   0    0   4.28314e-02 NA NA           0.00 11.5 0.0553 - 0.0875    theta_04
## 5   0    0   5.83685e-03 NA NA           0.00 7.85    0.925 - 1.26    theta_05
## 6   0    0  -1.71198e-03 NA NA           0.00 17.1   0.495 - 0.995    theta_06
## 7   0    0   1.51473e-03 NA NA           0.00 6.81   0.509 - 0.666    theta_07
## 8   1    0   0.00000e+00 NA NA           0.00    -               - omega_02_01
##    Parameter  unit transform    Description estimate_untransf se_est_untransf
## 1         KA   1/h       LIN       KA (1/h)         2.2705000     8.05467e-02
## 2         CL   L/h       LIN       CL (L/h)        74.2674000     3.76134e+00
## 3         V2     L       LIN         V2 (L)       468.1450000     2.82716e+01
## 4       RUVp     -       LIN       RUVp (-)         0.0714092     8.19589e-03
## 5       RUVa ng/mL       LIN   RUVa (ng/mL)         1.0932500     8.58609e-02
## 6      CL-WT     -       LIN      CL-WT (-)         0.7451050     1.27530e-01
## 7     CL-SEX     -       LIN     CL-SEX (-)         0.5872060     4.00082e-02
## 8 OMEGA(2,1)     -         - OMEGA(2,1) (-)         0.0000000     1.00000e+10
##   RSE_untransf   CI95_untransf equation trnsfd
## 1     3.547531     2.11 - 2.43        -      0
## 2     5.064591     66.9 - 81.6        -      0
## 3     6.039069       413 - 524        -      0
## 4    11.477359 0.0553 - 0.0875        -      0
## 5     7.853730    0.925 - 1.26        -      0
## 6    17.115709   0.495 - 0.995        -      0
## 7     6.813316   0.509 - 0.666        -      0
## 8          Inf               -        -      0
```

format with pretty = FALSE ensures that the formatting is performed but no column is removed. This leaves one with everything one can imagine, even the functions used for transformation. 
Explore the table provided and see how one can shrink it using `filter(on==0 or 1)` (include / exclude off-diagonals while keeping the THETAs of course) or `filter(fix=0 or 1)` to focus on (non-)estimated parameters.

Check `?format.nmpartab` for useful arguments and examples.

## Show the modeled data

Looking at the NONMEM analysis data with or without the `$IGNORE` and `$ACCEPT` components applied.


``` r
"run105" %>% nm_parse_dollar_data
```

```
## $data
## [1] "acop.csv"
## 
## $ignores
## [1] ""
## 
## $accepts
## NULL
```

``` r
"run105" %>% load_modeled_dataset() %>% as_tibble()
```

```
## did not find ../inst/extdata/NONMEM/acop.yaml
```

```
## # A tibble: 800 × 10
##       id  time   mdv  evid    dv   amt   sex    wt   etn   cmt
##    <int> <dbl> <int> <int> <dbl> <int> <int> <dbl> <int> <int>
##  1     1  0        1     1  0    10000     1  51.6     1     1
##  2     1  0        0     0  1.22     0     1  51.6     1     3
##  3     1  0.25     0     0 12.6      0     1  51.6     1     3
##  4     1  0.5      0     0 11.2      0     1  51.6     1     3
##  5     1  0.75     0     0 17.7      0     1  51.6     1     3
##  6     1  1        0     0 21.9      0     1  51.6     1     3
##  7     1  1.25     0     0 16.2      0     1  51.6     1     3
##  8     1  1.5      0     0 18.7      0     1  51.6     1     3
##  9     1  1.75     0     0 23.8      0     1  51.6     1     3
## 10     1  2        0     0 16.5      0     1  51.6     1     3
## # ℹ 790 more rows
```

``` r
"run105" %>% load_modeled_dataset(visibility = TRUE) %>% as_tibble()
```

```
## did not find ../inst/extdata/NONMEM/acop.yaml
```

```
## # A tibble: 800 × 11
##       id  time   mdv  evid    dv   amt   sex    wt   etn   cmt VISIBLE
##    <int> <dbl> <int> <int> <dbl> <int> <int> <dbl> <int> <int> <dvec> 
##  1     1  0        1     1  0    10000     1  51.6     1     1 1      
##  2     1  0        0     0  1.22     0     1  51.6     1     3 1      
##  3     1  0.25     0     0 12.6      0     1  51.6     1     3 1      
##  4     1  0.5      0     0 11.2      0     1  51.6     1     3 1      
##  5     1  0.75     0     0 17.7      0     1  51.6     1     3 1      
##  6     1  1        0     0 21.9      0     1  51.6     1     3 1      
##  7     1  1.25     0     0 16.2      0     1  51.6     1     3 1      
##  8     1  1.5      0     0 18.7      0     1  51.6     1     3 1      
##  9     1  1.75     0     0 23.8      0     1  51.6     1     3 1      
## 10     1  2        0     0 16.5      0     1  51.6     1     3 1      
## # ℹ 790 more rows
```

``` r
"run105" %>% load_modeled_dataset(visibility = TRUE) %>% decorations
```

```
## did not find ../inst/extdata/NONMEM/acop.yaml
```

```
## - id: 
## - time: 
## - mdv: 
## - evid: 
## - dv: 
## - amt: 
## - sex: 
## - wt: 
## - etn: 
## - cmt: 
## - VISIBLE
##  - label: Record Visibility
##  - guide
##   - Ignored: 0
##   - Visible: 1
```

``` r
## VISIBLE shows original dataset marked for included (VISIBLE=1) or excluded (VISIBLE=0) in the NONMEM model.


1001 %>% get_xpose_tables(x=.,directory=system.file('project/model',package='nonmemica'))
```

```
## # A tibble: 550 × 19
##       ID   AMT  TIME  EVID  IPRE CWRESI  CIWRESI    DV  PRED    RES     WRES
##    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>    <dbl> <dbl> <dbl>  <dbl>    <dbl>
##  1     1  1000  0        1 0      0      0       0     0      0      0      
##  2     1     0  0.25     0 0.365 -0.171 -0.00372 0.363 0.721 -0.358 -0.0832 
##  3     1     0  0.5      0 0.687  0.149  0.479   0.914 1.33  -0.415  0.256  
##  4     1     0  1        0 1.22  -0.580 -0.193   1.12  2.27  -1.15  -0.408  
##  5     1     0  2        0 1.95  -0.107  0.526   2.28  3.37  -1.09   0.00381
##  6     1     0  3        0 2.37  -1.28  -1.07    1.63  3.83  -2.20  -1.07   
##  7     1     0  4        0 2.60  -1.01  -0.762   2.04  3.97  -1.93  -0.842  
##  8     1     0  6        0 2.72  -1.48  -1.48    1.61  3.80  -2.19  -1.32   
##  9     1     0  8        0 2.65  -0.157  0.105   2.73  3.45  -0.720 -0.0508 
## 10     1     0 12        0 2.35   0.837  1.07    3.09  2.74   0.348  0.926  
## # ℹ 540 more rows
## # ℹ 8 more variables: CL <dbl>, V2 <dbl>, KA <dbl>, Q <dbl>, V3 <dbl>,
## #   ETA1 <dbl>, ETA2 <dbl>, ETA3 <dbl>
```

``` r
try(1001 %>% superset(project=system.file('project/model',package='nonmemica'))) # no
```

```
## Warning in file(con, "r"): cannot open file
## 'C:/Users/tim.bergsma/AppData/Local/R/win-library/4.4/nonmemica/project/model/1001.mod':
## No such file or directory
```

```
## Error in file(con, "r") : cannot open the connection
```

``` r
1001 %>% superset(project=system.file('project/model',package='nonmemica'),ext="ctl") %>% as_tibble # yes
```

```
## # A tibble: 600 × 39
##    C        ID  TIME   SEQ  EVID AMT   DV     SUBJ  HOUR HEIGHT WEIGHT   SEX
##    <chr> <int> <dbl> <int> <int> <chr> <chr> <int> <dbl>  <int>  <dbl> <int>
##  1 C         1  0        0     0 .     0         1  0       174   74.2     0
##  2 .         1  0        1     1 1000  .         1  0       174   74.2     0
##  3 .         1  0.25     0     0 .     0.363     1  0.25    174   74.2     0
##  4 .         1  0.5      0     0 .     0.914     1  0.5     174   74.2     0
##  5 .         1  1        0     0 .     1.12      1  1       174   74.2     0
##  6 .         1  2        0     0 .     2.28      1  2       174   74.2     0
##  7 .         1  3        0     0 .     1.63      1  3       174   74.2     0
##  8 .         1  4        0     0 .     2.04      1  4       174   74.2     0
##  9 .         1  6        0     0 .     1.61      1  6       174   74.2     0
## 10 .         1  8        0     0 .     2.73      1  8       174   74.2     0
## # ℹ 590 more rows
## # ℹ 27 more variables: AGE <dbl>, DOSE <dbl>, FED <int>, SMK <int>, DS <int>,
## #   CRCN <dbl>, TAFD <dbl>, TAD <chr>, LDOS <chr>, MDV <int>, predose <int>,
## #   zerodv <int>, VISIBLE <int>, IPRE <dbl>, CWRESI <dbl>, CIWRESI <dbl>,
## #   PRED <dbl>, RES <dbl>, WRES <dbl>, CL <dbl>, V2 <dbl>, KA <dbl>, Q <dbl>,
## #   V3 <dbl>, ETA1 <dbl>, ETA2 <dbl>, ETA3 <dbl>
```

The difference between superset() (nonmemica) and load_modeled_dataset() is the former returns a data.frame with columns of class character while the latter returns a tibble with exclusively double class.

## Load output dataset using get_xpose_tables()


``` r
"run103" %>% get_xpose_tables
```

```
## # A tibble: 800 × 20
##       ID   SEX   ETN    DV  PRED    RES   WRES    WT    CL     V    KA    ETA1
##    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>
##  1     1     1     1  0     0     0      0      51.6  31.9  468.  2.27 -0.0854
##  2     1     1     1  1.22  0     1.22   1.11   51.6  31.9  468.  2.27 -0.0854
##  3     1     1     1 12.6   9.16  3.41   1.93   51.6  31.9  468.  2.27 -0.0854
##  4     1     1     1 11.2  14.2  -2.96  -1.39   51.6  31.9  468.  2.27 -0.0854
##  5     1     1     1 17.7  16.9   0.844  0.348  51.6  31.9  468.  2.27 -0.0854
##  6     1     1     1 21.9  18.2   3.70   1.50   51.6  31.9  468.  2.27 -0.0854
##  7     1     1     1 16.2  18.8  -2.63  -1.08   51.6  31.9  468.  2.27 -0.0854
##  8     1     1     1 18.7  19.0  -0.331 -0.162  51.6  31.9  468.  2.27 -0.0854
##  9     1     1     1 23.8  19.0   4.81   1.90   51.6  31.9  468.  2.27 -0.0854
## 10     1     1     1 16.5  18.8  -2.33  -0.978  51.6  31.9  468.  2.27 -0.0854
## # ℹ 790 more rows
## # ℹ 8 more variables: ETA2 <dbl>, TIME <dbl>, MDV <dbl>, EVID <dbl>,
## #   IPRED <dbl>, IWRES <dbl>, CWRES <dbl>, DV.1 <dbl>
```

``` r
paste0("run", c(100,103,105)) %>% lapply(., function(x) get_xpose_tables(x))
```

```
## [[1]]
## # A tibble: 800 × 20
##       ID   SEX   ETN    DV  PRED     RES   WRES    WT    CL     V    KA   ETA1
##    <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
##  1     1     1     1  0     0     0       0      51.6  31.8  469.  2.27 -0.285
##  2     1     1     1  1.22  0     1.22    1.11   51.6  31.8  469.  2.27 -0.285
##  3     1     1     1 12.6   9.14  3.42    1.92   51.6  31.8  469.  2.27 -0.285
##  4     1     1     1 11.2  14.1  -2.90   -1.41   51.6  31.8  469.  2.27 -0.285
##  5     1     1     1 17.7  16.7   0.979   0.344  51.6  31.8  469.  2.27 -0.285
##  6     1     1     1 21.9  18.0   3.91    1.51   51.6  31.8  469.  2.27 -0.285
##  7     1     1     1 16.2  18.6  -2.35   -1.09   51.6  31.8  469.  2.27 -0.285
##  8     1     1     1 18.7  18.7   0.0182 -0.153  51.6  31.8  469.  2.27 -0.285
##  9     1     1     1 23.8  18.6   5.23    1.94   51.6  31.8  469.  2.27 -0.285
## 10     1     1     1 16.5  18.3  -1.84   -0.973  51.6  31.8  469.  2.27 -0.285
## # ℹ 790 more rows
## # ℹ 8 more variables: ETA2 <dbl>, TIME <dbl>, MDV <dbl>, EVID <dbl>,
## #   IPRED <dbl>, IWRES <dbl>, CWRES <dbl>, DV.1 <dbl>
## 
## [[2]]
## # A tibble: 800 × 20
##       ID   SEX   ETN    DV  PRED    RES   WRES    WT    CL     V    KA    ETA1
##    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>
##  1     1     1     1  0     0     0      0      51.6  31.9  468.  2.27 -0.0854
##  2     1     1     1  1.22  0     1.22   1.11   51.6  31.9  468.  2.27 -0.0854
##  3     1     1     1 12.6   9.16  3.41   1.93   51.6  31.9  468.  2.27 -0.0854
##  4     1     1     1 11.2  14.2  -2.96  -1.39   51.6  31.9  468.  2.27 -0.0854
##  5     1     1     1 17.7  16.9   0.844  0.348  51.6  31.9  468.  2.27 -0.0854
##  6     1     1     1 21.9  18.2   3.70   1.50   51.6  31.9  468.  2.27 -0.0854
##  7     1     1     1 16.2  18.8  -2.63  -1.08   51.6  31.9  468.  2.27 -0.0854
##  8     1     1     1 18.7  19.0  -0.331 -0.162  51.6  31.9  468.  2.27 -0.0854
##  9     1     1     1 23.8  19.0   4.81   1.90   51.6  31.9  468.  2.27 -0.0854
## 10     1     1     1 16.5  18.8  -2.33  -0.978  51.6  31.9  468.  2.27 -0.0854
## # ℹ 790 more rows
## # ℹ 8 more variables: ETA2 <dbl>, TIME <dbl>, MDV <dbl>, EVID <dbl>,
## #   IPRED <dbl>, IWRES <dbl>, CWRES <dbl>, DV.1 <dbl>
## 
## [[3]]
## # A tibble: 800 × 20
##       ID   SEX   ETN    DV  PRED    RES   WRES    WT    CL     V    KA    ETA1
##    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>
##  1     1     1     1  0     0     0      0      51.6  31.9  468.  2.27 -0.0856
##  2     1     1     1  1.22  0     1.22   1.11   51.6  31.9  468.  2.27 -0.0856
##  3     1     1     1 12.6   9.16  3.41   1.93   51.6  31.9  468.  2.27 -0.0856
##  4     1     1     1 11.2  14.2  -2.96  -1.39   51.6  31.9  468.  2.27 -0.0856
##  5     1     1     1 17.7  16.9   0.845  0.348  51.6  31.9  468.  2.27 -0.0856
##  6     1     1     1 21.9  18.2   3.70   1.50   51.6  31.9  468.  2.27 -0.0856
##  7     1     1     1 16.2  18.8  -2.63  -1.08   51.6  31.9  468.  2.27 -0.0856
##  8     1     1     1 18.7  19.0  -0.331 -0.162  51.6  31.9  468.  2.27 -0.0856
##  9     1     1     1 23.8  19.0   4.81   1.90   51.6  31.9  468.  2.27 -0.0856
## 10     1     1     1 16.5  18.8  -2.33  -0.978  51.6  31.9  468.  2.27 -0.0856
## # ℹ 790 more rows
## # ℹ 8 more variables: ETA2 <dbl>, TIME <dbl>, MDV <dbl>, EVID <dbl>,
## #   IPRED <dbl>, IWRES <dbl>, CWRES <dbl>, DV.1 <dbl>
```

``` r
library(ggplot2)
library(tidyr)
```

```
## 
## Attaching package: 'tidyr'
```

```
## The following object is masked from 'package:yamlet':
## 
##     unnest
```

```
## The following object is masked from 'package:magrittr':
## 
##     extract
```

```
## The following object is masked from 'package:qptools':
## 
##     unnest
```

``` r
paste0("run", c(100,103,105)) %>% lapply(., function(x) get_xpose_tables(x) %>% mutate(model=x)) -> tmp
do.call("rbind", tmp) %>%
  pivot_longer(cols = c(IPRED,PRED)) %>%
  ggplot(aes(y=DV,x=value)) +
  geom_point(col = "darkslategrey") +
  stat_smooth(method='loess', alpha=0.33) +
  facet_grid(name~model)
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

![](C:/project/devel/qptools/vignettes/qptools-introduction_files/figure-html/get_xpose_table-1.png)<!-- -->

`get_xpose_tables` is like get.xpose.tables from qpToolkit, but even more foolproof (non-xpose table names, column names nearly similar) and this returning a tibble for clear print results / overview.

## Make a Runrecord 

Using `nm_runrecord`.

By default the last estimation method from each run is used to compile the runrecord.


``` r
paste0("run", 100:105) %>% nm_runrecord()
```

```
##   Run Ref    OFV  dOFV  meth lap min rerr   cn     data nids nobs nth nom nsg
## 1 100   0 2085.6    NA focei  no   1    0 15.8 acop.csv   40  760 5/5 2/3 0/1
## 2 101 100 2076.5  -9.1 focei  no   1    0 30.2 acop.csv   40  760 6/6 2/3 0/1
## 3 102 100 2077.1  -8.5 focei  no   1    0 17.5 acop.csv   40  760 5/6 2/3 0/1
## 4 103 101 2041.8 -34.7 focei  no   1    0   26 acop.csv   40  760 7/7 2/3 0/1
## 5 105 102 2041.8 -35.3 focei  no   1    0 18.8 acop.csv   40  760 6/7 2/3 0/1
##   npar                         Description
## 1  7/9             PK model 1 cmt  - base 
## 2 8/10             PK model 1 cmt - WT-CL 
## 3 7/10    PK model 1 cmt - WT-CL allometry
## 4 9/11       PK model 1 cmt - WT-CL SEX-CL
## 5 8/11 PK model 1 cmt - WT-CL allom SEX-CL
```

``` r
paste0("run", 100:105) %>% nm_runrecord(. ,index = c(1,3,3))
```

```
## index supplied not of same length as number of parseable runs. Defaulting to last estimation method of each run.
```

```
##   Run Ref    OFV  dOFV  meth lap min rerr   cn     data nids nobs nth nom nsg
## 1 100   0 2085.6    NA focei  no   1    0 15.8 acop.csv   40  760 5/5 2/3 0/1
## 2 101 100 2076.5  -9.1 focei  no   1    0 30.2 acop.csv   40  760 6/6 2/3 0/1
## 3 102 100 2077.1  -8.5 focei  no   1    0 17.5 acop.csv   40  760 5/6 2/3 0/1
## 4 103 101 2041.8 -34.7 focei  no   1    0   26 acop.csv   40  760 7/7 2/3 0/1
## 5 105 102 2041.8 -35.3 focei  no   1    0 18.8 acop.csv   40  760 6/7 2/3 0/1
##   npar                         Description
## 1  7/9             PK model 1 cmt  - base 
## 2 8/10             PK model 1 cmt - WT-CL 
## 3 7/10    PK model 1 cmt - WT-CL allometry
## 4 9/11       PK model 1 cmt - WT-CL SEX-CL
## 5 8/11 PK model 1 cmt - WT-CL allom SEX-CL
```

``` r
paste0("run", 100:105) %>% nm_runrecord(. ,index = c(1,3,3,2,1))
```

```
##   Run Ref    OFV   dOFV  meth lap min rerr   cn     data nids nobs nth nom nsg
## 1 100   0 1705.6     NA  saem  no   0    0   11 acop.csv   40  760 5/5 2/3 0/1
## 2 101 100 2076.5  370.9 focei  no   1    0 30.2 acop.csv   40  760 6/6 2/3 0/1
## 3 102 100 2077.1  371.5 focei  no   1    0 17.5 acop.csv   40  760 5/6 2/3 0/1
## 4 103 101 2042.7  -33.8 imp-e  no   0    0 25.6 acop.csv   40  760 7/7 2/3 0/1
## 5 105 102 1653.7 -423.4  saem  no   0    0   24 acop.csv   40  760 6/7 2/3 0/1
##   npar                         Description
## 1  7/9             PK model 1 cmt  - base 
## 2 8/10             PK model 1 cmt - WT-CL 
## 3 7/10    PK model 1 cmt - WT-CL allometry
## 4 9/11       PK model 1 cmt - WT-CL SEX-CL
## 5 8/11 PK model 1 cmt - WT-CL allom SEX-CL
```

``` r
paste0("run", c(100,103,105)) %>% nm_runrecord_graph()
```

```
## `geom_smooth()` using method = 'loess' and formula = 'y ~ x'
```

![](C:/project/devel/qptools/vignettes/qptools-introduction_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

## Process an SCM table

There is a 17-character limit to the covariate effect name! So consider using 'short' names.


``` r
getOption("qpExampleDir") %>% dir
```

```
##  [1] "acop.csv"        "binom.csv"       "bootstrap"       "example1"       
##  [5] "example1.csv"    "example1.ctl"    "example1.lst"    "example2"       
##  [9] "example2.csv"    "example2.ctl"    "example2.lst"    "example3"       
## [13] "example3.csv"    "example3.ctl"    "example3.lst"    "run1"           
## [17] "run1.lst"        "run1.mod"        "run100"          "run100.lst"     
## [21] "run100.mod"      "run101"          "run101.lst"      "run101.mod"     
## [25] "run102"          "run102.lst"      "run102.mod"      "run103"         
## [29] "run103.lst"      "run103.mod"      "run105"          "run105.lst"     
## [33] "run105.mod"      "run105bs.mod"    "run106"          "run106.lst"     
## [37] "run106.mod"      "run107"          "run107.lst"      "run107.mod"     
## [41] "run108"          "run108.lst"      "run108.mod"      "scm_config2.scm"
## [45] "scm_example2"
```

``` r
## full SCM forward backward and final
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% as_tibble()
```

```
## # A tibble: 34 × 11
##     step model  ofvbase ofvtest   dofv  goal deltadf significant   pvalue chosen
##    <int> <chr>    <dbl>   <dbl>  <dbl> <dbl>   <int>       <int>    <dbl>  <dbl>
##  1     1 CLAGE…  -5495.  -8792. 3.30e3  6.63       1           1 0             0
##  2     1 CLGND…  -5495.  -9557. 4.06e3  6.63       1           1 0             1
##  3     1 QAGE-5  -5495.  -6123. 6.28e2  6.63       1           1 0             0
##  4     1 QGNDR…  -5495.  -8790. 3.30e3  6.63       1           1 0             0
##  5     1 V1AGE…  -5495.  -9146. 3.65e3  6.63       1           1 0             0
##  6     1 V1GND…  -5495.  -9050. 3.56e3  6.63       1           1 0             0
##  7     1 V2AGE…  -5495.  -8810. 3.32e3  6.63       1           1 0             0
##  8     1 V2GND…  -5495.  -8790. 3.30e3  6.63       1           1 0             0
##  9     2 CLAGE…  -9557.  -9746. 1.89e2  6.63       1           1 4.79e-43      1
## 10     2 QAGE-5  -9557.  -9560. 2.77e0  6.63       1           0 9.60e- 2      0
## # ℹ 24 more rows
## # ℹ 1 more variable: direction <dbl>
```

``` r
#now play with chosen, direction to get what you want.

## forward steps
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(chosen==0&direction==1)
```

```
##    step    model    ofvbase    ofvtest       dofv   goal deltadf significant
## 1     1  CLAGE-5  -5494.546  -8791.872 3297.32607 6.6349       1           1
## 2     1   QAGE-5  -5494.546  -6123.028  628.48146 6.6349       1           1
## 3     1  QGNDR-2  -5494.546  -8789.924 3295.37813 6.6349       1           1
## 4     1  V1AGE-5  -5494.546  -9145.808 3651.26194 6.6349       1           1
## 5     1 V1GNDR-2  -5494.546  -9049.804 3555.25789 6.6349       1           1
## 6     1  V2AGE-5  -5494.546  -8810.115 3315.56884 6.6349       1           1
## 7     1 V2GNDR-2  -5494.546  -8790.222 3295.67624 6.6349       1           1
## 8     2   QAGE-5  -9557.268  -9560.038    2.77025 6.6349       1           0
## 9     2  QGNDR-2  -9557.268  -9559.482    2.21381 6.6349       1           0
## 10    2  V1AGE-5  -9557.268  -9658.181  100.91305 6.6349       1           1
## 11    2 V1GNDR-2  -9557.268  -9565.896    8.62816 6.6349       1           1
## 12    2  V2AGE-5  -9557.268  -9570.108   12.84003 6.6349       1           1
## 13    2 V2GNDR-2  -9557.268  -9557.272    0.00373 6.6349       1           0
## 14    3   QAGE-5  -9746.452  -9746.702    0.25034 6.6349       1           0
## 15    3  QGNDR-2  -9746.452  -9748.516    2.06474 6.6349       1           0
## 16    3 V1GNDR-2  -9746.452  -9752.874    6.42272 6.6349       1           0
## 17    3  V2AGE-5  -9746.452  -9771.672   25.22079 6.6349       1           1
## 18    3 V2GNDR-2  -9746.452  -9746.473    0.02120 6.6349       1           0
## 19    4   QAGE-5 -10176.099 -10176.100    0.00089 6.6349       1           0
## 20    4  QGNDR-2 -10176.099 -10177.775    1.67521 6.6349       1           0
## 21    4  V2AGE-5 -10176.099 -10176.874    0.77419 6.6349       1           0
## 22    4 V2GNDR-2 -10176.099 -10176.230    0.13045 6.6349       1           0
## 23    5   QAGE-5 -10195.277 -10195.280    0.00280 6.6349       1           0
## 24    5  QGNDR-2 -10195.277 -10197.794    2.51704 6.6349       1           0
## 25    5  V2AGE-5 -10195.277 -10195.878    0.60062 6.6349       1           0
## 26    5 V2GNDR-2 -10195.277 -10195.824    0.54635 6.6349       1           0
##        pvalue chosen direction
## 1  0.0000e+00      0         1
## 2  0.0000e+00      0         1
## 3  0.0000e+00      0         1
## 4  0.0000e+00      0         1
## 5  0.0000e+00      0         1
## 6  0.0000e+00      0         1
## 7  0.0000e+00      0         1
## 8  9.6031e-02      0         1
## 9  1.3678e-01      0         1
## 10 9.6100e-24      0         1
## 11 3.3100e-03      0         1
## 12 3.3900e-04      0         1
## 13 9.5130e-01      0         1
## 14 6.1684e-01      0         1
## 15 1.5074e-01      0         1
## 16 1.1267e-02      0         1
## 17 1.0000e-06      0         1
## 18 8.8422e-01      0         1
## 19 9.7618e-01      0         1
## 20 1.9556e-01      0         1
## 21 3.7892e-01      0         1
## 22 7.1796e-01      0         1
## 23 9.5778e-01      0         1
## 24 1.1262e-01      0         1
## 25 4.3834e-01      0         1
## 26 4.5981e-01      0         1
```

``` r
## backward steps
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(direction==-1)
```

```
##   step    model   ofvbase    ofvtest       dofv    goal deltadf significant
## 1    6  CLAGE-1 -10195.28  -9671.863 -523.41471 -10.828      -1           0
## 2    6 CLGNDR-1 -10195.28  -9250.324 -944.95348 -10.828      -1           0
## 3    6  V1AGE-1 -10195.28  -9752.874 -442.40292 -10.828      -1           0
## 4    6 V1GNDR-1 -10195.28 -10169.003  -26.27446 -10.828      -1           0
##     pvalue chosen direction
## 1 0.00e+00      0        -1
## 2 0.00e+00      0        -1
## 3 0.00e+00      0        -1
## 4 2.96e-07      0        -1
```

``` r
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(chosen==0&direction==-1)
```

```
##   step    model   ofvbase    ofvtest       dofv    goal deltadf significant
## 1    6  CLAGE-1 -10195.28  -9671.863 -523.41471 -10.828      -1           0
## 2    6 CLGNDR-1 -10195.28  -9250.324 -944.95348 -10.828      -1           0
## 3    6  V1AGE-1 -10195.28  -9752.874 -442.40292 -10.828      -1           0
## 4    6 V1GNDR-1 -10195.28 -10169.003  -26.27446 -10.828      -1           0
##     pvalue chosen direction
## 1 0.00e+00      0        -1
## 2 0.00e+00      0        -1
## 3 0.00e+00      0        -1
## 4 2.96e-07      0        -1
```

``` r
## final model
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(chosen==1)
```

```
##   step    model    ofvbase    ofvtest       dofv   goal deltadf significant
## 1    1 CLGNDR-2  -5494.546  -9557.268 4062.72165 6.6349       1           1
## 2    2  CLAGE-5  -9557.268  -9746.452  189.18389 6.6349       1           1
## 3    3  V1AGE-5  -9746.452 -10176.099  429.64766 6.6349       1           1
## 4    4 V1GNDR-2 -10176.099 -10195.277   19.17797 6.6349       1           1
##     pvalue chosen direction
## 1 0.00e+00      1         1
## 2 4.79e-43      1         1
## 3 0.00e+00      1         1
## 4 1.20e-05      1         1
```

